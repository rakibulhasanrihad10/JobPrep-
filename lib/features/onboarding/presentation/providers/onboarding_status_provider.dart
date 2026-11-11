import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:job_prep/core/supabase/supabase_provider.dart';
import 'package:job_prep/core/theme/theme_controller.dart';
import 'package:job_prep/features/auth/domain/entities/auth_session_state.dart';
import 'package:job_prep/features/auth/presentation/providers/auth_providers.dart';
import 'package:job_prep/features/onboarding/data/repositories/supabase_onboarding_repository.dart';
import 'package:job_prep/features/onboarding/data/repositories/unconfigured_onboarding_repository.dart';
import 'package:job_prep/features/onboarding/domain/entities/onboarding_draft.dart';
import 'package:job_prep/features/onboarding/domain/entities/onboarding_status.dart';
import 'package:job_prep/features/onboarding/domain/repositories/onboarding_repository.dart';
import 'package:job_prep/features/today/presentation/providers/today_providers.dart';

Duration? _noRetry(int retryCount, Object error) => null;

/// Dependency-injected [OnboardingRepository] provider.
final Provider<OnboardingRepository> onboardingRepositoryProvider =
    Provider<OnboardingRepository>((ref) {
  final client = ref.watch(optionalSupabaseClientProvider);
  if (client == null) {
    final prefs = ref.watch(sharedPreferencesProvider);
    final userId =
        ref.watch(currentUserProvider.select((u) => u?.id)) ?? 'local';
    return UnconfiguredOnboardingRepository(prefs: prefs, userId: userId);
  }
  return SupabaseOnboardingRepository(client);
});

/// Clock callback for recording onboarding completion timestamps & plan dates.
final Provider<DateTime Function()> onboardingNowProvider =
    Provider<DateTime Function()>((ref) => ref.watch(todayNowProvider));

/// Coordinates persisted onboarding completion, step resume, reset ("Run setup
/// again"), and dismissal of the Today welcome tips.
class OnboardingStatusNotifier extends AsyncNotifier<OnboardingStatus> {
  @override
  FutureOr<OnboardingStatus> build() {
    final authState = ref.watch(authSessionProvider);
    if (authState.status != AuthStatus.signedIn) {
      return const OnboardingStatus();
    }
    final repo = ref.watch(onboardingRepositoryProvider);
    return repo.getStatus();
  }

  /// Persists in-progress wizard [step] and [draft] so closing midway resumes.
  Future<void> saveProgress({
    required int step,
    required OnboardingDraft draft,
  }) async {
    final current = state.asData?.value ?? const OnboardingStatus();
    state = AsyncData<OnboardingStatus>(
      current.copyWith(onboardingStep: step.clamp(1, 6), draft: draft),
    );
    try {
      final saved = await ref.read(onboardingRepositoryProvider).saveProgress(
            step: step,
            draft: draft,
          );
      if (ref.mounted) {
        state = AsyncData<OnboardingStatus>(saved);
      }
    } on Object {
      // Keep local draft intact cleanly on transient network drops.
    }
  }

  /// Marks onboarding complete cleanly (`onboarding_completed_at = now`).
  Future<bool> complete(OnboardingDraft draft) async {
    final now = ref.read(onboardingNowProvider)().toUtc();
    try {
      final saved =
          await ref.read(onboardingRepositoryProvider).completeOnboarding(
                completedAt: now,
                draft: draft,
              );
      if (ref.mounted) {
        state = AsyncData<OnboardingStatus>(saved);
      }
      return true;
    } on Object {
      return false;
    }
  }

  /// Resets completion timestamp and jumps back to step 1 ("Run setup again").
  Future<bool> runSetupAgain() async {
    try {
      final saved =
          await ref.read(onboardingRepositoryProvider).resetOnboarding();
      if (ref.mounted) {
        state = AsyncData<OnboardingStatus>(saved);
      }
      return true;
    } on Object {
      return false;
    }
  }

  /// Marks Today screen's three onboarding tips as dismissed.
  Future<void> dismissTodayTips() async {
    final current = state.asData?.value ?? const OnboardingStatus();
    state = AsyncData<OnboardingStatus>(
      current.copyWith(todayTipsDismissed: true),
    );
    try {
      final saved =
          await ref.read(onboardingRepositoryProvider).dismissTodayTips();
      if (ref.mounted) {
        state = AsyncData<OnboardingStatus>(saved);
      }
    } on Object {
      // Preserve optimistic dismissal so UX feels instant.
    }
  }
}

/// Provides the active user's persisted [OnboardingStatus].
final AsyncNotifierProvider<OnboardingStatusNotifier, OnboardingStatus>
    onboardingStatusProvider =
    AsyncNotifierProvider<OnboardingStatusNotifier, OnboardingStatus>(
  OnboardingStatusNotifier.new,
  retry: _noRetry,
);
