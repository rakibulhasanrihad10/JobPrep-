import 'dart:async' show unawaited;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:job_prep/core/localization/app_localizations_extension.dart';
import 'package:job_prep/core/localization/formatters.dart';
import 'package:job_prep/core/localization/locale_controller.dart';
import 'package:job_prep/core/theme/app_theme_tokens.dart';
import 'package:job_prep/core/widgets/glass_button.dart';
import 'package:job_prep/core/widgets/glass_card.dart';
import 'package:job_prep/core/widgets/glass_text_field.dart';
import 'package:job_prep/features/onboarding/presentation/providers/onboarding_status_provider.dart';
import 'package:job_prep/features/onboarding/presentation/providers/onboarding_wizard_controller.dart';

/// Step 5: Optional quick-capture fields saving the user's first circular
/// into Inbox, or cleanly left blank to skip.
class OnboardingStepCircular extends ConsumerWidget {
  /// Creates an [OnboardingStepCircular].
  const OnboardingStepCircular({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tokens = context.tokens;
    final colors = tokens.colors;
    final spacing = tokens.spacing;
    final l10n = context.l10n;
    final locale = ref.watch(localeProvider);
    final useBanglaDigits = ref.watch(useBanglaDigitsProvider);
    final state = ref.watch(onboardingWizardControllerProvider);
    final draft = state.draft;
    final controller = ref.read(onboardingWizardControllerProvider.notifier);

    final deadlineText = draft.circularDeadline == null
        ? l10n.quickCaptureDeadlineLabel
        : AppFormatters.formatDate(
            draft.circularDeadline!,
            locale: locale,
            useBanglaDigits: useBanglaDigits,
          );

    return GlassCard(
      key: const ValueKey('onboarding-step-5'),
      padding: spacing.insetsAllXl,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            l10n.onboardingCircularTitle,
            style: tokens.textStyles.headlineMedium,
          ),
          SizedBox(height: spacing.xs),
          Text(
            l10n.onboardingCircularSubtitle,
            style: tokens.textStyles.bodyMedium,
          ),
          SizedBox(height: spacing.lg),
          GlassTextField(
            key: const ValueKey('onboarding-circular-link-input'),
            initialValue: draft.circularLink,
            keyboardType: TextInputType.url,
            labelText: l10n.quickCaptureLinkLabel,
            hintText: l10n.quickCaptureLinkHint,
            errorText: state.circularLinkError != null
                ? l10n.onboardingValidationInvalidUrl
                : null,
            prefixIcon: Icon(Icons.link_rounded, color: colors.textSecondary),
            onChanged: controller.setCircularLink,
          ),
          SizedBox(height: spacing.md),
          GlassTextField(
            key: const ValueKey('onboarding-circular-title-input'),
            initialValue: draft.circularTitle,
            labelText: l10n.quickCaptureTitleLabel,
            hintText: l10n.quickCaptureTitleHint,
            onChanged: controller.setCircularTitle,
          ),
          SizedBox(height: spacing.md),
          Wrap(
            spacing: spacing.sm,
            runSpacing: spacing.sm,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              GlassButton(
                key: const ValueKey('onboarding-circular-deadline-btn'),
                onPressed: () => unawaited(
                  _pickDeadline(
                    context,
                    ref,
                    draft.circularDeadline,
                    controller,
                  ),
                ),
                leading: Icon(Icons.event_outlined, size: spacing.lg),
                child: Text(deadlineText),
              ),
              if (draft.circularDeadline != null)
                TextButton(
                  key: const ValueKey('onboarding-circular-clear-deadline-btn'),
                  onPressed: () => controller.setCircularDeadline(null),
                  child: Text(l10n.circularFieldClearDeadlineTooltip),
                ),
            ],
          ),
          SizedBox(height: spacing.md),
          Text(
            l10n.onboardingCircularOptionalNote,
            style: tokens.textStyles.bodySmall,
          ),
        ],
      ),
    );
  }

  Future<void> _pickDeadline(
    BuildContext context,
    WidgetRef ref,
    DateTime? current,
    OnboardingWizardController controller,
  ) async {
    final now = ref.read(onboardingNowProvider)();
    final todayCal = DateTime(now.year, now.month, now.day);
    final picked = await showDatePicker(
      context: context,
      initialDate: current != null && !current.isBefore(todayCal)
          ? current
          : todayCal.add(const Duration(days: 14)),
      firstDate: todayCal,
      lastDate: todayCal.add(const Duration(days: 1095)),
    );
    if (picked != null) {
      controller.setCircularDeadline(
        DateTime.utc(picked.year, picked.month, picked.day),
      );
    }
  }
}
