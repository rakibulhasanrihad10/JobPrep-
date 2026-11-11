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
import 'package:job_prep/features/prep/presentation/utils/prep_style_tokens.dart';
import 'package:job_prep/features/prep/presentation/utils/study_timer_l10n.dart';

/// Per-subject study hours `BarChart` and color legend inside Study Analytics.
class StudyAnalyticsSubjectHoursCard extends ConsumerWidget {
  /// Creates a [StudyAnalyticsSubjectHoursCard].
  const StudyAnalyticsSubjectHoursCard({
    required this.summary,
    required this.replayKey,
    super.key,
  });

  /// Computed study analytics summary with subject breakdown times.
  final StudyAnalyticsSummary summary;

  /// Key replaying bar entrance from zero when switching tabs or filters.
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

    final timedSubjects = summary.subjectBreakdown
        .where((item) => item.sessionSeconds > 0)
        .toList(growable: false)
      ..sort((a, b) => b.sessionSeconds.compareTo(a.sessionSeconds));

    var maxHours = 0.0;
    for (final s in timedSubjects) {
      if (s.hours > maxHours) maxHours = s.hours;
    }
    final rawMaxY = maxHours * 1.2 < 1.0 ? 1.0 : maxHours * 1.2;
    final yInterval = math.max(0.25, (rawMaxY / 4 * 4).ceil() / 4);
    final maxY = yInterval * 4;

    return GlassCard(
      key: const ValueKey('analytics-subject-hours-card'),
      padding: spacing.insetsAllLg,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Icon(
                Icons.hourglass_bottom_rounded,
                size: spacing.lg,
                color: colors.goldAccent,
              ),
              SizedBox(width: spacing.xs),
              Expanded(
                child: Text(
                  l10n.prepAnalyticsSubjectHoursTitle,
                  style: tokens.textStyles.titleMedium,
                ),
              ),
            ],
          ),
          SizedBox(height: spacing.md),
          if (timedSubjects.isEmpty)
            Text(
              l10n.prepAnalyticsSubjectHoursEmpty,
              key: const ValueKey('analytics-subject-hours-empty'),
              style: tokens.textStyles.bodyMedium.copyWith(
                color: colors.textSecondary,
              ),
            )
          else
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TweenAnimationBuilder<double>(
                  key: ValueKey(
                    'subject-hours-$replayKey-${summary.range.name}',
                  ),
                  tween: Tween<double>(
                    begin: reduceEffects ? 1 : 0,
                    end: 1,
                  ),
                  duration: reduceEffects ? Duration.zero : durations.slow,
                  curve: Curves.easeOutCubic,
                  builder: (context, animProgress, _) {
                    return SizedBox(
                      key: const ValueKey('analytics-subject-hours-chart'),
                      height: 180,
                      child: BarChart(
                        duration:
                            reduceEffects ? Duration.zero : durations.normal,
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
                                      style: tokens.textStyles.bodySmall
                                          .copyWith(color: colors.textMuted),
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
                                  if (idx < 0 || idx >= timedSubjects.length) {
                                    return const SizedBox.shrink();
                                  }
                                  return SideTitleWidget(
                                    meta: meta,
                                    space: spacing.xs,
                                    child: ConstrainedBox(
                                      constraints:
                                          const BoxConstraints(maxWidth: 72),
                                      child: Text(
                                        timedSubjects[idx].subjectName,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: tokens.textStyles.bodySmall
                                            .copyWith(color: colors.textMuted),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                          barGroups: [
                            for (var i = 0; i < timedSubjects.length; i++)
                              BarChartGroupData(
                                x: i,
                                barRods: [
                                  BarChartRodData(
                                    toY: timedSubjects[i].hours * animProgress,
                                    width: 24,
                                    borderRadius: BorderRadius.vertical(
                                      top: Radius.circular(radii.sm),
                                    ),
                                    color: PrepStyleTokens.resolveSubjectColor(
                                      timedSubjects[i].colorKey,
                                      colors,
                                    ),
                                  ),
                                ],
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
                SizedBox(height: spacing.md),
                Wrap(
                  spacing: spacing.md,
                  runSpacing: spacing.xs,
                  children: [
                    for (final item in timedSubjects)
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: spacing.sm,
                            height: spacing.sm,
                            decoration: BoxDecoration(
                              color: PrepStyleTokens.resolveSubjectColor(
                                item.colorKey,
                                colors,
                              ),
                              shape: BoxShape.circle,
                            ),
                          ),
                          SizedBox(width: spacing.xs),
                          Text(
                            l10n.prepAnalyticsSubjectHoursLegend(
                              item.subjectName,
                              StudyTimerL10n.formatHoursNumber(
                                item.sessionSeconds,
                                locale: locale,
                                useBanglaDigits: useBanglaDigits,
                              ),
                            ),
                            style: tokens.textStyles.bodySmall,
                          ),
                        ],
                      ),
                  ],
                ),
              ],
            ),
        ],
      ),
    );
  }
}
