import 'package:flutter/material.dart';
import 'package:job_prep/core/localization/app_localizations_extension.dart';
import 'package:job_prep/core/theme/app_theme_tokens.dart';
import 'package:job_prep/core/widgets/animated_counter.dart';
import 'package:job_prep/core/widgets/glass_button.dart';
import 'package:job_prep/core/widgets/glass_card.dart';
import 'package:job_prep/features/prep/domain/utils/revision_scheduler.dart';
import 'package:job_prep/features/prep/presentation/providers/revision_state.dart';
import 'package:job_prep/features/prep/presentation/utils/revision_l10n.dart';

/// Compact summary stat counter displayed inside the Revision Queue header.
class RevisionHeaderStat extends StatelessWidget {
  /// Creates a [RevisionHeaderStat].
  const RevisionHeaderStat({
    required this.label,
    required this.value,
    required this.color,
    required this.replayKey,
    super.key,
  });

  /// Metric label.
  final String label;

  /// Integer metric value.
  final int value;

  /// Token accent color.
  final Color color;

  /// Key replaying [AnimatedCounter] when switching tabs.
  final Object replayKey;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AnimatedCounter(
          value: value,
          replayKey: replayKey,
          style: tokens.textStyles.headlineMedium.copyWith(color: color),
        ),
        Text(label, style: tokens.textStyles.bodySmall),
      ],
    );
  }
}

/// Inline confirmation banner offering 1-tap Undo after Easy, Still hard,
/// Snooze, or Dismiss actions.
class RevisionUndoBanner extends StatelessWidget {
  /// Creates a [RevisionUndoBanner].
  const RevisionUndoBanner({
    required this.record,
    required this.locale,
    required this.useBanglaDigits,
    required this.isBusy,
    required this.onUndo,
    required this.onDismiss,
    super.key,
  });

  /// Latest reversible queue action snapshot.
  final RevisionUndoRecord record;

  /// Active locale.
  final Locale locale;

  /// Whether Bangla numerals are enabled.
  final bool useBanglaDigits;

  /// Disables Undo button while saving.
  final bool isBusy;

  /// Restores `record.previousItem`.
  final VoidCallback onUndo;

  /// Dismisses this banner cleanly.
  final VoidCallback onDismiss;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final colors = tokens.colors;
    final spacing = tokens.spacing;
    final l10n = context.l10n;

    final undoText = RevisionL10n.undoBannerText(
      record,
      l10n: l10n,
      locale: locale,
      useBanglaDigits: useBanglaDigits,
    );
    final undoButton = GlassButton(
      key: const ValueKey('revision-undo-button'),
      variant: GlassButtonVariant.primary,
      onPressed: isBusy ? null : onUndo,
      child: Text(l10n.prepRevisionUndoButton),
    );
    final dismissButton = IconButton(
      key: const ValueKey('revision-undo-dismiss-button'),
      tooltip: l10n.prepRevisionUndoDismissTooltip,
      onPressed: onDismiss,
      icon: Icon(Icons.close, size: spacing.lg),
    );

    return GlassCard(
      key: const ValueKey('revision-undo-banner'),
      padding: spacing.insetsAllMd,
      borderColor: colors.goldAccent.withValues(alpha: 0.65),
      child: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth >= 480) {
            return Row(
              children: [
                Icon(Icons.history, size: spacing.lg, color: colors.goldAccent),
                SizedBox(width: spacing.sm),
                Expanded(
                  child: Text(
                    undoText,
                    style: tokens.textStyles.bodyMedium.copyWith(
                      color: colors.textPrimary,
                    ),
                  ),
                ),
                SizedBox(width: spacing.sm),
                undoButton,
                dismissButton,
              ],
            );
          }
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: EdgeInsets.only(top: spacing.xxs),
                    child: Icon(
                      Icons.history,
                      size: spacing.lg,
                      color: colors.goldAccent,
                    ),
                  ),
                  SizedBox(width: spacing.sm),
                  Expanded(
                    child: Text(
                      undoText,
                      style: tokens.textStyles.bodyMedium.copyWith(
                        color: colors.textPrimary,
                      ),
                    ),
                  ),
                  dismissButton,
                ],
              ),
              SizedBox(height: spacing.xs),
              Align(
                alignment: AlignmentDirectional.centerEnd,
                child: undoButton,
              ),
            ],
          );
        },
      ),
    );
  }
}

/// Tailored empty state card rendered for each Revision Queue tab.
class RevisionEmptyQueueCard extends StatelessWidget {
  /// Creates a [RevisionEmptyQueueCard].
  const RevisionEmptyQueueCard({
    required this.tab,
    required this.hasFilters,
    required this.onClearFilters,
    super.key,
  });

  /// Currently selected queue tab.
  final RevisionQueueTab tab;

  /// Whether active subject/material filters hid all items.
  final bool hasFilters;

  /// Resets filters to show matching queue items.
  final VoidCallback onClearFilters;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final colors = tokens.colors;
    final spacing = tokens.spacing;
    final l10n = context.l10n;

    final String title;
    final String body;
    final IconData icon;
    switch (tab) {
      case RevisionQueueTab.dueToday:
        title = l10n.prepRevisionEmptyDueTitle;
        body = hasFilters
            ? l10n.prepRevisionEmptyFilteredBody
            : l10n.prepRevisionEmptyDueBody;
        icon = Icons.check_circle_outline;
      case RevisionQueueTab.overdue:
        title = l10n.prepRevisionEmptyOverdueTitle;
        body = hasFilters
            ? l10n.prepRevisionEmptyFilteredBody
            : l10n.prepRevisionEmptyOverdueBody;
        icon = Icons.event_available_outlined;
      case RevisionQueueTab.upcoming:
        title = l10n.prepRevisionEmptyUpcomingTitle;
        body = hasFilters
            ? l10n.prepRevisionEmptyFilteredBody
            : l10n.prepRevisionEmptyUpcomingBody;
        icon = Icons.schedule_outlined;
      case RevisionQueueTab.done:
        title = l10n.prepRevisionEmptyDoneTitle;
        body = hasFilters
            ? l10n.prepRevisionEmptyFilteredBody
            : l10n.prepRevisionEmptyDoneBody;
        icon = Icons.verified_outlined;
    }

    return GlassCard(
      key: ValueKey('revision-empty-${tab.name}'),
      padding: spacing.insetsAllXl,
      child: Column(
        children: [
          Icon(icon, size: spacing.xxl, color: colors.goldAccent),
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
          if (hasFilters) ...[
            SizedBox(height: spacing.md),
            GlassButton(
              onPressed: onClearFilters,
              child: Text(l10n.prepRevisionClearFilters),
            ),
          ],
        ],
      ),
    );
  }
}
