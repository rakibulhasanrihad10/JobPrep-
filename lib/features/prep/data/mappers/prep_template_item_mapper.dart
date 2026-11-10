import 'package:job_prep/features/prep/data/mappers/prep_json_helpers.dart';
import 'package:job_prep/features/prep/domain/entities/prep_enums.dart';
import 'package:job_prep/features/prep/domain/entities/prep_template_item.dart';

/// Maps between PostgreSQL `public.prep_template_items` JSON rows and
/// [PrepTemplateItem].
abstract final class PrepTemplateItemMapper {
  /// Deserializes a single `prep_template_items` JSON row.
  static PrepTemplateItem fromJson(Map<String, dynamic> json) {
    final totalUnits = PrepJsonHelpers.readRequiredInt(json, 'total_units');
    final subjectSortOrder =
        PrepJsonHelpers.readRequiredInt(json, 'subject_sort_order');
    final itemSortOrder =
        PrepJsonHelpers.readRequiredInt(json, 'item_sort_order');

    return PrepTemplateItem(
      id: PrepJsonHelpers.readRequiredString(json, 'id'),
      templateId: PrepJsonHelpers.readRequiredString(json, 'template_id'),
      userId: PrepJsonHelpers.readOptionalString(
        json,
        'user_id',
        trimEmptyToNull: true,
      ),
      subjectName: PrepJsonHelpers.readRequiredString(json, 'subject_name'),
      subjectColor: PrepJsonHelpers.readOptionalString(
            json,
            'subject_color',
            trimEmptyToNull: true,
          ) ??
          'gold',
      subjectIcon: PrepJsonHelpers.readOptionalString(
            json,
            'subject_icon',
            trimEmptyToNull: true,
          ) ??
          'menu_book',
      examType: PrepJsonHelpers.readOptionalString(
            json,
            'exam_type',
            trimEmptyToNull: true,
          ) ??
          'general',
      subjectSortOrder: subjectSortOrder < 0 ? 0 : subjectSortOrder,
      materialTitle: PrepJsonHelpers.readOptionalString(
        json,
        'material_title',
        trimEmptyToNull: true,
      ),
      materialKind: MaterialKind.fromValue(
        PrepJsonHelpers.readOptionalString(json, 'material_kind'),
      ),
      unitLabel: PrepJsonHelpers.readOptionalString(
            json,
            'unit_label',
            trimEmptyToNull: true,
          ) ??
          'pages',
      totalUnits: totalUnits < 0 ? 0 : totalUnits,
      itemSortOrder: itemSortOrder < 0 ? 0 : itemSortOrder,
      createdAt: PrepJsonHelpers.readOptionalDateTime(json, 'created_at'),
      updatedAt: PrepJsonHelpers.readOptionalDateTime(json, 'updated_at'),
    );
  }

  /// Deserializes and sorts a list of `prep_template_items` rows.
  static List<PrepTemplateItem> fromJsonList(List<dynamic> rows) {
    if (rows.isEmpty) return const [];
    final parsed = rows
        .whereType<Map<String, dynamic>>()
        .map(fromJson)
        .toList(growable: false)
      ..sort((a, b) {
        final bySubject = a.subjectSortOrder.compareTo(b.subjectSortOrder);
        if (bySubject != 0) return bySubject;
        return a.itemSortOrder.compareTo(b.itemSortOrder);
      });
    return List<PrepTemplateItem>.unmodifiable(parsed);
  }

  /// Serializes [item] for `INSERT` into `public.prep_template_items`.
  static Map<String, dynamic> toInsertJson(
    PrepTemplateItem item, {
    required String templateId,
    String? userId,
  }) {
    final resolvedUserId = (userId ?? item.userId)?.trim();
    final trimmedMaterial = item.materialTitle?.trim();

    return <String, dynamic>{
      if (item.id.trim().isNotEmpty) 'id': item.id.trim(),
      'template_id': templateId.trim(),
      if (resolvedUserId != null && resolvedUserId.isNotEmpty)
        'user_id': resolvedUserId,
      'subject_name': item.subjectName.trim(),
      'subject_color':
          item.subjectColor.trim().isEmpty ? 'gold' : item.subjectColor.trim(),
      'subject_icon': item.subjectIcon.trim().isEmpty
          ? 'menu_book'
          : item.subjectIcon.trim(),
      'exam_type':
          item.examType.trim().isEmpty ? 'general' : item.examType.trim(),
      'subject_sort_order':
          item.subjectSortOrder < 0 ? 0 : item.subjectSortOrder,
      'material_title': (trimmedMaterial != null && trimmedMaterial.isNotEmpty)
          ? trimmedMaterial
          : null,
      'material_kind': item.materialKind.value,
      'unit_label':
          item.unitLabel.trim().isEmpty ? 'pages' : item.unitLabel.trim(),
      'total_units': item.totalUnits < 0 ? 0 : item.totalUnits,
      'item_sort_order': item.itemSortOrder < 0 ? 0 : item.itemSortOrder,
    };
  }
}
