import 'package:job_prep/features/circulars/data/mappers/circular_json_helpers.dart';
import 'package:job_prep/features/circulars/domain/entities/circular_file.dart';

/// Maps between PostgreSQL `public.circular_files` JSON and [CircularFile].
abstract final class CircularFileMapper {
  /// Deserializes a single `circular_files` JSON row.
  static CircularFile fromJson(Map<String, dynamic> json) {
    return CircularFile(
      id: CircularJsonHelpers.readRequiredString(json, 'id'),
      circularId: CircularJsonHelpers.readRequiredString(json, 'circular_id'),
      userId: CircularJsonHelpers.readRequiredString(json, 'user_id'),
      storagePath: CircularJsonHelpers.readRequiredString(json, 'storage_path'),
      fileName: CircularJsonHelpers.readRequiredString(json, 'file_name'),
      mimeType: CircularJsonHelpers.readRequiredString(json, 'mime_type'),
      sizeBytes: CircularJsonHelpers.readRequiredInt(json, 'size_bytes'),
      createdAt: CircularJsonHelpers.readOptionalDateTime(json, 'created_at'),
      updatedAt: CircularJsonHelpers.readOptionalDateTime(json, 'updated_at'),
    );
  }

  /// Deserializes a list of nested `circular_files` JSON rows.
  static List<CircularFile> fromJsonList(List<Map<String, dynamic>> rows) {
    if (rows.isEmpty) return const [];
    return List.unmodifiable(rows.map(fromJson));
  }

  /// Serializes all fields of [file] into a JSON map.
  static Map<String, dynamic> toJson(CircularFile file) {
    return <String, dynamic>{
      'id': file.id,
      'circular_id': file.circularId,
      'user_id': file.userId,
      'storage_path': file.storagePath,
      'file_name': file.fileName,
      'mime_type': file.mimeType,
      'size_bytes': file.sizeBytes,
      'created_at': file.createdAt?.toUtc().toIso8601String(),
      'updated_at': file.updatedAt?.toUtc().toIso8601String(),
    };
  }

  /// Serializes fields for `INSERT` into `public.circular_files`.
  static Map<String, dynamic> toInsertJson(
    CircularFile file, {
    String? userId,
  }) {
    final resolvedUserId = (userId ?? file.userId).trim();
    return <String, dynamic>{
      if (file.id.trim().isNotEmpty) 'id': file.id.trim(),
      'circular_id': file.circularId.trim(),
      if (resolvedUserId.isNotEmpty) 'user_id': resolvedUserId,
      'storage_path': file.storagePath.trim(),
      'file_name': file.fileName.trim(),
      'mime_type': file.mimeType.trim(),
      'size_bytes': file.sizeBytes,
    };
  }
}
