import 'dart:convert' show jsonDecode;

import 'package:job_prep/features/prep/data/mappers/prep_json_helpers.dart';
import 'package:job_prep/features/prep/domain/entities/prep_enums.dart';
import 'package:job_prep/features/prep/domain/entities/subject.dart';

/// Maps between PostgreSQL `public.subjects` JSON rows and [Subject].
abstract final class SubjectMapper {
  /// Deserializes a single `subjects` JSON row.
  static Subject fromJson(Map<String, dynamic> json) {
    List<String> parseCheckpoints(dynamic raw) {
      if (raw is List) {
        return raw
            .map((e) => e.toString().trim())
            .where((s) => s.isNotEmpty)
            .toList();
      } else if (raw is String && raw.trim().isNotEmpty) {
        try {
          final decoded = jsonDecode(raw);
          if (decoded is List) {
            return decoded
                .map((e) => e.toString().trim())
                .where((s) => s.isNotEmpty)
                .toList();
          }
        } on Object catch (_) {}
      }
      return SyllabusCheckpoint.defaultEnabledValues;
    }

    return Subject(
      id: PrepJsonHelpers.readRequiredString(json, 'id'),
      userId: PrepJsonHelpers.readRequiredString(json, 'user_id'),
      name: PrepJsonHelpers.readRequiredString(json, 'name'),
      color: PrepJsonHelpers.readOptionalString(
            json,
            'color',
            trimEmptyToNull: true,
          ) ??
          'gold',
      icon: PrepJsonHelpers.readOptionalString(
            json,
            'icon',
            trimEmptyToNull: true,
          ) ??
          'menu_book',
      examType: PrepJsonHelpers.readOptionalString(
            json,
            'exam_type',
            trimEmptyToNull: true,
          ) ??
          'general',
      sortOrder: PrepJsonHelpers.readRequiredInt(json, 'sort_order'),
      enabledCheckpoints: parseCheckpoints(json['enabled_checkpoints']),
      createdAt: PrepJsonHelpers.readOptionalDateTime(json, 'created_at'),
      updatedAt: PrepJsonHelpers.readOptionalDateTime(json, 'updated_at'),
    );
  }

  /// Deserializes a list of `subjects` rows preserving sort order.
  static List<Subject> fromJsonList(List<Map<String, dynamic>> rows) {
    if (rows.isEmpty) return const [];
    return List<Subject>.unmodifiable(rows.map(fromJson));
  }

  /// Serializes all fields of [subject] into a JSON map.
  static Map<String, dynamic> toJson(Subject subject) {
    return <String, dynamic>{
      'id': subject.id,
      'user_id': subject.userId,
      'name': subject.name,
      'color': subject.color,
      'icon': subject.icon,
      'exam_type': subject.examType,
      'sort_order': subject.sortOrder,
      'enabled_checkpoints': subject.enabledCheckpoints,
      'created_at': subject.createdAt?.toUtc().toIso8601String(),
      'updated_at': subject.updatedAt?.toUtc().toIso8601String(),
    };
  }

  /// Serializes fields for `INSERT` into `public.subjects`.
  static Map<String, dynamic> toInsertJson(Subject subject, {String? userId}) {
    final resolvedUserId = (userId ?? subject.userId).trim();
    return <String, dynamic>{
      if (subject.id.trim().isNotEmpty) 'id': subject.id.trim(),
      if (resolvedUserId.isNotEmpty) 'user_id': resolvedUserId,
      'name': subject.name.trim(),
      'color': subject.color.trim().isEmpty ? 'gold' : subject.color.trim(),
      'icon': subject.icon.trim().isEmpty ? 'menu_book' : subject.icon.trim(),
      'exam_type':
          subject.examType.trim().isEmpty ? 'general' : subject.examType.trim(),
      'sort_order': subject.sortOrder < 0 ? 0 : subject.sortOrder,
      'enabled_checkpoints': subject.enabledCheckpoints,
    };
  }

  /// Serializes mutable fields for `UPDATE` on `public.subjects`.
  static Map<String, dynamic> toUpdateJson(Subject subject) {
    return <String, dynamic>{
      'name': subject.name.trim(),
      'color': subject.color.trim().isEmpty ? 'gold' : subject.color.trim(),
      'icon': subject.icon.trim().isEmpty ? 'menu_book' : subject.icon.trim(),
      'exam_type':
          subject.examType.trim().isEmpty ? 'general' : subject.examType.trim(),
      'sort_order': subject.sortOrder < 0 ? 0 : subject.sortOrder,
      'enabled_checkpoints': subject.enabledCheckpoints,
    };
  }
}
