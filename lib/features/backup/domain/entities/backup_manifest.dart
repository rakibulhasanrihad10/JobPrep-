import 'dart:convert' show jsonEncode;

import 'package:flutter/foundation.dart' show immutable;

/// Encapsulates serialized table contents included in a JobPrep backup.
@immutable
class BackupDataTables {
  /// Creates a [BackupDataTables].
  const BackupDataTables({
    this.circulars = const <Map<String, dynamic>>[],
    this.circularExamDates = const <Map<String, dynamic>>[],
    this.subjects = const <Map<String, dynamic>>[],
    this.materials = const <Map<String, dynamic>>[],
    this.progressLogs = const <Map<String, dynamic>>[],
    this.topics = const <Map<String, dynamic>>[],
    this.circularSubjects = const <Map<String, dynamic>>[],
    this.studyPlans = const <Map<String, dynamic>>[],
    this.mockTests = const <Map<String, dynamic>>[],
    this.revisionItems = const <Map<String, dynamic>>[],
    this.studySessions = const <Map<String, dynamic>>[],
    this.notifications = const <Map<String, dynamic>>[],
    this.portalAccounts = const <Map<String, dynamic>>[],
    this.userSettings = const <Map<String, dynamic>>[],
  });

  /// Parses table sections from raw [json] map.
  factory BackupDataTables.fromJson(Map<String, dynamic> json) {
    List<Map<String, dynamic>> readList(String key) {
      final list = json[key];
      if (list is! List) return const <Map<String, dynamic>>[];
      return list
          .whereType<Map<Object?, Object?>>()
          .map(Map<String, dynamic>.from)
          .toList(growable: false);
    }

    return BackupDataTables(
      circulars: readList('circulars'),
      circularExamDates: readList('circular_exam_dates'),
      subjects: readList('subjects'),
      materials: readList('materials'),
      progressLogs: readList('progress_logs'),
      topics: readList('topics'),
      circularSubjects: readList('circular_subjects'),
      studyPlans: readList('study_plans'),
      mockTests: readList('mock_tests'),
      revisionItems: readList('revision_items'),
      studySessions: readList('study_sessions'),
      notifications: readList('notifications'),
      portalAccounts: readList('portal_accounts'),
      userSettings: readList('user_settings'),
    );
  }

  /// Stored job circulars.
  final List<Map<String, dynamic>> circulars;

  /// Stored circular exam dates.
  final List<Map<String, dynamic>> circularExamDates;

  /// Stored prep subjects.
  final List<Map<String, dynamic>> subjects;

  /// Stored study materials / books.
  final List<Map<String, dynamic>> materials;

  /// Stored progress logs.
  final List<Map<String, dynamic>> progressLogs;

  /// Stored subject topics.
  final List<Map<String, dynamic>> topics;

  /// Stored circular-to-subject links.
  final List<Map<String, dynamic>> circularSubjects;

  /// Stored study plans.
  final List<Map<String, dynamic>> studyPlans;

  /// Stored mock tests.
  final List<Map<String, dynamic>> mockTests;

  /// Stored spaced revision items.
  final List<Map<String, dynamic>> revisionItems;

  /// Stored stopwatch study sessions.
  final List<Map<String, dynamic>> studySessions;

  /// Stored in-app notifications.
  final List<Map<String, dynamic>> notifications;

  /// Stored encrypted portal accounts (ciphertext only).
  final List<Map<String, dynamic>> portalAccounts;

  /// Stored user settings.
  final List<Map<String, dynamic>> userSettings;

  /// Sum of all records contained across all tables.
  int get totalRecords =>
      circulars.length +
      circularExamDates.length +
      subjects.length +
      materials.length +
      progressLogs.length +
      topics.length +
      circularSubjects.length +
      studyPlans.length +
      mockTests.length +
      revisionItems.length +
      studySessions.length +
      notifications.length +
      portalAccounts.length +
      userSettings.length;

  /// Map of table name to row count.
  Map<String, int> get tableCounts => <String, int>{
        'circulars': circulars.length,
        'circular_exam_dates': circularExamDates.length,
        'subjects': subjects.length,
        'materials': materials.length,
        'progress_logs': progressLogs.length,
        'topics': topics.length,
        'circular_subjects': circularSubjects.length,
        'study_plans': studyPlans.length,
        'mock_tests': mockTests.length,
        'revision_items': revisionItems.length,
        'study_sessions': studySessions.length,
        'notifications': notifications.length,
        'portal_accounts': portalAccounts.length,
        'user_settings': userSettings.length,
      };

  /// Converts table collections to a JSON-encodable map.
  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'circulars': circulars,
      'circular_exam_dates': circularExamDates,
      'subjects': subjects,
      'materials': materials,
      'progress_logs': progressLogs,
      'topics': topics,
      'circular_subjects': circularSubjects,
      'study_plans': studyPlans,
      'mock_tests': mockTests,
      'revision_items': revisionItems,
      'study_sessions': studySessions,
      'notifications': notifications,
      'portal_accounts': portalAccounts,
      'user_settings': userSettings,
    };
  }
}

/// Versioned backup manifest holding metadata, cryptographic checksum,
/// and data.
@immutable
class BackupManifest {
  /// Creates a [BackupManifest].
  const BackupManifest({
    required this.schemaVersion,
    required this.appVersion,
    required this.exportedAt,
    required this.checksum,
    required this.data,
    this.format = formatIdentifier,
  });

  /// Parses a [BackupManifest] from JSON.
  factory BackupManifest.fromJson(Map<String, dynamic> json) {
    final rawData = json['data'];
    final dataMap = rawData is Map
        ? Map<String, dynamic>.from(rawData)
        : <String, dynamic>{};

    return BackupManifest(
      format: (json['format'] as String?) ?? formatIdentifier,
      schemaVersion: (json['schemaVersion'] as num?)?.toInt() ?? 1,
      appVersion: (json['appVersion'] as String?) ?? '0.1.0',
      exportedAt: DateTime.tryParse((json['exportedAt'] as String?) ?? '') ??
          DateTime.now().toUtc(),
      checksum: (json['checksum'] as String?) ?? '',
      data: BackupDataTables.fromJson(dataMap),
    );
  }

  /// Standard plaintext format identifier.
  static const String formatIdentifier = 'jobprep_backup';

  /// Format header string.
  final String format;

  /// Backup schema version.
  final int schemaVersion;

  /// Application version that exported this backup.
  final String appVersion;

  /// UTC timestamp of backup generation.
  final DateTime exportedAt;

  /// Hex-encoded SHA-256 checksum over the serialized data tables.
  final String checksum;

  /// Data tables contents.
  final BackupDataTables data;

  /// Converts manifest to a JSON-encodable map.
  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'format': format,
      'schemaVersion': schemaVersion,
      'appVersion': appVersion,
      'exportedAt': exportedAt.toUtc().toIso8601String(),
      'checksum': checksum,
      'data': data.toJson(),
    };
  }

  /// Encodes this manifest directly to a JSON string.
  String toJsonString() => jsonEncode(toJson());
}
