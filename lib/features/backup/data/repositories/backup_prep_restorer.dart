import 'package:job_prep/features/backup/domain/entities/backup_manifest.dart';
import 'package:job_prep/features/backup/domain/entities/backup_validation_result.dart';
import 'package:job_prep/features/backup/domain/services/backup_entity_codec.dart';
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

/// Helper restoring prep and study related tables during backup restore.
abstract final class BackupPrepRestorer {
  /// Restores all preparation tables in strict dependency order.
  static Future<int> restorePrepTables({
    required BackupDataTables tables,
    required RestoreStrategy strategy,
    required SubjectRepository subjectRepo,
    required ChapterRepository chapterRepo,
    required TopicRepository topicRepo,
    required MaterialRepository materialRepo,
    required ProgressLogRepository progressLogRepo,
    required StudyPlanRepository studyPlanRepo,
    required MockTestRepository mockTestRepo,
    required RevisionItemRepository revisionItemRepo,
    required StudySessionRepository studySessionRepo,
    MaterialChapterRepository? materialChapterRepo,
    MockTestTopicRepository? mockTestTopicRepo,
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

    // 2. Chapters
    for (final raw in tables.chapters) {
      final c = BackupEntityCodec.chapterFromJson(raw);
      final existingChapters =
          await chapterRepo.getChaptersForSubject(c.subjectId);
      final match = existingChapters.where((i) => i.id == c.id).firstOrNull;
      if (match == null) {
        await chapterRepo.createChapter(c);
        count++;
      } else if (strategy.isReplace ||
          (c.updatedAt != null &&
              match.updatedAt != null &&
              c.updatedAt!.isAfter(match.updatedAt!))) {
        await chapterRepo.updateChapter(c);
        count++;
      }
    }

    // 3. Topics
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

    // 4. Materials
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

    // 5. Material Chapters
    if (materialChapterRepo != null) {
      for (final raw in tables.materialChapters) {
        final mc = BackupEntityCodec.materialChapterFromJson(raw);
        await materialChapterRepo.linkChapter(
          materialId: mc.materialId,
          chapterId: mc.chapterId,
          id: mc.id,
        );
        count++;
      }
    }

    // 6. Progress Logs
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

    // 9. Mock Test Topics
    if (mockTestTopicRepo != null) {
      for (final raw in tables.mockTestTopics) {
        final mt = BackupEntityCodec.mockTestTopicFromJson(raw);
        await mockTestTopicRepo.linkTopic(
          mockTestId: mt.mockTestId,
          topicId: mt.topicId,
          id: mt.id,
        );
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

    return count;
  }
}
