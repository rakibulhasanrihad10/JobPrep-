import 'package:job_prep/features/prep/data/mappers/prep_json_helpers.dart';
import 'package:job_prep/features/prep/data/mappers/prep_template_item_mapper.dart';
import 'package:job_prep/features/prep/domain/entities/prep_template.dart';
import 'package:job_prep/features/prep/domain/entities/prep_template_item.dart';

/// Maps between PostgreSQL `public.prep_templates` JSON rows (optionally with
/// embedded `prep_template_items`) and [PrepTemplate].
abstract final class PrepTemplateMapper {
  /// Deserializes a single `prep_templates` JSON row.
  static PrepTemplate fromJson(
    Map<String, dynamic> json, {
    List<PrepTemplateItem>? explicitItems,
  }) {
    final rawItems = json['prep_template_items'];
    final items = explicitItems ??
        (rawItems is List<dynamic>
            ? PrepTemplateItemMapper.fromJsonList(rawItems)
            : const <PrepTemplateItem>[]);
    final sortOrder = PrepJsonHelpers.readRequiredInt(json, 'sort_order');

    return PrepTemplate(
      id: PrepJsonHelpers.readRequiredString(json, 'id'),
      userId: PrepJsonHelpers.readOptionalString(
        json,
        'user_id',
        trimEmptyToNull: true,
      ),
      slug: PrepJsonHelpers.readOptionalString(
        json,
        'slug',
        trimEmptyToNull: true,
      ),
      title: PrepJsonHelpers.readRequiredString(json, 'title'),
      description: PrepJsonHelpers.readOptionalString(
        json,
        'description',
        trimEmptyToNull: true,
      ),
      examType: PrepJsonHelpers.readOptionalString(
            json,
            'exam_type',
            trimEmptyToNull: true,
          ) ??
          'general',
      isSystem: _readBool(json, 'is_system'),
      sortOrder: sortOrder < 0 ? 0 : sortOrder,
      items: items,
      createdAt: PrepJsonHelpers.readOptionalDateTime(json, 'created_at'),
      updatedAt: PrepJsonHelpers.readOptionalDateTime(json, 'updated_at'),
    );
  }

  /// Deserializes a list of `prep_templates` JSON rows.
  static List<PrepTemplate> fromJsonList(List<Map<String, dynamic>> rows) {
    if (rows.isEmpty) return const [];
    return List<PrepTemplate>.unmodifiable(rows.map(fromJson));
  }

  /// Serializes fields for `INSERT` into `public.prep_templates` when saving a
  /// user-owned personal template (`is_system = false`).
  static Map<String, dynamic> toInsertJson(
    PrepTemplate template, {
    String? userId,
  }) {
    final resolvedUserId = (userId ?? template.userId)?.trim();
    final trimmedDesc = template.description?.trim();

    return <String, dynamic>{
      if (template.id.trim().isNotEmpty) 'id': template.id.trim(),
      if (resolvedUserId != null && resolvedUserId.isNotEmpty)
        'user_id': resolvedUserId,
      'title': template.title.trim(),
      if (trimmedDesc != null && trimmedDesc.isNotEmpty)
        'description': trimmedDesc,
      'exam_type': template.examType.trim().isEmpty
          ? 'general'
          : template.examType.trim(),
      'is_system': false,
      'sort_order': template.sortOrder < 0 ? 0 : template.sortOrder,
    };
  }

  static bool _readBool(Map<String, dynamic> json, String key) {
    final value = json[key];
    if (value is bool) return value;
    if (value is String) return value.trim().toLowerCase() == 'true';
    return false;
  }
}
