import 'package:flutter/foundation.dart' show immutable;
import 'package:job_prep/features/circulars/domain/utils/quick_capture_helpers.dart';
import 'package:job_prep/features/onboarding/domain/entities/onboarding_draft.dart';
import 'package:job_prep/features/onboarding/domain/utils/onboarding_planner.dart';

/// Immutable UI & validation state driving the 6-step onboarding wizard.
@immutable
class OnboardingWizardState {
  /// Creates an [OnboardingWizardState].
  const OnboardingWizardState({
    this.step = 1,
    this.draft = const OnboardingDraft(),
    this.maxDailyPaceInput = '',
    this.subjectsError,
    this.scheduleError,
    this.circularLinkError,
    this.isApplying = false,
    this.applyFailed = false,
    this.didComplete = false,
  });

  static const Object _unset = Object();

  /// Active wizard step index (`1..6`).
  final int step;

  /// Editable user choices & customized subjects/materials across steps.
  final OnboardingDraft draft;

  /// Raw text typed into the optional max daily pace field on Step 4.
  final String maxDailyPaceInput;

  /// Validation error from Step 3, if any.
  final OnboardingSubjectsValidationError? subjectsError;

  /// Validation error from Step 4, if any.
  final OnboardingScheduleValidationError? scheduleError;

  /// Validation error from Step 5 optional circular link, if invalid.
  final QuickCaptureLinkValidationError? circularLinkError;

  /// True while finishing & persisting everything on Step 6 or Skipping.
  final bool isApplying;

  /// True when saving on Step 6 or Skip encountered a failure.
  final bool applyFailed;

  /// True once onboarding has completed cleanly.
  final bool didComplete;

  /// Total number of steps shown in the wizard progress bar.
  static const int totalSteps = 6;

  /// Normalized progress ratio (`step / 6`).
  double get progress => (step.clamp(1, totalSteps)) / totalSteps;

  /// Returns a copy with specified fields overridden.
  OnboardingWizardState copyWith({
    int? step,
    OnboardingDraft? draft,
    String? maxDailyPaceInput,
    Object? subjectsError = _unset,
    Object? scheduleError = _unset,
    Object? circularLinkError = _unset,
    bool? isApplying,
    bool? applyFailed,
    bool? didComplete,
  }) {
    return OnboardingWizardState(
      step: (step ?? this.step).clamp(1, totalSteps),
      draft: draft ?? this.draft,
      maxDailyPaceInput: maxDailyPaceInput ?? this.maxDailyPaceInput,
      subjectsError: identical(subjectsError, _unset)
          ? this.subjectsError
          : subjectsError as OnboardingSubjectsValidationError?,
      scheduleError: identical(scheduleError, _unset)
          ? this.scheduleError
          : scheduleError as OnboardingScheduleValidationError?,
      circularLinkError: identical(circularLinkError, _unset)
          ? this.circularLinkError
          : circularLinkError as QuickCaptureLinkValidationError?,
      isApplying: isApplying ?? this.isApplying,
      applyFailed: applyFailed ?? this.applyFailed,
      didComplete: didComplete ?? this.didComplete,
    );
  }
}
