import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:job_prep/core/localization/app_localizations_extension.dart';
import 'package:job_prep/core/localization/formatters.dart';
import 'package:job_prep/core/localization/locale_controller.dart';
import 'package:job_prep/core/theme/app_theme_tokens.dart';
import 'package:job_prep/core/widgets/animated_progress_ring.dart';
import 'package:job_prep/core/widgets/glass_card.dart';
import 'package:job_prep/features/auth/presentation/providers/auth_providers.dart';
import 'package:job_prep/features/today/domain/entities/today_summary.dart';
import 'package:job_prep/features/today/presentation/utils/today_l10n.dart';

/// Top Today header displaying localized greeting, full date, refresh icon,
/// and replayable daily progress ring.
class TodayHeaderCard extends ConsumerWidget {
  /// Creates a [TodayHeaderCard].
  const TodayHeaderCard({
    required this.summary,
    required this.visitId,
    required this.onRefresh,
    super.key,
  });

  /// Live computed Today view model.
  final TodaySummary summary;

  /// Monotonic visit token replaying [AnimatedProgressRing] from zero on mount.
  final int visitId;

  /// Callback triggering a data refresh across Today providers.
  final VoidCallback onRefresh;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tokens = context.tokens;
    final colors = tokens.colors;
    final spacing = tokens.spacing;
    final l10n = context.l10n;
    final locale = ref.watch(localeProvider);
    final useBanglaDigits = ref.watch(useBanglaDigitsProvider);
    final user = ref.watch(currentUserProvider);

    final greeting = TodayL10n.greetingText(
      now: summary.date,
      user: user,
      l10n: l10n,
    );
    final formattedDate = AppFormatters.formatDate(
      summary.date,
      locale: locale,
      pattern: 'EEEE, d MMMM y',
      useBanglaDigits: useBanglaDigits,
    );

    final percentValue = (summary.dailyProgress * 100).round();
    final formattedPercent = TodayL10n.formatCount(
      percentValue,
      locale: locale,
      useBanglaDigits: useBanglaDigits,
    );
    final formattedDone = TodayL10n.formatCount(
      summary.dailyDoneUnits,
      locale: locale,
      useBanglaDigits: useBanglaDigits,
    );
    final formattedTarget = TodayL10n.formatCount(
      summary.dailyTargetUnits,
      locale: locale,
      useBanglaDigits: useBanglaDigits,
    );

    final ringColor =
        summary.hasActiveStudyPlans && summary.dailyProgress >= 1.0
            ? colors.success
            : colors.goldAccent;

    final progressSublabel = summary.hasActiveStudyPlans
        ? l10n.todayDailyDoneOfTarget(formattedDone, formattedTarget)
        : l10n.todayNoPlanHeaderHint;

    return GlassCard(
      key: const ValueKey('today-header-card'),
      padding: spacing.insetsAllXl,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isCompact = constraints.maxWidth < 420;
          final ringBlock = Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedProgressRing(
                key: const ValueKey('today-daily-progress-ring'),
                value: summary.hasActiveStudyPlans ? summary.dailyProgress : 0,
                replayKey: 'today-ring-$visitId',
                size: 88,
                strokeWidth: 7,
                progressColor: ringColor,
                child: Text(
                  l10n.todayProgressRingLabel(formattedPercent),
                  style: tokens.textStyles.titleMedium.copyWith(
                    color: colors.textPrimary,
                  ),
                ),
              ),
              SizedBox(width: spacing.md),
              Flexible(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      l10n.todayProgressRingCaption,
                      style: tokens.textStyles.labelLarge,
                    ),
                    SizedBox(height: spacing.xxs),
                    Text(
                      progressSublabel,
                      style: tokens.textStyles.bodySmall.copyWith(
                        color: summary.hasActiveStudyPlans
                            ? colors.goldAccent
                            : colors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );

          final textHeader = Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      greeting,
                      key: const ValueKey('today-greeting-text'),
                      style: tokens.textStyles.headlineMedium,
                    ),
                  ),
                  SizedBox(width: spacing.xs),
                  IconButton(
                    key: const ValueKey('today-refresh-button'),
                    tooltip: l10n.todayRefreshTooltip,
                    onPressed: onRefresh,
                    icon: const Icon(Icons.refresh_rounded),
                  ),
                ],
              ),
              SizedBox(height: spacing.xxs),
              Text(
                formattedDate,
                key: const ValueKey('today-date-text'),
                style: tokens.textStyles.labelLarge.copyWith(
                  color: colors.goldAccent,
                ),
              ),
              SizedBox(height: spacing.xxs),
              Text(
                l10n.todaySubtitle,
                style: tokens.textStyles.bodyMedium,
              ),
            ],
          );

          if (isCompact) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                textHeader,
                SizedBox(height: spacing.md),
                ringBlock,
              ],
            );
          }

          return Row(
            children: [
              Expanded(child: textHeader),
              SizedBox(width: spacing.xl),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 260),
                child: ringBlock,
              ),
            ],
          );
        },
      ),
    );
  }
}
