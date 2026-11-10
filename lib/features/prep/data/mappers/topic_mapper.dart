import 'package:job_prep/features/prep/data/mappers/prep_json_helpers.dart';
import 'package:job_prep/features/prep/domain/entities/prep_enums.dart';
import 'package:job_prep/features/prep/domain/entities/topic.dart';

/// Maps between PostgreSQL `public.topics` JSON rows and [Topic].
abstract final class TopicMapper {
  /// Deserializes a single `topics` JSON row.
  static Topic fromJson(Map<String, dynamic> json) {
    return Topic(
      id: PrepJsonHelpers.readRequiredString(json, 'id'),
      userId: PrepJsonHelpers.readRequiredString(json, 'user_id'),
      subjectId: PrepJsonHelpers.readRequiredString(json, 'subject_id'),
      name: PrepJsonHelpers.readRequiredString(json, 'name'),
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
      'name': topic.name,
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
      'name': topic.name.trim(),
      'status': topic.status.value,
    };
  }

  /// Serializes mutable fields for `UPDATE` on `public.topics`.
  static Map<String, dynamic> toUpdateJson(Topic topic) {
    return <String, dynamic>{
      'name': topic.name.trim(),
      'status': topic.status.value,
    };
  }
}
