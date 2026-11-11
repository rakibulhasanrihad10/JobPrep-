import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:job_prep/core/localization/app_localizations_extension.dart';
import 'package:job_prep/core/localization/formatters.dart';
import 'package:job_prep/core/localization/locale_controller.dart';
import 'package:job_prep/core/theme/app_theme_tokens.dart';
import 'package:job_prep/core/widgets/animated_counter.dart';
import 'package:job_prep/core/widgets/glass_card.dart';
import 'package:job_prep/features/prep/domain/entities/study_analytics.dart';

/// Four primary animated KPI cards (`Current streak`, `Longest streak`,
/// `Units this week`, `Consistency`) plus rolling 7/30-day averages, best/weak
/// days, and mock test overview highlights.
class StudyAnalyticsMetricsGrid extends ConsumerWidget {
  /// Creates a [StudyAnalyticsMetricsGrid].
  const StudyAnalyticsMetricsGrid({
    required this.summary,
    required this.replayKey,
    super.key,
  });

  /// Computed study analytics metrics.
  final StudyAnalyticsSummary summary;

  /// Key triggering [AnimatedCounter] replay whenever the Analytics tab opens.
  final Object replayKey;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tokens = context.tokens;
    final colors = tokens.colors;
    final spacing = tokens.spacing;
    final l10n = context.l10n;
    final locale = ref.watch(localeProvider);
    final useBanglaDigits = ref.watch(useBanglaDigitsProvider);

    String fmtInt(int value) => AppFormatters.formatNumber(
          value,
          locale: locale,
          useBanglaDigits: useBanglaDigits,
        );

    String fmtDec(double value) => AppFormatters.formatNumber(
          value,
          locale: locale,
          useBanglaDigits: useBanglaDigits,
          decimalDigits: 1,
        );

    String fmtDaySummary(DailyStudyTotal? entry) {
      if (entry == null) return l10n.prepAnalyticsNoDataDash;
      final dateStr = AppFormatters.formatDate(
        entry.date,
        locale: locale,
        pattern: 'd MMM',
        useBanglaDigits: useBanglaDigits,
      );
      return l10n.prepAnalyticsDaySummaryValue(fmtInt(entry.units), dateStr);
    }

    final primaryCards = <Widget>[
      _KpiCard(
        key: const ValueKey('analytics-kpi-current-streak'),
        icon: Icons.local_fire_department_outlined,
        label: l10n.prepAnalyticsCurrentStreak,
        value: summary.currentStreak,
        suffix: l10n.prepAnalyticsDaysSuffix(summary.currentStreak),
        accent: colors.goldAccent,
        replayKey: replayKey,
      ),
      _KpiCard(
        key: const ValueKey('analytics-kpi-longest-streak'),
        icon: Icons.workspace_premium_outlined,
        label: l10n.prepAnalyticsLongestStreak,
        value: summary.longestStreak,
        suffix: l10n.prepAnalyticsDaysSuffix(summary.longestStreak),
        accent: colors.info,
        replayKey: replayKey,
      ),
      _KpiCard(
        key: const ValueKey('analytics-kpi-units-week'),
        icon: Icons.menu_book_outlined,
        label: l10n.prepAnalyticsUnitsThisWeek,
        value: summary.unitsThisWeek,
        suffix: '',
        caption: l10n
            .prepAnalyticsAvgPerDayCaption(fmtDec(summary.averageLast7Days)),
        accent: colors.success,
        replayKey: replayKey,
      ),
      _KpiCard(
        key: const ValueKey('analytics-kpi-consistency'),
        icon: Icons.verified_outlined,
        label: l10n.prepAnalyticsConsistency,
        value: (summary.consistencyScore * 100).round(),
        suffix: l10n.prepAnalyticsPercentSuffix,
        caption: l10n.prepAnalyticsActiveDaysCaption(
          fmtInt(summary.activeDaysInRange),
          fmtInt(summary.range.days),
        ),
        accent: colors.accentSecondary,
        replayKey: replayKey,
      ),
    ];

    final highlights = <Widget>[
      _HighlightTile(
        key: const ValueKey('analytics-highlight-avg-7d'),
        label: l10n.prepAnalyticsRolling7dLabel,
        value: l10n
            .prepAnalyticsUnitsPerDayValue(fmtDec(summary.averageLast7Days)),
        valueColor: colors.textPrimary,
      ),
      _HighlightTile(
        key: const ValueKey('analytics-highlight-avg-30d'),
        label: l10n.prepAnalyticsRolling30dLabel,
        value: l10n
            .prepAnalyticsUnitsPerDayValue(fmtDec(summary.averageLast30Days)),
        valueColor: colors.textPrimary,
      ),
      _HighlightTile(
        key: const ValueKey('analytics-highlight-best-day'),
        label: l10n.prepAnalyticsBestDayLabel,
        value: fmtDaySummary(summary.bestDay),
        valueColor: summary.bestDay != null ? colors.success : colors.textMuted,
      ),
      _HighlightTile(
        key: const ValueKey('analytics-highlight-weakest-day'),
        label: l10n.prepAnalyticsWeakestDayLabel,
        value: fmtDaySummary(summary.weakestDay),
        valueColor:
            summary.weakestDay != null ? colors.warning : colors.textMuted,
      ),
    ];

    if (summary.mockTestCountInRange > 0 &&
        summary.averageMockScoreInRange != null) {
      highlights.add(
        _HighlightTile(
          key: const ValueKey('analytics-highlight-mocks'),
          label: l10n.prepAnalyticsMockOverviewLabel,
          value: l10n.prepAnalyticsMockOverviewValue(
            summary.mockTestCountInRange,
            fmtInt(summary.mockTestCountInRange),
            fmtDec(summary.averageMockScoreInRange!),
          ),
          valueColor: colors.goldAccent,
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        LayoutBuilder(
          builder: (context, constraints) {
            if (constraints.maxWidth >= 600) {
              return IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    for (var i = 0; i < primaryCards.length; i++) ...[
                      if (i > 0) SizedBox(width: spacing.sm),
                      Expanded(child: primaryCards[i]),
                    ],
                  ],
                ),
              );
            }
            return Column(
              children: [
                IntrinsicHeight(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Expanded(child: primaryCards[0]),
                      SizedBox(width: spacing.sm),
                      Expanded(child: primaryCards[1]),
                    ],
                  ),
                ),
                SizedBox(height: spacing.sm),
                IntrinsicHeight(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Expanded(child: primaryCards[2]),
                      SizedBox(width: spacing.sm),
                      Expanded(child: primaryCards[3]),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
        SizedBox(height: spacing.md),
        GlassCard(
          padding: spacing.insetsAllMd,
          child: Wrap(
            spacing: spacing.lg,
            runSpacing: spacing.sm,
            children: highlights,
          ),
        ),
      ],
    );
  }
}

class _KpiCard extends StatelessWidget {
  const _KpiCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.suffix,
    required this.accent,
    required this.replayKey,
    super.key,
    this.caption,
  });

  final IconData icon;
  final String label;
  final int value;
  final String suffix;
  final Color accent;
  final Object replayKey;
  final String? caption;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final colors = tokens.colors;
    final spacing = tokens.spacing;

    return GlassCard(
      padding: spacing.insetsAllMd,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(icon, size: spacing.lg, color: accent),
              SizedBox(width: spacing.xs),
              Expanded(
                child: Text(
                  label,
                  style: tokens.textStyles.labelMedium.copyWith(
                    color: colors.textSecondary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          SizedBox(height: spacing.xs),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: AnimatedCounter(
              value: value,
              suffix: suffix.isEmpty ? null : suffix,
              replayKey: replayKey,
              style: tokens.textStyles.headlineMedium.copyWith(
                color: accent,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          if (caption != null) ...[
            SizedBox(height: spacing.xxs),
            Text(
              caption!,
              style: tokens.textStyles.bodySmall.copyWith(
                color: colors.textMuted,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ],
      ),
    );
  }
}

class _HighlightTile extends StatelessWidget {
  const _HighlightTile({
    required this.label,
    required this.value,
    required this.valueColor,
    super.key,
  });

  final String label;
  final String value;
  final Color valueColor;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final colors = tokens.colors;
    final spacing = tokens.spacing;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: tokens.textStyles.labelSmall.copyWith(
            color: colors.textMuted,
          ),
        ),
        SizedBox(height: spacing.xxs),
        Text(
          value,
          style: tokens.textStyles.labelLarge.copyWith(color: valueColor),
        ),
      ],
    );
  }
}
