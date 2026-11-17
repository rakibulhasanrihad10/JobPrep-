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
import 'package:job_prep/features/prep/domain/utils/weekly_topic_counts_calculator.dart';

/// Bar chart summarizing syllabus topics completed per calendar week.
class StudyAnalyticsTopicsWeeklyChart extends ConsumerWidget {
  /// Creates a [StudyAnalyticsTopicsWeeklyChart].
  const StudyAnalyticsTopicsWeeklyChart({
    required this.buckets,
    required this.replayKey,
    super.key,
  });

  /// Precomputed weekly topic completion buckets.
  final List<WeeklyTopicBucket> buckets;

  /// Key triggering animation replay.
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

    var maxTopics = 0;
    for (final b in buckets) {
      if (b.completedCount > maxTopics) maxTopics = b.completedCount;
    }
    final rawMaxY = (maxTopics * 1.25).ceil();
    final effectiveMax = rawMaxY < 5 ? 5 : rawMaxY;
    final yInterval = math.max(1, (effectiveMax / 4).ceil()).toDouble();
    final maxY = yInterval * 4;
    final labelStep = math.max(1, (buckets.length / 5).ceil());
    final barWidth = buckets.length <= 5 ? 24.0 : 12.0;

    return GlassCard(
      key: const ValueKey('analytics-topics-weekly-chart-card'),
      padding: spacing.insetsAllLg,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Icon(
                Icons.checklist_rounded,
                size: spacing.lg,
                color: colors.goldAccent,
              ),
              SizedBox(width: spacing.xs),
              Expanded(
                child: Text(
                  l10n.prepAnalyticsWeeklyTopicsTitle,
                  style: tokens.textStyles.titleMedium,
                ),
              ),
            ],
          ),
          SizedBox(height: spacing.md),
          TweenAnimationBuilder<double>(
            key: ValueKey('topics-weekly-bar-$replayKey'),
            tween: Tween<double>(
              begin: reduceEffects ? 1 : 0,
              end: 1,
            ),
            duration: reduceEffects ? Duration.zero : durations.slow,
            curve: Curves.easeOutCubic,
            builder: (context, animProgress, _) {
              return SizedBox(
                key: const ValueKey('analytics-topics-weekly-bar-chart'),
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
                            reservedSize: 40,
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
                              if (idx < 0 || idx >= buckets.length) {
                                return const SizedBox.shrink();
                              }
                              if (idx % labelStep != 0 &&
                                  idx != buckets.length - 1) {
                                return const SizedBox.shrink();
                              }
                              final label = AppFormatters.formatDate(
                                buckets[idx].weekStart,
                                locale: locale,
                                pattern: 'd MMM',
                                useBanglaDigits: useBanglaDigits,
                              );
                              return SideTitleWidget(
                                meta: meta,
                                space: spacing.xs,
                                child: Text(
                                  label,
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
                        for (var i = 0; i < buckets.length; i++)
                          BarChartGroupData(
                            x: i,
                            barRods: [
                              BarChartRodData(
                                toY: buckets[i].completedCount * animProgress,
                                width: barWidth,
                                borderRadius: BorderRadius.vertical(
                                  top: Radius.circular(radii.sm),
                                ),
                                color: buckets[i].completedCount > 0
                                    ? colors.goldAccent
                                    : colors.textMuted.withValues(alpha: 0.25),
                              ),
                            ],
                          ),
                      ],
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
