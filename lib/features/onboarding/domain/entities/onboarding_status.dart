import 'package:flutter/foundation.dart' show immutable;
import 'package:job_prep/features/onboarding/domain/entities/onboarding_draft.dart';

/// Persisted onboarding completion state stored in `public.user_settings`.
@immutable
class OnboardingStatus {
  /// Creates an [OnboardingStatus].
  const OnboardingStatus({
    this.id = '',
    this.userId = '',
    this.onboardingCompletedAt,
    this.onboardingStep = 1,
    this.draft = const OnboardingDraft(),
    this.todayTipsDismissed = false,
    this.createdAt,
    this.updatedAt,
  });

  static const Object _unset = Object();

  /// Primary UUID from `user_settings`.
  final String id;

  /// Owner user ID matching `auth.uid()`.
  final String userId;

  /// Completion timestamp, or `null` when the user still needs onboarding.
  final DateTime? onboardingCompletedAt;

  /// Last reached wizard step (`1..6`) enabling mid-flow resume.
  final int onboardingStep;

  /// Saved non-PII draft choices for resuming midway.
  final OnboardingDraft draft;

  /// Whether the three onboarding tips shown on Today have been dismissed.
  final bool todayTipsDismissed;

  /// Row creation timestamp.
  final DateTime? createdAt;

  /// Row update timestamp.
  final DateTime? updatedAt;

  /// True when onboarding was finished or skipped.
  bool get isCompleted => onboardingCompletedAt != null;

  /// True when the signed-in user must be routed to the onboarding wizard.
  bool get needsOnboarding => onboardingCompletedAt == null;

  /// True when onboarding is done and the starter tips are not yet dismissed.
  bool get showTodayTips => isCompleted && !todayTipsDismissed;

  /// Returns a copy with specified fields overridden.
  OnboardingStatus copyWith({
    String? id,
    String? userId,
    Object? onboardingCompletedAt = _unset,
    int? onboardingStep,
    OnboardingDraft? draft,
    bool? todayTipsDismissed,
    Object? createdAt = _unset,
    Object? updatedAt = _unset,
  }) {
    return OnboardingStatus(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      onboardingCompletedAt: identical(onboardingCompletedAt, _unset)
          ? this.onboardingCompletedAt
          : onboardingCompletedAt as DateTime?,
      onboardingStep: (onboardingStep ?? this.onboardingStep).clamp(1, 6),
      draft: draft ?? this.draft,
      todayTipsDismissed: todayTipsDismissed ?? this.todayTipsDismissed,
      createdAt: identical(createdAt, _unset)
          ? this.createdAt
          : createdAt as DateTime?,
      updatedAt: identical(updatedAt, _unset)
          ? this.updatedAt
          : updatedAt as DateTime?,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is OnboardingStatus &&
        other.id == id &&
        other.userId == userId &&
        other.onboardingCompletedAt == onboardingCompletedAt &&
        other.onboardingStep == onboardingStep &&
        other.draft == draft &&
        other.todayTipsDismissed == todayTipsDismissed &&
        other.createdAt == createdAt &&
        other.updatedAt == updatedAt;
  }

  @override
  int get hashCode => Object.hash(
        id,
        userId,
        onboardingCompletedAt,
        onboardingStep,
        draft,
        todayTipsDismissed,
        createdAt,
        updatedAt,
      );
}
