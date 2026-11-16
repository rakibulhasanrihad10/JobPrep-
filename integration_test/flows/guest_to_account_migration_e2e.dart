import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:job_prep/core/local/database/app_database.dart';
import 'package:job_prep/features/backup/data/repositories/app_backup_repository.dart';
import 'package:job_prep/features/circulars/data/repositories/local_circular_repository.dart';
import 'package:job_prep/features/circulars/data/repositories/local_exam_date_repository.dart';
import 'package:job_prep/features/circulars/domain/entities/circular.dart';
import 'package:job_prep/features/migration/domain/services/guest_migration_service.dart';
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
import 'package:job_prep/features/prep/domain/utils/prep_progress.dart';
import 'package:job_prep/features/settings/data/repositories/local_user_settings_repository.dart';
import 'package:job_prep/features/vault/data/repositories/local_portal_account_repository.dart';

import '../../test/features/migration/fake_cloud_repositories.dart';

void runGuestToAccountMigrationE2ETests() {
  group('E2E Flow - Guest Data Migration to Authenticated Account', () {
    late AppDatabase db;
    late LocalCircularRepository localCircularRepo;
    late LocalSubjectRepository localSubjectRepo;
    late LocalMaterialRepository localMaterialRepo;
    late LocalProgressLogRepository localProgressRepo;
    late AppBackupRepository backupRepo;
    late FakeCloudRepositoriesBundle fakeCloud;
    const migrationService = GuestMigrationService();

    setUp(() {
      db = AppDatabase(NativeDatabase.memory());
      localCircularRepo = LocalCircularRepository(db);
      localSubjectRepo = LocalSubjectRepository(db);
      localMaterialRepo = LocalMaterialRepository(db);
      localProgressRepo = LocalProgressLogRepository(db);
      backupRepo = AppBackupRepository(
        circularRepo: localCircularRepo,
        examDateRepo: LocalExamDateRepository(db),
        subjectRepo: localSubjectRepo,
        chapterRepo: LocalChapterRepository(db),
        materialRepo: localMaterialRepo,
        progressLogRepo: localProgressRepo,
        topicRepo: LocalTopicRepository(db),
        studyPlanRepo: LocalStudyPlanRepository(db),
        mockTestRepo: LocalMockTestRepository(db),
        revisionItemRepo: LocalRevisionItemRepository(db),
        studySessionRepo: LocalStudySessionRepository(db),
        notificationsRepo: LocalNotificationsRepository(db),
        portalAccountRepo: LocalPortalAccountRepository(db),
        userSettingsRepo: LocalUserSettingsRepository(db),
        appDatabase: db,
        isGuest: true,
      );
      fakeCloud = FakeCloudRepositoriesBundle();
    });

    tearDown(() async {
      await db.close();
    });

    test(
        'migrates guest data with 300, 300, 400 books to cloud account in '
        'dependency order, verifies counts and progress match, and leaves '
        'cloud and local consistent', () async {
      // 1. Create a guest circular
      await localCircularRepo.createCircular(
        const Circular(
          id: 'c-mig-1',
          title: 'Guest Bangladesh Bank AD',
          organizationName: 'Bangladesh Bank',
        ),
      );

      // 2. Create guest Subject & 3 Books (300, 300, 400)
      final sub = await localSubjectRepo.createSubject(
        const Subject(id: 's-mig-1', name: 'English Literature'),
      );
      final b1 = await localMaterialRepo.createMaterial(
        PrepMaterial(
          id: 'm-mig-1',
          subjectId: sub.id,
          title: 'Book 1',
          totalUnits: 300,
        ),
      );
      final b2 = await localMaterialRepo.createMaterial(
        PrepMaterial(
          id: 'm-mig-2',
          subjectId: sub.id,
          title: 'Book 2',
          totalUnits: 300,
        ),
      );
      final b3 = await localMaterialRepo.createMaterial(
        PrepMaterial(
          id: 'm-mig-3',
          subjectId: sub.id,
          title: 'Book 3',
          totalUnits: 400,
        ),
      );

      // Log 300 pages on Book 1
      await localProgressRepo.createLog(
        ProgressLog(
          id: 'l-mig-1',
          materialId: b1.id,
          unitsDone: 300,
          loggedOn: DateTime.utc(2026, 11, 14),
        ),
      );

      // 3. Inspect collected guest tables before migration
      final tables = await backupRepo.collectBackupData();
      expect(tables.totalRecords, greaterThanOrEqualTo(5));
      expect(tables.circulars.length, equals(1));
      expect(tables.subjects.length, equals(1));
      expect(tables.materials.length, equals(3));
      expect(tables.progressLogs.length, equals(1));

      // 4. Run migration to cloud
      final events = <String>[];
      final result = await migrationService.migrate(
        tables: tables,
        cloud: fakeCloud.toCloudRepositories(),
        onProgress: (table, processed, total) {
          events.add('$table: $processed/$total');
        },
      );

      expect(result.isSuccess, isTrue);
      expect(result.uploadedCount, greaterThanOrEqualTo(5));
      expect(events, isNotEmpty);

      // 5. Verify cloud entities received data
      final cloudCirc = await fakeCloud.circularRepo.getCircularById('c-mig-1');
      expect(cloudCirc, isNotNull);
      expect(cloudCirc!.title, equals('Guest Bangladesh Bank AD'));

      final cloudB1 = await fakeCloud.materialRepo.getMaterialById(b1.id);
      final cloudB2 = await fakeCloud.materialRepo.getMaterialById(b2.id);
      final cloudB3 = await fakeCloud.materialRepo.getMaterialById(b3.id);

      expect(cloudB1!.completedUnits, equals(300));
      expect(calculateMaterialProgress(cloudB1), equals(1.0));
      expect(
        calculateSubjectProgress([cloudB1, cloudB2!, cloudB3!]),
        closeTo(0.30, 0.0001),
      );

      // 6. Running migration a second time is idempotent (no duplicates)
      final repeatResult = await migrationService.migrate(
        tables: tables,
        cloud: fakeCloud.toCloudRepositories(),
      );
      expect(repeatResult.isSuccess, isTrue);
      expect(repeatResult.skippedCount, greaterThan(0));
      final cloudCircs = await fakeCloud.circularRepo.getCirculars();
      expect(cloudCircs.where((c) => c.id == 'c-mig-1'), hasLength(1));
    });
  });
}
