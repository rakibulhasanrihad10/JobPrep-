import 'dart:typed_data';

import 'package:job_prep/features/circulars/domain/entities/circular_file.dart';

/// Contract for private file storage (`circular-files`) paired with
/// `public.circular_files` metadata persistence.
abstract interface class CircularFileRepository {
  /// Fetches all attachments recorded for [circularId].
  Future<List<CircularFile>> getFilesForCircular(String circularId);

  /// Uploads binary [bytes] to private user-scoped storage and inserts the
  /// corresponding row into `public.circular_files`.
  ///
  /// Progress values between `0.0` and `1.0` are delivered via [onProgress].
  Future<CircularFile> uploadFile({
    required String circularId,
    required String fileName,
    required String mimeType,
    required Uint8List bytes,
    void Function(double progress)? onProgress,
  });

  /// Generates a time-limited signed URL for previewing or downloading [file].
  ///
  /// Never exposes or returns unauthenticated public links.
  Future<Uri> createSignedUrl(
    CircularFile file, {
    Duration expiresIn = const Duration(minutes: 10),
    bool download = false,
  });

  /// Deletes both the `public.circular_files` record and underlying private
  /// Storage object.
  Future<void> deleteFile(CircularFile file);
}
