import 'package:job_prep/features/backup/domain/entities/backup_manifest.dart';
import 'package:job_prep/features/backup/domain/services/backup_entity_codec.dart';
import 'package:job_prep/features/migration/domain/entities/migration_verification_result.dart';
import 'package:job_prep/features/migration/domain/repositories/cloud_repositories.dart';
import 'package:job_prep/features/migration/domain/services/guest_prep_uploader.dart';
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

    // 1. Preparation tables uploaded in dependency order
    final prepCounts = await GuestPrepUploader.uploadPrepTables(
      tables: tables,
      cloud: cloud,
      onStep: (table, p) {
        processed = p;
        report(table);
      },
      initialProcessed: processed,
      initialUploaded: uploaded,
      initialSkipped: skipped,
    );
    processed = prepCounts.processed;
    uploaded = prepCounts.uploaded;
    skipped = prepCounts.skipped;

    // 2. Circulars
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

    // 3. Exam Dates
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

    // 4. Circular Subjects Link
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

    // 5. Portal Accounts (as ciphertext)
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

    // 6. User Settings
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
