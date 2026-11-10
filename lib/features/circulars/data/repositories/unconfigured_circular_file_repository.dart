import 'dart:typed_data';

import 'package:job_prep/features/circulars/domain/entities/circular_file.dart';
import 'package:job_prep/features/circulars/domain/errors/circular_failure.dart';
import 'package:job_prep/features/circulars/domain/repositories/circular_file_repository.dart';

/// Safe fallback [CircularFileRepository] used when Supabase environment keys
/// have not been configured.
class UnconfiguredCircularFileRepository implements CircularFileRepository {
  /// Creates an [UnconfiguredCircularFileRepository].
  const UnconfiguredCircularFileRepository();

  static const _notConfiguredError = UnknownCircularFailure(
    code: 'supabase_not_configured',
    message: 'Supabase is not configured. Provide SUPABASE_URL and '
        'SUPABASE_ANON_KEY via --dart-define.',
  );

  @override
  Future<List<CircularFile>> getFilesForCircular(String circularId) async =>
      const [];

  @override
  Future<CircularFile> uploadFile({
    required String circularId,
    required String fileName,
    required String mimeType,
    required Uint8List bytes,
    void Function(double progress)? onProgress,
  }) =>
      Future.error(_notConfiguredError);

  @override
  Future<Uri> createSignedUrl(
    CircularFile file, {
    Duration expiresIn = const Duration(minutes: 10),
    bool download = false,
  }) =>
      Future.error(_notConfiguredError);

  @override
  Future<void> deleteFile(CircularFile file) =>
      Future.error(_notConfiguredError);
}
