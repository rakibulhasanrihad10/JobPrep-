import 'package:job_prep/features/backup/domain/entities/backup_manifest.dart';
import 'package:job_prep/features/backup/domain/services/backup_entity_codec.dart';
import 'package:job_prep/features/migration/domain/repositories/cloud_repositories.dart';

/// Result counts from uploading prep records during migration.
class GuestPrepUploadCounts {
  const GuestPrepUploadCounts({
    required this.processed,
    required this.uploaded,
    required this.skipped,
  });

  final int processed;
  final int uploaded;
  final int skipped;
}

/// Helper uploading preparation tables during guest migration in
/// dependency order.
abstract final class GuestPrepUploader {
  /// Uploads prep tables from [tables] into [cloud] repositories.
  static Future<GuestPrepUploadCounts> uploadPrepTables({
    required BackupDataTables tables,
    required CloudRepositories cloud,
    required void Function(String table, int processed) onStep,
    int initialProcessed = 0,
    int initialUploaded = 0,
    int initialSkipped = 0,
  }) async {
    var processed = initialProcessed;
    var uploaded = initialUploaded;
    var skipped = initialSkipped;

    // 1. Subjects
    final cloudSubjects = await cloud.subjectRepo.getSubjects();
    final cloudSubjectMap = {for (final s in cloudSubjects) s.id: s};
    for (final raw in tables.subjects) {
      final s = BackupEntityCodec.subjectFromJson(raw);
      if (cloudSubjectMap.containsKey(s.id)) {
        skipped++;
      } else {
        await cloud.subjectRepo.createSubject(s);
        uploaded++;
      }
      processed++;
      onStep('subjects', processed);
    }

    // 2. Chapters
    for (final raw in tables.chapters) {
      final c = BackupEntityCodec.chapterFromJson(raw);
      final existingChapters =
          await cloud.chapterRepo.getChaptersForSubject(c.subjectId);
      final match =
          existingChapters.where((item) => item.id == c.id).firstOrNull;
      if (match != null) {
        skipped++;
      } else {
        await cloud.chapterRepo.createChapter(c);
        uploaded++;
      }
      processed++;
      onStep('chapters', processed);
    }

    // 3. Topics
    for (final raw in tables.topics) {
      final t = BackupEntityCodec.topicFromJson(raw);
      final existingTopics =
          await cloud.topicRepo.getTopicsForSubject(t.subjectId);
      final match = existingTopics.where((item) => item.id == t.id).firstOrNull;
      if (match != null) {
        skipped++;
      } else {
        await cloud.topicRepo.createTopic(t);
        uploaded++;
      }
      processed++;
      onStep('topics', processed);
    }

    // 4. Materials
    for (final raw in tables.materials) {
      final m = BackupEntityCodec.materialFromJson(raw);
      final existingMaterials =
          await cloud.materialRepo.getMaterialsForSubject(m.subjectId);
      final match =
          existingMaterials.where((item) => item.id == m.id).firstOrNull;
      if (match != null) {
        skipped++;
      } else {
        await cloud.materialRepo.createMaterial(m);
        uploaded++;
      }
      processed++;
      onStep('materials', processed);
    }

    // 5. Material Chapters
    if (cloud.materialChapterRepo != null) {
      final existingLinks = await cloud.materialChapterRepo!.getAll();
      final linkIds = {for (final l in existingLinks) l.id};
      for (final raw in tables.materialChapters) {
        final mc = BackupEntityCodec.materialChapterFromJson(raw);
        if (linkIds.contains(mc.id)) {
          skipped++;
        } else {
          await cloud.materialChapterRepo!.linkChapter(
            materialId: mc.materialId,
            chapterId: mc.chapterId,
            id: mc.id,
          );
          uploaded++;
        }
        processed++;
        onStep('material_chapters', processed);
      }
    }

    // 6. Progress Logs
    for (final raw in tables.progressLogs) {
      final log = BackupEntityCodec.progressLogFromJson(raw);
      final existingLogs =
          await cloud.progressLogRepo.getLogsForMaterial(log.materialId);
      final match = existingLogs.where((l) => l.id == log.id).firstOrNull;
      if (match != null) {
        skipped++;
      } else {
        await cloud.progressLogRepo.createLog(log);
        uploaded++;
      }
      processed++;
      onStep('progress_logs', processed);
    }

    // 7. Study Plans
    final cloudPlans = await cloud.studyPlanRepo.getPlans();
    final cloudPlanMap = {for (final p in cloudPlans) p.id: p};
    for (final raw in tables.studyPlans) {
      final p = BackupEntityCodec.studyPlanFromJson(raw);
      if (cloudPlanMap.containsKey(p.id)) {
        skipped++;
      } else {
        await cloud.studyPlanRepo.savePlan(p);
        uploaded++;
      }
      processed++;
      onStep('study_plans', processed);
    }

    // 8. Mock Tests
    final cloudTests = await cloud.mockTestRepo.getTests();
    final cloudTestMap = {for (final t in cloudTests) t.id: t};
    for (final raw in tables.mockTests) {
      final mt = BackupEntityCodec.mockTestFromJson(raw);
      if (cloudTestMap.containsKey(mt.id)) {
        skipped++;
      } else {
        await cloud.mockTestRepo.createTest(mt);
        uploaded++;
      }
      processed++;
      onStep('mock_tests', processed);
    }

    // 9. Mock Test Topics
    if (cloud.mockTestTopicRepo != null) {
      final existingLinks = await cloud.mockTestTopicRepo!.getAll();
      final linkIds = {for (final l in existingLinks) l.id};
      for (final raw in tables.mockTestTopics) {
        final mt = BackupEntityCodec.mockTestTopicFromJson(raw);
        if (linkIds.contains(mt.id)) {
          skipped++;
        } else {
          await cloud.mockTestTopicRepo!.linkTopic(
            mockTestId: mt.mockTestId,
            topicId: mt.topicId,
            id: mt.id,
          );
          uploaded++;
        }
        processed++;
        onStep('mock_test_topics', processed);
      }
    }

    // 10. Revision Items
    final cloudRevisions = await cloud.revisionItemRepo.getRevisionItems();
    final cloudRevisionMap = {for (final r in cloudRevisions) r.id: r};
    for (final raw in tables.revisionItems) {
      final r = BackupEntityCodec.revisionItemFromJson(raw);
      if (cloudRevisionMap.containsKey(r.id)) {
        skipped++;
      } else {
        await cloud.revisionItemRepo.createRevisionItem(r);
        uploaded++;
      }
      processed++;
      onStep('revision_items', processed);
    }

    // 11. Study Sessions
    final cloudSessions = await cloud.studySessionRepo.getStudySessions();
    final cloudSessionMap = {for (final s in cloudSessions) s.id: s};
    for (final raw in tables.studySessions) {
      final s = BackupEntityCodec.studySessionFromJson(raw);
      if (cloudSessionMap.containsKey(s.id)) {
        skipped++;
      } else {
        await cloud.studySessionRepo.createStudySession(s);
        uploaded++;
      }
      processed++;
      onStep('study_sessions', processed);
    }

    return GuestPrepUploadCounts(
      processed: processed,
      uploaded: uploaded,
      skipped: skipped,
    );
  }
}
