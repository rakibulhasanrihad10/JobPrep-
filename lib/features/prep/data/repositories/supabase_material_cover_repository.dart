import 'dart:typed_data';

import 'package:job_prep/features/prep/data/mappers/prep_error_mapper.dart';
import 'package:job_prep/features/prep/domain/errors/prep_failure.dart';
import 'package:job_prep/features/prep/domain/repositories/material_cover_repository.dart';
import 'package:job_prep/features/prep/domain/utils/material_cover_validator.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supabase;

/// Supabase Storage implementation of [MaterialCoverRepository].
///
/// Stores objects inside the private `material-covers` bucket under
/// `<user_id>/<folderKey>/...` and reads them solely via signed URLs.
class SupabaseMaterialCoverRepository implements MaterialCoverRepository {
  /// Creates a [SupabaseMaterialCoverRepository].
  const SupabaseMaterialCoverRepository(this._client);

  /// Name of the private Supabase Storage bucket storing material covers.
  static const String bucketName = 'material-covers';

  final supabase.SupabaseClient _client;

  @override
  Future<String> uploadCover({
    required String folderKey,
    required String fileName,
    required String mimeType,
    required Uint8List bytes,
  }) async {
    final trimmedFolder = folderKey.trim();
    if (trimmedFolder.isEmpty) {
      throw const PrepValidationFailure(
        code: 'missing_cover_folder',
        message: 'Cover upload requires a target subject or material key.',
      );
    }

    final validationError = MaterialCoverValidator.validateFile(
      fileName: fileName,
      sizeBytes: bytes.length,
    );
    if (validationError != null) {
      throw PrepValidationFailure(
        code: validationError.name,
        message: 'Cover image failed validation (${validationError.name}).',
      );
    }

    final userId = _client.auth.currentUser?.id.trim() ?? '';
    if (userId.isEmpty) {
      throw const PrepPermissionFailure(
        code: 'not_authenticated',
        message: 'Sign in required before uploading cover images.',
      );
    }

    final storagePath = MaterialCoverValidator.buildStoragePath(
      userId: userId,
      folderKey: trimmedFolder,
      fileName: fileName,
    );

    try {
      await _client.storage.from(bucketName).uploadBinary(
            storagePath,
            bytes,
            fileOptions: supabase.FileOptions(
              contentType: mimeType.trim(),
              upsert: true,
            ),
          );
      return storagePath;
    } on Object catch (error) {
      throw PrepErrorMapper.map(error);
    }
  }

  @override
  Future<Uri> createSignedCoverUrl(
    String storagePath, {
    Duration expiresIn = const Duration(minutes: 30),
  }) async {
    final trimmedPath = storagePath.trim();
    if (trimmedPath.isEmpty) {
      throw const PrepNotFoundFailure(
        code: 'missing_storage_path',
        message: 'Material has no uploaded cover storage path.',
      );
    }

    try {
      final rawUrl = await _client.storage.from(bucketName).createSignedUrl(
            trimmedPath,
            expiresIn.inSeconds,
          );
      return Uri.parse(rawUrl);
    } on Object catch (error) {
      throw PrepErrorMapper.map(error);
    }
  }

  @override
  Future<void> deleteCover(String storagePath) async {
    final trimmedPath = storagePath.trim();
    if (trimmedPath.isEmpty) {
      return;
    }
    try {
      await _client.storage.from(bucketName).remove([trimmedPath]);
    } on Object catch (error) {
      throw PrepErrorMapper.map(error);
    }
  }
}
