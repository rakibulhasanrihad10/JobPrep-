import 'dart:async' show unawaited;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:job_prep/core/localization/app_localizations_extension.dart';
import 'package:job_prep/core/theme/app_theme_tokens.dart';
import 'package:job_prep/core/widgets/glass_button.dart';
import 'package:job_prep/core/widgets/glass_card.dart';
import 'package:job_prep/features/auth/presentation/navigation/auth_redirect.dart';
import 'package:job_prep/features/onboarding/presentation/providers/onboarding_status_provider.dart';

/// Settings card exposing the **Run setup again** action to reopen the
/// onboarding wizard cleanly without duplicating existing workspace items.
class SetupWizardSettingsCard extends ConsumerStatefulWidget {
  /// Creates a [SetupWizardSettingsCard].
  const SetupWizardSettingsCard({super.key});

  @override
  ConsumerState<SetupWizardSettingsCard> createState() =>
      _SetupWizardSettingsCardState();
}

class _SetupWizardSettingsCardState
    extends ConsumerState<SetupWizardSettingsCard> {
  bool _isBusy = false;

  Future<void> _handleRerun() async {
    if (_isBusy) return;
    setState(() => _isBusy = true);
    final router = GoRouter.maybeOf(context);
    final ok =
        await ref.read(onboardingStatusProvider.notifier).runSetupAgain();
    if (!mounted) return;
    setState(() => _isBusy = false);
    if (ok) {
      router?.go(AppRoutePaths.onboarding);
    }
  }

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final spacing = tokens.spacing;
    final colors = tokens.colors;
    final l10n = context.l10n;

    return GlassCard(
      key: const ValueKey('settings-setup-wizard-card'),
      padding: spacing.insetsAllXl,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Icon(
                Icons.auto_fix_high_outlined,
                color: colors.goldAccent,
                size: spacing.xl,
              ),
              SizedBox(width: spacing.sm),
              Expanded(
                child: Text(
                  l10n.settingsSetupCardTitle,
                  style: tokens.textStyles.titleLarge,
                ),
              ),
            ],
          ),
          SizedBox(height: spacing.xs),
          Text(
            l10n.settingsSetupCardSubtitle,
            style: tokens.textStyles.bodyMedium,
          ),
          SizedBox(height: spacing.lg),
          Align(
            alignment: AlignmentDirectional.centerStart,
            child: GlassButton(
              key: const ValueKey('settings-run-setup-again-btn'),
              onPressed: _isBusy ? null : () => unawaited(_handleRerun()),
              leading: Icon(Icons.replay_rounded, size: spacing.lg),
              child: Text(l10n.settingsRunSetupAgainButton),
            ),
          ),
        ],
      ),
    );
  }
}
