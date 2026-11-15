import 'dart:convert';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:job_prep/core/local/database/app_database.dart';
import 'package:job_prep/features/backup/data/repositories/app_backup_repository.dart';
import 'package:job_prep/features/backup/domain/entities/backup_validation_result.dart';
import 'package:job_prep/features/backup/domain/services/backup_crypto_service.dart';
import 'package:job_prep/features/backup/domain/services/backup_format_service.dart';
import 'package:job_prep/features/circulars/data/repositories/local_circular_repository.dart';
import 'package:job_prep/features/circulars/data/repositories/local_exam_date_repository.dart';
import 'package:job_prep/features/circulars/domain/entities/circular.dart';
import 'package:job_prep/features/notifications/data/repositories/local_notifications_repository.dart';
import 'package:job_prep/features/prep/data/repositories/local_material_repository.dart';
import 'package:job_prep/features/prep/data/repositories/local_mock_test_repository.dart';
import 'package:job_prep/features/prep/data/repositories/local_progress_log_repository.dart';
import 'package:job_prep/features/prep/data/repositories/local_revision_item_repository.dart';
import 'package:job_prep/features/prep/data/repositories/local_study_plan_repository.dart';
import 'package:job_prep/features/prep/data/repositories/local_study_session_repository.dart';
import 'package:job_prep/features/prep/data/repositories/local_subject_repository.dart';
import 'package:job_prep/features/prep/data/repositories/local_topic_repository.dart';
import 'package:job_prep/features/prep/domain/entities/prep_material.dart';
import 'package:job_prep/features/prep/domain/entities/progress_log.dart';
import 'package:job_prep/features/prep/domain/entities/subject.dart';
import 'package:job_prep/features/prep/domain/utils/prep_progress.dart';
import 'package:job_prep/features/settings/data/repositories/local_user_settings_repository.dart';
import 'package:job_prep/features/vault/data/repositories/local_portal_account_repository.dart';

AppBackupRepository _createRepo(AppDatabase db, {bool isGuest = true}) {
  return AppBackupRepository(
    circularRepo: LocalCircularRepository(db),
    examDateRepo: LocalExamDateRepository(db),
    subjectRepo: LocalSubjectRepository(db),
    materialRepo: LocalMaterialRepository(db),
    progressLogRepo: LocalProgressLogRepository(db),
    topicRepo: LocalTopicRepository(db),
    studyPlanRepo: LocalStudyPlanRepository(db),
    mockTestRepo: LocalMockTestRepository(db),
    revisionItemRepo: LocalRevisionItemRepository(db),
    studySessionRepo: LocalStudySessionRepository(db),
    notificationsRepo: LocalNotificationsRepository(db),
    portalAccountRepo: LocalPortalAccountRepository(db),
    userSettingsRepo: LocalUserSettingsRepository(db),
    appDatabase: db,
    isGuest: isGuest,
  );
}

void runBackupAndRestoreE2ETests() {
  group('E2E Flow - Backup and Restore Round Trip', () {
    late AppDatabase sourceDb;
    late AppDatabase targetDb;

    setUp(() {
      sourceDb = AppDatabase(NativeDatabase.memory());
      targetDb = AppDatabase(NativeDatabase.memory());
    });

    tearDown(() async {
      await sourceDb.close();
      await targetDb.close();
    });

    test(
        'exports full guest backup, encrypts, decrypts, and restores into '
        'fresh database preserving 300, 300, 400 page invariant', () async {
      final sourceRepo = _createRepo(sourceDb);
      final targetRepo = _createRepo(targetDb);

      // 1. Create a Circular
      await sourceRepo.circularRepo.createCircular(
        const Circular(
          id: 'c-e2e-1',
          title: '38th BCS Officer',
          organizationName: 'BPSC',
        ),
      );

      // 2. Create Subject & Books (300, 300, 400 pages)
      final sub = await sourceRepo.subjectRepo.createSubject(
        const Subject(id: 's-e2e-1', name: 'General Science'),
      );
      final b1 = await sourceRepo.materialRepo.createMaterial(
        PrepMaterial(
          id: 'm-e2e-1',
          subjectId: sub.id,
          title: 'Physics',
          totalUnits: 300,
        ),
      );
      final b2 = await sourceRepo.materialRepo.createMaterial(
        PrepMaterial(
          id: 'm-e2e-2',
          subjectId: sub.id,
          title: 'Chemistry',
          totalUnits: 300,
        ),
      );
      final b3 = await sourceRepo.materialRepo.createMaterial(
        PrepMaterial(
          id: 'm-e2e-3',
          subjectId: sub.id,
          title: 'Biology',
          totalUnits: 400,
        ),
      );

      // Log 300 pages on Book 1
      await sourceRepo.progressLogRepo.createLog(
        ProgressLog(
          id: 'l-e2e-1',
          materialId: b1.id,
          unitsDone: 300,
          loggedOn: DateTime.utc(2026, 11, 14),
        ),
      );

      // Verify source progress
      final updatedB1 = await sourceRepo.materialRepo.getMaterialById(b1.id);
      expect(calculateMaterialProgress(updatedB1!), equals(1.0));
      expect(
        calculateSubjectProgress([updatedB1, b2, b3]),
        closeTo(0.30, 0.0001),
      );

      // 3. Export Backup JSON
      final data = await sourceRepo.collectBackupData();
      final manifest = BackupFormatService.createManifest(
        tables: data,
      );
      final rawBytes = BackupFormatService.encodeManifest(manifest);
      final rawJson = utf8.decode(rawBytes);

      // Verify format and checksum
      final validation = await BackupFormatService.validateBytes(rawBytes);
      expect(validation.isValid, isTrue);

      // 4. Encrypt with AES-GCM + PBKDF2 passphrase
      const passphrase = 'MySuperSecretVaultKey123!';
      final envelope = await BackupCryptoService.encrypt(
        plainJson: rawJson,
        passphrase: passphrase,
        schemaVersion: BackupFormatService.currentSchemaVersion,
        appVersion: '0.1.0',
      );
      final encodedEnvelope = BackupFormatService.encodeEnvelope(envelope);
      final encryptedJson = utf8.decode(encodedEnvelope);
      expect(encryptedJson, isNot(equals(rawJson)));

      // 5. Decrypt
      final decryptedJson = await BackupCryptoService.decrypt(
        envelope: envelope,
        passphrase: passphrase,
      );
      expect(decryptedJson, equals(rawJson));

      // 6. Restore into target database using Replace strategy
      final decryptedValidation = BackupFormatService.validateParsedJson(
        jsonDecode(decryptedJson) as Map<String, dynamic>,
      );
      expect(decryptedValidation.isValid, isTrue);
      final restoredCount = await targetRepo.restoreBackup(
        manifest: decryptedValidation.manifest!,
        strategy: RestoreStrategy.replace,
      );
      expect(restoredCount, greaterThan(0));

      // 7. Verify restored circular & books
      final restoredCircular =
          await targetRepo.circularRepo.getCircularById('c-e2e-1');
      expect(restoredCircular, isNotNull);
      expect(restoredCircular!.title, equals('38th BCS Officer'));

      final restB1 = await targetRepo.materialRepo.getMaterialById(b1.id);
      final restB2 = await targetRepo.materialRepo.getMaterialById(b2.id);
      final restB3 = await targetRepo.materialRepo.getMaterialById(b3.id);

      expect(restB1!.completedUnits, equals(300));
      expect(calculateMaterialProgress(restB1), equals(1.0));
      expect(
        calculateSubjectProgress([restB1, restB2!, restB3!]),
        closeTo(0.30, 0.0001),
      );
    });
  });
}
