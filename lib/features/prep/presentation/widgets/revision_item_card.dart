import 'package:flutter/material.dart';
import 'package:job_prep/core/localization/app_localizations_extension.dart';
import 'package:job_prep/core/localization/formatters.dart';
import 'package:job_prep/core/theme/app_theme_tokens.dart';
import 'package:job_prep/core/widgets/glass_card.dart';
import 'package:job_prep/features/prep/domain/entities/prep_enums.dart';
import 'package:job_prep/features/prep/domain/entities/revision_item.dart';
import 'package:job_prep/features/prep/domain/utils/revision_scheduler.dart';
import 'package:job_prep/features/prep/presentation/utils/revision_l10n.dart';
import 'package:job_prep/features/prep/presentation/widgets/revision_item_parts.dart';

/// Card displaying one [RevisionItem] with subject/material tags, reason,
/// spacing status, and per-item actions (`Easy`, `Still hard`, `Snooze`,
/// `Dismiss`, or Delete in Done tab).
class RevisionItemCard extends StatelessWidget {
  /// Creates a [RevisionItemCard].
  const RevisionItemCard({
    required this.item,
    required this.subjectName,
    required this.subjectColor,
    required this.today,
    required this.locale,
    required this.useBanglaDigits,
    required this.isBusy,
    required this.onReviewAction,
    required this.onDelete,
    super.key,
    this.materialTitle,
  });

  /// Revision mark rendered by this card.
  final RevisionItem item;

  /// Owning subject display title.
  final String subjectName;

  /// Resolved subject accent color.
  final Color subjectColor;

  /// Current normalized calendar date used for overdue/due display.
  final DateTime today;

  /// Optional linked material title.
  final String? materialTitle;

  /// Active UI locale.
  final Locale locale;

  /// Whether Bangla numerals are enabled.
  final bool useBanglaDigits;

  /// Disables actions while a mutation is running.
  final bool isBusy;

  /// Invoked when the user triggers Easy / Still hard / Snooze / Dismiss.
  final ValueChanged<RevisionReviewAction> onReviewAction;

  /// Permanently deletes this revision item (used on Done tab).
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final colors = tokens.colors;
    final spacing = tokens.spacing;
    final radii = tokens.radii;
    final l10n = context.l10n;

    final reasonColor = RevisionL10n.reasonColor(item.reason, colors);
    final scheduleText = RevisionL10n.scheduleBadgeText(
      item,
      today: today,
      l10n: l10n,
      locale: locale,
      useBanglaDigits: useBanglaDigits,
    );

    final Color scheduleColor;
    if (item.status == RevisionStatus.mastered) {
      scheduleColor = colors.success;
    } else if (item.status == RevisionStatus.dismissed) {
      scheduleColor = colors.textMuted;
    } else if (RevisionScheduler.daysOverdue(item, today: today) > 0) {
      scheduleColor = colors.danger;
    } else if (RevisionScheduler.classifyTab(item, today: today) ==
        RevisionQueueTab.dueToday) {
      scheduleColor = colors.goldAccent;
    } else {
      scheduleColor = colors.info;
    }

    final nextGap = RevisionScheduler.nextEasyGapDays(item);
    final easyHint = nextGap == null
        ? l10n.prepRevisionActionEasyMasteredHint
        : l10n.prepRevisionActionEasyHint(
            AppFormatters.formatNumber(
              nextGap,
              locale: locale,
              useBanglaDigits: useBanglaDigits,
            ),
          );
    final easyLabel = '${l10n.prepRevisionActionEasy} ($easyHint)';

    final dueDateFormatted = AppFormatters.formatDate(
      item.dueOn,
      locale: locale,
      pattern: 'yMMMd',
    );
    final reviewFormatted = AppFormatters.formatNumber(
      item.reviewCount,
      locale: locale,
      useBanglaDigits: useBanglaDigits,
    );

    return GlassCard(
      key: ValueKey('revision-item-card-${item.id}'),
      padding: spacing.insetsAllLg,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: spacing.sm,
                height: spacing.sm,
                margin: EdgeInsets.only(top: spacing.xs, right: spacing.sm),
                decoration: BoxDecoration(
                  color: subjectColor,
                  shape: BoxShape.circle,
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.referenceLabel,
                      style: tokens.textStyles.titleMedium,
                    ),
                    SizedBox(height: spacing.xxs),
                    Wrap(
                      spacing: spacing.xs,
                      runSpacing: spacing.xxs,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        RevisionItemBadgePill(
                          label: subjectName,
                          color: subjectColor,
                        ),
                        if (materialTitle != null &&
                            materialTitle!.trim().isNotEmpty)
                          RevisionItemBadgePill(
                            label: materialTitle!,
                            color: colors.textSecondary,
                          ),
                        if (item.pageNumber != null)
                          RevisionItemBadgePill(
                            label: l10n.prepRevisionPageChip(
                              AppFormatters.formatNumber(
                                item.pageNumber!,
                                locale: locale,
                                useBanglaDigits: useBanglaDigits,
                              ),
                            ),
                            color: colors.goldAccent,
                          ),
                        RevisionItemBadgePill(
                          label: RevisionL10n.reasonLabel(item.reason, l10n),
                          color: reasonColor,
                        ),
                        RevisionItemBadgePill(
                          label: RevisionL10n.sourceLabel(item.source, l10n),
                          color: colors.textMuted,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              if (item.isDone)
                IconButton(
                  key: ValueKey('revision-delete-${item.id}'),
                  tooltip: l10n.prepRevisionDeleteTooltip,
                  visualDensity: VisualDensity.compact,
                  onPressed: isBusy ? null : onDelete,
                  icon: Icon(
                    Icons.delete_outline,
                    color: colors.danger,
                    size: spacing.lg,
                  ),
                ),
            ],
          ),
          if (item.note != null && item.note!.trim().isNotEmpty) ...[
            SizedBox(height: spacing.sm),
            Text(
              item.note!.trim(),
              style: tokens.textStyles.bodyMedium.copyWith(
                color: colors.textSecondary,
              ),
            ),
          ],
          SizedBox(height: spacing.sm),
          Wrap(
            spacing: spacing.sm,
            runSpacing: spacing.xs,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: spacing.sm,
                  vertical: spacing.xxs,
                ),
                decoration: BoxDecoration(
                  color: scheduleColor.withValues(alpha: 0.14),
                  borderRadius: radii.smRadius,
                  border: Border.all(
                    color: scheduleColor.withValues(alpha: 0.45),
                  ),
                ),
                child: Text(
                  scheduleText,
                  style: tokens.textStyles.labelSmall.copyWith(
                    color: scheduleColor,
                  ),
                ),
              ),
              Text(
                l10n.prepRevisionDueDateLabel(dueDateFormatted),
                style: tokens.textStyles.bodySmall.copyWith(
                  color: colors.textSecondary,
                ),
              ),
              Text(
                l10n.prepRevisionReviewCountChip(
                  item.reviewCount,
                  reviewFormatted,
                ),
                style: tokens.textStyles.bodySmall.copyWith(
                  color: colors.textMuted,
                ),
              ),
            ],
          ),
          if (item.isActive) ...[
            SizedBox(height: spacing.md),
            RevisionItemActionBar(
              itemId: item.id,
              easyLabel: easyLabel,
              isBusy: isBusy,
              onReviewAction: onReviewAction,
            ),
          ],
        ],
      ),
    );
  }
}
