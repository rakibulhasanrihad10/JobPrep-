import 'dart:async' show unawaited;
import 'dart:typed_data';

import 'package:job_prep/features/circulars/data/mappers/circular_error_mapper.dart';
import 'package:job_prep/features/circulars/data/mappers/circular_file_mapper.dart';
import 'package:job_prep/features/circulars/domain/entities/circular_file.dart';
import 'package:job_prep/features/circulars/domain/errors/circular_failure.dart';
import 'package:job_prep/features/circulars/domain/repositories/circular_file_repository.dart';
import 'package:job_prep/features/circulars/domain/utils/circular_file_validator.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supabase;

/// Supabase Storage + PostgREST implementation of [CircularFileRepository].
///
/// Stores objects in the private `circular-files` bucket under
/// `<user_id>/<circular_id>/...` and accesses them solely via signed URLs.
class SupabaseCircularFileRepository implements CircularFileRepository {
  /// Creates a [SupabaseCircularFileRepository].
  const SupabaseCircularFileRepository(this._client);

  /// Name of the private Supabase Storage bucket storing circular files.
  static const String bucketName = 'circular-files';

  static const String _table = 'circular_files';

  final supabase.SupabaseClient _client;

  @override
  Future<List<CircularFile>> getFilesForCircular(String circularId) async {
    final trimmedId = circularId.trim();
    if (trimmedId.isEmpty) {
      return const [];
    }

    try {
      final rows = await _client
          .from(_table)
          .select()
          .eq('circular_id', trimmedId)
          .order('created_at', ascending: false);
      return CircularFileMapper.fromJsonList(rows);
    } on Object catch (error) {
      throw CircularErrorMapper.map(error);
    }
  }

  @override
  Future<CircularFile> uploadFile({
    required String circularId,
    required String fileName,
    required String mimeType,
    required Uint8List bytes,
    void Function(double progress)? onProgress,
  }) async {
    final trimmedCircularId = circularId.trim();
    if (trimmedCircularId.isEmpty) {
      throw const CircularValidationFailure(
        code: 'missing_circular_id',
        message: 'Attachment requires a parent circular id.',
      );
    }

    final validationError = CircularFileValidator.validateFile(
      fileName: fileName,
      sizeBytes: bytes.length,
    );
    if (validationError != null) {
      throw CircularValidationFailure(
        code: validationError.name,
        message: 'Attachment failed validation (${validationError.name}).',
      );
    }

    final userId = _client.auth.currentUser?.id.trim() ?? '';
    if (userId.isEmpty) {
      throw const CircularPermissionFailure(
        code: 'not_authenticated',
        message: 'Sign in required before uploading attachments.',
      );
    }

    final storagePath = CircularFileValidator.buildStoragePath(
      userId: userId,
      circularId: trimmedCircularId,
      fileName: fileName,
    );

    var uploadedToStorage = false;
    try {
      onProgress?.call(0.15);
      await _client.storage.from(bucketName).uploadBinary(
            storagePath,
            bytes,
            fileOptions: supabase.FileOptions(
              contentType: mimeType.trim(),
            ),
          );
      uploadedToStorage = true;
      onProgress?.call(0.75);

      final payload = CircularFileMapper.toInsertJson(
        CircularFile(
          circularId: trimmedCircularId,
          userId: userId,
          storagePath: storagePath,
          fileName: CircularFileValidator.sanitizeFileName(fileName),
          mimeType: mimeType.trim(),
          sizeBytes: bytes.length,
        ),
        userId: userId,
      );

      final row = await _client.from(_table).insert(payload).select().single();
      onProgress?.call(1);
      return CircularFileMapper.fromJson(row);
    } on Object catch (error) {
      if (uploadedToStorage) {
        // Best-effort cleanup so failed DB inserts never leave orphaned blobs.
        unawaited(
          _client.storage
              .from(bucketName)
              .remove([storagePath]).catchError((_) => <supabase.FileObject>[]),
        );
      }
      throw CircularErrorMapper.map(error);
    }
  }

  @override
  Future<Uri> createSignedUrl(
    CircularFile file, {
    Duration expiresIn = const Duration(minutes: 10),
    bool download = false,
  }) async {
    final path = file.storagePath.trim();
    if (path.isEmpty) {
      throw const CircularNotFoundFailure(
        code: 'missing_storage_path',
        message: 'Attachment has no storage path.',
      );
    }

    try {
      final rawUrl = await _client.storage.from(bucketName).createSignedUrl(
            path,
            expiresIn.inSeconds,
            download: download
                ? supabase.DownloadBehavior.named(file.fileName)
                : null,
          );
      return Uri.parse(rawUrl);
    } on Object catch (error) {
      throw CircularErrorMapper.map(error);
    }
  }

  @override
  Future<void> deleteFile(CircularFile file) async {
    final trimmedId = file.id.trim();
    if (trimmedId.isEmpty) {
      throw const CircularValidationFailure(
        code: 'missing_file_id',
        message: 'Cannot delete an attachment without an id.',
      );
    }

    try {
      await _client.from(_table).delete().eq('id', trimmedId);
      final path = file.storagePath.trim();
      if (path.isNotEmpty) {
        await _client.storage.from(bucketName).remove([path]);
      }
    } on Object catch (error) {
      throw CircularErrorMapper.map(error);
    }
  }
}
