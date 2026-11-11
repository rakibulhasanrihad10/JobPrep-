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

/// Donut pie chart + accessible legend listing where study units (and mock
/// tests) went across subjects in the selected date window.
class StudyAnalyticsSubjectBreakdownCard extends ConsumerWidget {
  /// Creates a [StudyAnalyticsSubjectBreakdownCard].
  const StudyAnalyticsSubjectBreakdownCard({
    required this.summary,
    required this.replayKey,
    super.key,
  });

  /// Computed study analytics summary containing subject breakdown entries.
  final StudyAnalyticsSummary summary;

  /// Key triggering animation from zero when opening or switching tabs.
  final Object replayKey;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tokens = context.tokens;
    final colors = tokens.colors;
    final spacing = tokens.spacing;
    final durations = tokens.durations;
    final l10n = context.l10n;
    final locale = ref.watch(localeProvider);
    final useBanglaDigits = ref.watch(useBanglaDigitsProvider);
    final reduceEffects = ref.watch(reduceEffectsProvider);

    final items = summary.subjectBreakdown;
    final hasUnitSlices = items.any((item) => item.units > 0);

    return GlassCard(
      key: const ValueKey('analytics-subject-breakdown-card'),
      padding: spacing.insetsAllLg,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Icon(
                Icons.pie_chart_outline_rounded,
                size: spacing.lg,
                color: colors.accentSecondary,
              ),
              SizedBox(width: spacing.xs),
              Expanded(
                child: Text(
                  l10n.prepAnalyticsSubjectChartTitle,
                  style: tokens.textStyles.titleMedium,
                ),
              ),
            ],
          ),
          SizedBox(height: spacing.md),
          if (items.isEmpty)
            Text(
              l10n.prepAnalyticsSubjectNoData,
              style: tokens.textStyles.bodyMedium.copyWith(
                color: colors.textSecondary,
              ),
            )
          else
            LayoutBuilder(
              builder: (context, constraints) {
                final legend = _LegendList(
                  items: items,
                  locale: locale,
                  useBanglaDigits: useBanglaDigits,
                );

                if (!hasUnitSlices) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        l10n.prepAnalyticsSubjectNoData,
                        style: tokens.textStyles.bodySmall.copyWith(
                          color: colors.textSecondary,
                        ),
                      ),
                      SizedBox(height: spacing.sm),
                      legend,
                    ],
                  );
                }

                final chartWidget = TweenAnimationBuilder<double>(
                  key: ValueKey('subject-pie-$replayKey-${summary.range.name}'),
                  tween: Tween<double>(
                    begin: reduceEffects ? 1 : 0,
                    end: 1,
                  ),
                  duration: reduceEffects ? Duration.zero : durations.slow,
                  curve: Curves.easeOutCubic,
                  builder: (context, animProgress, _) {
                    return SizedBox(
                      key: const ValueKey('analytics-subject-pie-chart'),
                      width: 170,
                      height: 170,
                      child: PieChart(
                        duration:
                            reduceEffects ? Duration.zero : durations.normal,
                        curve: Curves.easeOutCubic,
                        PieChartData(
                          startDegreeOffset: -90,
                          sectionsSpace: 2,
                          centerSpaceRadius: 36,
                          sections: [
                            for (final item in items)
                              if (item.units > 0)
                                PieChartSectionData(
                                  value: item.units.toDouble(),
                                  title: '',
                                  radius: 10 + 26 * animProgress,
                                  color: PrepStyleTokens.resolveSubjectColor(
                                    item.colorKey,
                                    colors,
                                  ),
                                ),
                          ],
                        ),
                      ),
                    );
                  },
                );

                if (constraints.maxWidth >= 460) {
                  return Row(
                    children: [
                      chartWidget,
                      SizedBox(width: spacing.lg),
                      Expanded(child: legend),
                    ],
                  );
                }

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Center(child: chartWidget),
                    SizedBox(height: spacing.md),
                    legend,
                  ],
                );
              },
            ),
        ],
      ),
    );
  }
}

class _LegendList extends StatelessWidget {
  const _LegendList({
    required this.items,
    required this.locale,
    required this.useBanglaDigits,
  });

  final List<SubjectStudyBreakdown> items;
  final Locale locale;
  final bool useBanglaDigits;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final colors = tokens.colors;
    final spacing = tokens.spacing;
    final l10n = context.l10n;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (var i = 0; i < items.length; i++) ...[
          if (i > 0) SizedBox(height: spacing.sm),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                margin: EdgeInsets.only(top: spacing.xxs),
                width: spacing.md,
                height: spacing.md,
                decoration: BoxDecoration(
                  color: PrepStyleTokens.resolveSubjectColor(
                    items[i].colorKey,
                    colors,
                  ),
                  borderRadius: tokens.radii.smRadius,
                ),
              ),
              SizedBox(width: spacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      items[i].subjectName,
                      style: tokens.textStyles.labelLarge,
                    ),
                    Text(
                      l10n.prepAnalyticsSubjectRowSubtitle(
                        AppFormatters.formatNumber(
                          items[i].units,
                          locale: locale,
                          useBanglaDigits: useBanglaDigits,
                        ),
                        AppFormatters.formatNumber(
                          (items[i].share * 100).round(),
                          locale: locale,
                          useBanglaDigits: useBanglaDigits,
                        ),
                      ),
                      style: tokens.textStyles.bodySmall.copyWith(
                        color: colors.textSecondary,
                      ),
                    ),
                    if (items[i].mockTestCount > 0 &&
                        items[i].averageMockScore != null)
                      Text(
                        l10n.prepAnalyticsSubjectMockHint(
                          items[i].mockTestCount,
                          AppFormatters.formatNumber(
                            items[i].mockTestCount,
                            locale: locale,
                            useBanglaDigits: useBanglaDigits,
                          ),
                          AppFormatters.formatNumber(
                            items[i].averageMockScore!,
                            locale: locale,
                            useBanglaDigits: useBanglaDigits,
                            decimalDigits: 1,
                          ),
                        ),
                        style: tokens.textStyles.bodySmall.copyWith(
                          color: colors.goldAccent,
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }
}
