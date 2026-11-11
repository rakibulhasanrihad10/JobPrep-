import 'package:flutter/material.dart';
import 'package:job_prep/core/localization/app_localizations_extension.dart';
import 'package:job_prep/core/theme/app_theme_tokens.dart';
import 'package:job_prep/core/widgets/glass_button.dart';
import 'package:job_prep/core/widgets/glass_card.dart';
import 'package:job_prep/features/prep/presentation/utils/prep_l10n.dart';

/// Loading indicator card shared across the Mock Tests tab and Subject detail.
class MockTestLoadingCard extends StatelessWidget {
  /// Creates a [MockTestLoadingCard].
  const MockTestLoadingCard({super.key});

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final spacing = tokens.spacing;
    final l10n = context.l10n;

    return GlassCard(
      padding: spacing.insetsAllXl,
      child: Column(
        children: [
          const CircularProgressIndicator(),
          SizedBox(height: spacing.sm),
          Text(
            l10n.prepMockLoadingLabel,
            style: tokens.textStyles.bodyMedium,
          ),
        ],
      ),
    );
  }
}

/// Error + retry card shared across the Mock Tests tab and Subject detail.
class MockTestErrorCard extends StatelessWidget {
  /// Creates a [MockTestErrorCard].
  const MockTestErrorCard({
    required this.error,
    required this.onRetry,
    super.key,
    this.retryButtonKey,
  });

  /// Caught asynchronous failure surfaced to the user.
  final Object error;

  /// Callback triggering repository refresh.
  final VoidCallback onRetry;

  /// Optional test key for the retry button.
  final Key? retryButtonKey;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final colors = tokens.colors;
    final spacing = tokens.spacing;
    final l10n = context.l10n;

    return GlassCard(
      padding: spacing.insetsAllLg,
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.prepMockLoadErrorTitle,
                  style: tokens.textStyles.titleMedium.copyWith(
                    color: colors.danger,
                  ),
                ),
                SizedBox(height: spacing.xxs),
                Text(
                  PrepL10n.failureMessage(error, l10n),
                  style: tokens.textStyles.bodySmall,
                ),
              ],
            ),
          ),
          SizedBox(width: spacing.md),
          GlassButton(
            key: retryButtonKey,
            onPressed: onRetry,
            child: Text(l10n.calendarRetry),
          ),
        ],
      ),
    );
  }
}

/// Empty-state CTA card used when either all tests or filtered results are
/// empty.
class MockTestEmptyCard extends StatelessWidget {
  /// Creates a [MockTestEmptyCard].
  const MockTestEmptyCard({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.body,
    required this.actionLabel,
    required this.onAction,
    super.key,
    this.actionKey,
    this.primaryAction = true,
  });

  /// Leading icon displayed centered above the empty state copy.
  final IconData icon;

  /// Color applied to [icon].
  final Color iconColor;

  /// Localized empty-state headline.
  final String title;

  /// Localized explanatory body copy.
  final String body;

  /// Localized CTA button label.
  final String actionLabel;

  /// Callback invoked when the CTA button is pressed (`null` disables).
  final VoidCallback? onAction;

  /// Optional test key assigned to the CTA button.
  final Key? actionKey;

  /// Renders the CTA as [GlassButtonVariant.primary] when true.
  final bool primaryAction;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final spacing = tokens.spacing;

    return GlassCard(
      padding: spacing.insetsAllXl,
      child: Column(
        children: [
          Icon(icon, size: spacing.xxl, color: iconColor),
          SizedBox(height: spacing.md),
          Text(
            title,
            style: tokens.textStyles.titleMedium,
            textAlign: TextAlign.center,
          ),
          SizedBox(height: spacing.xs),
          Text(
            body,
            style: tokens.textStyles.bodyMedium,
            textAlign: TextAlign.center,
          ),
          SizedBox(height: spacing.lg),
          GlassButton(
            key: actionKey,
            variant: primaryAction
                ? GlassButtonVariant.primary
                : GlassButtonVariant.standard,
            onPressed: onAction,
            child: Text(actionLabel),
          ),
        ],
      ),
    );
  }
}
