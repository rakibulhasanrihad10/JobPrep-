import 'package:job_prep/features/backup/domain/entities/backup_manifest.dart';
import 'package:job_prep/features/backup/domain/entities/backup_validation_result.dart';
import 'package:job_prep/features/backup/domain/services/backup_entity_codec.dart';
import 'package:job_prep/features/circulars/domain/repositories/circular_repository.dart';
import 'package:job_prep/features/circulars/domain/repositories/exam_date_repository.dart';
import 'package:job_prep/features/notifications/domain/repositories/notifications_repository.dart';
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

/// Pure helper executing table-by-table restore in dependency order.
abstract final class BackupDataRestorer {
  /// Restores [tables] into target repositories following [strategy].
  static Future<int> restoreTables({
    required BackupDataTables tables,
    required RestoreStrategy strategy,
    required SubjectRepository subjectRepo,
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
  }) async {
    var count = 0;

    // 1. Subjects
    final existingSubjects = await subjectRepo.getSubjects();
    final subjectMap = {for (final s in existingSubjects) s.id: s};
    for (final raw in tables.subjects) {
      final s = BackupEntityCodec.subjectFromJson(raw);
      final existing = subjectMap[s.id];
      if (existing == null) {
        await subjectRepo.createSubject(s);
        count++;
      } else if (strategy.isReplace ||
          (s.updatedAt != null &&
              existing.updatedAt != null &&
              s.updatedAt!.isAfter(existing.updatedAt!))) {
        await subjectRepo.updateSubject(s);
        count++;
      }
    }

    // 2. Topics
    for (final raw in tables.topics) {
      final t = BackupEntityCodec.topicFromJson(raw);
      final existingTopics = await topicRepo.getTopicsForSubject(t.subjectId);
      final match = existingTopics.where((item) => item.id == t.id).firstOrNull;
      if (match == null) {
        await topicRepo.createTopic(t);
        count++;
      } else if (strategy.isReplace ||
          (t.updatedAt != null &&
              match.updatedAt != null &&
              t.updatedAt!.isAfter(match.updatedAt!))) {
        await topicRepo.updateTopic(t);
        count++;
      }
    }

    // 3. Materials
    final existingMaterials = await materialRepo.getAllMaterials();
    final matMap = {for (final m in existingMaterials) m.id: m};
    for (final raw in tables.materials) {
      final m = BackupEntityCodec.materialFromJson(raw);
      final existing = matMap[m.id];
      if (existing == null) {
        await materialRepo.createMaterial(m);
        count++;
      } else if (strategy.isReplace ||
          (m.updatedAt != null &&
              existing.updatedAt != null &&
              m.updatedAt!.isAfter(existing.updatedAt!))) {
        await materialRepo.updateMaterial(m);
        count++;
      }
    }

    // 4. Circulars
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

    // 5. Circular Exam Dates
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

    // 6. Circular Subjects links
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

    // 7. Study Plans
    final existingPlans = await studyPlanRepo.getPlans();
    final planMap = {for (final p in existingPlans) p.id: p};
    for (final raw in tables.studyPlans) {
      final p = BackupEntityCodec.studyPlanFromJson(raw);
      final existing = planMap[p.id];
      if (existing == null ||
          strategy.isReplace ||
          (p.updatedAt != null &&
              existing.updatedAt != null &&
              p.updatedAt!.isAfter(existing.updatedAt!))) {
        await studyPlanRepo.savePlan(p);
        count++;
      }
    }

    // 8. Mock Tests
    final existingTests = await mockTestRepo.getTests();
    final testMap = {for (final t in existingTests) t.id: t};
    for (final raw in tables.mockTests) {
      final t = BackupEntityCodec.mockTestFromJson(raw);
      final existing = testMap[t.id];
      if (existing == null) {
        await mockTestRepo.createTest(t);
        count++;
      } else if (strategy.isReplace ||
          (t.updatedAt != null &&
              existing.updatedAt != null &&
              t.updatedAt!.isAfter(existing.updatedAt!))) {
        await mockTestRepo.updateTest(t);
        count++;
      }
    }

    // 9. Progress Logs
    for (final raw in tables.progressLogs) {
      final log = BackupEntityCodec.progressLogFromJson(raw);
      final existingLogs =
          await progressLogRepo.getLogsForMaterial(log.materialId);
      final match = existingLogs.where((l) => l.id == log.id).firstOrNull;
      if (match == null) {
        await progressLogRepo.createLog(log);
        count++;
      } else if (strategy.isReplace ||
          (log.createdAt != null &&
              match.createdAt != null &&
              log.createdAt!.isAfter(match.createdAt!))) {
        await progressLogRepo.updateLog(log);
        count++;
      }
    }

    // 10. Revision Items
    final existingItems = await revisionItemRepo.getRevisionItems();
    final revMap = {for (final r in existingItems) r.id: r};
    for (final raw in tables.revisionItems) {
      final r = BackupEntityCodec.revisionItemFromJson(raw);
      final existing = revMap[r.id];
      if (existing == null) {
        await revisionItemRepo.createRevisionItem(r);
        count++;
      } else if (strategy.isReplace ||
          (r.updatedAt != null &&
              existing.updatedAt != null &&
              r.updatedAt!.isAfter(existing.updatedAt!))) {
        await revisionItemRepo.updateRevisionItem(r);
        count++;
      }
    }

    // 11. Study Sessions
    final existingSessions = await studySessionRepo.getStudySessions();
    final sessMap = {for (final s in existingSessions) s.id: s};
    for (final raw in tables.studySessions) {
      final s = BackupEntityCodec.studySessionFromJson(raw);
      final existing = sessMap[s.id];
      if (existing == null) {
        await studySessionRepo.createStudySession(s);
        count++;
      } else if (strategy.isReplace ||
          (s.updatedAt != null &&
              existing.updatedAt != null &&
              s.updatedAt!.isAfter(existing.updatedAt!))) {
        await studySessionRepo.updateStudySession(s);
        count++;
      }
    }

    // 12. Notifications
    final existingNotifs = await notificationsRepo.getNotifications();
    final notifMap = {for (final n in existingNotifs) n.id: n};
    for (final raw in tables.notifications) {
      final n = BackupEntityCodec.notificationFromJson(raw);
      if (!notifMap.containsKey(n.id)) {
        await notificationsRepo.insertNotification(n);
        count++;
      }
    }

    // 13. Portal Accounts (remains ciphertext)
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

    // 14. User Settings
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
