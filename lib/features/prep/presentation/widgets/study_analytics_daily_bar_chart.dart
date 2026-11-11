import 'dart:math' as math;

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:job_prep/core/localization/app_localizations_extension.dart';
import 'package:job_prep/core/localization/formatters.dart';
import 'package:job_prep/core/localization/locale_controller.dart';
import 'package:job_prep/core/theme/app_colors.dart';
import 'package:job_prep/core/theme/app_theme_tokens.dart';
import 'package:job_prep/core/theme/reduce_effects_controller.dart';
import 'package:job_prep/core/widgets/glass_card.dart';
import 'package:job_prep/features/prep/domain/entities/study_analytics.dart';

/// Daily study units bar chart for 7, 30, or 90 days with an optional daily
/// target line sourced from active study plans.
class StudyAnalyticsDailyBarChart extends ConsumerWidget {
  /// Creates a [StudyAnalyticsDailyBarChart].
  const StudyAnalyticsDailyBarChart({
    required this.summary,
    required this.replayKey,
    super.key,
  });

  /// Computed study analytics summary containing `dailyTotals` & `dailyTarget`.
  final StudyAnalyticsSummary summary;

  /// Key triggering entrance animation from zero when the Analytics tab opens.
  final Object replayKey;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tokens = context.tokens;
    final colors = tokens.colors;
    final spacing = tokens.spacing;
    final radii = tokens.radii;
    final durations = tokens.durations;
    final l10n = context.l10n;
    final locale = ref.watch(localeProvider);
    final useBanglaDigits = ref.watch(useBanglaDigitsProvider);
    final reduceEffects = ref.watch(reduceEffectsProvider);

    final days = summary.dailyTotals;
    final target = summary.dailyTarget;
    final hasTarget = target != null && target > 0;

    var maxUnits = 0;
    for (final d in days) {
      if (d.units > maxUnits) maxUnits = d.units;
    }
    final ceilingRef = math.max(maxUnits, hasTarget ? target : 0);
    final scaledMax = ceilingRef * 1.18;
    final rawMaxY = scaledMax < 10 ? 10 : scaledMax;
    final yInterval = math.max(1, (rawMaxY / 4).ceil()).toDouble();
    final maxY = yInterval * 4;

    final barWidth = switch (summary.range) {
      StudyAnalyticsRange.days7 => 20.0,
      StudyAnalyticsRange.days30 => 6.5,
      StudyAnalyticsRange.days90 => 2.5,
    };
    final labelStep = switch (summary.range) {
      StudyAnalyticsRange.days7 => 1,
      StudyAnalyticsRange.days30 => 6,
      StudyAnalyticsRange.days90 => 18,
    };

    return GlassCard(
      key: const ValueKey('analytics-daily-bar-card'),
      padding: spacing.insetsAllLg,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: spacing.sm,
            runSpacing: spacing.xs,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.bar_chart_rounded,
                    size: spacing.lg,
                    color: colors.goldAccent,
                  ),
                  SizedBox(width: spacing.xs),
                  Flexible(
                    child: Text(
                      l10n.prepAnalyticsDailyChartTitle,
                      style: tokens.textStyles.titleMedium,
                    ),
                  ),
                ],
              ),
              if (hasTarget)
                Container(
                  key: const ValueKey('analytics-daily-target-badge'),
                  padding: EdgeInsets.symmetric(
                    horizontal: spacing.sm,
                    vertical: spacing.xxs,
                  ),
                  decoration: BoxDecoration(
                    color: colors.goldAccentSubtle,
                    borderRadius: radii.smRadius,
                  ),
                  child: Text(
                    l10n.prepAnalyticsDailyTargetLegend(
                      AppFormatters.formatNumber(
                        target,
                        locale: locale,
                        useBanglaDigits: useBanglaDigits,
                      ),
                    ),
                    style: tokens.textStyles.labelSmall.copyWith(
                      color: colors.goldAccent,
                    ),
                  ),
                ),
            ],
          ),
          SizedBox(height: spacing.md),
          TweenAnimationBuilder<double>(
            key: ValueKey('daily-bar-$replayKey-${summary.range.name}'),
            tween: Tween<double>(
              begin: reduceEffects ? 1 : 0,
              end: 1,
            ),
            duration: reduceEffects ? Duration.zero : durations.slow,
            curve: Curves.easeOutCubic,
            builder: (context, animProgress, _) {
              return SizedBox(
                key: const ValueKey('analytics-daily-bar-chart'),
                height: 210,
                child: Padding(
                  padding: EdgeInsets.only(
                    top: spacing.xs,
                    right: spacing.sm,
                  ),
                  child: BarChart(
                    duration: reduceEffects ? Duration.zero : durations.normal,
                    curve: Curves.easeOutCubic,
                    BarChartData(
                      minY: 0,
                      maxY: maxY,
                      alignment: BarChartAlignment.spaceAround,
                      gridData: FlGridData(
                        drawVerticalLine: false,
                        horizontalInterval: yInterval,
                        getDrawingHorizontalLine: (_) => FlLine(
                          color: colors.glassBorder.withValues(alpha: 0.45),
                          strokeWidth: 1,
                          dashArray: const [4, 4],
                        ),
                      ),
                      borderData: FlBorderData(
                        border: Border(
                          bottom: BorderSide(color: colors.glassBorder),
                          left: BorderSide(color: colors.glassBorder),
                        ),
                      ),
                      extraLinesData: ExtraLinesData(
                        horizontalLines: [
                          if (hasTarget)
                            HorizontalLine(
                              y: target.toDouble(),
                              color: colors.goldAccent,
                              strokeWidth: 1.8,
                              dashArray: const [6, 4],
                            ),
                        ],
                      ),
                      titlesData: FlTitlesData(
                        topTitles: const AxisTitles(),
                        rightTitles: const AxisTitles(),
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 44,
                            interval: yInterval,
                            getTitlesWidget: (value, meta) {
                              return SideTitleWidget(
                                meta: meta,
                                space: spacing.xs,
                                child: Text(
                                  AppFormatters.formatNumber(
                                    value.round(),
                                    locale: locale,
                                    useBanglaDigits: useBanglaDigits,
                                  ),
                                  maxLines: 1,
                                  softWrap: false,
                                  style: tokens.textStyles.bodySmall.copyWith(
                                    color: colors.textMuted,
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 28,
                            getTitlesWidget: (value, meta) {
                              final idx = value.round();
                              if (idx < 0 || idx >= days.length) {
                                return const SizedBox.shrink();
                              }
                              if (summary.range != StudyAnalyticsRange.days7 &&
                                  idx % labelStep != 0 &&
                                  idx != days.length - 1) {
                                return const SizedBox.shrink();
                              }
                              final label = AppFormatters.formatDate(
                                days[idx].date,
                                locale: locale,
                                pattern:
                                    summary.range == StudyAnalyticsRange.days7
                                        ? 'E'
                                        : 'd MMM',
                                useBanglaDigits: useBanglaDigits,
                              );
                              return SideTitleWidget(
                                meta: meta,
                                space: spacing.xs,
                                child: Text(
                                  label,
                                  maxLines: 1,
                                  softWrap: false,
                                  style: tokens.textStyles.bodySmall.copyWith(
                                    color: colors.textMuted,
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                      barGroups: [
                        for (var i = 0; i < days.length; i++)
                          BarChartGroupData(
                            x: i,
                            barRods: [
                              BarChartRodData(
                                toY: days[i].units * animProgress,
                                width: barWidth,
                                borderRadius: BorderRadius.vertical(
                                  top: Radius.circular(radii.sm),
                                ),
                                color: _barColor(
                                  units: days[i].units,
                                  target: hasTarget ? target : null,
                                  colors: colors,
                                ),
                              ),
                            ],
                          ),
                      ],
                      barTouchData: BarTouchData(
                        touchTooltipData: BarTouchTooltipData(
                          getTooltipColor: (_) => colors.surfaceElevated,
                          tooltipBorderRadius: radii.mdRadius,
                          fitInsideHorizontally: true,
                          fitInsideVertically: true,
                          getTooltipItem: (group, groupIndex, rod, rodIndex) {
                            final idx = group.x.clamp(0, days.length - 1);
                            final day = days[idx];
                            final dateLabel = AppFormatters.formatDate(
                              day.date,
                              locale: locale,
                              pattern: 'd MMM yyyy',
                              useBanglaDigits: useBanglaDigits,
                            );
                            final unitsLabel = AppFormatters.formatNumber(
                              day.units,
                              locale: locale,
                              useBanglaDigits: useBanglaDigits,
                            );
                            return BarTooltipItem(
                              l10n.prepAnalyticsDailyTooltip(
                                dateLabel,
                                unitsLabel,
                              ),
                              tokens.textStyles.bodySmall.copyWith(
                                color: colors.textPrimary,
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Color _barColor({
    required int units,
    required int? target,
    required AppColorsToken colors,
  }) {
    if (units <= 0) {
      return colors.textMuted.withValues(alpha: 0.25);
    }
    if (target != null && units >= target) {
      return colors.success;
    }
    if (target != null) {
      return colors.goldAccent;
    }
    return colors.info;
  }
}
