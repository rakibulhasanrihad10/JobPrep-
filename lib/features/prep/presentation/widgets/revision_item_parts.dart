import 'package:flutter/material.dart';
import 'package:job_prep/core/localization/app_localizations_extension.dart';
import 'package:job_prep/core/theme/app_theme_tokens.dart';
import 'package:job_prep/core/widgets/glass_button.dart';
import 'package:job_prep/features/prep/domain/utils/revision_scheduler.dart';

/// Compact color-tinted status/metadata badge displayed inside
/// `RevisionItemCard`.
class RevisionItemBadgePill extends StatelessWidget {
  /// Creates a [RevisionItemBadgePill].
  const RevisionItemBadgePill({
    required this.label,
    required this.color,
    super.key,
  });

  /// Display text shown inside the badge.
  final String label;

  /// Accent color for fill and text contrast.
  final Color color;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final spacing = tokens.spacing;
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: spacing.sm,
        vertical: spacing.xxs,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.14),
        borderRadius: tokens.radii.smRadius,
      ),
      child: Text(
        label,
        style: tokens.textStyles.labelSmall.copyWith(color: color),
      ),
    );
  }
}

/// Spaced repetition action buttons (`Easy`, `Still hard`, `Snooze +1d`,
/// `Dismiss`) rendered for pending and revised items on `RevisionItemCard`.
class RevisionItemActionBar extends StatelessWidget {
  /// Creates a [RevisionItemActionBar].
  const RevisionItemActionBar({
    required this.itemId,
    required this.easyLabel,
    required this.isBusy,
    required this.onReviewAction,
    super.key,
  });

  /// Owning revision item identifier for stable widget keys.
  final String itemId;

  /// Pre-formatted label for the Easy button including next interval hint.
  final String easyLabel;

  /// Disables actions while a repository write is in progress.
  final bool isBusy;

  /// Invoked when the user triggers any review or snooze/dismiss action.
  final ValueChanged<RevisionReviewAction> onReviewAction;

  @override
  Widget build(BuildContext context) {
    final colors = context.tokens.colors;
    final spacing = context.tokens.spacing;
    final l10n = context.l10n;

    return Wrap(
      spacing: spacing.xs,
      runSpacing: spacing.xs,
      children: [
        GlassButton(
          key: ValueKey('revision-action-easy-$itemId'),
          variant: GlassButtonVariant.primary,
          onPressed:
              isBusy ? null : () => onReviewAction(RevisionReviewAction.easy),
          leading: Icon(
            Icons.check_circle_outline,
            size: spacing.lg,
            color: colors.success,
          ),
          child: Text(easyLabel),
        ),
        GlassButton(
          key: ValueKey('revision-action-stillHard-$itemId'),
          onPressed: isBusy
              ? null
              : () => onReviewAction(RevisionReviewAction.stillHard),
          leading: Icon(
            Icons.replay,
            size: spacing.lg,
            color: colors.warning,
          ),
          child: Text(l10n.prepRevisionActionStillHard),
        ),
        GlassButton(
          key: ValueKey('revision-action-snooze-$itemId'),
          onPressed:
              isBusy ? null : () => onReviewAction(RevisionReviewAction.snooze),
          leading: Icon(
            Icons.snooze,
            size: spacing.lg,
            color: colors.info,
          ),
          child: Text(l10n.prepRevisionActionSnooze),
        ),
        GlassButton(
          key: ValueKey('revision-action-dismiss-$itemId'),
          onPressed: isBusy
              ? null
              : () => onReviewAction(RevisionReviewAction.dismiss),
          leading: Icon(
            Icons.close_rounded,
            size: spacing.lg,
            color: colors.textMuted,
          ),
          child: Text(l10n.prepRevisionActionDismiss),
        ),
      ],
    );
  }
}
