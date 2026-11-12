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
import 'package:job_prep/features/prep/presentation/utils/study_timer_l10n.dart';

/// Daily study hours bar chart rendered inside Phase 6E Study Analytics.
class StudyAnalyticsDailyHoursChart extends ConsumerWidget {
  /// Creates a [StudyAnalyticsDailyHoursChart].
  const StudyAnalyticsDailyHoursChart({
    required this.summary,
    required this.replayKey,
    super.key,
  });

  /// Computed study analytics summary containing `dailyTotals.hours`.
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

    final days = summary.dailyTotals;
    var maxHours = 0.0;
    for (final d in days) {
      if (d.hours > maxHours) maxHours = d.hours;
    }
    final rawMaxY = maxHours * 1.2 < 2.0 ? 2.0 : maxHours * 1.2;
    final yInterval = math.max(0.5, (rawMaxY / 4 * 2).ceil() / 2);
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
      key: const ValueKey('analytics-daily-hours-card'),
      padding: spacing.insetsAllLg,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Icon(
                Icons.schedule_rounded,
                size: spacing.lg,
                color: colors.info,
              ),
              SizedBox(width: spacing.xs),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.prepAnalyticsDailyHoursTitle,
                      style: tokens.textStyles.titleMedium,
                    ),
                    Text(
                      l10n.prepAnalyticsDailyHoursSubtitle,
                      style: tokens.textStyles.bodySmall.copyWith(
                        color: colors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: spacing.md),
          TweenAnimationBuilder<double>(
            key: ValueKey('daily-hours-$replayKey-${summary.range.name}'),
            tween: Tween<double>(
              begin: reduceEffects ? 1 : 0,
              end: 1,
            ),
            duration: reduceEffects ? Duration.zero : durations.slow,
            curve: Curves.easeOutCubic,
            builder: (context, animProgress, _) {
              return SizedBox(
                key: const ValueKey('analytics-daily-hours-chart'),
                height: 210,
                child: Semantics(
                  label: l10n.prepAnalyticsDailyHoursTitle,
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
                        show: true,
                        border: Border(
                          left: BorderSide(color: colors.glassBorder),
                          bottom: BorderSide(color: colors.glassBorder),
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
                              final formatted = AppFormatters.formatNumber(
                                value,
                                locale: locale,
                                useBanglaDigits: useBanglaDigits,
                                decimalDigits: value % 1 == 0 ? 0 : 1,
                              );
                              return SideTitleWidget(
                                meta: meta,
                                space: spacing.xs,
                                child: Text(
                                  l10n.prepAnalyticsHoursValue(formatted),
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
                                toY: days[i].hours * animProgress,
                                width: barWidth,
                                borderRadius: BorderRadius.vertical(
                                  top: Radius.circular(radii.sm),
                                ),
                                color: days[i].hasQualifyingSession
                                    ? colors.success
                                    : (days[i].sessionSeconds > 0
                                        ? colors.info
                                        : colors.textMuted
                                            .withValues(alpha: 0.25)),
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
                          getTooltipItem: (group, _, __, ___) {
                            final idx = group.x.clamp(0, days.length - 1);
                            final day = days[idx];
                            final dateLabel = AppFormatters.formatDate(
                              day.date,
                              locale: locale,
                              pattern: 'd MMM yyyy',
                              useBanglaDigits: useBanglaDigits,
                            );
                            final hrsLabel = StudyTimerL10n.formatHoursNumber(
                              day.sessionSeconds,
                              locale: locale,
                              useBanglaDigits: useBanglaDigits,
                            );
                            return BarTooltipItem(
                              l10n.prepAnalyticsDailyHoursTooltip(
                                dateLabel,
                                hrsLabel,
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
