import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:job_prep/core/localization/app_localizations_extension.dart';
import 'package:job_prep/core/localization/formatters.dart';
import 'package:job_prep/core/localization/locale_controller.dart';
import 'package:job_prep/core/theme/app_theme_tokens.dart';
import 'package:job_prep/core/widgets/glass_card.dart';
import 'package:job_prep/features/prep/domain/entities/study_analytics.dart';

/// Warning card highlighting when today and/or yesterday finished below the
/// active study plan's daily unit target.
class StudyAnalyticsTargetBanner extends ConsumerWidget {
  /// Creates a [StudyAnalyticsTargetBanner].
  const StudyAnalyticsTargetBanner({
    required this.summary,
    super.key,
  });

  /// Computed study analytics snapshot.
  final StudyAnalyticsSummary summary;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final target = summary.dailyTarget;
    if (target == null ||
        target <= 0 ||
        summary.targetAlertStatus == StudyDayTargetStatus.onTrackOrNoTarget) {
      return const SizedBox.shrink();
    }

    final tokens = context.tokens;
    final colors = tokens.colors;
    final spacing = tokens.spacing;
    final l10n = context.l10n;
    final locale = ref.watch(localeProvider);
    final useBanglaDigits = ref.watch(useBanglaDigitsProvider);

    final title = switch (summary.targetAlertStatus) {
      StudyDayTargetStatus.bothBelowTarget => l10n.prepAnalyticsAlertBothTitle,
      StudyDayTargetStatus.todayBelowTarget =>
        l10n.prepAnalyticsAlertTodayTitle,
      StudyDayTargetStatus.yesterdayBelowTarget =>
        l10n.prepAnalyticsAlertYesterdayTitle,
      StudyDayTargetStatus.onTrackOrNoTarget => '',
    };

    final todayFmt = AppFormatters.formatNumber(
      summary.todayUnits,
      locale: locale,
      useBanglaDigits: useBanglaDigits,
    );
    final yesterdayFmt = AppFormatters.formatNumber(
      summary.yesterdayUnits,
      locale: locale,
      useBanglaDigits: useBanglaDigits,
    );
    final targetFmt = AppFormatters.formatNumber(
      target,
      locale: locale,
      useBanglaDigits: useBanglaDigits,
    );

    return GlassCard(
      key: const ValueKey('analytics-below-target-banner'),
      padding: spacing.insetsAllLg,
      borderColor: colors.warning,
      fillColor: colors.warning.withValues(alpha: 0.12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.warning_amber_rounded,
            color: colors.warning,
            size: spacing.xl,
          ),
          SizedBox(width: spacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: tokens.textStyles.titleMedium.copyWith(
                    color: colors.textPrimary,
                  ),
                ),
                SizedBox(height: spacing.xxs),
                Text(
                  l10n.prepAnalyticsAlertBody(
                    todayFmt,
                    yesterdayFmt,
                    targetFmt,
                  ),
                  style: tokens.textStyles.bodySmall.copyWith(
                    color: colors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
