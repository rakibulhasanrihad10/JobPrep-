import 'dart:convert' show utf8;
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:job_prep/core/data/app_mode.dart';
import 'package:job_prep/core/local/local_database_provider.dart';
import 'package:job_prep/core/storage/preferences_provider.dart';
import 'package:job_prep/features/backup/data/repositories/app_backup_repository.dart';
import 'package:job_prep/features/backup/domain/entities/backup_crypto_envelope.dart';
import 'package:job_prep/features/backup/domain/entities/backup_manifest.dart';
import 'package:job_prep/features/backup/domain/entities/backup_validation_result.dart';
import 'package:job_prep/features/backup/domain/repositories/backup_repository.dart';
import 'package:job_prep/features/backup/domain/services/backup_crypto_service.dart';
import 'package:job_prep/features/backup/domain/services/backup_format_service.dart';
import 'package:job_prep/features/circulars/presentation/providers/circulars_providers.dart';
import 'package:job_prep/features/circulars/presentation/providers/exam_date_providers.dart';
import 'package:job_prep/features/notifications/presentation/providers/notifications_providers.dart';
import 'package:job_prep/features/prep/presentation/providers/mock_test_providers.dart';
import 'package:job_prep/features/prep/presentation/providers/prep_providers.dart';
import 'package:job_prep/features/prep/presentation/providers/revision_providers.dart';
import 'package:job_prep/features/prep/presentation/providers/study_plan_providers.dart';
import 'package:job_prep/features/prep/presentation/providers/study_session_providers.dart';
import 'package:job_prep/features/settings/presentation/providers/data_export_providers.dart';
import 'package:job_prep/features/settings/presentation/providers/user_settings_providers.dart';
import 'package:job_prep/features/vault/presentation/providers/portal_vault_providers.dart';

/// Injects the repository-based backup service for both cloud and guest modes.
final Provider<BackupRepository> backupRepositoryProvider =
    Provider<BackupRepository>((ref) {
  return AppBackupRepository(
    circularRepo: ref.watch(circularRepositoryProvider),
    examDateRepo: ref.watch(examDateRepositoryProvider),
    subjectRepo: ref.watch(subjectRepositoryProvider),
    chapterRepo: ref.watch(chapterRepositoryProvider),
    materialRepo: ref.watch(materialRepositoryProvider),
    materialChapterRepo: ref.watch(materialChapterRepositoryProvider),
    progressLogRepo: ref.watch(progressLogRepositoryProvider),
    topicRepo: ref.watch(topicRepositoryProvider),
    studyPlanRepo: ref.watch(studyPlanRepositoryProvider),
    mockTestRepo: ref.watch(mockTestRepositoryProvider),
    mockTestTopicRepo: ref.watch(mockTestTopicRepositoryProvider),
    revisionItemRepo: ref.watch(revisionItemRepositoryProvider),
    studySessionRepo: ref.watch(studySessionRepositoryProvider),
    notificationsRepo: ref.watch(notificationsRepositoryProvider),
    portalAccountRepo: ref.watch(portalAccountRepositoryProvider),
    userSettingsRepo: ref.watch(userSettingsRepositoryProvider),
    appDatabase: ref.watch(appDatabaseProvider),
    isGuest: ref.watch(appModeProvider)?.isGuest ?? false,
  );
});

/// File picker callback delivering picked backup file bytes.
typedef BackupFilePickerFn = Future<Uint8List?> Function();

/// Platform file picker delivering JSON backup bytes.
final Provider<BackupFilePickerFn> backupFilePickerProvider =
    Provider<BackupFilePickerFn>((ref) {
  return () async {
    final picked = await FilePicker.pickFile(
      type: FileType.custom,
      allowedExtensions: ['json'],
    );
    if (picked == null) return null;
    return await picked.readAsBytes();
  };
});

/// Reuses the platform file saver abstraction for backup exports.
final Provider<DataExportFileSaverFn> backupFileSaverProvider =
    Provider<DataExportFileSaverFn>((ref) {
  return ref.watch(dataExportFileSaverProvider);
});

/// SharedPreferences key for recording the latest backup timestamp.
const String lastBackupTimeStorageKey = 'jobprep_last_backup_time';

/// Notifier tracking and persisting the last successful backup timestamp.
class LastBackupTimeNotifier extends Notifier<DateTime?> {
  @override
  DateTime? build() {
    final prefs = ref.watch(sharedPreferencesProvider);
    final raw = prefs.getString(lastBackupTimeStorageKey);
    return raw != null ? DateTime.tryParse(raw)?.toLocal() : null;
  }

  /// Updates and stores the last backup timestamp.
  Future<void> recordBackup(DateTime timestamp) async {
    state = timestamp;
    final prefs = ref.read(sharedPreferencesProvider);
    await prefs.setString(
      lastBackupTimeStorageKey,
      timestamp.toUtc().toIso8601String(),
    );
  }
}

/// Provider exposing the last backup timestamp.
final NotifierProvider<LastBackupTimeNotifier, DateTime?>
    lastBackupTimeProvider =
    NotifierProvider<LastBackupTimeNotifier, DateTime?>(
  LastBackupTimeNotifier.new,
);

/// Configurable reminder threshold in days (default: 7 days).
final Provider<int> backupReminderDaysProvider = Provider<int>((ref) => 7);

/// Session-scoped flag indicating user dismissed the 7-day backup reminder.
class BackupReminderDismissedNotifier extends Notifier<bool> {
  @override
  bool build() => false;

  /// Dismisses reminder banner for current session.
  void dismiss() => state = true;
}

/// Provider for dismissed state of backup reminder banner.
final NotifierProvider<BackupReminderDismissedNotifier, bool>
    backupReminderDismissedProvider =
    NotifierProvider<BackupReminderDismissedNotifier, bool>(
  BackupReminderDismissedNotifier.new,
);

/// Computes the number of modified/created records since the last backup.
final FutureProvider<int> backupChangesCountProvider =
    FutureProvider<int>((ref) async {
  final lastBackup = ref.watch(lastBackupTimeProvider);
  final repo = ref.watch(backupRepositoryProvider);
  final tables = await repo.collectBackupData();

  if (lastBackup == null) {
    return tables.totalRecords;
  }

  // Count records whose created/updated timestamp is after lastBackup.
  var count = 0;
  for (final s in tables.subjects) {
    final updated = s['updated_at'] != null
        ? DateTime.tryParse(s['updated_at'] as String)
        : null;
    if (updated != null && updated.isAfter(lastBackup)) count++;
  }
  for (final m in tables.materials) {
    final updated = m['updated_at'] != null
        ? DateTime.tryParse(m['updated_at'] as String)
        : null;
    if (updated != null && updated.isAfter(lastBackup)) count++;
  }
  for (final c in tables.circulars) {
    final updated = c['updated_at'] != null
        ? DateTime.tryParse(c['updated_at'] as String)
        : null;
    if (updated != null && updated.isAfter(lastBackup)) count++;
  }
  for (final l in tables.progressLogs) {
    final created = l['created_at'] != null
        ? DateTime.tryParse(l['created_at'] as String)
        : null;
    if (created != null && created.isAfter(lastBackup)) count++;
  }

  return count > 0 ? count : (tables.totalRecords > 0 ? 1 : 0);
});

/// Indicates whether the 7-day reminder banner should be rendered.
final Provider<bool> backupReminderVisibleProvider = Provider<bool>((ref) {
  final dismissed = ref.watch(backupReminderDismissedProvider);
  if (dismissed) return false;

  final lastBackup = ref.watch(lastBackupTimeProvider);
  if (lastBackup == null) return false;

  final threshold = ref.watch(backupReminderDaysProvider);
  final diff = DateTime.now().difference(lastBackup).inDays;
  return diff >= threshold;
});

/// Orchestrates backup export, file picker parsing, and restoration.
class BackupController {
  /// Creates a [BackupController].
  const BackupController(this._ref);

  final Ref _ref;

  /// Exports study data as plaintext or passphrase-encrypted JSON.
  Future<String?> exportBackup({String? passphrase}) async {
    final repo = _ref.read(backupRepositoryProvider);
    final saver = _ref.read(backupFileSaverProvider);
    final tables = await repo.collectBackupData();
    final manifest = BackupFormatService.createManifest(tables: tables);

    final String jsonString;
    final String fileNamePrefix;

    if (passphrase != null && passphrase.trim().isNotEmpty) {
      final envelope = await BackupCryptoService.encrypt(
        plainJson: manifest.toJsonString(),
        passphrase: passphrase.trim(),
        schemaVersion: manifest.schemaVersion,
        appVersion: manifest.appVersion,
        exportedAt: manifest.exportedAt,
      );
      jsonString = envelope.toJsonString();
      fileNamePrefix = 'jobprep_backup_encrypted';
    } else {
      jsonString = manifest.toJsonString();
      fileNamePrefix = 'jobprep_backup';
    }

    final timestamp = manifest.exportedAt
        .toIso8601String()
        .replaceAll(':', '-')
        .split('.')
        .first;
    final fileName = '${fileNamePrefix}_$timestamp.json';

    final bytes = Uint8List.fromList(utf8.encode(jsonString));
    final uri = await saver(
      fileName: fileName,
      bytes: bytes,
      mimeType: 'application/json',
    );

    if (uri != null) {
      await _ref
          .read(lastBackupTimeProvider.notifier)
          .recordBackup(DateTime.now());
      return fileName;
    }
    return null;
  }

  /// Picks and validates a backup file without writing to repositories.
  Future<BackupValidationResult?> pickAndValidateBackup() async {
    final picker = _ref.read(backupFilePickerProvider);
    final bytes = await picker();
    if (bytes == null || bytes.isEmpty) return null;

    return await BackupFormatService.validateRawBytes(bytes);
  }

  /// Decrypts an encrypted envelope using [passphrase] and returns preview.
  Future<BackupValidationResult> unlockEncryptedBackup({
    required BackupCryptoEnvelope envelope,
    required String passphrase,
  }) async {
    final decryptedJson = await BackupCryptoService.decrypt(
      envelope: envelope,
      passphrase: passphrase,
    );
    final manifest = await BackupFormatService.parseAndMigrate(decryptedJson);
    return BackupValidationResult.success(manifest);
  }

  /// Restores [manifest] into target repositories using [strategy].
  Future<int> restoreBackup({
    required BackupManifest manifest,
    required RestoreStrategy strategy,
    Future<void> Function(BackupManifest safety)? onSaveSafetyBackup,
  }) async {
    final repo = _ref.read(backupRepositoryProvider);
    return await repo.restoreBackup(
      manifest: manifest,
      strategy: strategy,
      onSaveSafetyBackup: onSaveSafetyBackup,
    );
  }
}

/// Provider exposing [BackupController].
final Provider<BackupController> backupControllerProvider =
    Provider<BackupController>(BackupController.new);
