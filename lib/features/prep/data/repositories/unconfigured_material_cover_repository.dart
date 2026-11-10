import 'dart:typed_data';

import 'package:job_prep/features/prep/domain/errors/prep_failure.dart';
import 'package:job_prep/features/prep/domain/repositories/material_cover_repository.dart';

/// Fallback [MaterialCoverRepository] used when Supabase is not configured.
class UnconfiguredMaterialCoverRepository implements MaterialCoverRepository {
  /// Creates an [UnconfiguredMaterialCoverRepository].
  const UnconfiguredMaterialCoverRepository();

  @override
  Future<String> uploadCover({
    required String folderKey,
    required String fileName,
    required String mimeType,
    required Uint8List bytes,
  }) async {
    throw const PrepPermissionFailure(
      code: 'supabase_unconfigured',
      message: 'Supabase is not configured for cover uploads.',
    );
  }

  @override
  Future<Uri> createSignedCoverUrl(
    String storagePath, {
    Duration expiresIn = const Duration(minutes: 30),
  }) async {
    throw const PrepNotFoundFailure(
      code: 'supabase_unconfigured',
      message: 'Supabase is not configured for cover image viewing.',
    );
  }

  @override
  Future<void> deleteCover(String storagePath) async {}
}
