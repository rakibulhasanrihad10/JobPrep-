import 'package:job_prep/features/prep/data/mappers/prep_json_helpers.dart';
import 'package:job_prep/features/prep/domain/entities/prep_enums.dart';
import 'package:job_prep/features/prep/domain/entities/prep_material.dart';

/// Maps between PostgreSQL `public.materials` JSON rows and [PrepMaterial].
abstract final class PrepMaterialMapper {
  /// Deserializes a single `materials` JSON row.
  static PrepMaterial fromJson(Map<String, dynamic> json) {
    return PrepMaterial(
      id: PrepJsonHelpers.readRequiredString(json, 'id'),
      userId: PrepJsonHelpers.readRequiredString(json, 'user_id'),
      subjectId: PrepJsonHelpers.readRequiredString(json, 'subject_id'),
      title: PrepJsonHelpers.readRequiredString(json, 'title'),
      kind: MaterialKind.fromValue(
        PrepJsonHelpers.readOptionalString(json, 'kind'),
      ),
      unitLabel: PrepJsonHelpers.readOptionalString(
            json,
            'unit_label',
            trimEmptyToNull: true,
          ) ??
          'pages',
      totalUnits: PrepJsonHelpers.readRequiredInt(json, 'total_units'),
      completedUnits: PrepJsonHelpers.readRequiredInt(json, 'completed_units'),
      coverImagePath: PrepJsonHelpers.readOptionalString(
        json,
        'cover_image_path',
        trimEmptyToNull: true,
      ),
      coverImageUrl: PrepJsonHelpers.readOptionalString(
        json,
        'cover_image_url',
        trimEmptyToNull: true,
      ),
      createdAt: PrepJsonHelpers.readOptionalDateTime(json, 'created_at'),
      updatedAt: PrepJsonHelpers.readOptionalDateTime(json, 'updated_at'),
    );
  }

  /// Deserializes a list of `materials` JSON rows.
  static List<PrepMaterial> fromJsonList(List<Map<String, dynamic>> rows) {
    if (rows.isEmpty) return const [];
    return List<PrepMaterial>.unmodifiable(rows.map(fromJson));
  }

  /// Serializes all fields of [material] into a JSON map.
  static Map<String, dynamic> toJson(PrepMaterial material) {
    return <String, dynamic>{
      'id': material.id,
      'user_id': material.userId,
      'subject_id': material.subjectId,
      'title': material.title,
      'kind': material.kind.value,
      'unit_label': material.unitLabel,
      'total_units': material.totalUnits,
      'completed_units': material.completedUnits,
      'cover_image_path': material.coverImagePath,
      'cover_image_url': material.coverImageUrl,
      'created_at': material.createdAt?.toUtc().toIso8601String(),
      'updated_at': material.updatedAt?.toUtc().toIso8601String(),
    };
  }

  /// Serializes fields for `INSERT` into `public.materials`.
  static Map<String, dynamic> toInsertJson(
    PrepMaterial material, {
    String? userId,
  }) {
    final resolvedUserId = (userId ?? material.userId).trim();
    final safeTotal = material.totalUnits < 0 ? 0 : material.totalUnits;
    final safeCompleted = material.completedUnits < 0
        ? 0
        : (material.completedUnits > safeTotal
            ? safeTotal
            : material.completedUnits);

    return <String, dynamic>{
      if (material.id.trim().isNotEmpty) 'id': material.id.trim(),
      if (resolvedUserId.isNotEmpty) 'user_id': resolvedUserId,
      'subject_id': material.subjectId.trim(),
      'title': material.title.trim(),
      'kind': material.kind.value,
      'unit_label': material.unitLabel.trim().isEmpty
          ? 'pages'
          : material.unitLabel.trim(),
      'total_units': safeTotal,
      'completed_units': safeCompleted,
      'cover_image_path': material.coverImagePath,
      'cover_image_url': material.coverImageUrl,
    };
  }

  /// Serializes mutable fields for `UPDATE` on `public.materials`.
  static Map<String, dynamic> toUpdateJson(PrepMaterial material) {
    final safeTotal = material.totalUnits < 0 ? 0 : material.totalUnits;
    return <String, dynamic>{
      'title': material.title.trim(),
      'kind': material.kind.value,
      'unit_label': material.unitLabel.trim().isEmpty
          ? 'pages'
          : material.unitLabel.trim(),
      'total_units': safeTotal,
      'cover_image_path': material.coverImagePath,
      'cover_image_url': material.coverImageUrl,
    };
  }
}
