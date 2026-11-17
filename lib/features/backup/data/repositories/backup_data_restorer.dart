import 'package:job_prep/features/backup/data/repositories/backup_prep_restorer.dart';
import 'package:job_prep/features/backup/domain/entities/backup_manifest.dart';
import 'package:job_prep/features/backup/domain/entities/backup_validation_result.dart';
import 'package:job_prep/features/backup/domain/services/backup_entity_codec.dart';
import 'package:job_prep/features/circulars/domain/repositories/circular_repository.dart';
import 'package:job_prep/features/circulars/domain/repositories/exam_date_repository.dart';
import 'package:job_prep/features/notifications/domain/repositories/notifications_repository.dart';
import 'package:job_prep/features/prep/domain/repositories/chapter_repository.dart';
import 'package:job_prep/features/prep/domain/repositories/material_chapter_repository.dart';
import 'package:job_prep/features/prep/domain/repositories/material_repository.dart';
import 'package:job_prep/features/prep/domain/repositories/mock_test_repository.dart';
import 'package:job_prep/features/prep/domain/repositories/mock_test_topic_repository.dart';
import 'package:job_prep/features/prep/domain/repositories/progress_log_repository.dart';
import 'package:job_prep/features/prep/domain/repositories/revision_item_repository.dart';
import 'package:job_prep/features/prep/domain/repositories/study_plan_repository.dart';
import 'package:job_prep/features/prep/domain/repositories/study_session_repository.dart';
import 'package:job_prep/features/prep/domain/repositories/subject_repository.dart';
import 'package:job_prep/features/prep/domain/repositories/topic_repository.dart';
import 'package:job_prep/features/settings/domain/repositories/user_settings_repository.dart';
import 'package:job_prep/features/vault/domain/repositories/portal_account_repository.dart';

/// Pure helper executing table-by-table restore in dependency order.
abstract final class BackupDataRestorer {
  /// Restores [tables] into target repositories following [strategy].
  static Future<int> restoreTables({
    required BackupDataTables tables,
    required RestoreStrategy strategy,
    required SubjectRepository subjectRepo,
    required ChapterRepository chapterRepo,
    required TopicRepository topicRepo,
    required MaterialRepository materialRepo,
    required CircularRepository circularRepo,
    required ExamDateRepository examDateRepo,
    required StudyPlanRepository studyPlanRepo,
    required MockTestRepository mockTestRepo,
    required ProgressLogRepository progressLogRepo,
    required RevisionItemRepository revisionItemRepo,
    required StudySessionRepository studySessionRepo,
    required NotificationsRepository notificationsRepo,
    required PortalAccountRepository portalAccountRepo,
    required UserSettingsRepository userSettingsRepo,
    MaterialChapterRepository? materialChapterRepo,
    MockTestTopicRepository? mockTestTopicRepo,
  }) async {
    var count = 0;

    // 1. Preparation & study tables restored in dependency order
    count += await BackupPrepRestorer.restorePrepTables(
      tables: tables,
      strategy: strategy,
      subjectRepo: subjectRepo,
      chapterRepo: chapterRepo,
      topicRepo: topicRepo,
      materialRepo: materialRepo,
      materialChapterRepo: materialChapterRepo,
      progressLogRepo: progressLogRepo,
      studyPlanRepo: studyPlanRepo,
      mockTestRepo: mockTestRepo,
      mockTestTopicRepo: mockTestTopicRepo,
      revisionItemRepo: revisionItemRepo,
      studySessionRepo: studySessionRepo,
    );

    // 2. Circulars
    final existingCirculars = await circularRepo.getCirculars();
    final circMap = {for (final c in existingCirculars) c.id: c};
    for (final raw in tables.circulars) {
      final c = BackupEntityCodec.circularFromJson(raw);
      final existing = circMap[c.id];
      if (existing == null) {
        await circularRepo.createCircular(c);
        count++;
      } else if (strategy.isReplace ||
          (c.updatedAt != null &&
              existing.updatedAt != null &&
              c.updatedAt!.isAfter(existing.updatedAt!))) {
        await circularRepo.updateCircular(c);
        count++;
      }
    }

    // 3. Circular Exam Dates
    for (final raw in tables.circularExamDates) {
      final d = BackupEntityCodec.examDateFromJson(raw);
      final dates = await examDateRepo.getExamDatesForCircular(d.circularId);
      final match = dates.where((item) => item.id == d.id).firstOrNull;
      if (match == null) {
        await examDateRepo.createExamDate(d);
        count++;
      } else if (strategy.isReplace ||
          (d.updatedAt != null &&
              match.updatedAt != null &&
              d.updatedAt!.isAfter(match.updatedAt!))) {
        await examDateRepo.updateExamDate(d);
        count++;
      }
    }

    // 4. Circular Subjects links
    for (final link in tables.circularSubjects) {
      final cId = link['circular_id'] as String?;
      final sId = link['subject_id'] as String?;
      if (cId != null && sId != null) {
        await subjectRepo.linkSubjectToCircular(
          circularId: cId,
          subjectId: sId,
        );
        count++;
      }
    }

    // 5. Notifications
    final existingNotifs = await notificationsRepo.getNotifications();
    final notifMap = {for (final n in existingNotifs) n.id: n};
    for (final raw in tables.notifications) {
      final n = BackupEntityCodec.notificationFromJson(raw);
      if (!notifMap.containsKey(n.id)) {
        await notificationsRepo.insertNotification(n);
        count++;
      }
    }

    // 6. Portal Accounts (remains ciphertext)
    final existingAccounts = await portalAccountRepo.getAllAccounts();
    final accMap = {for (final a in existingAccounts) a.id: a};
    for (final raw in tables.portalAccounts) {
      final a = BackupEntityCodec.portalAccountFromJson(raw);
      final existing = accMap[a.id];
      if (existing == null) {
        await portalAccountRepo.createAccount(a);
        count++;
      } else if (strategy.isReplace ||
          (a.updatedAt != null &&
              existing.updatedAt != null &&
              a.updatedAt!.isAfter(existing.updatedAt!))) {
        await portalAccountRepo.updateAccount(a);
        count++;
      }
    }

    // 7. User Settings
    if (tables.userSettings.isNotEmpty) {
      final s =
          BackupEntityCodec.userSettingsFromJson(tables.userSettings.first);
      final existing = await userSettingsRepo.getSettings();
      if (existing == null ||
          strategy.isReplace ||
          (s.updatedAt != null &&
              existing.updatedAt != null &&
              s.updatedAt!.isAfter(existing.updatedAt!))) {
        await userSettingsRepo.upsertSettings(s);
        count++;
      }
    }

    return count;
  }
}
