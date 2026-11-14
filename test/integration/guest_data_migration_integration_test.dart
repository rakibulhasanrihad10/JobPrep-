import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:job_prep/core/local/database/app_database.dart';
import 'package:job_prep/features/backup/data/repositories/app_backup_repository.dart';
import 'package:job_prep/features/circulars/data/repositories/local_circular_repository.dart';
import 'package:job_prep/features/circulars/data/repositories/local_exam_date_repository.dart';
import 'package:job_prep/features/circulars/domain/entities/circular.dart';
import 'package:job_prep/features/circulars/domain/entities/circular_enums.dart';
import 'package:job_prep/features/migration/domain/services/guest_migration_service.dart';
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

import '../features/migration/fake_cloud_repositories.dart';

void main() {
  late AppDatabase db;
  late LocalCircularRepository localCircularRepo;
  late LocalSubjectRepository localSubjectRepo;
  late LocalMaterialRepository localMaterialRepo;
  late LocalProgressLogRepository localProgressRepo;
  late AppBackupRepository localBackupRepo;
  late FakeCloudRepositoriesBundle fakeCloud;
  late GuestMigrationService migrationService;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    localCircularRepo = LocalCircularRepository(db);
    localSubjectRepo = LocalSubjectRepository(db);
    localMaterialRepo = LocalMaterialRepository(db);
    localProgressRepo = LocalProgressLogRepository(db);

    localBackupRepo = AppBackupRepository(
      circularRepo: localCircularRepo,
      examDateRepo: LocalExamDateRepository(db),
      subjectRepo: localSubjectRepo,
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
    migrationService = const GuestMigrationService();
  });

  tearDown(() async {
    await db.close();
  });

  test(
    'moves a guest circular and a prep subject into a new account with '
    'progress totals',
    () async {
      // 1. Create a guest circular
      final circular = await localCircularRepo.createCircular(
        Circular(
          id: 'guest-circular-46',
          title: '46th BCS Special Circular',
          organizationName: 'Bangladesh Public Service Commission',
          applicationStatus: ApplicationStatus.applied,
          deadline: DateTime.utc(2026, 12),
          createdAt: DateTime.utc(2026, 11, 10),
          updatedAt: DateTime.utc(2026, 11, 10),
        ),
      );

      // 2. Create a guest prep subject with 3 materials (300, 300, 400 pages)
      final subject = await localSubjectRepo.createSubject(
        Subject(
          id: 'guest-sub-math',
          name: 'General Mathematics',
          color: '#D4AF37',
          createdAt: DateTime.utc(2026, 11, 10),
          updatedAt: DateTime.utc(2026, 11, 10),
        ),
      );

      final mat1 = await localMaterialRepo.createMaterial(
        PrepMaterial(
          id: 'guest-book-1',
          subjectId: subject.id,
          title: 'Arithmetic Vol 1',
          totalUnits: 300,
          createdAt: DateTime.utc(2026, 11, 10),
          updatedAt: DateTime.utc(2026, 11, 10),
        ),
      );

      await localMaterialRepo.createMaterial(
        PrepMaterial(
          id: 'guest-book-2',
          subjectId: subject.id,
          title: 'Algebra Vol 2',
          totalUnits: 300,
          createdAt: DateTime.utc(2026, 11, 10),
          updatedAt: DateTime.utc(2026, 11, 10),
        ),
      );

      await localMaterialRepo.createMaterial(
        PrepMaterial(
          id: 'guest-book-3',
          subjectId: subject.id,
          title: 'Geometry & Statistics',
          totalUnits: 400,
          createdAt: DateTime.utc(2026, 11, 10),
          updatedAt: DateTime.utc(2026, 11, 10),
        ),
      );

      // Log progress on book 1 (300 pages done => 100% book 1, 30% subject)
      await localProgressRepo.createLog(
        ProgressLog(
          id: 'log-book-1-done',
          materialId: mat1.id,
          unitsDone: 300,
          loggedOn: DateTime.utc(2026, 11, 11),
          createdAt: DateTime.utc(2026, 11, 11),
        ),
      );

      // 3. Collect local guest data
      final localData = await localBackupRepo.collectBackupData();
      expect(localData.circulars.length, 1);
      expect(localData.subjects.length, 1);
      expect(localData.materials.length, 3);
      expect(localData.progressLogs.length, 1);

      // 4. Run Migration to Cloud Account
      final verification = await migrationService.migrate(
        tables: localData,
        cloud: fakeCloud.toCloudRepositories(),
      );

      expect(verification.isSuccess, isTrue);
      expect(verification.progressTotalsMatch, isTrue);

      // 5. Verify cloud account state
      final cloudCirculars = await fakeCloud.circularRepo.getCirculars();
      expect(cloudCirculars.length, 1);
      expect(cloudCirculars.first.id, circular.id);
      expect(cloudCirculars.first.title, '46th BCS Special Circular');

      final cloudSubjects = await fakeCloud.subjectRepo.getSubjects();
      expect(cloudSubjects.length, 1);
      expect(cloudSubjects.first.id, subject.id);
      expect(cloudSubjects.first.name, 'General Mathematics');

      final cloudMaterials =
          await fakeCloud.materialRepo.getMaterialsForSubject('guest-sub-math');
      expect(cloudMaterials.length, 3);

      final cloudBook1 = cloudMaterials.firstWhere((m) => m.id == mat1.id);
      expect(cloudBook1.totalUnits, 300);

      // Progress calculation check
      final cloudLogs =
          await fakeCloud.progressLogRepo.getLogsForMaterial(mat1.id);
      expect(cloudLogs.length, 1);
      expect(cloudLogs.first.unitsDone, 300);

      // Subject progress calculation on cloud materials
      final progressFraction = calculateSubjectProgress(cloudMaterials);
      expect(progressFraction, 0.30);
      expect((progressFraction * 100).round(), 30);

      // 6. User chooses to erase local copy on device
      await db.eraseAllData();

      final clearedData = await localBackupRepo.collectBackupData();
      expect(clearedData.totalRecords, 0);
    },
  );
}
