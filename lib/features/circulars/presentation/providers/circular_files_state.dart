import 'package:flutter/foundation.dart' show immutable;
import 'package:job_prep/features/circulars/domain/errors/circular_failure.dart';
import 'package:job_prep/features/circulars/domain/utils/circular_file_validator.dart';

const Object _unset = Object();

/// Typed error union surfaced by `CircularFilesController` so widgets render
/// fully localized copy without hardcoded strings.
@immutable
sealed class CircularFilesUiError {
  /// Creates a [CircularFilesUiError].
  const CircularFilesUiError();
}

/// Validation failure mapped from [CircularFileValidationError].
final class CircularFilesValidationUiError extends CircularFilesUiError {
  /// Creates a [CircularFilesValidationUiError].
  const CircularFilesValidationUiError(this.validationError);

  /// Validation error code.
  final CircularFileValidationError validationError;
}

/// Raw image exceeded client-side resize input cap (`25 MiB`).
final class CircularFilesRawImageTooLargeUiError extends CircularFilesUiError {
  /// Creates a [CircularFilesRawImageTooLargeUiError].
  const CircularFilesRawImageTooLargeUiError();
}

/// Launching the temporary signed URL externally failed.
final class CircularFilesOpenSignedLinkUiError extends CircularFilesUiError {
  /// Creates a [CircularFilesOpenSignedLinkUiError].
  const CircularFilesOpenSignedLinkUiError();
}

/// Repository or storage failure mapped from [CircularFailure].
final class CircularFilesFailureUiError extends CircularFilesUiError {
  /// Creates a [CircularFilesFailureUiError].
  const CircularFilesFailureUiError(this.failure);

  /// Domain failure instance.
  final CircularFailure failure;
}

/// Immutable attachment action & upload progress state for one circular.
@immutable
class CircularFilesActionState {
  /// Creates a [CircularFilesActionState].
  const CircularFilesActionState({
    this.isUploading = false,
    this.uploadProgress = 0,
    this.uploadingFileName,
    this.busyFileId,
    this.error,
  });

  /// Whether an attachment upload is currently in progress.
  final bool isUploading;

  /// Normalized upload progress (`0.0` to `1.0`).
  final double uploadProgress;

  /// Display name of the file currently being uploaded.
  final String? uploadingFileName;

  /// ID of an existing attachment currently generating a URL or deleting.
  final String? busyFileId;

  /// Latest validation or repository error, if any.
  final CircularFilesUiError? error;

  /// Returns an updated copy of this [CircularFilesActionState].
  CircularFilesActionState copyWith({
    bool? isUploading,
    double? uploadProgress,
    Object? uploadingFileName = _unset,
    Object? busyFileId = _unset,
    Object? error = _unset,
  }) {
    return CircularFilesActionState(
      isUploading: isUploading ?? this.isUploading,
      uploadProgress: uploadProgress ?? this.uploadProgress,
      uploadingFileName: identical(uploadingFileName, _unset)
          ? this.uploadingFileName
          : uploadingFileName as String?,
      busyFileId: identical(busyFileId, _unset)
          ? this.busyFileId
          : busyFileId as String?,
      error: identical(error, _unset)
          ? this.error
          : error as CircularFilesUiError?,
    );
  }
}

/// Validates raw selected attachment byte counts against PDF (`5 MiB`) and
/// pre-resize image (`25 MiB`) bounds before reading or decoding payloads.
CircularFilesUiError? validateRawCircularFileSize({
  required int sizeBytes,
  required bool isImage,
}) {
  if (sizeBytes <= 0) {
    return const CircularFilesValidationUiError(
      CircularFileValidationError.emptyFile,
    );
  }
  if (isImage) {
    if (sizeBytes > CircularFileValidator.maxRawImageInputBytes) {
      return const CircularFilesRawImageTooLargeUiError();
    }
    return null;
  }
  if (sizeBytes > CircularFileValidator.maxCircularFileSizeBytes) {
    return const CircularFilesValidationUiError(
      CircularFileValidationError.fileTooLarge,
    );
  }
  return null;
}
