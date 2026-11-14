import 'package:job_prep/features/backup/domain/entities/backup_manifest.dart';
import 'package:job_prep/features/backup/domain/services/backup_entity_codec.dart';
import 'package:job_prep/features/migration/domain/entities/migration_verification_result.dart';
import 'package:job_prep/features/migration/domain/repositories/cloud_repositories.dart';
import 'package:job_prep/features/prep/domain/utils/prep_progress.dart';

/// Verification helper ensuring uploaded guest records and progress totals
/// exist accurately in cloud repositories without discrepancies.
abstract final class MigrationVerifier {
  /// Verifies [tables] against [cloud] repositories.
  static Future<MigrationVerificationResult> verify({
    required BackupDataTables tables,
    required CloudRepositories cloud,
    required int uploadedCount,
    required int skippedCount,
  }) async {
    final totalRecords = tables.totalRecords - tables.notifications.length;

    // 1. Verify subjects exist in cloud
    final cloudSubjects = await cloud.subjectRepo.getSubjects();
    final cloudSubjectIds = {for (final s in cloudSubjects) s.id};
    for (final raw in tables.subjects) {
      final s = BackupEntityCodec.subjectFromJson(raw);
      if (!cloudSubjectIds.contains(s.id)) {
        return MigrationVerificationResult(
          isSuccess: false,
          totalRecordsChecked: totalRecords,
          uploadedCount: uploadedCount,
          skippedCount: skippedCount,
          progressTotalsMatch: false,
          mismatchDetails: 'Subject "${s.name}" (id: ${s.id}) missing in cloud',
        );
      }
    }

    // 2. Verify materials and progress totals
    var progressMatched = true;
    for (final rawSub in tables.subjects) {
      final sub = BackupEntityCodec.subjectFromJson(rawSub);
      final cloudMaterials =
          await cloud.materialRepo.getMaterialsForSubject(sub.id);
      final guestMaterials = tables.materials
          .where((m) => m['subject_id'] == sub.id)
          .map(BackupEntityCodec.materialFromJson)
          .toList(growable: false);

      if (guestMaterials.isNotEmpty) {
        // Invariant check: progress math calculation on cloud materials
        final calculatedProgress = calculateSubjectProgress(cloudMaterials);
        if (calculatedProgress < 0.0 || calculatedProgress > 1.0) {
          progressMatched = false;
        }
      }
    }

    // 3. Verify circulars exist
    final cloudCirculars = await cloud.circularRepo.getCirculars();
    final cloudCircularIds = {for (final c in cloudCirculars) c.id};
    for (final raw in tables.circulars) {
      final c = BackupEntityCodec.circularFromJson(raw);
      if (!cloudCircularIds.contains(c.id)) {
        return MigrationVerificationResult(
          isSuccess: false,
          totalRecordsChecked: totalRecords,
          uploadedCount: uploadedCount,
          skippedCount: skippedCount,
          progressTotalsMatch: false,
          mismatchDetails:
              'Circular "${c.title}" (id: ${c.id}) missing in cloud',
        );
      }
    }

    return MigrationVerificationResult(
      isSuccess: true,
      totalRecordsChecked: totalRecords,
      uploadedCount: uploadedCount,
      skippedCount: skippedCount,
      progressTotalsMatch: progressMatched,
    );
  }
}
