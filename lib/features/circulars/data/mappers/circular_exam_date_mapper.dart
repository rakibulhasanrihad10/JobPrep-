import 'package:job_prep/features/circulars/data/mappers/circular_json_helpers.dart';
import 'package:job_prep/features/circulars/domain/entities/circular_exam_date.dart';

/// Maps between PostgreSQL `public.circular_exam_dates` JSON and
/// [CircularExamDate].
abstract final class CircularExamDateMapper {
  /// Deserializes a single `circular_exam_dates` JSON row.
  static CircularExamDate fromJson(Map<String, dynamic> json) {
    return CircularExamDate(
      id: CircularJsonHelpers.readRequiredString(json, 'id'),
      circularId: CircularJsonHelpers.readRequiredString(json, 'circular_id'),
      userId: CircularJsonHelpers.readRequiredString(json, 'user_id'),
      stage: CircularJsonHelpers.readRequiredString(json, 'stage'),
      examDate: CircularJsonHelpers.readRequiredDateTime(json, 'exam_date'),
      venue: CircularJsonHelpers.readOptionalString(json, 'venue'),
      notes: CircularJsonHelpers.readOptionalString(json, 'notes'),
      createdAt: CircularJsonHelpers.readOptionalDateTime(json, 'created_at'),
      updatedAt: CircularJsonHelpers.readOptionalDateTime(json, 'updated_at'),
    );
  }

  /// Deserializes a list of nested `circular_exam_dates` rows sorted by date.
  static List<CircularExamDate> fromJsonList(List<Map<String, dynamic>> rows) {
    if (rows.isEmpty) return const [];
    final mapped = rows.map(fromJson).toList()
      ..sort((a, b) => a.examDate.compareTo(b.examDate));
    return List.unmodifiable(mapped);
  }

  /// Serializes all fields of [examDate] into a JSON map.
  static Map<String, dynamic> toJson(CircularExamDate examDate) {
    return <String, dynamic>{
      'id': examDate.id,
      'circular_id': examDate.circularId,
      'user_id': examDate.userId,
      'stage': examDate.stage,
      'exam_date': examDate.examDate.toUtc().toIso8601String(),
      'venue': examDate.venue,
      'notes': examDate.notes,
      'created_at': examDate.createdAt?.toUtc().toIso8601String(),
      'updated_at': examDate.updatedAt?.toUtc().toIso8601String(),
    };
  }

  /// Serializes mutable fields for `INSERT` into `public.circular_exam_dates`.
  static Map<String, dynamic> toInsertJson(
    CircularExamDate examDate, {
    String? userId,
  }) {
    final resolvedUserId = (userId ?? examDate.userId).trim();
    return <String, dynamic>{
      if (examDate.id.trim().isNotEmpty) 'id': examDate.id.trim(),
      'circular_id': examDate.circularId.trim(),
      if (resolvedUserId.isNotEmpty) 'user_id': resolvedUserId,
      'stage': examDate.stage.trim(),
      'exam_date': examDate.examDate.toUtc().toIso8601String(),
      'venue': examDate.venue,
      'notes': examDate.notes,
    };
  }

  /// Serializes mutable fields for `UPDATE` on `public.circular_exam_dates`.
  static Map<String, dynamic> toUpdateJson(CircularExamDate examDate) {
    return <String, dynamic>{
      'stage': examDate.stage.trim(),
      'exam_date': examDate.examDate.toUtc().toIso8601String(),
      'venue': examDate.venue,
      'notes': examDate.notes,
    };
  }
}
