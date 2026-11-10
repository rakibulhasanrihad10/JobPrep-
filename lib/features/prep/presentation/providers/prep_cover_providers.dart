import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show FutureProviderFamily;
import 'package:job_prep/core/supabase/supabase_provider.dart';
import 'package:job_prep/features/auth/presentation/providers/auth_providers.dart';
import 'package:job_prep/features/prep/data/repositories/supabase_material_cover_repository.dart';
import 'package:job_prep/features/prep/data/repositories/unconfigured_material_cover_repository.dart';
import 'package:job_prep/features/prep/domain/repositories/material_cover_repository.dart';
import 'package:job_prep/features/prep/domain/utils/material_cover_validator.dart';
import 'package:job_prep/features/prep/presentation/utils/material_cover_resizer.dart';

Duration? _noRetry(int retryCount, Object error) => null;

/// Lightweight abstraction over a picked cover photo so tests can inject
/// images without platform channels.
@immutable
class PickedMaterialCover {
  /// Creates a [PickedMaterialCover].
  const PickedMaterialCover({
    required this.name,
    required this.readBytes,
    this.sizeBytes,
  });

  /// Convenience factory wrapping an in-memory [bytes] buffer.
  factory PickedMaterialCover.fromBytes({
    required String name,
    required Uint8List bytes,
    int? sizeBytes,
  }) {
    return PickedMaterialCover(
      name: name,
      sizeBytes: sizeBytes ?? bytes.length,
      readBytes: () => Future<Uint8List>.value(bytes),
    );
  }

  /// Original file name including extension (e.g. `cover.jpg`).
  final String name;

  /// Optional byte size reported by the platform picker.
  final int? sizeBytes;

  /// Reads raw bytes for validation and 600 px resizing.
  final Future<Uint8List> Function() readBytes;
}

/// Callback signature for picking a single material cover photo.
typedef MaterialCoverPickerFn = Future<PickedMaterialCover?> Function();

/// Optional override builder for rendering cover thumbnails from network or
/// signed [Uri]s without making live HTTP calls inside widget tests.
typedef MaterialCoverPreviewBuilder = Widget Function(
  BuildContext context,
  Uri imageUri,
);

/// Dependency-injected [MaterialCoverRepository] provider.
final Provider<MaterialCoverRepository> materialCoverRepositoryProvider =
    Provider<MaterialCoverRepository>((ref) {
  final client = ref.watch(optionalSupabaseClientProvider);
  if (client == null) {
    return const UnconfiguredMaterialCoverRepository();
  }
  return SupabaseMaterialCoverRepository(client);
});

/// Resolves a short-lived signed URL for a private `storagePath` inside
/// `material-covers`.
final FutureProviderFamily<Uri?, String> materialCoverSignedUrlProvider =
    FutureProvider.family<Uri?, String>(
  (ref, storagePath) {
    ref.watch(currentUserProvider.select((user) => user?.id));
    final trimmed = storagePath.trim();
    if (trimmed.isEmpty) {
      return Future<Uri?>.value();
    }
    return ref
        .watch(materialCoverRepositoryProvider)
        .createSignedCoverUrl(trimmed);
  },
  retry: _noRetry,
);

/// Dependency-injected image file picker restricted to jpg/png/webp.
final Provider<MaterialCoverPickerFn> materialCoverPickerProvider =
    Provider<MaterialCoverPickerFn>((ref) {
  return () async {
    final picked = await FilePicker.pickFile(
      type: FileType.custom,
      allowedExtensions: MaterialCoverValidator.allowedExtensions,
    );
    if (picked == null) return null;
    final size = picked.lengthSync() ?? await picked.length();
    return PickedMaterialCover(
      name: picked.name,
      sizeBytes: size,
      readBytes: picked.readAsBytes,
    );
  };
});

/// Dependency-injected cover resizer callback (~600 px width).
final Provider<MaterialCoverResizerFn> materialCoverResizerProvider =
    Provider<MaterialCoverResizerFn>((ref) {
  return MaterialCoverResizer.resizeToMaxWidth;
});

/// Optional test hook overriding inline `Image.network` rendering for cover
/// previews and thumbnails.
final Provider<MaterialCoverPreviewBuilder?>
    materialCoverPreviewImageBuilderProvider =
    Provider<MaterialCoverPreviewBuilder?>((ref) => null);
