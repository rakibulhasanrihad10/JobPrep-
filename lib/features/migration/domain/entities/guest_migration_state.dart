import 'package:flutter/foundation.dart';
import 'package:job_prep/features/backup/domain/entities/backup_manifest.dart';
import 'package:job_prep/features/migration/domain/entities/migration_verification_result.dart';

/// Phase or status of the guest migration workflow.
enum MigrationStatus {
  /// No migration in progress.
  idle,

  /// Uploading batches in dependency order.
  uploading,

  /// Verifying records and progress totals in the cloud.
  verifying,

  /// Verification succeeded; ready for optional final backup and erasure.
  completed,

  /// Migration failed; local data untouched and remaining in guest mode.
  failed,
}

/// Immutable state capturing current progress of the guest-to-account
/// migration.
@immutable
class GuestMigrationState {
  /// Creates a [GuestMigrationState].
  const GuestMigrationState({
    this.status = MigrationStatus.idle,
    this.currentTable = '',
    this.processedRecords = 0,
    this.totalRecords = 0,
    this.verificationResult,
    this.finalBackupManifest,
    this.errorMessage,
  });

  /// Factory for idle state.
  factory GuestMigrationState.idle() => const GuestMigrationState();

  /// Current workflow status.
  final MigrationStatus status;

  /// Current table name being uploaded.
  final String currentTable;

  /// Number of records processed so far.
  final int processedRecords;

  /// Total number of records across all tables.
  final int totalRecords;

  /// Verification outcome populated upon successful cloud validation.
  final MigrationVerificationResult? verificationResult;

  /// Final backup manifest generated for user download before local erasure.
  final BackupManifest? finalBackupManifest;

  /// Error message explaining migration failure.
  final String? errorMessage;

  /// Progress fraction from 0.0 to 1.0.
  double get progressFraction {
    if (totalRecords <= 0) return 0;
    final f = processedRecords / totalRecords;
    if (f < 0) return 0;
    if (f > 1) return 1;
    return f;
  }

  /// Whether migration is actively running.
  bool get isRunning =>
      status == MigrationStatus.uploading ||
      status == MigrationStatus.verifying;

  /// Whether migration succeeded.
  bool get isCompleted => status == MigrationStatus.completed;

  /// Whether migration failed.
  bool get isFailed => status == MigrationStatus.failed;

  /// Copies state with updated parameters.
  GuestMigrationState copyWith({
    MigrationStatus? status,
    String? currentTable,
    int? processedRecords,
    int? totalRecords,
    MigrationVerificationResult? verificationResult,
    BackupManifest? finalBackupManifest,
    String? errorMessage,
  }) {
    return GuestMigrationState(
      status: status ?? this.status,
      currentTable: currentTable ?? this.currentTable,
      processedRecords: processedRecords ?? this.processedRecords,
      totalRecords: totalRecords ?? this.totalRecords,
      verificationResult: verificationResult ?? this.verificationResult,
      finalBackupManifest: finalBackupManifest ?? this.finalBackupManifest,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}
