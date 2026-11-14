import 'package:job_prep/features/backup/domain/entities/backup_manifest.dart';
import 'package:job_prep/features/backup/domain/services/backup_entity_codec.dart';
import 'package:job_prep/features/migration/domain/entities/migration_verification_result.dart';
import 'package:job_prep/features/migration/domain/repositories/cloud_repositories.dart';
import 'package:job_prep/features/migration/domain/services/migration_verifier.dart';

/// Exception thrown when guest migration fails or verification mismatches.
class MigrationException implements Exception {
  /// Creates a [MigrationException].
  const MigrationException(this.message);

  /// Human-readable explanation.
  final String message;

  @override
  String toString() => 'MigrationException: $message';
}

/// Service executing idempotent, dependency-ordered batch upload of guest data
/// into cloud repositories with conflict resolution preserving cloud data.
class GuestMigrationService {
  /// Creates a [GuestMigrationService].
  const GuestMigrationService();

  /// Migrates [tables] to [cloud] in strict dependency order without
  /// overwriting existing cloud records, reporting progress, and verifying
  /// integrity.
  Future<MigrationVerificationResult> migrate({
    required BackupDataTables tables,
    required CloudRepositories cloud,
    void Function(String table, int processed, int total)? onProgress,
  }) async {
    final total = tables.totalRecords - tables.notifications.length;
    var processed = 0;
    var uploaded = 0;
    var skipped = 0;

    void report(String table) {
      onProgress?.call(table, processed, total);
    }

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
      report('subjects');
    }

    // 2. Materials
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
      report('materials');
    }

    // 3. Progress Logs
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
      report('progress_logs');
    }

    // 4. Topics
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
      report('topics');
    }

    // 5. Circulars
    final cloudCirculars = await cloud.circularRepo.getCirculars();
    final cloudCircularMap = {for (final c in cloudCirculars) c.id: c};
    for (final raw in tables.circulars) {
      final c = BackupEntityCodec.circularFromJson(raw);
      if (cloudCircularMap.containsKey(c.id)) {
        skipped++;
      } else {
        await cloud.circularRepo.createCircular(c);
        uploaded++;
      }
      processed++;
      report('circulars');
    }

    // 6. Exam Dates
    for (final raw in tables.circularExamDates) {
      final d = BackupEntityCodec.examDateFromJson(raw);
      final existingDates =
          await cloud.examDateRepo.getExamDatesForCircular(d.circularId);
      final match = existingDates.where((item) => item.id == d.id).firstOrNull;
      if (match != null) {
        skipped++;
      } else {
        await cloud.examDateRepo.createExamDate(d);
        uploaded++;
      }
      processed++;
      report('circular_exam_dates');
    }

    // 7. Circular Subjects Link
    for (final raw in tables.circularSubjects) {
      final cId = (raw['circular_id'] as String?) ?? '';
      final sId = (raw['subject_id'] as String?) ?? '';
      if (cId.isNotEmpty && sId.isNotEmpty) {
        await cloud.subjectRepo.linkSubjectToCircular(
          circularId: cId,
          subjectId: sId,
        );
      }
      processed++;
      report('circular_subjects');
    }

    // 8. Study Plans
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
      report('study_plans');
    }

    // 9. Mock Tests
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
      report('mock_tests');
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
      report('revision_items');
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
      report('study_sessions');
    }

    // 12. Portal Accounts (as ciphertext)
    final cloudPortals = await cloud.portalAccountRepo.getAllAccounts();
    final cloudPortalMap = {for (final p in cloudPortals) p.id: p};
    for (final raw in tables.portalAccounts) {
      final pa = BackupEntityCodec.portalAccountFromJson(raw);
      if (cloudPortalMap.containsKey(pa.id)) {
        skipped++;
      } else {
        await cloud.portalAccountRepo.createAccount(pa);
        uploaded++;
      }
      processed++;
      report('portal_accounts');
    }

    // 13. User Settings
    if (tables.userSettings.isNotEmpty) {
      final cloudSettings = await cloud.userSettingsRepo.getSettings();
      if (cloudSettings != null) {
        skipped++;
      } else {
        final us = BackupEntityCodec.userSettingsFromJson(
          tables.userSettings.first,
        );
        await cloud.userSettingsRepo.upsertSettings(us);
        uploaded++;
      }
      processed++;
      report('user_settings');
    }

    // Post-upload verification
    final result = await MigrationVerifier.verify(
      tables: tables,
      cloud: cloud,
      uploadedCount: uploaded,
      skippedCount: skipped,
    );

    if (!result.isSuccess) {
      throw MigrationException(
        result.mismatchDetails ??
            'Post-migration integrity verification failed',
      );
    }

    return result;
  }
}
