import 'dart:math' as math;

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:job_prep/core/localization/app_localizations_extension.dart';
import 'package:job_prep/core/localization/formatters.dart';
import 'package:job_prep/core/localization/locale_controller.dart';
import 'package:job_prep/core/theme/app_theme_tokens.dart';
import 'package:job_prep/core/theme/reduce_effects_controller.dart';
import 'package:job_prep/core/widgets/glass_card.dart';
import 'package:job_prep/features/prep/domain/entities/study_analytics.dart';

/// Bar chart summarizing total study units logged per calendar week across the
/// selected date window.
class StudyAnalyticsWeeklyChart extends ConsumerWidget {
  /// Creates a [StudyAnalyticsWeeklyChart].
  const StudyAnalyticsWeeklyChart({
    required this.summary,
    required this.replayKey,
    super.key,
  });

  /// Computed study analytics summary containing weekly totals.
  final StudyAnalyticsSummary summary;

  /// Key triggering animation from zero when opening or switching tabs.
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

    final weeks = summary.weeklyTotals;
    var maxUnits = 0;
    for (final w in weeks) {
      if (w.units > maxUnits) maxUnits = w.units;
    }
    final scaledMax = maxUnits * 1.18;
    final rawMaxY = scaledMax < 10 ? 10 : scaledMax;
    final yInterval = math.max(1, (rawMaxY / 4).ceil()).toDouble();
    final maxY = yInterval * 4;
    final labelStep = math.max(1, (weeks.length / 5).ceil());
    final barWidth = weeks.length <= 5 ? 24.0 : 12.0;

    return GlassCard(
      key: const ValueKey('analytics-weekly-chart-card'),
      padding: spacing.insetsAllLg,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Icon(
                Icons.date_range_outlined,
                size: spacing.lg,
                color: colors.info,
              ),
              SizedBox(width: spacing.xs),
              Expanded(
                child: Text(
                  l10n.prepAnalyticsWeeklyChartTitle,
                  style: tokens.textStyles.titleMedium,
                ),
              ),
            ],
          ),
          SizedBox(height: spacing.md),
          TweenAnimationBuilder<double>(
            key: ValueKey('weekly-bar-$replayKey-${summary.range.name}'),
            tween: Tween<double>(
              begin: reduceEffects ? 1 : 0,
              end: 1,
            ),
            duration: reduceEffects ? Duration.zero : durations.slow,
            curve: Curves.easeOutCubic,
            builder: (context, animProgress, _) {
              return SizedBox(
                key: const ValueKey('analytics-weekly-bar-chart'),
                height: 200,
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
                              if (idx < 0 || idx >= weeks.length) {
                                return const SizedBox.shrink();
                              }
                              if (idx % labelStep != 0 &&
                                  idx != weeks.length - 1) {
                                return const SizedBox.shrink();
                              }
                              final label = AppFormatters.formatDate(
                                weeks[idx].weekStart,
                                locale: locale,
                                pattern: 'd MMM',
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
                        for (var i = 0; i < weeks.length; i++)
                          BarChartGroupData(
                            x: i,
                            barRods: [
                              BarChartRodData(
                                toY: weeks[i].units * animProgress,
                                width: barWidth,
                                borderRadius: BorderRadius.vertical(
                                  top: Radius.circular(radii.sm),
                                ),
                                color: weeks[i].units > 0
                                    ? colors.info
                                    : colors.textMuted.withValues(alpha: 0.25),
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
                            final idx = group.x.clamp(0, weeks.length - 1);
                            final week = weeks[idx];
                            final startStr = AppFormatters.formatDate(
                              week.weekStart,
                              locale: locale,
                              pattern: 'd MMM',
                              useBanglaDigits: useBanglaDigits,
                            );
                            final endStr = AppFormatters.formatDate(
                              week.weekEnd,
                              locale: locale,
                              pattern: 'd MMM',
                              useBanglaDigits: useBanglaDigits,
                            );
                            final rangeStr = l10n.prepAnalyticsWeeklyRangeLabel(
                              startStr,
                              endStr,
                            );
                            return BarTooltipItem(
                              l10n.prepAnalyticsWeeklyTooltip(
                                rangeStr,
                                AppFormatters.formatNumber(
                                  week.units,
                                  locale: locale,
                                  useBanglaDigits: useBanglaDigits,
                                ),
                                AppFormatters.formatNumber(
                                  week.activeDays,
                                  locale: locale,
                                  useBanglaDigits: useBanglaDigits,
                                ),
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
}
