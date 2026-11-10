import 'dart:typed_data';

/// Contract for private per-user material cover storage operations.
abstract interface class MaterialCoverRepository {
  /// Uploads resized cover [bytes] into `<user_id>/<folderKey>/...` and returns
  /// the resulting Storage object path.
  Future<String> uploadCover({
    required String folderKey,
    required String fileName,
    required String mimeType,
    required Uint8List bytes,
  });

  /// Creates a short-lived signed URL for viewing a private cover image.
  Future<Uri> createSignedCoverUrl(
    String storagePath, {
    Duration expiresIn = const Duration(minutes: 30),
  });

  /// Removes the cover object at [storagePath] from private storage.
  Future<void> deleteCover(String storagePath);
}
