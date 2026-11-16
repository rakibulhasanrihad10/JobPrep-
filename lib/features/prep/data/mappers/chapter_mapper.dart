import 'package:job_prep/features/prep/data/mappers/prep_json_helpers.dart';
import 'package:job_prep/features/prep/domain/entities/chapter.dart';

/// Maps between PostgreSQL `public.chapters` JSON rows and [Chapter].
abstract final class ChapterMapper {
  /// Deserializes a single `chapters` JSON row.
  static Chapter fromJson(Map<String, dynamic> json) {
    return Chapter(
      id: PrepJsonHelpers.readRequiredString(json, 'id'),
      userId: PrepJsonHelpers.readRequiredString(json, 'user_id'),
      subjectId: PrepJsonHelpers.readRequiredString(json, 'subject_id'),
      title: PrepJsonHelpers.readRequiredString(json, 'title'),
      sortOrder: PrepJsonHelpers.readOptionalInt(json, 'sort_order') ?? 0,
      createdAt: PrepJsonHelpers.readOptionalDateTime(json, 'created_at'),
      updatedAt: PrepJsonHelpers.readOptionalDateTime(json, 'updated_at'),
    );
  }

  /// Deserializes a list of `chapters` JSON rows.
  static List<Chapter> fromJsonList(List<Map<String, dynamic>> rows) {
    if (rows.isEmpty) return const [];
    return List<Chapter>.unmodifiable(rows.map(fromJson));
  }

  /// Serializes all fields of [chapter] into a JSON map.
  static Map<String, dynamic> toJson(Chapter chapter) {
    return <String, dynamic>{
      'id': chapter.id,
      'user_id': chapter.userId,
      'subject_id': chapter.subjectId,
      'title': chapter.title,
      'sort_order': chapter.sortOrder,
      'created_at': chapter.createdAt?.toUtc().toIso8601String(),
      'updated_at': chapter.updatedAt?.toUtc().toIso8601String(),
    };
  }

  /// Serializes fields for `INSERT` into `public.chapters`.
  static Map<String, dynamic> toInsertJson(Chapter chapter, {String? userId}) {
    final resolvedUserId = (userId ?? chapter.userId).trim();
    return <String, dynamic>{
      if (chapter.id.trim().isNotEmpty) 'id': chapter.id.trim(),
      if (resolvedUserId.isNotEmpty) 'user_id': resolvedUserId,
      'subject_id': chapter.subjectId.trim(),
      'title': chapter.title.trim(),
      'sort_order': chapter.sortOrder < 0 ? 0 : chapter.sortOrder,
    };
  }

  /// Serializes mutable fields for `UPDATE` on `public.chapters`.
  static Map<String, dynamic> toUpdateJson(Chapter chapter) {
    return <String, dynamic>{
      'title': chapter.title.trim(),
      'sort_order': chapter.sortOrder < 0 ? 0 : chapter.sortOrder,
    };
  }
}
