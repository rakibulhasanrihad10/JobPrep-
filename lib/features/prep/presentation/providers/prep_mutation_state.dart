import 'package:flutter/foundation.dart' show immutable;
import 'package:job_prep/features/prep/domain/utils/material_cover_validator.dart';

/// Immutable UI mutation status for subject and material CRUD, reordering,
/// and cover image preparation/upload.
@immutable
class PrepMutationState {
  /// Creates a [PrepMutationState].
  const PrepMutationState({
    this.isSubmitting = false,
    this.isReordering = false,
    this.isUploadingCover = false,
    this.activeId,
    this.error,
    this.coverValidationError,
    this.isRawImageTooLarge = false,
  });

  static const Object _unset = Object();

  /// Whether a create, update, or delete operation is in flight.
  final bool isSubmitting;

  /// Whether a subject reorder write is in flight.
  final bool isReordering;

  /// Whether a cover image resize or storage upload is currently active.
  final bool isUploadingCover;

  /// Identifier of the subject or material currently mutating, if applicable.
  final String? activeId;

  /// Last unexpected repository error encountered during a mutation.
  final Object? error;

  /// Last cover file or URL validation error encountered.
  final MaterialCoverValidationError? coverValidationError;

  /// Whether a picked raw cover exceeded `maxRawImageInputBytes`.
  final bool isRawImageTooLarge;

  /// Whether any blocking mutation is running.
  bool get isBusy => isSubmitting || isReordering || isUploadingCover;

  /// Returns a copy with overridden mutation fields.
  PrepMutationState copyWith({
    bool? isSubmitting,
    bool? isReordering,
    bool? isUploadingCover,
    Object? activeId = _unset,
    Object? error = _unset,
    Object? coverValidationError = _unset,
    bool? isRawImageTooLarge,
  }) {
    return PrepMutationState(
      isSubmitting: isSubmitting ?? this.isSubmitting,
      isReordering: isReordering ?? this.isReordering,
      isUploadingCover: isUploadingCover ?? this.isUploadingCover,
      activeId:
          identical(activeId, _unset) ? this.activeId : activeId as String?,
      error: identical(error, _unset) ? this.error : error,
      coverValidationError: identical(coverValidationError, _unset)
          ? this.coverValidationError
          : coverValidationError as MaterialCoverValidationError?,
      isRawImageTooLarge: isRawImageTooLarge ?? this.isRawImageTooLarge,
    );
  }
}
