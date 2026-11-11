import 'package:job_prep/features/prep/data/mappers/prep_json_helpers.dart';
import 'package:job_prep/features/prep/domain/entities/prep_enums.dart';
import 'package:job_prep/features/prep/domain/entities/progress_log.dart';

/// Maps between PostgreSQL `public.progress_logs` JSON rows and [ProgressLog].
abstract final class ProgressLogMapper {
  /// Deserializes a single `progress_logs` JSON row.
  static ProgressLog fromJson(Map<String, dynamic> json) {
    return ProgressLog(
      id: PrepJsonHelpers.readRequiredString(json, 'id'),
      userId: PrepJsonHelpers.readRequiredString(json, 'user_id'),
      materialId: PrepJsonHelpers.readRequiredString(json, 'material_id'),
      unitsDone: PrepJsonHelpers.readRequiredInt(json, 'units_done'),
      entryType: ProgressLogEntryType.fromValue(
        PrepJsonHelpers.readOptionalString(json, 'entry_type'),
      ),
      loggedOn: PrepJsonHelpers.readRequiredDateOnly(json, 'logged_on'),
      note: PrepJsonHelpers.readOptionalString(json, 'note'),
      createdAt: PrepJsonHelpers.readOptionalDateTime(json, 'created_at'),
      updatedAt: PrepJsonHelpers.readOptionalDateTime(json, 'updated_at'),
    );
  }

  /// Deserializes a list of `progress_logs` JSON rows.
  static List<ProgressLog> fromJsonList(List<Map<String, dynamic>> rows) {
    if (rows.isEmpty) return const [];
    return List<ProgressLog>.unmodifiable(rows.map(fromJson));
  }

  /// Serializes all fields of [log] into a JSON map.
  static Map<String, dynamic> toJson(ProgressLog log) {
    return <String, dynamic>{
      'id': log.id,
      'user_id': log.userId,
      'material_id': log.materialId,
      'units_done': log.unitsDone,
      'entry_type': log.entryType.value,
      'logged_on': PrepJsonHelpers.formatDateOnly(log.loggedOn),
      'note': log.note,
      'created_at': log.createdAt?.toUtc().toIso8601String(),
      'updated_at': log.updatedAt?.toUtc().toIso8601String(),
    };
  }

  /// Serializes fields for `INSERT` into `public.progress_logs`.
  static Map<String, dynamic> toInsertJson(
    ProgressLog log, {
    String? userId,
  }) {
    final resolvedUserId = (userId ?? log.userId).trim();
    return <String, dynamic>{
      if (log.id.trim().isNotEmpty) 'id': log.id.trim(),
      if (resolvedUserId.isNotEmpty) 'user_id': resolvedUserId,
      'material_id': log.materialId.trim(),
      'units_done': log.unitsDone,
      'entry_type': log.entryType.value,
      'logged_on': PrepJsonHelpers.formatDateOnly(log.loggedOn),
      'note': log.note,
    };
  }

  /// Serializes mutable fields for `UPDATE` on `public.progress_logs`.
  static Map<String, dynamic> toUpdateJson(ProgressLog log) {
    return <String, dynamic>{
      'material_id': log.materialId.trim(),
      'units_done': log.unitsDone,
      'entry_type': log.entryType.value,
      'logged_on': PrepJsonHelpers.formatDateOnly(log.loggedOn),
      'note': log.note,
    };
  }
}
