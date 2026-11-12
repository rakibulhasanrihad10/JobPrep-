import 'dart:convert';

import 'package:job_prep/features/settings/domain/utils/data_export_json.dart';
import 'package:job_prep/features/settings/domain/utils/data_export_snapshot.dart';

/// Builds a normalized RFC-4180 CSV spreadsheet combining all exported
/// circulars and preparation records.
abstract final class DataExportCsv {
  /// Header columns written as the first CSV row.
  static const List<String> columns = <String>[
    'record_type',
    'id',
    'parent_id',
    'title_or_name',
    'status_or_kind',
    'date_primary',
    'date_secondary',
    'numeric_primary',
    'numeric_secondary',
    'details_json',
  ];

  /// Escapes a single CSV cell according to RFC 4180.
  static String escapeCell(String raw) {
    final needsQuotes = raw.contains(',') ||
        raw.contains('"') ||
        raw.contains('\n') ||
        raw.contains('\r');
    if (!needsQuotes) return raw;
    return '"${raw.replaceAll('"', '""')}"';
  }

  /// Renders [snapshot] to an RFC-4180 CSV string with `\n` line endings.
  static String build(DataExportSnapshot snapshot) {
    final map = DataExportJson.buildMap(snapshot);
    final lines = <String>[columns.map(escapeCell).join(',')];

    void addRow({
      required String type,
      required String id,
      required String title,
      String parentId = '',
      String status = '',
      String date1 = '',
      String date2 = '',
      num? num1,
      num? num2,
      Map<String, dynamic>? details,
    }) {
      lines.add(
        <String>[
          type,
          id,
          parentId,
          title,
          status,
          date1,
          date2,
          num1?.toString() ?? '',
          num2?.toString() ?? '',
          if (details == null) '' else jsonEncode(details),
        ].map(escapeCell).join(','),
      );
    }

    for (final row in map['circulars'] as List<dynamic>) {
      final item = row as Map<String, dynamic>;
      addRow(
        type: 'circular',
        id: item['id'] as String,
        title: item['title'] as String,
        status: '${item['workflowStatus']}:${item['applicationStatus']}',
        date1: (item['deadline'] as String?) ?? '',
        date2: (item['updatedAt'] as String?) ?? '',
        num1: item['vacancies'] as num?,
        num2: item['applicationFee'] as num?,
        details: item,
      );
    }

    for (final row in map['circularExamDates'] as List<dynamic>) {
      final item = row as Map<String, dynamic>;
      addRow(
        type: 'circular_exam_date',
        id: item['id'] as String,
        parentId: item['circularId'] as String,
        title: item['stage'] as String,
        date1: item['examDate'] as String,
        details: item,
      );
    }

    for (final row in map['subjects'] as List<dynamic>) {
      final item = row as Map<String, dynamic>;
      addRow(
        type: 'subject',
        id: item['id'] as String,
        title: item['name'] as String,
        status: item['examType'] as String,
        num1: item['sortOrder'] as num?,
        details: item,
      );
    }

    for (final row in map['materials'] as List<dynamic>) {
      final item = row as Map<String, dynamic>;
      addRow(
        type: 'material',
        id: item['id'] as String,
        parentId: item['subjectId'] as String,
        title: item['title'] as String,
        status: item['kind'] as String,
        num1: item['completedUnits'] as num?,
        num2: item['totalUnits'] as num?,
        details: item,
      );
    }

    for (final row in map['topics'] as List<dynamic>) {
      final item = row as Map<String, dynamic>;
      addRow(
        type: 'topic',
        id: item['id'] as String,
        parentId: item['subjectId'] as String,
        title: item['name'] as String,
        status: item['status'] as String,
        details: item,
      );
    }

    for (final row in map['progressLogs'] as List<dynamic>) {
      final item = row as Map<String, dynamic>;
      addRow(
        type: 'progress_log',
        id: item['id'] as String,
        parentId: item['materialId'] as String,
        title: (item['note'] as String?) ?? '',
        status: item['entryType'] as String,
        date1: item['loggedOn'] as String,
        num1: item['unitsDone'] as num?,
        details: item,
      );
    }

    for (final row in map['studyPlans'] as List<dynamic>) {
      final item = row as Map<String, dynamic>;
      addRow(
        type: 'study_plan',
        id: item['id'] as String,
        parentId: (item['subjectId'] as String?) ?? '',
        title: 'study_plan',
        date1: item['startDate'] as String,
        date2: item['targetDate'] as String,
        num1: item['finishBufferDays'] as num?,
        num2: item['maxDailyPace'] as num?,
        details: item,
      );
    }

    for (final row in map['mockTests'] as List<dynamic>) {
      final item = row as Map<String, dynamic>;
      addRow(
        type: 'mock_test',
        id: item['id'] as String,
        parentId: item['subjectId'] as String,
        title: item['title'] as String,
        status: (item['source'] as String?) ?? '',
        date1: item['takenOn'] as String,
        num1: item['marksObtained'] as num?,
        num2: item['totalMarks'] as num?,
        details: item,
      );
    }

    for (final row in map['revisionItems'] as List<dynamic>) {
      final item = row as Map<String, dynamic>;
      addRow(
        type: 'revision_item',
        id: item['id'] as String,
        parentId:
            (item['materialId'] as String?) ?? item['subjectId'] as String,
        title: item['referenceLabel'] as String,
        status: '${item['status']}:${item['reason']}',
        date1: item['dueOn'] as String,
        date2: (item['lastReviewedOn'] as String?) ?? '',
        num1: item['reviewCount'] as num?,
        num2: item['pageNumber'] as num?,
        details: item,
      );
    }

    for (final row in map['studySessions'] as List<dynamic>) {
      final item = row as Map<String, dynamic>;
      addRow(
        type: 'study_session',
        id: item['id'] as String,
        parentId:
            (item['materialId'] as String?) ?? item['subjectId'] as String,
        title: (item['note'] as String?) ?? '',
        status: item['mode'] as String,
        date1: item['startedAt'] as String,
        date2: (item['endedAt'] as String?) ?? '',
        num1: item['durationSeconds'] as num?,
        details: item,
      );
    }

    return lines.join('\n');
  }
}
