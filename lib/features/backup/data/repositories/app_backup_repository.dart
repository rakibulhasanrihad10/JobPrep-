import 'package:job_prep/core/local/database/app_database.dart';
import 'package:job_prep/features/backup/data/repositories/backup_data_restorer.dart';
import 'package:job_prep/features/backup/domain/entities/backup_manifest.dart';
import 'package:job_prep/features/backup/domain/entities/backup_validation_result.dart';
import 'package:job_prep/features/backup/domain/repositories/backup_repository.dart';
import 'package:job_prep/features/backup/domain/services/backup_entity_codec.dart';
import 'package:job_prep/features/backup/domain/services/backup_format_service.dart';
import 'package:job_prep/features/circulars/domain/repositories/circular_repository.dart';
import 'package:job_prep/features/circulars/domain/repositories/exam_date_repository.dart';
import 'package:job_prep/features/notifications/domain/repositories/notifications_repository.dart';
import 'package:job_prep/features/prep/domain/repositories/chapter_repository.dart';
import 'package:job_prep/features/prep/domain/repositories/material_repository.dart';
import 'package:job_prep/features/prep/domain/repositories/mock_test_repository.dart';
import 'package:job_prep/features/prep/domain/repositories/progress_log_repository.dart';
import 'package:job_prep/features/prep/domain/repositories/revision_item_repository.dart';
import 'package:job_prep/features/prep/domain/repositories/study_plan_repository.dart';
import 'package:job_prep/features/prep/domain/repositories/study_session_repository.dart';
import 'package:job_prep/features/prep/domain/repositories/subject_repository.dart';
import 'package:job_prep/features/prep/domain/repositories/topic_repository.dart';
import 'package:job_prep/features/settings/domain/repositories/user_settings_repository.dart';
import 'package:job_prep/features/vault/domain/repositories/portal_account_repository.dart';

/// Implementation of [BackupRepository] orchestrating data collection and
/// restoration exclusively through application repository interfaces.
class AppBackupRepository implements BackupRepository {
  /// Creates an [AppBackupRepository].
  const AppBackupRepository({
    required this.circularRepo,
    required this.examDateRepo,
    required this.subjectRepo,
    required this.chapterRepo,
    required this.materialRepo,
    required this.progressLogRepo,
    required this.topicRepo,
    required this.studyPlanRepo,
    required this.mockTestRepo,
    required this.revisionItemRepo,
    required this.studySessionRepo,
    required this.notificationsRepo,
    required this.portalAccountRepo,
    required this.userSettingsRepo,
    this.appDatabase,
    this.isGuest = false,
  });

  final CircularRepository circularRepo;
  final ExamDateRepository examDateRepo;
  final SubjectRepository subjectRepo;
  final ChapterRepository chapterRepo;
  final MaterialRepository materialRepo;
  final ProgressLogRepository progressLogRepo;
  final TopicRepository topicRepo;
  final StudyPlanRepository studyPlanRepo;
  final MockTestRepository mockTestRepo;
  final RevisionItemRepository revisionItemRepo;
  final StudySessionRepository studySessionRepo;
  final NotificationsRepository notificationsRepo;
  final PortalAccountRepository portalAccountRepo;
  final UserSettingsRepository userSettingsRepo;
  final AppDatabase? appDatabase;
  final bool isGuest;

  @override
  Future<BackupDataTables> collectBackupData() async {
    final circulars = await circularRepo.getCirculars();
    final examDates = <Map<String, dynamic>>[];
    final circularSubjects = <Map<String, dynamic>>[];

    for (final c in circulars) {
      final dates = await examDateRepo.getExamDatesForCircular(c.id);
      examDates.addAll(dates.map(BackupEntityCodec.examDateToJson));

      final linkedSubjectIds = await subjectRepo.getSubjectIdsForCircular(c.id);
      for (final sId in linkedSubjectIds) {
        circularSubjects.add(<String, dynamic>{
          'circular_id': c.id,
          'subject_id': sId,
        });
      }
    }

    final subjects = await subjectRepo.getSubjects();
    final chapters = <Map<String, dynamic>>[];
    final topics = <Map<String, dynamic>>[];
    for (final s in subjects) {
      final sChapters = await chapterRepo.getChaptersForSubject(s.id);
      chapters.addAll(sChapters.map(BackupEntityCodec.chapterToJson));
      final sTopics = await topicRepo.getTopicsForSubject(s.id);
      topics.addAll(sTopics.map(BackupEntityCodec.topicToJson));
    }

    final materials = await materialRepo.getAllMaterials();
    final progressLogs = <Map<String, dynamic>>[];
    for (final m in materials) {
      final logs = await progressLogRepo.getLogsForMaterial(m.id);
      progressLogs.addAll(logs.map(BackupEntityCodec.progressLogToJson));
    }

    final plans = await studyPlanRepo.getPlans();
    final mockTests = await mockTestRepo.getTests();
    final revisionItems = await revisionItemRepo.getRevisionItems();
    final sessions = await studySessionRepo.getStudySessions();
    final notifications = await notificationsRepo.getNotifications();
    final portalAccounts = await portalAccountRepo.getAllAccounts();
    final settings = await userSettingsRepo.getSettings();

    return BackupDataTables(
      circulars: circulars.map(BackupEntityCodec.circularToJson).toList(),
      circularExamDates: examDates,
      subjects: subjects.map(BackupEntityCodec.subjectToJson).toList(),
      chapters: chapters,
      materials: materials.map(BackupEntityCodec.materialToJson).toList(),
      progressLogs: progressLogs,
      topics: topics,
      circularSubjects: circularSubjects,
      studyPlans: plans.map(BackupEntityCodec.studyPlanToJson).toList(),
      mockTests: mockTests.map(BackupEntityCodec.mockTestToJson).toList(),
      revisionItems:
          revisionItems.map(BackupEntityCodec.revisionItemToJson).toList(),
      studySessions:
          sessions.map(BackupEntityCodec.studySessionToJson).toList(),
      notifications:
          notifications.map(BackupEntityCodec.notificationToJson).toList(),
      portalAccounts:
          portalAccounts.map(BackupEntityCodec.portalAccountToJson).toList(),
      userSettings: settings != null
          ? [BackupEntityCodec.userSettingsToJson(settings)]
          : const <Map<String, dynamic>>[],
    );
  }

  @override
  Future<int> restoreBackup({
    required BackupManifest manifest,
    required RestoreStrategy strategy,
    Future<void> Function(BackupManifest safetyManifest)? onSaveSafetyBackup,
  }) async {
    if (strategy.isReplace) {
      if (!isGuest) {
        throw UnsupportedError(
          'Replace strategy is only permitted in guest mode.',
        );
      }
      if (onSaveSafetyBackup != null) {
        final currentData = await collectBackupData();
        final safetyManifest =
            BackupFormatService.createManifest(tables: currentData);
        await onSaveSafetyBackup(safetyManifest);
      }
      if (appDatabase != null) {
        await appDatabase!.eraseAllData();
      }
    }

    return await BackupDataRestorer.restoreTables(
      tables: manifest.data,
      strategy: strategy,
      subjectRepo: subjectRepo,
      chapterRepo: chapterRepo,
      topicRepo: topicRepo,
      materialRepo: materialRepo,
      circularRepo: circularRepo,
      examDateRepo: examDateRepo,
      studyPlanRepo: studyPlanRepo,
      mockTestRepo: mockTestRepo,
      progressLogRepo: progressLogRepo,
      revisionItemRepo: revisionItemRepo,
      studySessionRepo: studySessionRepo,
      notificationsRepo: notificationsRepo,
      portalAccountRepo: portalAccountRepo,
      userSettingsRepo: userSettingsRepo,
    );
  }
}
