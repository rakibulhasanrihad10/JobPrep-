import 'dart:async' show unawaited;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:job_prep/core/localization/app_localizations_extension.dart';
import 'package:job_prep/core/localization/formatters.dart';
import 'package:job_prep/core/localization/locale_controller.dart';
import 'package:job_prep/core/theme/app_theme_tokens.dart';
import 'package:job_prep/core/widgets/animated_progress_bar.dart';
import 'package:job_prep/core/widgets/fade_slide_in.dart';
import 'package:job_prep/core/widgets/glass_button.dart';
import 'package:job_prep/core/widgets/glass_card.dart';
import 'package:job_prep/features/auth/presentation/navigation/auth_redirect.dart';
import 'package:job_prep/features/onboarding/presentation/providers/onboarding_wizard_controller.dart';
import 'package:job_prep/features/onboarding/presentation/providers/onboarding_wizard_state.dart';
import 'package:job_prep/features/onboarding/presentation/widgets/onboarding_step_circular.dart';
import 'package:job_prep/features/onboarding/presentation/widgets/onboarding_step_finish.dart';
import 'package:job_prep/features/onboarding/presentation/widgets/onboarding_step_schedule.dart';
import 'package:job_prep/features/onboarding/presentation/widgets/onboarding_step_subjects.dart';
import 'package:job_prep/features/onboarding/presentation/widgets/onboarding_step_track.dart';
import 'package:job_prep/features/onboarding/presentation/widgets/onboarding_step_welcome.dart';

/// Full-screen glassmorphic 6-step onboarding wizard shown to signed-in users
/// before entering the main shell (`onboarding_completed_at == null`).
class OnboardingWizardScreen extends ConsumerWidget {
  /// Creates an [OnboardingWizardScreen].
  const OnboardingWizardScreen({super.key});

  Future<void> _handleNext(BuildContext context, WidgetRef ref) async {
    final router = GoRouter.maybeOf(context);
    final controller = ref.read(onboardingWizardControllerProvider.notifier);
    final ok = await controller.goNext();
    if (!context.mounted) return;
    if (ok && ref.read(onboardingWizardControllerProvider).didComplete) {
      router?.go(AppRoutePaths.today);
    }
  }

  Future<void> _handleSkip(BuildContext context, WidgetRef ref) async {
    final router = GoRouter.maybeOf(context);
    final ok = await ref
        .read(onboardingWizardControllerProvider.notifier)
        .skipOnboarding();
    if (!context.mounted) return;
    if (ok) {
      router?.go(AppRoutePaths.today);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tokens = context.tokens;
    final colors = tokens.colors;
    final spacing = tokens.spacing;
    final breakpoints = tokens.breakpoints;
    final l10n = context.l10n;
    final locale = ref.watch(localeProvider);
    final useBanglaDigits = ref.watch(useBanglaDigitsProvider);
    final state = ref.watch(onboardingWizardControllerProvider);
    final controller = ref.read(onboardingWizardControllerProvider.notifier);

    final stepFormatted = AppFormatters.formatNumber(
      state.step,
      locale: locale,
      useBanglaDigits: useBanglaDigits,
    );
    final totalFormatted = AppFormatters.formatNumber(
      OnboardingWizardState.totalSteps,
      locale: locale,
      useBanglaDigits: useBanglaDigits,
    );

    final width = MediaQuery.sizeOf(context).width;
    final horizontalPad =
        breakpoints.isCompact(width) ? spacing.lg : spacing.xl;

    return Scaffold(
      key: const ValueKey('onboarding-wizard-screen'),
      backgroundColor: colors.background,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 760),
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: horizontalPad,
                vertical: spacing.lg,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  GlassCard(
                    padding: spacing.insetsAllLg,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                l10n.onboardingStepProgress(
                                  stepFormatted,
                                  totalFormatted,
                                ),
                                key: const ValueKey(
                                  'onboarding-progress-label',
                                ),
                                style: tokens.textStyles.labelLarge.copyWith(
                                  color: colors.goldAccent,
                                ),
                              ),
                            ),
                            TextButton(
                              key: const ValueKey('onboarding-skip-btn'),
                              onPressed: state.isApplying
                                  ? null
                                  : () => unawaited(_handleSkip(context, ref)),
                              child: Text(l10n.onboardingSkipButton),
                            ),
                          ],
                        ),
                        SizedBox(height: spacing.sm),
                        AnimatedProgressBar(
                          key: const ValueKey('onboarding-progress-bar'),
                          value: state.progress,
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: spacing.lg),
                  Expanded(
                    child: SingleChildScrollView(
                      key: ValueKey('onboarding-step-scroll-${state.step}'),
                      child: FadeSlideIn(
                        key: ValueKey('onboarding-step-anim-${state.step}'),
                        child: _buildStepBody(state.step),
                      ),
                    ),
                  ),
                  SizedBox(height: spacing.md),
                  GlassCard(
                    padding: spacing.insetsAllMd,
                    child: Wrap(
                      spacing: spacing.sm,
                      runSpacing: spacing.sm,
                      alignment: WrapAlignment.spaceBetween,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        GlassButton(
                          key: const ValueKey('onboarding-back-btn'),
                          onPressed: state.step > 1 && !state.isApplying
                              ? () => unawaited(controller.goBack())
                              : null,
                          leading:
                              Icon(Icons.arrow_back_rounded, size: spacing.lg),
                          child: Text(l10n.onboardingBackButton),
                        ),
                        GlassButton(
                          key: const ValueKey('onboarding-next-btn'),
                          variant: GlassButtonVariant.primary,
                          onPressed: state.isApplying
                              ? null
                              : () => unawaited(_handleNext(context, ref)),
                          trailing: state.isApplying
                              ? SizedBox(
                                  width: spacing.lg,
                                  height: spacing.lg,
                                  child: const CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : Icon(
                                  state.step == OnboardingWizardState.totalSteps
                                      ? Icons.check_rounded
                                      : Icons.arrow_forward_rounded,
                                  size: spacing.lg,
                                ),
                          child: Text(
                            state.step == OnboardingWizardState.totalSteps
                                ? l10n.onboardingFinishButton
                                : l10n.onboardingNextButton,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStepBody(int step) {
    return switch (step) {
      1 => const OnboardingStepWelcome(),
      2 => const OnboardingStepTrack(),
      3 => const OnboardingStepSubjects(),
      4 => const OnboardingStepSchedule(),
      5 => const OnboardingStepCircular(),
      _ => const OnboardingStepFinish(),
    };
  }
}
