import 'package:job_prep/features/backup/domain/entities/backup_manifest.dart';
import 'package:job_prep/features/backup/domain/entities/backup_validation_result.dart';

/// Repository contract for gathering and restoring full application state
/// across guest and cloud repositories.
abstract interface class BackupRepository {
  /// Collects all domain entities across repositories into
  /// [BackupDataTables].
  Future<BackupDataTables> collectBackupData();

  /// Restores [manifest] into the active repository targets using [strategy].
  ///
  /// In [RestoreStrategy.replace] mode (guest only), an automatic safety backup
  /// is generated and passed to [onSaveSafetyBackup] before any data is wiped.
  Future<int> restoreBackup({
    required BackupManifest manifest,
    required RestoreStrategy strategy,
    Future<void> Function(BackupManifest safetyManifest)? onSaveSafetyBackup,
  });
}
