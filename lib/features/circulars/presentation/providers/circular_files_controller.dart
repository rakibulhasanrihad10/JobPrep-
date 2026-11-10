import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show ProviderFamily;
import 'package:job_prep/features/circulars/domain/entities/circular_file.dart';
import 'package:job_prep/features/circulars/domain/errors/circular_failure.dart';
import 'package:job_prep/features/circulars/domain/utils/circular_file_validator.dart';
import 'package:job_prep/features/circulars/presentation/providers/circular_file_providers.dart';
import 'package:job_prep/features/circulars/presentation/providers/circular_files_state.dart';
import 'package:job_prep/features/circulars/presentation/providers/circulars_providers.dart';
import 'package:job_prep/features/circulars/presentation/providers/url_launcher_provider.dart';
import 'package:job_prep/features/circulars/presentation/utils/circular_image_resizer.dart';

export 'circular_files_state.dart';

/// Controller coordinating file selection, validation, image resizing, upload
/// progress, signed URL preview/download, and deletion.
class CircularFilesController
    extends Notifier<Map<String, CircularFilesActionState>> {
  @override
  Map<String, CircularFilesActionState> build() =>
      const <String, CircularFilesActionState>{};

  CircularFilesActionState _stateFor(String circularId) {
    return state[circularId] ?? const CircularFilesActionState();
  }

  void _updateState(
    String circularId,
    CircularFilesActionState Function(CircularFilesActionState current)
        transform,
  ) {
    final next = Map<String, CircularFilesActionState>.from(state);
    next[circularId] = transform(_stateFor(circularId));
    state = next;
  }

  /// Opens the configured file picker and uploads the chosen attachment for
  /// [circularId] after validation and optional image resizing.
  Future<CircularFile?> pickAndUploadFile(String circularId) async {
    if (_stateFor(circularId).isUploading) return null;

    _updateState(circularId, (s) => s.copyWith(error: null));

    PickedCircularFile? picked;
    try {
      picked = await ref.read(circularFilePickerProvider)();
    } on Object catch (error) {
      if (ref.mounted) {
        _setError(circularId, _toUiFailureError(error));
      }
      return null;
    }

    if (picked == null || !ref.mounted) return null;
    final uploaded = await uploadPickedFile(circularId, picked);
    return uploaded;
  }

  /// Validates, resizes (when image > 1600 px), and uploads [picked] for
  /// [circularId].
  Future<CircularFile?> uploadPickedFile(
    String circularId,
    PickedCircularFile picked,
  ) async {
    if (_stateFor(circularId).isUploading) return null;

    final typeError = CircularFileValidator.validateFileType(picked.name);
    if (typeError != null) {
      _setError(circularId, CircularFilesValidationUiError(typeError));
      return null;
    }

    final initialMime = CircularFileValidator.resolveMimeType(picked.name)!;
    final isImage = CircularFileValidator.isImageMimeType(initialMime);

    final preSize = picked.sizeBytes;
    if (preSize != null) {
      final preError = validateRawCircularFileSize(
        sizeBytes: preSize,
        isImage: isImage,
      );
      if (preError != null) {
        _setError(circularId, preError);
        return null;
      }
    }

    _updateState(
      circularId,
      (s) => s.copyWith(
        isUploading: true,
        uploadProgress: 0.05,
        uploadingFileName: picked.name,
        error: null,
      ),
    );

    try {
      final rawBytes = await picked.readBytes();
      if (!ref.mounted) return null;

      final rawError = validateRawCircularFileSize(
        sizeBytes: rawBytes.length,
        isImage: isImage,
      );
      if (rawError != null) {
        _finishUploadWithError(circularId, rawError);
        return null;
      }

      if (_stateFor(circularId).uploadProgress < 0.1) {
        _updateState(
          circularId,
          (s) => s.copyWith(uploadProgress: 0.1),
        );
      }

      final prepared = await ref.read(circularImageResizerProvider)(
        bytes: rawBytes,
        fileName: picked.name,
        mimeType: initialMime,
        maxDimension: CircularImageResizer.defaultMaxDimension,
      );
      if (!ref.mounted) return null;

      final postError = CircularFileValidator.validateFile(
        fileName: prepared.fileName,
        sizeBytes: prepared.bytes.length,
      );
      if (postError != null) {
        _finishUploadWithError(
          circularId,
          CircularFilesValidationUiError(postError),
        );
        return null;
      }

      final uploaded =
          await ref.read(circularFileRepositoryProvider).uploadFile(
                circularId: circularId,
                fileName: prepared.fileName,
                mimeType: prepared.mimeType,
                bytes: prepared.bytes,
                onProgress: (progress) {
                  if (!ref.mounted) return;
                  final clamped = progress.clamp(0.1, 1).toDouble();
                  _updateState(
                    circularId,
                    (s) => s.copyWith(uploadProgress: clamped),
                  );
                },
              );
      if (!ref.mounted) return uploaded;

      _updateState(
        circularId,
        (s) => s.copyWith(
          isUploading: false,
          uploadProgress: 0,
          uploadingFileName: null,
          error: null,
        ),
      );
      _invalidateCaches(circularId);
      return uploaded;
    } on Object catch (error) {
      if (ref.mounted) {
        _finishUploadWithError(circularId, _toUiFailureError(error));
      }
      return null;
    }
  }

  /// Creates a short-lived signed URL for previewing [file].
  Future<Uri?> createSignedPreviewUrl(CircularFile file) {
    return _withFileBusy(
      file,
      () => ref.read(circularFileRepositoryProvider).createSignedUrl(file),
    );
  }

  /// Creates a short-lived download signed URL and opens it externally.
  Future<bool> downloadFile(CircularFile file) async {
    final uri = await _withFileBusy(
      file,
      () => ref.read(circularFileRepositoryProvider).createSignedUrl(
            file,
            download: true,
          ),
    );
    if (uri == null || !ref.mounted) return false;

    final opened = await openSignedUri(file.circularId, uri);
    return opened;
  }

  /// Launches a previously created signed [uri] via
  /// [circularUrlLauncherProvider].
  Future<bool> openSignedUri(String circularId, Uri uri) async {
    try {
      final opened = await ref.read(circularUrlLauncherProvider)(uri);
      if (!ref.mounted) return opened;
      if (!opened) {
        _setError(circularId, const CircularFilesOpenSignedLinkUiError());
      }
      return opened;
    } on Object catch (_) {
      if (ref.mounted) {
        _setError(circularId, const CircularFilesOpenSignedLinkUiError());
      }
      return false;
    }
  }

  /// Deletes [file] from storage and `public.circular_files` metadata.
  Future<bool> deleteFile(CircularFile file) async {
    final deleted = await _withFileBusy<bool>(file, () async {
      await ref.read(circularFileRepositoryProvider).deleteFile(file);
      if (ref.mounted) {
        _invalidateCaches(file.circularId);
      }
      return true;
    });
    return deleted ?? false;
  }

  /// Dismisses the error banner for [circularId].
  void clearError(String circularId) {
    if (_stateFor(circularId).error != null) {
      _updateState(circularId, (s) => s.copyWith(error: null));
    }
  }

  Future<T?> _withFileBusy<T>(
    CircularFile file,
    Future<T> Function() action,
  ) async {
    if (_stateFor(file.circularId).busyFileId == file.id) return null;

    _updateState(
      file.circularId,
      (s) => s.copyWith(busyFileId: file.id, error: null),
    );
    try {
      final result = await action();
      if (ref.mounted) {
        _updateState(file.circularId, (s) => s.copyWith(busyFileId: null));
      }
      return result;
    } on Object catch (error) {
      if (ref.mounted) {
        _updateState(
          file.circularId,
          (s) => s.copyWith(
            busyFileId: null,
            error: _toUiFailureError(error),
          ),
        );
      }
      return null;
    }
  }

  CircularFilesUiError _toUiFailureError(Object error) {
    if (error is CircularFailure) {
      return CircularFilesFailureUiError(error);
    }
    return CircularFilesFailureUiError(
      UnknownCircularFailure(message: error.toString()),
    );
  }

  void _setError(String circularId, CircularFilesUiError error) {
    _updateState(circularId, (s) => s.copyWith(error: error));
  }

  void _finishUploadWithError(String circularId, CircularFilesUiError error) {
    _updateState(
      circularId,
      (s) => s.copyWith(
        isUploading: false,
        uploadProgress: 0,
        uploadingFileName: null,
        error: error,
      ),
    );
  }

  void _invalidateCaches(String circularId) {
    ref
      ..invalidate(circularFilesProvider(circularId))
      ..invalidate(circularByIdProvider(circularId))
      ..invalidate(circularsListProvider);
  }
}

/// Provides file upload, signed URL preview/download, and delete actions.
final NotifierProvider<CircularFilesController,
        Map<String, CircularFilesActionState>> circularFilesControllerProvider =
    NotifierProvider<CircularFilesController,
        Map<String, CircularFilesActionState>>(
  CircularFilesController.new,
);

/// Watches [CircularFilesActionState] scoped to a single `circularId`.
final ProviderFamily<CircularFilesActionState, String>
    circularFilesActionStateProvider =
    Provider.family<CircularFilesActionState, String>((ref, circularId) {
  final byCircular = ref.watch(circularFilesControllerProvider);
  return byCircular[circularId] ?? const CircularFilesActionState();
});
