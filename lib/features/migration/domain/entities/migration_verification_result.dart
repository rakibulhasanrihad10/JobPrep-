import 'package:flutter/foundation.dart';

/// Outcome of post-upload integrity verification for guest data migration.
@immutable
class MigrationVerificationResult {
  /// Creates a [MigrationVerificationResult].
  const MigrationVerificationResult({
    required this.isSuccess,
    required this.totalRecordsChecked,
    required this.uploadedCount,
    required this.skippedCount,
    required this.progressTotalsMatch,
    this.mismatchDetails,
  });

  /// True if all uploaded records exist and progress totals match.
  final bool isSuccess;

  /// Total number of guest records inspected.
  final int totalRecordsChecked;

  /// Count of newly inserted records in cloud repositories.
  final int uploadedCount;

  /// Count of existing cloud records preserved (not overwritten).
  final int skippedCount;

  /// True if cloud progress totals equal or exceed merged expected totals.
  final bool progressTotalsMatch;

  /// Explanatory details if verification failed.
  final String? mismatchDetails;
}
