import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show FutureProviderFamily;
import 'package:job_prep/core/supabase/supabase_provider.dart';
import 'package:job_prep/features/auth/presentation/providers/auth_providers.dart';
import 'package:job_prep/features/circulars/data/repositories/supabase_circular_file_repository.dart';
import 'package:job_prep/features/circulars/data/repositories/unconfigured_circular_file_repository.dart';
import 'package:job_prep/features/circulars/domain/entities/circular_file.dart';
import 'package:job_prep/features/circulars/domain/repositories/circular_file_repository.dart';
import 'package:job_prep/features/circulars/domain/utils/circular_file_validator.dart';
import 'package:job_prep/features/circulars/presentation/utils/circular_image_resizer.dart';

Duration? _noRetry(int retryCount, Object error) => null;

/// Lightweight abstraction over a file picked from the platform picker so tests
/// can inject files cleanly without platform channels.
@immutable
class PickedCircularFile {
  /// Creates a [PickedCircularFile].
  const PickedCircularFile({
    required this.name,
    required this.readBytes,
    this.sizeBytes,
  });

  /// Convenience factory wrapping an in-memory [bytes] buffer.
  factory PickedCircularFile.fromBytes({
    required String name,
    required Uint8List bytes,
    int? sizeBytes,
  }) {
    return PickedCircularFile(
      name: name,
      sizeBytes: sizeBytes ?? bytes.length,
      readBytes: () => Future<Uint8List>.value(bytes),
    );
  }

  /// File name including extension (e.g. `circular.pdf`).
  final String name;

  /// Optional pre-read byte count reported by the platform picker.
  final int? sizeBytes;

  /// Reads raw bytes for validation, image resizing, and upload.
  final Future<Uint8List> Function() readBytes;
}

/// Callback signature for picking a single circular attachment file.
typedef CircularFilePickerFn = Future<PickedCircularFile?> Function();

/// Optional override builder for rendering an image preview from a signed URL.
typedef CircularPreviewImageBuilder = Widget Function(
  BuildContext context,
  Uri signedUri,
);

/// Dependency-injected [CircularFileRepository] provider.
///
/// Override this provider in tests with an in-memory fake repository.
final Provider<CircularFileRepository> circularFileRepositoryProvider =
    Provider<CircularFileRepository>((ref) {
  final client = ref.watch(optionalSupabaseClientProvider);
  if (client == null) {
    return const UnconfiguredCircularFileRepository();
  }
  return SupabaseCircularFileRepository(client);
});

/// Fetches attached files for `circularId`, ordered most recent first.
final FutureProviderFamily<List<CircularFile>, String> circularFilesProvider =
    FutureProvider.family<List<CircularFile>, String>(
  (ref, circularId) {
    ref.watch(currentUserProvider.select((user) => user?.id));
    if (circularId.trim().isEmpty) {
      return Future<List<CircularFile>>.value(const []);
    }
    return ref.watch(circularFileRepositoryProvider).getFilesForCircular(
          circularId,
        );
  },
  retry: _noRetry,
);

/// Dependency-injected file picker callback wrapping `file_picker`.
final Provider<CircularFilePickerFn> circularFilePickerProvider =
    Provider<CircularFilePickerFn>((ref) {
  return () async {
    final picked = await FilePicker.pickFile(
      type: FileType.custom,
      allowedExtensions: CircularFileValidator.allowedExtensions,
    );
    if (picked == null) return null;
    final size = picked.lengthSync() ?? await picked.length();
    return PickedCircularFile(
      name: picked.name,
      sizeBytes: size,
      readBytes: picked.readAsBytes,
    );
  };
});

/// Dependency-injected client-side image resizer callback.
final Provider<CircularImageResizerFn> circularImageResizerProvider =
    Provider<CircularImageResizerFn>((ref) {
  return CircularImageResizer.resizeIfNeeded;
});

/// Optional test hook overriding inline network image rendering inside the
/// preview dialog while preserving the resolved signed [Uri].
final Provider<CircularPreviewImageBuilder?>
    circularPreviewImageBuilderProvider =
    Provider<CircularPreviewImageBuilder?>((ref) => null);
