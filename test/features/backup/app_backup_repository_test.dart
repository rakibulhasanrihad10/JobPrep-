import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:job_prep/core/local/database/app_database.dart';
import 'package:job_prep/features/backup/data/repositories/app_backup_repository.dart';
import 'package:job_prep/features/backup/domain/entities/backup_manifest.dart';
import 'package:job_prep/features/backup/domain/entities/backup_validation_result.dart';
import 'package:job_prep/features/backup/domain/services/backup_format_service.dart';
import 'package:job_prep/features/circulars/data/repositories/local_circular_repository.dart';
import 'package:job_prep/features/circulars/data/repositories/local_exam_date_repository.dart';
import 'package:job_prep/features/circulars/domain/entities/circular.dart';
import 'package:job_prep/features/circulars/domain/entities/circular_enums.dart';
import 'package:job_prep/features/circulars/domain/entities/circular_exam_date.dart';
import 'package:job_prep/features/notifications/data/repositories/local_notifications_repository.dart';
import 'package:job_prep/features/prep/data/repositories/local_chapter_repository.dart';
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
import 'package:job_prep/features/prep/domain/entities/topic.dart';
import 'package:job_prep/features/prep/domain/utils/prep_progress.dart';
import 'package:job_prep/features/settings/data/repositories/local_user_settings_repository.dart';
import 'package:job_prep/features/vault/data/repositories/local_portal_account_repository.dart';

void main() {
  AppBackupRepository createBackupRepo(AppDatabase db, {bool isGuest = true}) {
    return AppBackupRepository(
      circularRepo: LocalCircularRepository(db),
      examDateRepo: LocalExamDateRepository(db),
      subjectRepo: LocalSubjectRepository(db),
      chapterRepo: LocalChapterRepository(db),
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

  group('AppBackupRepository & 300, 300, 400 page invariant', () {
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
        'export then restore into empty database gives identical data '
        'including 300, 300, 400 progress example (100% book 1, 30% subject)',
        () async {
      final sourceRepo = createBackupRepo(sourceDb);
      final targetRepo = createBackupRepo(targetDb);

      // 1. Seed source DB with Subject & 3 Books (300, 300, 400 pages)
      final sub = await sourceRepo.subjectRepo.createSubject(
        Subject(
          id: 'sub-math-1',
          name: 'Mathematics',
          color: '#3B82F6',
          createdAt: DateTime.utc(2026, 11),
          updatedAt: DateTime.utc(2026, 11),
        ),
      );

      final mat1 = await sourceRepo.materialRepo.createMaterial(
        PrepMaterial(
          id: 'mat-1',
          subjectId: sub.id,
          title: 'Higher Math Vol 1',
          totalUnits: 300,
          createdAt: DateTime.utc(2026, 11),
          updatedAt: DateTime.utc(2026, 11),
        ),
      );

      await sourceRepo.materialRepo.createMaterial(
        PrepMaterial(
          id: 'mat-2',
          subjectId: sub.id,
          title: 'Higher Math Vol 2',
          totalUnits: 300,
          createdAt: DateTime.utc(2026, 11),
          updatedAt: DateTime.utc(2026, 11),
        ),
      );

      await sourceRepo.materialRepo.createMaterial(
        PrepMaterial(
          id: 'mat-3',
          subjectId: sub.id,
          title: 'Geometry & Calculus',
          totalUnits: 400,
          createdAt: DateTime.utc(2026, 11),
          updatedAt: DateTime.utc(2026, 11),
        ),
      );

      // Log progress: complete 300 pages on Book 1
      await sourceRepo.progressLogRepo.createLog(
        ProgressLog(
          id: 'log-1',
          materialId: mat1.id,
          unitsDone: 300,
          loggedOn: DateTime.utc(2026, 11, 2),
          createdAt: DateTime.utc(2026, 11, 2),
        ),
      );

      // Add a circular and exam date
      final circ = await sourceRepo.circularRepo.createCircular(
        Circular(
          id: 'circ-1',
          title: 'Bangladesh Bank Assistant Director',
          organizationName: 'Bangladesh Bank',
          circularUrl: 'https://bb.org.bd',
          applicationStatus: ApplicationStatus.applied,
          createdAt: DateTime.utc(2026, 11),
          updatedAt: DateTime.utc(2026, 11),
        ),
      );

      await sourceRepo.examDateRepo.createExamDate(
        CircularExamDate(
          id: 'date-1',
          circularId: circ.id,
          stage: 'preliminary',
          examDate: DateTime.utc(2026, 12),
          createdAt: DateTime.utc(2026, 11),
        ),
      );

      await sourceRepo.topicRepo.createTopic(
        Topic(
          id: 'top-1',
          subjectId: sub.id,
          name: 'Algebra',
          createdAt: DateTime.utc(2026, 11),
        ),
      );

      // 2. Export backup from source
      final backupData = await sourceRepo.collectBackupData();
      final manifest = BackupFormatService.createManifest(tables: backupData);

      expect(manifest.data.subjects.length, 1);
      expect(manifest.data.materials.length, 3);
      expect(manifest.data.progressLogs.length, 1);
      expect(manifest.data.circulars.length, 1);
      expect(manifest.data.circularExamDates.length, 1);
      expect(manifest.data.topics.length, 1);

      // 3. Restore into empty target DB
      final restoredCount = await targetRepo.restoreBackup(
        manifest: manifest,
        strategy: RestoreStrategy.merge,
      );
      expect(restoredCount, greaterThanOrEqualTo(8));

      // 4. Verify progress invariant in target DB
      final targetMaterials = await targetRepo.materialRepo.getAllMaterials();
      expect(targetMaterials.length, 3);

      final restoredMat1 = targetMaterials.firstWhere((m) => m.id == mat1.id);
      expect(restoredMat1.completedUnits, 300);
      expect(restoredMat1.totalUnits, 300);

      final subjectProgress = calculateSubjectProgress(targetMaterials);
      // 300 completed out of 1000 total = 30% for the subject
      expect((subjectProgress * 100).round(), 30);

      // 5. Verify circulars & exam dates restored
      final targetCirculars = await targetRepo.circularRepo.getCirculars();
      expect(targetCirculars.length, 1);
      expect(targetCirculars.first.title, 'Bangladesh Bank Assistant Director');

      final targetDates = await targetRepo.examDateRepo
          .getExamDatesForCircular(targetCirculars.first.id);
      expect(targetDates.length, 1);
      expect(targetDates.first.stage, 'preliminary');
    });

    test('restoring the same file twice in Merge mode creates no duplicates',
        () async {
      final sourceRepo = createBackupRepo(sourceDb);
      final targetRepo = createBackupRepo(targetDb);

      await sourceRepo.subjectRepo.createSubject(
        Subject(
          id: 'sub-single',
          name: 'English',
          color: '#10B981',
          createdAt: DateTime.utc(2026, 11),
        ),
      );

      final manifest = BackupFormatService.createManifest(
        tables: await sourceRepo.collectBackupData(),
      );

      // Restore first time
      await targetRepo.restoreBackup(
        manifest: manifest,
        strategy: RestoreStrategy.merge,
      );
      var subjects = await targetRepo.subjectRepo.getSubjects();
      expect(subjects.length, 1);

      // Restore second time
      await targetRepo.restoreBackup(
        manifest: manifest,
        strategy: RestoreStrategy.merge,
      );
      subjects = await targetRepo.subjectRepo.getSubjects();
      expect(subjects.length, 1); // No duplicate created
    });

    test('Replace mode in guest saves safety backup and replaces all data',
        () async {
      final targetRepo = createBackupRepo(targetDb);

      // Populate target with old subject
      await targetRepo.subjectRepo.createSubject(
        Subject(
          id: 'old-sub',
          name: 'Old Subject',
          color: '#000000',
          createdAt: DateTime.utc(2026, 11),
        ),
      );

      // New manifest
      final newManifest = BackupFormatService.createManifest(
        tables: const BackupDataTables(
          subjects: [
            {
              'id': 'fresh-sub',
              'name': 'Fresh Subject',
              'color_hex': '#FFFFFF',
            },
          ],
        ),
      );

      var safetyBackupCalled = false;
      await targetRepo.restoreBackup(
        manifest: newManifest,
        strategy: RestoreStrategy.replace,
        onSaveSafetyBackup: (safety) async {
          safetyBackupCalled = true;
          expect(safety.data.subjects.first['id'], 'old-sub');
        },
      );

      expect(safetyBackupCalled, isTrue);

      final subjects = await targetRepo.subjectRepo.getSubjects();
      expect(subjects.length, 1);
      expect(subjects.first.id, 'fresh-sub');
      expect(subjects.any((s) => s.id == 'old-sub'), isFalse);
    });

    test('Replace mode in signed-in mode throws UnsupportedError', () async {
      final signedInRepo = createBackupRepo(targetDb, isGuest: false);

      final manifest = BackupFormatService.createManifest(
        tables: const BackupDataTables(),
      );

      expect(
        () => signedInRepo.restoreBackup(
          manifest: manifest,
          strategy: RestoreStrategy.replace,
        ),
        throwsA(isA<UnsupportedError>()),
      );
    });
  });
}
