import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:job_prep/core/localization/app_localizations_extension.dart';
import 'package:job_prep/core/localization/formatters.dart';
import 'package:job_prep/core/localization/locale_controller.dart';
import 'package:job_prep/core/theme/app_theme_tokens.dart';
import 'package:job_prep/core/widgets/animated_counter.dart';
import 'package:job_prep/core/widgets/glass_card.dart';
import 'package:job_prep/features/notifications/domain/entities/weekly_review_summary.dart';
import 'package:job_prep/features/notifications/presentation/utils/weekly_review_formatters.dart';

/// Responsive metric card grid displaying Weekly Review numbers, consistency,
/// mock performance, and comparisons against the previous 7 days.
class WeeklyReviewMetricsGrid extends ConsumerWidget {
  /// Creates a [WeeklyReviewMetricsGrid].
  const WeeklyReviewMetricsGrid({
    required this.summary,
    this.replayKey,
    super.key,
  });

  /// Calculated metrics for the trailing 7 days vs prior week.
  final WeeklyReviewSummary summary;

  /// Optional animation replay token when entering Weekly Review.
  final Object? replayKey;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tokens = context.tokens;
    final colors = tokens.colors;
    final spacing = tokens.spacing;
    final breakpoints = tokens.breakpoints;
    final l10n = context.l10n;
    final locale = ref.watch(localeProvider);
    final useBanglaDigits = ref.watch(useBanglaDigitsProvider);

    final unitsDeltaText = WeeklyReviewFormatters.formatIntDelta(
      delta: summary.unitsDelta,
      l10n: l10n,
      locale: locale,
      useBanglaDigits: useBanglaDigits,
    );
    final hoursDeltaText = WeeklyReviewFormatters.formatHoursDelta(
      deltaHours: summary.hoursDelta,
      l10n: l10n,
      locale: locale,
      useBanglaDigits: useBanglaDigits,
    );
    final studiedText = AppFormatters.formatNumber(
      summary.daysStudied,
      locale: locale,
      useBanglaDigits: useBanglaDigits,
    );
    final totalDaysText = AppFormatters.formatNumber(
      7,
      locale: locale,
      useBanglaDigits: useBanglaDigits,
    );
    final missedDaysText = summary.missedDaysCount == 0
        ? l10n.weeklyReviewMissedDaysNone
        : l10n.weeklyReviewMissedDaysCount(
            summary.missedDaysCount,
            AppFormatters.formatNumber(
              summary.missedDaysCount,
              locale: locale,
              useBanglaDigits: useBanglaDigits,
            ),
          );
    final missedDatesLabel = summary.missedDates.isEmpty
        ? null
        : summary.missedDates
            .map(
              (date) => AppFormatters.formatDate(
                date,
                locale: locale,
                pattern: 'E d MMM',
                useBanglaDigits: useBanglaDigits,
              ),
            )
            .join(', ');

    final mockCountLabel = l10n.weeklyReviewMockCountSubtitle(
      summary.mockTestsThisWeekCount,
      AppFormatters.formatNumber(
        summary.mockTestsThisWeekCount,
        locale: locale,
        useBanglaDigits: useBanglaDigits,
      ),
    );
    final mockDeltaPart = summary.mockAverageDelta == null
        ? null
        : WeeklyReviewFormatters.formatMockDelta(
            delta: summary.mockAverageDelta!,
            l10n: l10n,
            locale: locale,
            useBanglaDigits: useBanglaDigits,
          );
    final mockDeltaLabel = mockDeltaPart == null
        ? mockCountLabel
        : '$mockCountLabel · $mockDeltaPart';

    final cards = <Widget>[
      _MetricTile(
        key: const ValueKey('weekly-review-units-card'),
        icon: Icons.menu_book_outlined,
        accent: colors.goldAccent,
        title: l10n.weeklyReviewUnitsTitle,
        valueWidget: AnimatedCounter(
          value: summary.unitsThisWeek,
          replayKey: replayKey,
          style: tokens.textStyles.headlineMedium.copyWith(
            color: colors.textPrimary,
            fontWeight: FontWeight.w700,
          ),
        ),
        subtitle: unitsDeltaText,
        subtitleColor: WeeklyReviewFormatters.deltaColor(
          summary.unitsDelta,
          context,
        ),
      ),
      _MetricTile(
        key: const ValueKey('weekly-review-hours-card'),
        icon: Icons.schedule_rounded,
        accent: colors.info,
        title: l10n.weeklyReviewHoursTitle,
        valueWidget: Text(
          l10n.weeklyReviewHoursValue(
            AppFormatters.formatNumber(
              summary.hoursThisWeek,
              locale: locale,
              useBanglaDigits: useBanglaDigits,
              decimalDigits: 1,
            ),
          ),
          style: tokens.textStyles.headlineMedium.copyWith(
            color: colors.textPrimary,
            fontWeight: FontWeight.w700,
          ),
        ),
        subtitle: hoursDeltaText,
        subtitleColor: WeeklyReviewFormatters.deltaColor(
          summary.hoursDelta,
          context,
        ),
      ),
      _MetricTile(
        key: const ValueKey('weekly-review-days-card'),
        icon: Icons.calendar_today_outlined,
        accent: summary.missedDaysCount == 0 ? colors.success : colors.warning,
        title: l10n.weeklyReviewConsistencyTitle,
        valueWidget: Text(
          l10n.weeklyReviewDaysFraction(studiedText, totalDaysText),
          style: tokens.textStyles.headlineMedium.copyWith(
            color: colors.textPrimary,
            fontWeight: FontWeight.w700,
          ),
        ),
        subtitle: missedDatesLabel == null
            ? missedDaysText
            : '$missedDaysText ($missedDatesLabel)',
        subtitleColor: summary.missedDaysCount == 0
            ? colors.success
            : colors.textSecondary,
      ),
      _MetricTile(
        key: const ValueKey('weekly-review-mock-card'),
        icon: Icons.quiz_outlined,
        accent: colors.accentSecondary,
        title: l10n.weeklyReviewMockAvgTitle,
        valueWidget: summary.mockTestAverageThisWeek == null
            ? Text(
                l10n.weeklyReviewMockNoData,
                style: tokens.textStyles.titleLarge.copyWith(
                  color: colors.textMuted,
                ),
              )
            : Text(
                l10n.weeklyReviewMockPercent(
                  AppFormatters.formatNumber(
                    summary.mockTestAverageThisWeek!,
                    locale: locale,
                    useBanglaDigits: useBanglaDigits,
                    decimalDigits: 1,
                  ),
                ),
                style: tokens.textStyles.headlineMedium.copyWith(
                  color: colors.textPrimary,
                  fontWeight: FontWeight.w700,
                ),
              ),
        subtitle: mockDeltaLabel,
        subtitleColor: summary.mockAverageDelta == null
            ? colors.textSecondary
            : WeeklyReviewFormatters.deltaColor(
                summary.mockAverageDelta!,
                context,
              ),
      ),
      _MetricTile(
        key: const ValueKey('weekly-review-revision-card'),
        icon: Icons.history_edu_outlined,
        accent: colors.success,
        title: l10n.weeklyReviewRevisionsClearedTitle,
        valueWidget: AnimatedCounter(
          value: summary.revisionsClearedThisWeek,
          replayKey: replayKey,
          style: tokens.textStyles.headlineMedium.copyWith(
            color: colors.textPrimary,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final columns = breakpoints.isCompact(width)
            ? 1
            : (breakpoints.isExpanded(width) ? 3 : 2);
        if (columns == 1) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (var i = 0; i < cards.length; i++) ...[
                if (i > 0) SizedBox(height: spacing.md),
                cards[i],
              ],
            ],
          );
        }

        final rows = columns == 3
            ? <List<Widget>>[cards.sublist(0, 3), cards.sublist(3)]
            : <List<Widget>>[
                cards.sublist(0, 2),
                cards.sublist(2, 4),
                cards.sublist(4),
              ];

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (var r = 0; r < rows.length; r++) ...[
              if (r > 0) SizedBox(height: spacing.md),
              IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    for (var c = 0; c < rows[r].length; c++) ...[
                      if (c > 0) SizedBox(width: spacing.md),
                      Expanded(child: rows[r][c]),
                    ],
                  ],
                ),
              ),
            ],
          ],
        );
      },
    );
  }
}

class _MetricTile extends StatelessWidget {
  const _MetricTile({
    required this.icon,
    required this.accent,
    required this.title,
    required this.valueWidget,
    this.subtitle,
    this.subtitleColor,
    super.key,
  });

  final IconData icon;
  final Color accent;
  final String title;
  final Widget valueWidget;
  final String? subtitle;
  final Color? subtitleColor;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final spacing = tokens.spacing;

    return GlassCard(
      padding: spacing.insetsAllLg,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: spacing.lg, color: accent),
              SizedBox(width: spacing.xs),
              Expanded(
                child: Text(
                  title,
                  style: tokens.textStyles.labelLarge,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          SizedBox(height: spacing.md),
          valueWidget,
          if (subtitle != null) ...[
            SizedBox(height: spacing.xs),
            Text(
              subtitle!,
              style: tokens.textStyles.bodySmall.copyWith(
                color: subtitleColor ?? tokens.colors.textSecondary,
              ),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ],
      ),
    );
  }
}
