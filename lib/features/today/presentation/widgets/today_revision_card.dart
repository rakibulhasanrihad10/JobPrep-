import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:job_prep/core/localization/app_localizations_extension.dart';
import 'package:job_prep/core/localization/locale_controller.dart';
import 'package:job_prep/core/theme/app_theme_tokens.dart';
import 'package:job_prep/core/widgets/glass_button.dart';
import 'package:job_prep/core/widgets/glass_card.dart';
import 'package:job_prep/features/prep/domain/utils/revision_scheduler.dart';
import 'package:job_prep/features/prep/presentation/providers/revision_providers.dart';
import 'package:job_prep/features/prep/presentation/utils/revision_l10n.dart';
import 'package:job_prep/features/today/domain/entities/today_summary.dart';
import 'package:job_prep/features/today/presentation/utils/today_l10n.dart';

/// Displays revisions due today (and overdue count), first preview entries,
/// and a Start revision action routing straight into the Prep revision queue.
class TodayRevisionCard extends ConsumerWidget {
  /// Creates a [TodayRevisionCard].
  const TodayRevisionCard({
    required this.summary,
    required this.referenceNow,
    super.key,
  });

  /// Computed revision summary for Today.
  final TodayRevisionSummary summary;

  /// Current reference date used to render localized due/overdue labels.
  final DateTime referenceNow;

  void _openRevisionQueue(BuildContext context, WidgetRef ref) {
    ref.read(revisionFilterProvider.notifier).clear();
    final targetTab = summary.overdueCount > 0
        ? RevisionQueueTab.overdue
        : RevisionQueueTab.dueToday;
    ref.read(revisionQueueTabProvider.notifier).selectTab(targetTab);
    GoRouter.maybeOf(context)?.go('/prep/revision');
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tokens = context.tokens;
    final colors = tokens.colors;
    final spacing = tokens.spacing;
    final radii = tokens.radii;
    final l10n = context.l10n;
    final locale = ref.watch(localeProvider);
    final useBanglaDigits = ref.watch(useBanglaDigitsProvider);

    final fmtTotal = TodayL10n.formatCount(
      summary.totalDueCount,
      locale: locale,
      useBanglaDigits: useBanglaDigits,
    );
    final badgeAccent = summary.overdueCount > 0
        ? colors.warning
        : (summary.totalDueCount > 0 ? colors.goldAccent : colors.success);

    return GlassCard(
      key: const ValueKey('today-revision-card'),
      padding: spacing.insetsAllLg,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Icon(
                Icons.flag_outlined,
                size: spacing.lg,
                color: colors.goldAccent,
              ),
              SizedBox(width: spacing.sm),
              Expanded(
                child: Wrap(
                  spacing: spacing.xs,
                  runSpacing: spacing.xs,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Text(
                      l10n.todayRevisionTitle,
                      style: tokens.textStyles.titleMedium,
                    ),
                    Container(
                      key: const ValueKey('today-revision-count-badge'),
                      padding: EdgeInsets.symmetric(
                        horizontal: spacing.sm,
                        vertical: spacing.xxs,
                      ),
                      decoration: BoxDecoration(
                        color: badgeAccent.withValues(alpha: 0.14),
                        borderRadius: radii.smRadius,
                        border: Border.all(
                          color: badgeAccent.withValues(alpha: 0.45),
                        ),
                      ),
                      child: Text(
                        l10n.todayRevisionCountBadge(fmtTotal),
                        style: tokens.textStyles.labelSmall.copyWith(
                          color: badgeAccent,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (summary.overdueCount > 0 && summary.dueTodayCount > 0) ...[
            SizedBox(height: spacing.xs),
            Text(
              l10n.todayRevisionOverdueBreakdown(
                TodayL10n.formatCount(
                  summary.overdueCount,
                  locale: locale,
                  useBanglaDigits: useBanglaDigits,
                ),
                TodayL10n.formatCount(
                  summary.dueTodayCount,
                  locale: locale,
                  useBanglaDigits: useBanglaDigits,
                ),
              ),
              style: tokens.textStyles.bodySmall.copyWith(
                color: colors.textSecondary,
              ),
            ),
          ],
          SizedBox(height: spacing.md),
          if (summary.totalDueCount == 0)
            Container(
              key: const ValueKey('today-revision-empty'),
              padding: spacing.insetsAllMd,
              decoration: BoxDecoration(
                color: colors.surfaceElevated,
                borderRadius: radii.cardRadius,
                border: Border.all(color: colors.glassBorder),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    l10n.todayRevisionEmptyTitle,
                    style: tokens.textStyles.labelLarge,
                  ),
                  SizedBox(height: spacing.xs),
                  Text(
                    l10n.todayRevisionEmptyBody,
                    style: tokens.textStyles.bodySmall,
                  ),
                ],
              ),
            )
          else ...[
            for (var i = 0; i < summary.previewItems.length; i++) ...[
              if (i > 0) SizedBox(height: spacing.sm),
              _RevisionPreviewRow(
                entry: summary.previewItems[i],
                referenceNow: referenceNow,
                locale: locale,
                useBanglaDigits: useBanglaDigits,
                onTap: () => _openRevisionQueue(context, ref),
              ),
            ],
          ],
          SizedBox(height: spacing.md),
          Align(
            alignment: AlignmentDirectional.centerStart,
            child: GlassButton(
              key: const ValueKey('today-start-revision-btn'),
              variant: summary.totalDueCount > 0
                  ? GlassButtonVariant.primary
                  : GlassButtonVariant.standard,
              onPressed: () => _openRevisionQueue(context, ref),
              leading: Icon(
                Icons.play_lesson_outlined,
                size: spacing.lg,
                color: summary.totalDueCount > 0
                    ? colors.goldAccent
                    : colors.textSecondary,
              ),
              child: Text(l10n.todayRevisionStartButton),
            ),
          ),
        ],
      ),
    );
  }
}

class _RevisionPreviewRow extends StatelessWidget {
  const _RevisionPreviewRow({
    required this.entry,
    required this.referenceNow,
    required this.locale,
    required this.useBanglaDigits,
    required this.onTap,
  });

  final TodayRevisionPreviewEntry entry;
  final DateTime referenceNow;
  final Locale locale;
  final bool useBanglaDigits;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final colors = tokens.colors;
    final spacing = tokens.spacing;
    final radii = tokens.radii;
    final l10n = context.l10n;

    final item = entry.item;
    final reasonColor = RevisionL10n.reasonColor(item.reason, colors);
    final reasonLabel = RevisionL10n.reasonLabel(item.reason, l10n);
    final dueText = RevisionL10n.scheduleBadgeText(
      item,
      today: referenceNow,
      l10n: l10n,
      locale: locale,
      useBanglaDigits: useBanglaDigits,
    );
    final subjectTitle = entry.subject?.name ?? '';
    final materialTitle = entry.material?.title;
    final subtitle = (materialTitle != null && materialTitle.isNotEmpty)
        ? '$subjectTitle · $materialTitle'
        : subjectTitle;

    return InkWell(
      key: ValueKey('today-revision-item-${item.id}'),
      borderRadius: radii.cardRadius,
      onTap: onTap,
      child: Container(
        padding: spacing.insetsAllMd,
        decoration: BoxDecoration(
          color: colors.surfaceElevated,
          borderRadius: radii.cardRadius,
          border: Border.all(
            color: entry.isOverdue
                ? colors.warning.withValues(alpha: 0.45)
                : colors.glassBorder,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.referenceLabel,
                    style: tokens.textStyles.labelLarge,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (subtitle.isNotEmpty) ...[
                    SizedBox(height: spacing.xxs),
                    Text(
                      subtitle,
                      style: tokens.textStyles.bodySmall,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
            SizedBox(width: spacing.sm),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  dueText,
                  style: tokens.textStyles.labelSmall.copyWith(
                    color: entry.isOverdue ? colors.warning : colors.goldAccent,
                  ),
                ),
                SizedBox(height: spacing.xxs),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: spacing.xs,
                    vertical: spacing.xxs,
                  ),
                  decoration: BoxDecoration(
                    color: reasonColor.withValues(alpha: 0.14),
                    borderRadius: radii.smRadius,
                  ),
                  child: Text(
                    reasonLabel,
                    style: tokens.textStyles.labelSmall.copyWith(
                      color: reasonColor,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
