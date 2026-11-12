import 'package:job_prep/features/prep/data/mappers/prep_json_helpers.dart';
import 'package:job_prep/features/prep/domain/entities/mock_test.dart';

/// Maps between PostgreSQL `public.mock_tests` JSON payloads and [MockTest].
abstract final class MockTestMapper {
  /// Parses a single JSON row returned by PostgREST into [MockTest].
  static MockTest fromJson(Map<String, dynamic> json) {
    return MockTest(
      id: PrepJsonHelpers.readRequiredString(json, 'id'),
      userId: PrepJsonHelpers.readRequiredString(json, 'user_id'),
      subjectId: PrepJsonHelpers.readRequiredString(json, 'subject_id'),
      circularId: PrepJsonHelpers.readOptionalString(
        json,
        'circular_id',
        trimEmptyToNull: true,
      ),
      materialId: PrepJsonHelpers.readOptionalString(
        json,
        'material_id',
        trimEmptyToNull: true,
      ),
      topicId: PrepJsonHelpers.readOptionalString(
        json,
        'topic_id',
        trimEmptyToNull: true,
      ),
      title: PrepJsonHelpers.readRequiredString(json, 'title'),
      source: PrepJsonHelpers.readOptionalString(
        json,
        'source',
        trimEmptyToNull: true,
      ),
      takenOn: PrepJsonHelpers.readRequiredDateOnly(json, 'taken_on'),
      marksObtained: _readRequiredDouble(json, 'marks_obtained'),
      totalMarks: _readRequiredDouble(json, 'total_marks'),
      negativeMarks: _readOptionalDouble(json, 'negative_marks'),
      timeTakenMinutes: PrepJsonHelpers.readOptionalInt(
        json,
        'time_taken_minutes',
      ),
      timeLimitMinutes: PrepJsonHelpers.readOptionalInt(
        json,
        'time_limit_minutes',
      ),
      weakTopics: PrepJsonHelpers.readOptionalString(
        json,
        'weak_topics',
        trimEmptyToNull: true,
      ),
      notes: PrepJsonHelpers.readOptionalString(
        json,
        'notes',
        trimEmptyToNull: true,
      ),
      createdAt: PrepJsonHelpers.readOptionalDateTime(json, 'created_at'),
      updatedAt: PrepJsonHelpers.readOptionalDateTime(json, 'updated_at'),
    );
  }

  /// Parses a PostgREST row list into immutable [MockTest] list.
  static List<MockTest> fromJsonList(List<dynamic> rows) {
    return rows
        .whereType<Map<String, dynamic>>()
        .map(fromJson)
        .toList(growable: false);
  }

  /// Converts [test] into an insert JSON map, letting Postgres generate `id`.
  static Map<String, dynamic> toInsertJson(
    MockTest test, {
    String? userId,
  }) {
    final resolvedUserId =
        userId?.trim().isNotEmpty == true ? userId!.trim() : test.userId.trim();
    return <String, dynamic>{
      if (resolvedUserId.isNotEmpty) 'user_id': resolvedUserId,
      ...toUpdateJson(test),
    };
  }

  /// Converts mutable fields of [test] into an update JSON map.
  static Map<String, dynamic> toUpdateJson(MockTest test) {
    return <String, dynamic>{
      'subject_id': test.subjectId.trim(),
      'circular_id': _nullableTrim(test.circularId),
      'material_id': _nullableTrim(test.materialId),
      'topic_id': _nullableTrim(test.topicId),
      'title': test.title.trim(),
      'source': _nullableTrim(test.source),
      'taken_on': PrepJsonHelpers.formatDateOnly(test.takenOn),
      'marks_obtained': test.marksObtained,
      'total_marks': test.totalMarks,
      'negative_marks': test.negativeMarks,
      'time_taken_minutes': test.timeTakenMinutes,
      'time_limit_minutes': test.timeLimitMinutes,
      'weak_topics': _nullableTrim(test.weakTopics),
      'notes': _nullableTrim(test.notes),
    };
  }

  static String? _nullableTrim(String? raw) {
    if (raw == null) return null;
    final trimmed = raw.trim();
    return trimmed.isEmpty ? null : trimmed;
  }

  static double? _readOptionalDouble(Map<String, dynamic> json, String key) {
    final value = json[key];
    if (value == null) return null;
    if (value is num) return value.toDouble();
    if (value is String) {
      final trimmed = value.trim();
      if (trimmed.isEmpty) return null;
      return double.tryParse(trimmed);
    }
    return null;
  }

  static double _readRequiredDouble(Map<String, dynamic> json, String key) {
    return _readOptionalDouble(json, key) ?? 0.0;
  }
}
