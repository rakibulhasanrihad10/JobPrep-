import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:job_prep/core/localization/app_localizations_extension.dart';
import 'package:job_prep/core/localization/formatters.dart';
import 'package:job_prep/core/localization/locale_controller.dart';
import 'package:job_prep/core/theme/app_theme_tokens.dart';
import 'package:job_prep/core/widgets/animated_counter.dart';
import 'package:job_prep/core/widgets/glass_card.dart';
import 'package:job_prep/features/prep/domain/entities/mock_test.dart';

/// Four-card metric grid showing Latest, Best, Average, and Improvement scores.
class MockTestStatsGrid extends ConsumerWidget {
  /// Creates a [MockTestStatsGrid].
  const MockTestStatsGrid({
    required this.summary,
    required this.accentColor,
    super.key,
    this.replayKey,
  });

  /// Aggregated statistics to display.
  final MockTestSummary summary;

  /// Semantic accent color from the active subject or gold fallback.
  final Color accentColor;

  /// Optional animation replay key bumped when opening or switching tabs.
  final Object? replayKey;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tokens = context.tokens;
    final colors = tokens.colors;
    final spacing = tokens.spacing;
    final l10n = context.l10n;
    final locale = ref.watch(localeProvider);
    final useBanglaDigits = ref.watch(useBanglaDigitsProvider);

    final useLastFive = summary.testCount > 5;
    final improvementValue = useLastFive
        ? summary.improvementLastFive
        : summary.improvementFirstToLatest;

    final String improvementCaption;
    if (!summary.hasImprovementComparison) {
      improvementCaption = l10n.prepMockStatImprovementNeedsTwo;
    } else if (useLastFive) {
      final windowFormatted = AppFormatters.formatNumber(
        5,
        locale: locale,
        useBanglaDigits: useBanglaDigits,
      );
      improvementCaption =
          l10n.prepMockStatImprovementLastFive(windowFormatted);
    } else {
      improvementCaption = l10n.prepMockStatImprovementFirstToLatest;
    }

    final Color improvementColor;
    final IconData improvementIcon;
    if (!summary.hasImprovementComparison || improvementValue == 0) {
      improvementColor = colors.textSecondary;
      improvementIcon = Icons.trending_flat_rounded;
    } else if (improvementValue > 0) {
      improvementColor = colors.success;
      improvementIcon = Icons.trending_up_rounded;
    } else {
      improvementColor = colors.danger;
      improvementIcon = Icons.trending_down_rounded;
    }

    final percentSuffix = l10n.prepMockStatPercentValue('');

    final cards = <Widget>[
      _MetricTile(
        key: const ValueKey('mock-stat-latest'),
        label: l10n.prepMockStatLatest,
        icon: Icons.schedule_rounded,
        valueColor: accentColor,
        hasValue: summary.hasTests,
        value: summary.latestScore,
        percentSuffix: percentSuffix,
        replayKey: replayKey,
      ),
      _MetricTile(
        key: const ValueKey('mock-stat-best'),
        label: l10n.prepMockStatBest,
        icon: Icons.emoji_events_outlined,
        valueColor: colors.success,
        hasValue: summary.hasTests,
        value: summary.bestScore,
        percentSuffix: percentSuffix,
        replayKey: replayKey,
      ),
      _MetricTile(
        key: const ValueKey('mock-stat-average'),
        label: l10n.prepMockStatAverage,
        icon: Icons.show_chart_rounded,
        valueColor: colors.goldAccent,
        hasValue: summary.hasTests,
        value: summary.averageScore,
        percentSuffix: percentSuffix,
        replayKey: replayKey,
      ),
      _MetricTile(
        key: const ValueKey('mock-stat-improvement'),
        label: l10n.prepMockStatImprovement,
        icon: improvementIcon,
        valueColor: improvementColor,
        hasValue: summary.hasImprovementComparison,
        value: improvementValue,
        percentSuffix: percentSuffix,
        replayKey: replayKey,
        caption: improvementCaption,
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth >= 560) {
          return IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (var i = 0; i < cards.length; i++) ...[
                  if (i > 0) SizedBox(width: spacing.sm),
                  Expanded(child: cards[i]),
                ],
              ],
            ),
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(child: cards[0]),
                  SizedBox(width: spacing.sm),
                  Expanded(child: cards[1]),
                ],
              ),
            ),
            SizedBox(height: spacing.sm),
            IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(child: cards[2]),
                  SizedBox(width: spacing.sm),
                  Expanded(child: cards[3]),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

class _MetricTile extends StatelessWidget {
  const _MetricTile({
    required this.label,
    required this.icon,
    required this.valueColor,
    required this.hasValue,
    required this.value,
    required this.percentSuffix,
    super.key,
    this.replayKey,
    this.caption,
  });

  final String label;
  final IconData icon;
  final Color valueColor;
  final bool hasValue;
  final double value;
  final String percentSuffix;
  final Object? replayKey;
  final String? caption;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final colors = tokens.colors;
    final spacing = tokens.spacing;
    final l10n = context.l10n;

    return GlassCard(
      padding: spacing.insetsAllMd,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(icon, size: spacing.lg, color: valueColor),
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
            child: hasValue
                ? AnimatedCounter(
                    value: value,
                    decimalDigits: 1,
                    suffix: percentSuffix,
                    replayKey: replayKey,
                    style: tokens.textStyles.headlineMedium.copyWith(
                      color: valueColor,
                      fontWeight: FontWeight.w700,
                    ),
                  )
                : Text(
                    l10n.prepMockStatNotAvailable,
                    style: tokens.textStyles.headlineMedium.copyWith(
                      color: colors.textMuted,
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
