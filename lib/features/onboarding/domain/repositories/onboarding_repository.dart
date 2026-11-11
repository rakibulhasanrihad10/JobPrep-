import 'package:job_prep/features/onboarding/domain/entities/onboarding_draft.dart';
import 'package:job_prep/features/onboarding/domain/entities/onboarding_status.dart';

/// Repository contract reading and persisting per-user onboarding completion,
/// resumable step progress, and Today tips visibility (`public.user_settings`).
abstract interface class OnboardingRepository {
  /// Loads the active user's onboarding state, returning a step-1 pending
  /// status when no row has been created yet.
  Future<OnboardingStatus> getStatus();

  /// Persists current wizard [step] (`1..6`) and edited [draft] for resume.
  Future<OnboardingStatus> saveProgress({
    required int step,
    required OnboardingDraft draft,
  });

  /// Marks onboarding complete (`onboarding_completed_at = completedAt`),
  /// resets tip dismissal (`todayTipsDismissed = false`), and saves [draft].
  Future<OnboardingStatus> completeOnboarding({
    required DateTime completedAt,
    required OnboardingDraft draft,
  });

  /// Clears `onboarding_completed_at` and resets
  /// [OnboardingStatus.onboardingStep] to `1` on **Run setup again**.
  Future<OnboardingStatus> resetOnboarding();

  /// Permanently marks the three onboarding Today screen tips as dismissed.
  Future<OnboardingStatus> dismissTodayTips();
}
