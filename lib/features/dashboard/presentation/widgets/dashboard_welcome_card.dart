import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:job_prep/core/localization/app_localizations_extension.dart';
import 'package:job_prep/core/theme/app_theme_tokens.dart';
import 'package:job_prep/core/widgets/fade_slide_in.dart';
import 'package:job_prep/core/widgets/glass_button.dart';
import 'package:job_prep/core/widgets/glass_card.dart';

/// Onboarding card displayed to brand-new users before any circulars,
/// study subjects, or progress logs have been recorded.
class DashboardWelcomeCard extends StatelessWidget {
  /// Creates a [DashboardWelcomeCard].
  const DashboardWelcomeCard({super.key});

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final colors = tokens.colors;
    final spacing = tokens.spacing;
    final l10n = context.l10n;
    final router = GoRouter.maybeOf(context);

    return FadeSlideIn(
      child: GlassCard(
        key: const ValueKey('dashboard-new-user-welcome-card'),
        padding: spacing.insetsAllXl,
        borderColor: colors.goldAccent,
        fillColor: colors.goldAccentSubtle,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.explore_outlined,
                  color: colors.goldAccent,
                  size: spacing.xxl,
                ),
                SizedBox(width: spacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.dashboardWelcomeTitle,
                        style: tokens.textStyles.titleLarge,
                      ),
                      SizedBox(height: spacing.xs),
                      Text(
                        l10n.dashboardWelcomeBody,
                        style: tokens.textStyles.bodyMedium,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: spacing.lg),
            Wrap(
              spacing: spacing.sm,
              runSpacing: spacing.sm,
              children: [
                GlassButton(
                  key: const ValueKey('dashboard-welcome-add-circular'),
                  variant: GlassButtonVariant.primary,
                  onPressed: () => router?.go('/circulars/new'),
                  child: Text(l10n.dashboardWelcomeAddCircular),
                ),
                GlassButton(
                  key: const ValueKey('dashboard-welcome-setup-prep'),
                  onPressed: () => router?.go('/prep'),
                  child: Text(l10n.dashboardWelcomeSetupPrep),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
