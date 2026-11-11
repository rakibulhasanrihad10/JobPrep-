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
import 'package:job_prep/features/prep/domain/entities/mock_test.dart';

/// Score percentage trend line chart with an average reference line,
/// respecting theme tokens and [reduceEffectsProvider].
class MockTestTrendChart extends ConsumerWidget {
  /// Creates a [MockTestTrendChart].
  const MockTestTrendChart({
    required this.summary,
    required this.accentColor,
    super.key,
    this.replayKey,
  });

  /// Aggregated summary containing chronological trend points and average.
  final MockTestSummary summary;

  /// Semantic accent color for the primary line and dots.
  final Color accentColor;

  /// Optional key triggering entrance animation replay when tabs/subjects open.
  final Object? replayKey;

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

    final avgFormatted = AppFormatters.formatNumber(
      summary.averageScore,
      locale: locale,
      useBanglaDigits: useBanglaDigits,
      decimalDigits: 1,
    );

    return GlassCard(
      key: const ValueKey('mock-test-trend-chart-card'),
      padding: spacing.insetsAllLg,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Icon(
                Icons.insights_rounded,
                size: spacing.lg,
                color: accentColor,
              ),
              SizedBox(width: spacing.sm),
              Expanded(
                child: Text(
                  l10n.prepMockTrendChartTitle,
                  style: tokens.textStyles.titleMedium,
                ),
              ),
              if (summary.hasTests)
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: spacing.sm,
                    vertical: spacing.xxs,
                  ),
                  decoration: BoxDecoration(
                    color: colors.goldAccentSubtle,
                    borderRadius: radii.smRadius,
                  ),
                  child: Text(
                    l10n.prepMockTrendAverageLineLabel(avgFormatted),
                    style: tokens.textStyles.labelSmall.copyWith(
                      color: colors.goldAccent,
                    ),
                  ),
                ),
            ],
          ),
          SizedBox(height: spacing.md),
          if (!summary.hasTests)
            Text(
              l10n.prepMockTrendNeedsDataHint,
              style: tokens.textStyles.bodyMedium.copyWith(
                color: colors.textSecondary,
              ),
            )
          else
            TweenAnimationBuilder<double>(
              key: ValueKey('trend-$replayKey-${summary.testCount}'),
              tween: Tween<double>(
                begin: reduceEffects ? 1 : 0,
                end: 1,
              ),
              duration: reduceEffects ? Duration.zero : durations.slow,
              curve: Curves.easeOutCubic,
              builder: (context, animProgress, _) {
                final points = summary.trendPoints;
                final isSingle = points.length == 1;
                final maxX = isSingle ? 1.0 : (points.length - 1).toDouble();
                final spots = <FlSpot>[
                  for (final pt in points)
                    FlSpot(
                      isSingle ? 0.5 : pt.index.toDouble(),
                      pt.scorePercent * animProgress,
                    ),
                ];
                final labelStep = math.max(1, (points.length / 4).ceil());

                return SizedBox(
                  key: const ValueKey('mock-test-trend-chart'),
                  height: 210,
                  child: Padding(
                    padding: EdgeInsets.only(
                      top: spacing.xs,
                      right: spacing.lg,
                    ),
                    child: LineChart(
                      duration:
                          reduceEffects ? Duration.zero : durations.normal,
                      curve: Curves.easeOutCubic,
                      LineChartData(
                        minX: 0,
                        maxX: maxX,
                        minY: 0,
                        maxY: 100,
                        gridData: FlGridData(
                          drawVerticalLine: false,
                          horizontalInterval: 25,
                          getDrawingHorizontalLine: (_) => FlLine(
                            color: colors.glassBorder.withValues(alpha: 0.5),
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
                            HorizontalLine(
                              y: summary.averageScore,
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
                              reservedSize: 48,
                              interval: 50,
                              getTitlesWidget: (value, meta) {
                                if (value % 50 != 0) {
                                  return const SizedBox.shrink();
                                }
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
                              interval: isSingle ? 0.5 : 1.0,
                              getTitlesWidget: (value, meta) {
                                final int idx;
                                if (isSingle) {
                                  if ((value - 0.5).abs() > 0.02) {
                                    return const SizedBox.shrink();
                                  }
                                  idx = 0;
                                } else {
                                  if ((value - value.round()).abs() > 0.02) {
                                    return const SizedBox.shrink();
                                  }
                                  idx = value.round();
                                  if (idx < 0 || idx >= points.length) {
                                    return const SizedBox.shrink();
                                  }
                                  if (idx % labelStep != 0 &&
                                      idx != points.length - 1) {
                                    return const SizedBox.shrink();
                                  }
                                }
                                final dateLabel = AppFormatters.formatDate(
                                  points[idx].test.takenOn,
                                  locale: locale,
                                  pattern: 'd MMM',
                                  useBanglaDigits: useBanglaDigits,
                                );
                                return SideTitleWidget(
                                  meta: meta,
                                  space: spacing.xs,
                                  child: Text(
                                    dateLabel,
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
                        lineBarsData: [
                          LineChartBarData(
                            spots: spots,
                            isCurved: points.length >= 3,
                            preventCurveOverShooting: true,
                            color: accentColor,
                            barWidth: 3,
                            isStrokeCapRound: true,
                            dotData: FlDotData(
                              getDotPainter: (spot, percent, bar, index) =>
                                  FlDotCirclePainter(
                                radius: 4.5,
                                color: accentColor,
                                strokeWidth: 2,
                                strokeColor: colors.surface,
                              ),
                            ),
                            belowBarData: BarAreaData(
                              show: true,
                              color: accentColor.withValues(alpha: 0.14),
                            ),
                          ),
                        ],
                        lineTouchData: LineTouchData(
                          touchTooltipData: LineTouchTooltipData(
                            getTooltipColor: (_) => colors.surfaceElevated,
                            tooltipBorderRadius: radii.mdRadius,
                            fitInsideHorizontally: true,
                            fitInsideVertically: true,
                            getTooltipItems: (touchedSpots) =>
                                touchedSpots.map((spot) {
                              final idx = isSingle
                                  ? 0
                                  : spot.x.round().clamp(0, points.length - 1);
                              final pt = points[idx];
                              final pct = AppFormatters.formatNumber(
                                pt.scorePercent,
                                locale: locale,
                                useBanglaDigits: useBanglaDigits,
                                decimalDigits: 1,
                              );
                              final date = AppFormatters.formatDate(
                                pt.test.takenOn,
                                locale: locale,
                                pattern: 'd MMM yyyy',
                                useBanglaDigits: useBanglaDigits,
                              );
                              return LineTooltipItem(
                                l10n.prepMockTrendTooltip(
                                  pt.test.title,
                                  pct,
                                  date,
                                ),
                                tokens.textStyles.bodySmall.copyWith(
                                  color: colors.textPrimary,
                                ),
                              );
                            }).toList(),
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
