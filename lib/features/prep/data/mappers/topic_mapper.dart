import 'package:job_prep/features/prep/data/mappers/prep_json_helpers.dart';
import 'package:job_prep/features/prep/domain/entities/prep_enums.dart';
import 'package:job_prep/features/prep/domain/entities/topic.dart';

/// Maps between PostgreSQL `public.topics` JSON rows and [Topic].
abstract final class TopicMapper {
  /// Deserializes a single `topics` JSON row.
  static Topic fromJson(Map<String, dynamic> json) {
    final title = PrepJsonHelpers.readOptionalString(
          json,
          'title',
          trimEmptyToNull: true,
        ) ??
        PrepJsonHelpers.readOptionalString(
          json,
          'name',
          trimEmptyToNull: true,
        ) ??
        '';

    return Topic(
      id: PrepJsonHelpers.readRequiredString(json, 'id'),
      userId: PrepJsonHelpers.readRequiredString(json, 'user_id'),
      subjectId: PrepJsonHelpers.readRequiredString(json, 'subject_id'),
      chapterId: PrepJsonHelpers.readOptionalString(
        json,
        'chapter_id',
        trimEmptyToNull: true,
      ),
      title: title,
      sortOrder: PrepJsonHelpers.readOptionalInt(json, 'sort_order') ?? 0,
      weight: PrepJsonHelpers.readOptionalInt(json, 'weight') ?? 1,
      studyDoneAt: PrepJsonHelpers.readOptionalDateTime(json, 'study_done_at'),
      practiceDoneAt:
          PrepJsonHelpers.readOptionalDateTime(json, 'practice_done_at'),
      modelTestDoneAt:
          PrepJsonHelpers.readOptionalDateTime(json, 'model_test_done_at'),
      revisionDoneAt:
          PrepJsonHelpers.readOptionalDateTime(json, 'revision_done_at'),
      notes: PrepJsonHelpers.readOptionalString(
        json,
        'notes',
        trimEmptyToNull: true,
      ),
      status: TopicStatus.fromValue(
        PrepJsonHelpers.readOptionalString(json, 'status'),
      ),
      createdAt: PrepJsonHelpers.readOptionalDateTime(json, 'created_at'),
      updatedAt: PrepJsonHelpers.readOptionalDateTime(json, 'updated_at'),
    );
  }

  /// Deserializes a list of `topics` JSON rows.
  static List<Topic> fromJsonList(List<Map<String, dynamic>> rows) {
    if (rows.isEmpty) return const [];
    return List<Topic>.unmodifiable(rows.map(fromJson));
  }

  /// Serializes all fields of [topic] into a JSON map.
  static Map<String, dynamic> toJson(Topic topic) {
    return <String, dynamic>{
      'id': topic.id,
      'user_id': topic.userId,
      'subject_id': topic.subjectId,
      'chapter_id': topic.chapterId,
      'title': topic.title,
      'name': topic.name,
      'sort_order': topic.sortOrder,
      'weight': topic.weight,
      'study_done_at': topic.studyDoneAt?.toUtc().toIso8601String(),
      'practice_done_at': topic.practiceDoneAt?.toUtc().toIso8601String(),
      'model_test_done_at': topic.modelTestDoneAt?.toUtc().toIso8601String(),
      'revision_done_at': topic.revisionDoneAt?.toUtc().toIso8601String(),
      'notes': topic.notes,
      'status': topic.status.value,
      'created_at': topic.createdAt?.toUtc().toIso8601String(),
      'updated_at': topic.updatedAt?.toUtc().toIso8601String(),
    };
  }

  /// Serializes fields for `INSERT` into `public.topics`.
  static Map<String, dynamic> toInsertJson(Topic topic, {String? userId}) {
    final resolvedUserId = (userId ?? topic.userId).trim();
    return <String, dynamic>{
      if (topic.id.trim().isNotEmpty) 'id': topic.id.trim(),
      if (resolvedUserId.isNotEmpty) 'user_id': resolvedUserId,
      'subject_id': topic.subjectId.trim(),
      if (topic.chapterId != null && topic.chapterId!.trim().isNotEmpty)
        'chapter_id': topic.chapterId!.trim(),
      'title': topic.title.trim(),
      'name': topic.title.trim(),
      'sort_order': topic.sortOrder < 0 ? 0 : topic.sortOrder,
      'weight': topic.weight < 0 ? 0 : topic.weight,
      'study_done_at': topic.studyDoneAt?.toUtc().toIso8601String(),
      'practice_done_at': topic.practiceDoneAt?.toUtc().toIso8601String(),
      'model_test_done_at': topic.modelTestDoneAt?.toUtc().toIso8601String(),
      'revision_done_at': topic.revisionDoneAt?.toUtc().toIso8601String(),
      if (topic.notes != null) 'notes': topic.notes,
      'status': topic.status.value,
    };
  }

  /// Serializes mutable fields for `UPDATE` on `public.topics`.
  static Map<String, dynamic> toUpdateJson(Topic topic) {
    return <String, dynamic>{
      'chapter_id': topic.chapterId?.trim().isEmpty ?? true
          ? null
          : topic.chapterId!.trim(),
      'title': topic.title.trim(),
      'name': topic.title.trim(),
      'sort_order': topic.sortOrder < 0 ? 0 : topic.sortOrder,
      'weight': topic.weight < 0 ? 0 : topic.weight,
      'study_done_at': topic.studyDoneAt?.toUtc().toIso8601String(),
      'practice_done_at': topic.practiceDoneAt?.toUtc().toIso8601String(),
      'model_test_done_at': topic.modelTestDoneAt?.toUtc().toIso8601String(),
      'revision_done_at': topic.revisionDoneAt?.toUtc().toIso8601String(),
      'notes': topic.notes,
      'status': topic.status.value,
    };
  }
}
