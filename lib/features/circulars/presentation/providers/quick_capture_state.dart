import 'package:flutter/foundation.dart' show immutable;
import 'package:job_prep/features/circulars/domain/entities/circular.dart';
import 'package:job_prep/features/circulars/domain/entities/circular_enums.dart';
import 'package:job_prep/features/circulars/domain/errors/circular_failure.dart';
import 'package:job_prep/features/circulars/domain/utils/quick_capture_helpers.dart';

const Object _unset = Object();

/// Immutable UI state for the minimal Quick Capture dialog.
@immutable
class QuickCaptureState {
  /// Creates a [QuickCaptureState].
  const QuickCaptureState({
    this.link = '',
    this.title = '',
    this.deadline,
    this.linkError,
    this.duplicateCircular,
    this.hasAttemptedSubmit = false,
    this.isSubmitting = false,
    this.submitFailure,
    this.savedCircular,
  });

  /// Required circular URL text.
  final String link;

  /// Optional custom circular title.
  final String title;

  /// Optional application deadline.
  final DateTime? deadline;

  /// Validation error for [link], surfaced after submit or live fix.
  final QuickCaptureLinkValidationError? linkError;

  /// Existing saved circular sharing the same normalized link, if any.
  final Circular? duplicateCircular;

  /// Whether save has been attempted at least once.
  final bool hasAttemptedSubmit;

  /// Whether creation is currently in flight.
  final bool isSubmitting;

  /// Repository failure from the latest save attempt, if any.
  final CircularFailure? submitFailure;

  /// Created inbox circular after saving succeeds.
  final Circular? savedCircular;

  /// Effective circular title stored on save (user input or URL fallback).
  String get effectiveTitle {
    final trimmedTitle = title.trim();
    if (trimmedTitle.isNotEmpty) return trimmedTitle;
    return deriveTitleFromCircularUrl(link);
  }

  /// Builds the inbox [Circular] payload ready for persistence.
  Circular toInboxCircular() {
    return Circular(
      title: effectiveTitle,
      circularUrl: link.trim(),
      deadline: deadline,
      workflowStatus: CircularWorkflowStatus.inbox,
      isQuickCapture: true,
    );
  }

  /// Returns an updated copy of this [QuickCaptureState].
  QuickCaptureState copyWith({
    String? link,
    String? title,
    Object? deadline = _unset,
    Object? linkError = _unset,
    Object? duplicateCircular = _unset,
    bool? hasAttemptedSubmit,
    bool? isSubmitting,
    Object? submitFailure = _unset,
    Object? savedCircular = _unset,
  }) {
    return QuickCaptureState(
      link: link ?? this.link,
      title: title ?? this.title,
      deadline:
          identical(deadline, _unset) ? this.deadline : deadline as DateTime?,
      linkError: identical(linkError, _unset)
          ? this.linkError
          : linkError as QuickCaptureLinkValidationError?,
      duplicateCircular: identical(duplicateCircular, _unset)
          ? this.duplicateCircular
          : duplicateCircular as Circular?,
      hasAttemptedSubmit: hasAttemptedSubmit ?? this.hasAttemptedSubmit,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      submitFailure: identical(submitFailure, _unset)
          ? this.submitFailure
          : submitFailure as CircularFailure?,
      savedCircular: identical(savedCircular, _unset)
          ? this.savedCircular
          : savedCircular as Circular?,
    );
  }
}
