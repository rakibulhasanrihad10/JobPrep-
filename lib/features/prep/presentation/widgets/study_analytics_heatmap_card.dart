import 'dart:math' as math;

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

/// Rolling 91-day (13-week) Mon–Sun calendar heatmap visualizing daily study
/// consistency across local dates without per-cell blur overhead.
class StudyAnalyticsHeatmapCard extends ConsumerWidget {
  /// Creates a [StudyAnalyticsHeatmapCard].
  const StudyAnalyticsHeatmapCard({
    required this.summary,
    required this.replayKey,
    super.key,
  });

  /// Computed study analytics summary containing heatmap days.
  final StudyAnalyticsSummary summary;

  /// Key replaying reveal animation each time the Analytics tab opens.
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

    final days = summary.heatmapDays;
    if (days.isEmpty) {
      return const SizedBox.shrink();
    }

    var maxUnits = 0;
    for (final d in days) {
      if (d.units > maxUnits) maxUnits = d.units;
    }

    final leadingEmpty = days.first.date.weekday - DateTime.monday;
    final padded = <DailyStudyTotal?>[
      for (var i = 0; i < leadingEmpty; i++) null,
      ...days,
    ];
    final weekCount = (padded.length / 7).ceil();
    final columns = <List<DailyStudyTotal?>>[
      for (var w = 0; w < weekCount; w++)
        [
          for (var r = 0; r < 7; r++)
            if ((w * 7 + r) < padded.length) padded[w * 7 + r] else null,
        ],
    ];

    final weekdaySamples = <DateTime>[
      DateTime(2026, 11, 2), // Monday
      DateTime(2026, 11, 4), // Wednesday
      DateTime(2026, 11, 6), // Friday
    ];

    return GlassCard(
      key: const ValueKey('analytics-heatmap-card'),
      padding: spacing.insetsAllLg,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Icon(
                Icons.grid_view_rounded,
                size: spacing.lg,
                color: colors.success,
              ),
              SizedBox(width: spacing.xs),
              Expanded(
                child: Text(
                  l10n.prepAnalyticsHeatmapTitle,
                  style: tokens.textStyles.titleMedium,
                ),
              ),
            ],
          ),
          SizedBox(height: spacing.md),
          TweenAnimationBuilder<double>(
            key: ValueKey('heatmap-$replayKey'),
            tween: Tween<double>(
              begin: reduceEffects ? 1 : 0,
              end: 1,
            ),
            duration: reduceEffects ? Duration.zero : durations.slow,
            curve: Curves.easeOutCubic,
            builder: (context, animProgress, _) {
              return Opacity(
                opacity: animProgress.clamp(0.0, 1.0),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: EdgeInsets.only(right: spacing.sm),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            for (var r = 0; r < 7; r++) ...[
                              if (r > 0) SizedBox(height: spacing.xs),
                              SizedBox(
                                height: 14,
                                child: (r == 0 || r == 2 || r == 4)
                                    ? Align(
                                        alignment: Alignment.centerRight,
                                        child: Text(
                                          AppFormatters.formatDate(
                                            weekdaySamples[r ~/ 2],
                                            locale: locale,
                                            pattern: 'E',
                                            useBanglaDigits: useBanglaDigits,
                                          ),
                                          style: tokens.textStyles.labelSmall
                                              .copyWith(
                                            color: colors.textMuted,
                                          ),
                                        ),
                                      )
                                    : const SizedBox.shrink(),
                              ),
                            ],
                          ],
                        ),
                      ),
                      for (var w = 0; w < columns.length; w++) ...[
                        if (w > 0) SizedBox(width: spacing.xs),
                        Column(
                          children: [
                            for (var r = 0; r < 7; r++) ...[
                              if (r > 0) SizedBox(height: spacing.xs),
                              _HeatmapCell(
                                entry: columns[w][r],
                                maxUnits: math.max(
                                  maxUnits,
                                  summary.dailyTarget ?? 1,
                                ),
                                locale: locale,
                                useBanglaDigits: useBanglaDigits,
                                colors: colors,
                              ),
                            ],
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              );
            },
          ),
          SizedBox(height: spacing.md),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(
                l10n.prepAnalyticsHeatmapLess,
                style: tokens.textStyles.labelSmall.copyWith(
                  color: colors.textMuted,
                ),
              ),
              SizedBox(width: spacing.xs),
              for (var tier = 0; tier <= 4; tier++) ...[
                Container(
                  margin: EdgeInsets.symmetric(horizontal: spacing.xxs),
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: _colorForTier(tier, colors),
                    borderRadius: tokens.radii.smRadius,
                    border: Border.all(
                      color: colors.glassBorder.withValues(alpha: 0.4),
                    ),
                  ),
                ),
              ],
              SizedBox(width: spacing.xs),
              Text(
                l10n.prepAnalyticsHeatmapMore,
                style: tokens.textStyles.labelSmall.copyWith(
                  color: colors.textMuted,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  static Color _colorForTier(int tier, AppColorsToken colors) {
    return switch (tier) {
      0 => colors.surfaceElevated,
      1 => colors.goldAccent.withValues(alpha: 0.30),
      2 => colors.goldAccent.withValues(alpha: 0.65),
      3 => colors.success.withValues(alpha: 0.65),
      _ => colors.success,
    };
  }
}

class _HeatmapCell extends StatelessWidget {
  const _HeatmapCell({
    required this.entry,
    required this.maxUnits,
    required this.locale,
    required this.useBanglaDigits,
    required this.colors,
  });

  final DailyStudyTotal? entry;
  final int maxUnits;
  final Locale locale;
  final bool useBanglaDigits;
  final AppColorsToken colors;

  @override
  Widget build(BuildContext context) {
    final day = entry;
    if (day == null) {
      return const SizedBox(width: 14, height: 14);
    }

    final l10n = context.l10n;
    final tier = _tierForUnits(day.units, maxUnits);
    final cellColor = StudyAnalyticsHeatmapCard._colorForTier(tier, colors);

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

    return Tooltip(
      message: l10n.prepAnalyticsHeatmapTooltip(dateLabel, unitsLabel),
      child: Container(
        key: ValueKey(
          'heatmap-cell-${day.date.year}-${day.date.month}-${day.date.day}',
        ),
        width: 14,
        height: 14,
        decoration: BoxDecoration(
          color: cellColor,
          borderRadius: context.tokens.radii.smRadius,
          border: Border.all(
            color: day.units > 0
                ? cellColor
                : colors.glassBorder.withValues(alpha: 0.45),
          ),
        ),
      ),
    );
  }

  int _tierForUnits(int units, int peak) {
    if (units <= 0) return 0;
    if (peak <= 1) return 4;
    final ratio = units / peak;
    if (ratio >= 0.75) return 4;
    if (ratio >= 0.50) return 3;
    if (ratio >= 0.25) return 2;
    return 1;
  }
}
