import 'dart:convert';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart' show compute;
import 'package:job_prep/features/backup/domain/entities/backup_crypto_envelope.dart';
import 'package:job_prep/features/backup/domain/entities/backup_manifest.dart';
import 'package:job_prep/features/backup/domain/entities/backup_validation_result.dart';
import 'package:job_prep/features/prep/domain/entities/prep_enums.dart';

/// Serialization, checksum verification, isolate parsing, and version migration
/// for JobPrep backup archives.
abstract final class BackupFormatService {
  /// Maximum accepted backup size in bytes (25 MB).
  static const int maxBackupSizeBytes = 25 * 1024 * 1024;

  /// Active backup schema version.
  static const int currentSchemaVersion = 3;

  /// Current application version baseline.
  static const String currentAppVersion = '0.1.0';

  /// Computes a deterministic SHA-256 checksum over the encoded [data] table
  /// map.
  static String computeChecksum(BackupDataTables data) {
    final dataJson = jsonEncode(data.toJson());
    final digest = sha256.convert(utf8.encode(dataJson));
    return digest.toString();
  }

  /// Constructs a complete [BackupManifest] with canonical checksum and
  /// metadata.
  static BackupManifest createManifest({
    required BackupDataTables tables,
    DateTime? exportedAt,
    String appVersion = currentAppVersion,
  }) {
    final timestamp = exportedAt ?? DateTime.now().toUtc();
    final checksum = computeChecksum(tables);

    return BackupManifest(
      schemaVersion: currentSchemaVersion,
      appVersion: appVersion,
      exportedAt: timestamp,
      checksum: checksum,
      data: tables,
    );
  }

  /// Serializes a [BackupManifest] into pretty-printed UTF-8 JSON bytes.
  static Uint8List encodeManifest(BackupManifest manifest) {
    final jsonString =
        const JsonEncoder.withIndent('  ').convert(manifest.toJson());
    return Uint8List.fromList(utf8.encode(jsonString));
  }

  /// Serializes an encrypted [envelope] into formatted UTF-8 JSON bytes.
  static Uint8List encodeEnvelope(BackupCryptoEnvelope envelope) {
    final jsonString =
        const JsonEncoder.withIndent('  ').convert(envelope.toJson());
    return Uint8List.fromList(utf8.encode(jsonString));
  }

  /// Inspects raw backup [bytes], enforcing size limits, validating structure,
  /// and running JSON deserialization in an isolate when file is large.
  static Future<BackupValidationResult> validateBytes(Uint8List bytes) async {
    if (bytes.lengthInBytes > maxBackupSizeBytes) {
      return BackupValidationResult.failure(
        code: 'file_too_large',
        message: 'Backup file exceeds maximum allowed size (25 MB).',
      );
    }

    try {
      final jsonString = utf8.decode(bytes);
      // Run heavy JSON parsing in background isolate for archives over 100 KB.
      final parsedJson = (bytes.lengthInBytes > 100 * 1024)
          ? await compute(_parseJsonIsolate, jsonString)
          : jsonDecode(jsonString);

      if (parsedJson is! Map<String, dynamic>) {
        return BackupValidationResult.failure(
          code: 'invalid_format',
          message: 'Invalid or unreadable backup file format.',
        );
      }

      return validateParsedJson(parsedJson);
    } on Object catch (_) {
      return BackupValidationResult.failure(
        code: 'invalid_format',
        message: 'Invalid or unreadable backup file format.',
      );
    }
  }

  /// Validates an already-decoded JSON map.
  static BackupValidationResult validateParsedJson(Map<String, dynamic> json) {
    // 1. Check if encrypted envelope
    if (BackupCryptoEnvelope.isEncryptedEnvelope(json)) {
      final envelope = BackupCryptoEnvelope.fromJson(json);
      return BackupValidationResult.requiresPassphrase(envelope);
    }

    // 2. Validate format marker
    final format = json['format'];
    if (format != BackupManifest.formatIdentifier && format != null) {
      return BackupValidationResult.failure(
        code: 'invalid_format',
        message: 'Unrecognized backup format.',
      );
    }

    // 3. Newer app version check
    final fileAppVersion = (json['appVersion'] as String?) ?? '0.1.0';
    if (isNewerAppVersion(
      fileAppVersion: fileAppVersion,
      currentVersion: currentAppVersion,
    )) {
      return BackupValidationResult.failure(
        code: 'newer_version',
        message: 'This backup was created by a newer version of '
            'JobPrep (v$fileAppVersion).',
      );
    }

    // 4. Schema version & older version migration
    final fileSchema = (json['schemaVersion'] as num?)?.toInt() ?? 0;
    BackupDataTables tables;
    final rawData = json['data'];
    final dataMap = rawData is Map
        ? Map<String, dynamic>.from(rawData)
        : Map<String, dynamic>.from(json);

    if (fileSchema < currentSchemaVersion) {
      tables = migrateOlderSchema(dataMap, fileSchema);
    } else {
      tables = BackupDataTables.fromJson(dataMap);
    }

    // 5. Checksum verification for schema 1+
    final recordedChecksum = (json['checksum'] as String?) ?? '';
    if (fileSchema >= currentSchemaVersion && recordedChecksum.isNotEmpty) {
      final expectedChecksum = computeChecksum(tables);
      if (expectedChecksum != recordedChecksum) {
        return BackupValidationResult.failure(
          code: 'checksum_mismatch',
          message: 'Checksum mismatch: backup file has been corrupted '
              'or tampered with.',
        );
      }
    }

    final manifest = BackupManifest(
      schemaVersion: currentSchemaVersion,
      appVersion: fileAppVersion,
      exportedAt: DateTime.tryParse((json['exportedAt'] as String?) ?? '') ??
          DateTime.now().toUtc(),
      checksum: computeChecksum(tables),
      data: tables,
    );

    return BackupValidationResult.success(manifest);
  }

  /// Migrates older backup schema versions to [currentSchemaVersion].
  static BackupDataTables migrateOlderSchema(
    Map<String, dynamic> legacyData,
    int sourceSchemaVersion,
  ) {
    final tables = BackupDataTables.fromJson(legacyData);

    // Normalize progress logs: ensure every progress log has entry_type
    final upgradedLogs = tables.progressLogs.map((log) {
      final map = Map<String, dynamic>.from(log);
      map['entry_type'] = (map['entry_type'] as String?) ?? 'increment';
      return map;
    }).toList(growable: false);

    // Normalize subjects: ensure enabled_checkpoints defaults
    final upgradedSubjects = tables.subjects.map((sub) {
      final map = Map<String, dynamic>.from(sub);
      map['enabled_checkpoints'] = (map['enabled_checkpoints'] as List?) ??
          SyllabusCheckpoint.defaultEnabledValues;
      return map;
    }).toList(growable: false);

    // Normalize topics: weight, sort_order, title, and migrate status
    // to timestamps
    final upgradedTopics = tables.topics.map((top) {
      final map = Map<String, dynamic>.from(top);
      map['weight'] = (map['weight'] as num?)?.toInt() ?? 1;
      map['sort_order'] = (map['sort_order'] as num?)?.toInt() ?? 0;
      map['title'] =
          (map['title'] as String?) ?? (map['name'] as String?) ?? '';
      final statusVal = (map['status'] as String?)?.toLowerCase().trim();
      final nowStr = (map['updated_at'] as String?) ??
          DateTime.now().toUtc().toIso8601String();
      if (statusVal == 'learning' || statusVal == 'in_progress') {
        map['study_done_at'] ??= nowStr;
      } else if (statusVal == 'revised' || statusVal == 'needs_revision') {
        map['study_done_at'] ??= nowStr;
        map['revision_done_at'] ??= nowStr;
      } else if (statusVal == 'mastered' || statusVal == 'completed') {
        map['study_done_at'] ??= nowStr;
        map['practice_done_at'] ??= nowStr;
        map['model_test_done_at'] ??= nowStr;
        map['revision_done_at'] ??= nowStr;
      }
      return map;
    }).toList(growable: false);

    // Normalize study plans: ensure plan_basis defaults to reading_units
    final upgradedPlans = tables.studyPlans.map((plan) {
      final map = Map<String, dynamic>.from(plan);
      map['plan_basis'] = (map['plan_basis'] as String?) ?? 'reading_units';
      return map;
    }).toList(growable: false);

    return BackupDataTables(
      circulars: tables.circulars,
      circularExamDates: tables.circularExamDates,
      subjects: upgradedSubjects,
      chapters: tables.chapters,
      materials: tables.materials,
      progressLogs: upgradedLogs,
      topics: upgradedTopics,
      circularSubjects: tables.circularSubjects,
      studyPlans: upgradedPlans,
      mockTests: tables.mockTests,
      mockTestTopics: tables.mockTestTopics,
      materialChapters: tables.materialChapters,
      revisionItems: tables.revisionItems,
      studySessions: tables.studySessions,
      notifications: tables.notifications,
      portalAccounts: tables.portalAccounts,
      userSettings: tables.userSettings,
    );
  }

  /// Alias for [validateBytes].
  static Future<BackupValidationResult> validateRawBytes(
    Uint8List bytes, {
    String currentAppVersion = currentAppVersion,
  }) =>
      validateBytes(bytes);

  /// Parses decrypted JSON into a validated and migrated [BackupManifest].
  static Future<BackupManifest> parseAndMigrate(String jsonString) async {
    final parsed = jsonDecode(jsonString);
    if (parsed is! Map<String, dynamic>) {
      throw const FormatException('Invalid backup JSON format');
    }
    final validation = validateParsedJson(parsed);
    if (!validation.isValid || validation.manifest == null) {
      throw FormatException(validation.errorMessage ?? 'Validation failed');
    }
    return validation.manifest!;
  }

  /// Returns true if [fileAppVersion] is strictly newer than [currentVersion].
  static bool isNewerAppVersion({
    required String fileAppVersion,
    required String currentVersion,
  }) {
    List<int> parseParts(String v) {
      final clean = v.split('+').first;
      return clean.split('.').map((p) => int.tryParse(p) ?? 0).toList();
    }

    final fileParts = parseParts(fileAppVersion);
    final currentParts = parseParts(currentVersion);

    for (var i = 0; i < 3; i++) {
      final f = i < fileParts.length ? fileParts[i] : 0;
      final c = i < currentParts.length ? currentParts[i] : 0;
      if (f > c) return true;
      if (f < c) return false;
    }
    return false;
  }
}

Map<String, dynamic> _parseJsonIsolate(String source) {
  return jsonDecode(source) as Map<String, dynamic>;
}
