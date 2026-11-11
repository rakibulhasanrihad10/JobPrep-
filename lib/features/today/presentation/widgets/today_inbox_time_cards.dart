import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:job_prep/core/localization/app_localizations_extension.dart';
import 'package:job_prep/core/localization/locale_controller.dart';
import 'package:job_prep/core/theme/app_theme_tokens.dart';
import 'package:job_prep/core/widgets/glass_button.dart';
import 'package:job_prep/core/widgets/glass_card.dart';
import 'package:job_prep/features/today/presentation/utils/today_l10n.dart';

/// Displays the live pending Inbox count with a Review inbox action button.
class TodayInboxCard extends ConsumerWidget {
  /// Creates a [TodayInboxCard].
  const TodayInboxCard({
    required this.inboxCount,
    super.key,
  });

  /// Number of circulars currently waiting in Inbox triage status.
  final int inboxCount;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tokens = context.tokens;
    final colors = tokens.colors;
    final spacing = tokens.spacing;
    final radii = tokens.radii;
    final l10n = context.l10n;
    final locale = ref.watch(localeProvider);
    final useBanglaDigits = ref.watch(useBanglaDigitsProvider);
    final router = GoRouter.maybeOf(context);

    final fmtCount = TodayL10n.formatCount(
      inboxCount,
      locale: locale,
      useBanglaDigits: useBanglaDigits,
    );
    final accent = inboxCount > 0 ? colors.goldAccent : colors.success;

    return GlassCard(
      key: const ValueKey('today-inbox-card'),
      padding: spacing.insetsAllLg,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Icon(
                Icons.inbox_outlined,
                size: spacing.lg,
                color: accent,
              ),
              SizedBox(width: spacing.sm),
              Expanded(
                child: Text(
                  l10n.todayInboxTitle,
                  style: tokens.textStyles.titleMedium,
                ),
              ),
              Container(
                key: const ValueKey('today-inbox-count-chip'),
                padding: EdgeInsets.symmetric(
                  horizontal: spacing.sm,
                  vertical: spacing.xxs,
                ),
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.14),
                  borderRadius: radii.smRadius,
                  border: Border.all(color: accent.withValues(alpha: 0.45)),
                ),
                child: Text(
                  fmtCount,
                  style: tokens.textStyles.labelSmall.copyWith(color: accent),
                ),
              ),
            ],
          ),
          SizedBox(height: spacing.sm),
          Text(
            l10n.todayInboxWaitingSummary(inboxCount, fmtCount),
            style: tokens.textStyles.bodyMedium.copyWith(
              color: colors.textSecondary,
            ),
          ),
          SizedBox(height: spacing.md),
          Align(
            alignment: AlignmentDirectional.centerStart,
            child: GlassButton(
              key: const ValueKey('today-review-inbox-btn'),
              variant: inboxCount > 0
                  ? GlassButtonVariant.primary
                  : GlassButtonVariant.standard,
              onPressed: () => router?.go('/inbox'),
              leading: Icon(Icons.inbox_rounded, size: spacing.lg),
              child: Text(l10n.todayReviewInboxButton),
            ),
          ),
        ],
      ),
    );
  }
}

/// Displays total time studied today across study sessions and offers quick
/// access to the Study Timer.
class TodayTimeStudiedCard extends ConsumerWidget {
  /// Creates a [TodayTimeStudiedCard].
  const TodayTimeStudiedCard({
    required this.studiedSecondsToday,
    required this.sessionsTodayCount,
    required this.hasActiveSessionToday,
    super.key,
  });

  /// Total seconds studied on the current local calendar day.
  final int studiedSecondsToday;

  /// Count of sessions contributing today or started today.
  final int sessionsTodayCount;

  /// Whether an open active timer session exists today.
  final bool hasActiveSessionToday;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tokens = context.tokens;
    final colors = tokens.colors;
    final spacing = tokens.spacing;
    final radii = tokens.radii;
    final l10n = context.l10n;
    final locale = ref.watch(localeProvider);
    final useBanglaDigits = ref.watch(useBanglaDigitsProvider);
    final router = GoRouter.maybeOf(context);

    final durationText = TodayL10n.formatStudiedDuration(
      seconds: studiedSecondsToday,
      l10n: l10n,
      locale: locale,
      useBanglaDigits: useBanglaDigits,
    );
    final fmtSessions = TodayL10n.formatCount(
      sessionsTodayCount,
      locale: locale,
      useBanglaDigits: useBanglaDigits,
    );

    return GlassCard(
      key: const ValueKey('today-time-card'),
      padding: spacing.insetsAllLg,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Icon(
                Icons.timer_outlined,
                size: spacing.lg,
                color: colors.goldAccent,
              ),
              SizedBox(width: spacing.sm),
              Expanded(
                child: Text(
                  l10n.todayTimeStudiedTitle,
                  style: tokens.textStyles.titleMedium,
                ),
              ),
              if (hasActiveSessionToday)
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: spacing.sm,
                    vertical: spacing.xxs,
                  ),
                  decoration: BoxDecoration(
                    color: colors.success.withValues(alpha: 0.14),
                    borderRadius: radii.smRadius,
                    border: Border.all(
                      color: colors.success.withValues(alpha: 0.45),
                    ),
                  ),
                  child: Text(
                    l10n.todayTimeStudiedRunningNote,
                    style: tokens.textStyles.labelSmall.copyWith(
                      color: colors.success,
                    ),
                  ),
                ),
            ],
          ),
          SizedBox(height: spacing.md),
          Text(
            durationText,
            key: const ValueKey('today-time-studied-value'),
            style: tokens.textStyles.headlineMedium.copyWith(
              color: colors.goldAccent,
            ),
          ),
          SizedBox(height: spacing.xxs),
          Text(
            l10n.todayTimeStudiedSessionsSummary(
              sessionsTodayCount,
              fmtSessions,
            ),
            style: tokens.textStyles.bodySmall.copyWith(
              color: colors.textSecondary,
            ),
          ),
          SizedBox(height: spacing.md),
          Align(
            alignment: AlignmentDirectional.centerStart,
            child: GlassButton(
              key: const ValueKey('today-open-timer-btn'),
              onPressed: () => router?.go('/prep/timer'),
              leading: Icon(
                Icons.play_circle_outline_rounded,
                size: spacing.lg,
              ),
              child: Text(l10n.todayOpenTimerButton),
            ),
          ),
        ],
      ),
    );
  }
}
