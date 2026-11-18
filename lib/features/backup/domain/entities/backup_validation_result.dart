import 'package:flutter/foundation.dart' show immutable;
import 'package:job_prep/features/backup/domain/entities/backup_crypto_envelope.dart';
import 'package:job_prep/features/backup/domain/entities/backup_manifest.dart';

/// Strategy used when applying restored data onto existing application state.
enum RestoreStrategy {
  /// Preserves existing records; only overwrites when backup record is newer.
  merge,

  /// Clears all local records before applying backup data (guest mode only).
  replace;

  /// Whether strategy represents the destructive replace operation.
  bool get isReplace => this == RestoreStrategy.replace;

  /// Whether strategy represents the safe merge operation.
  bool get isMerge => this == RestoreStrategy.merge;
}

/// Result of parsing and validating an uploaded backup file.
@immutable
class BackupValidationResult {
  /// Creates a [BackupValidationResult].
  const BackupValidationResult({
    required this.isValid,
    required this.isEncrypted,
    this.manifest,
    this.envelope,
    this.errorMessage,
    this.errorCode,
    this.tableCounts = const <String, int>{},
    this.totalRecords = 0,
  });

  /// Creates a failure result.
  factory BackupValidationResult.failure({
    required String message,
    required String code,
    bool isEncrypted = false,
  }) {
    return BackupValidationResult(
      isValid: false,
      isEncrypted: isEncrypted,
      errorMessage: message,
      errorCode: code,
    );
  }

  /// Creates an encrypted file requiring passphrase prompt.
  factory BackupValidationResult.requiresPassphrase(
    BackupCryptoEnvelope envelope,
  ) {
    return BackupValidationResult(
      isValid: true,
      isEncrypted: true,
      envelope: envelope,
    );
  }

  /// Creates a successfully validated plaintext manifest result.
  factory BackupValidationResult.success(BackupManifest manifest) {
    return BackupValidationResult(
      isValid: true,
      isEncrypted: false,
      manifest: manifest,
      tableCounts: manifest.data.tableCounts,
      totalRecords: manifest.data.totalRecords,
    );
  }

  /// True if the backup is valid and ready to preview / restore.
  final bool isValid;

  /// True if the backup file is encrypted with a passphrase.
  final bool isEncrypted;

  /// Validated plaintext manifest (available if unencrypted or successfully
  /// decrypted).
  final BackupManifest? manifest;

  /// Encrypted envelope (available when file is encrypted).
  final BackupCryptoEnvelope? envelope;

  /// Error message explaining validation failure.
  final String? errorMessage;

  /// Machine-readable failure code.
  final String? errorCode;

  /// Count of rows per table.
  final Map<String, int> tableCounts;

  /// Total rows across all tables.
  final int totalRecords;
}
