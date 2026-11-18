import 'package:job_prep/features/prep/data/mappers/prep_json_helpers.dart';
import 'package:job_prep/features/prep/domain/entities/material_chapter.dart';

/// Maps between PostgreSQL `public.material_chapters` rows and
/// [MaterialChapter].
abstract final class MaterialChapterMapper {
  static MaterialChapter fromJson(Map<String, dynamic> json) {
    return MaterialChapter(
      id: PrepJsonHelpers.readRequiredString(json, 'id'),
      userId: PrepJsonHelpers.readRequiredString(json, 'user_id'),
      materialId: PrepJsonHelpers.readRequiredString(json, 'material_id'),
      chapterId: PrepJsonHelpers.readRequiredString(json, 'chapter_id'),
      createdAt: PrepJsonHelpers.readOptionalDateTime(json, 'created_at'),
    );
  }

  static List<MaterialChapter> fromJsonList(List<dynamic> rows) {
    return rows
        .whereType<Map<String, dynamic>>()
        .map(fromJson)
        .toList(growable: false);
  }

  static Map<String, dynamic> toInsertJson(
    MaterialChapter link, {
    String? userId,
  }) {
    final resolvedUser =
        userId?.trim().isNotEmpty == true ? userId!.trim() : link.userId.trim();
    return <String, dynamic>{
      if (link.id.trim().isNotEmpty) 'id': link.id.trim(),
      if (resolvedUser.isNotEmpty) 'user_id': resolvedUser,
      'material_id': link.materialId.trim(),
      'chapter_id': link.chapterId.trim(),
    };
  }
}
