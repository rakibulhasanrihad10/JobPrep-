import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:job_prep/core/localization/app_localizations_extension.dart';
import 'package:job_prep/core/localization/formatters.dart';
import 'package:job_prep/core/localization/locale_controller.dart';
import 'package:job_prep/core/theme/app_theme_tokens.dart';
import 'package:job_prep/core/widgets/fade_slide_in.dart';
import 'package:job_prep/core/widgets/glass_button.dart';
import 'package:job_prep/core/widgets/glass_card.dart';
import 'package:job_prep/features/auth/presentation/navigation/auth_redirect.dart';
import 'package:job_prep/features/notifications/domain/entities/weekly_review_summary.dart';
import 'package:job_prep/features/notifications/presentation/providers/notifications_providers.dart';
import 'package:job_prep/features/notifications/presentation/utils/notification_message_formatter.dart';
import 'package:job_prep/features/notifications/presentation/widgets/weekly_review_metrics_grid.dart';
import 'package:job_prep/features/notifications/presentation/widgets/weekly_review_upcoming_card.dart';

/// Weekly Review digest screen (`/weekly-review`) summarizing the trailing 7
/// local days compared with the previous 7 days plus next-week focus guidance.
class WeeklyReviewScreen extends ConsumerWidget {
  /// Creates a [WeeklyReviewScreen].
  const WeeklyReviewScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tokens = context.tokens;
    final spacing = tokens.spacing;
    final breakpoints = tokens.breakpoints;
    final l10n = context.l10n;
    final locale = ref.watch(localeProvider);
    final useBanglaDigits = ref.watch(useBanglaDigitsProvider);
    final summaryAsync = ref.watch(weeklyReviewSummaryProvider);
    final width = MediaQuery.sizeOf(context).width;
    final horizontalPad =
        breakpoints.isCompact(width) ? spacing.lg : spacing.xl;

    return SingleChildScrollView(
      key: const ValueKey('weekly-review-screen'),
      padding: EdgeInsets.fromLTRB(
        horizontalPad,
        spacing.xl,
        horizontalPad,
        spacing.xl + spacing.xxxl,
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: breakpoints.maxContentWidth),
          child: summaryAsync.when(
            loading: () => Padding(
              padding: EdgeInsets.symmetric(vertical: spacing.xxxl),
              child: const Center(child: CircularProgressIndicator()),
            ),
            error: (_, __) => GlassCard(
              key: const ValueKey('weekly-review-error-card'),
              padding: spacing.insetsAllXl,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    l10n.todayLoadError,
                    style: tokens.textStyles.titleMedium,
                  ),
                  SizedBox(height: spacing.md),
                  Align(
                    alignment: AlignmentDirectional.centerStart,
                    child: GlassButton(
                      onPressed: () =>
                          GoRouter.maybeOf(context)?.go(AppRoutePaths.today),
                      child: Text(l10n.weeklyReviewBackToToday),
                    ),
                  ),
                ],
              ),
            ),
            data: (summary) => _WeeklyReviewBody(
              summary: summary,
              locale: locale,
              useBanglaDigits: useBanglaDigits,
            ),
          ),
        ),
      ),
    );
  }
}

class _WeeklyReviewBody extends StatelessWidget {
  const _WeeklyReviewBody({
    required this.summary,
    required this.locale,
    required this.useBanglaDigits,
  });

  final WeeklyReviewSummary summary;
  final Locale locale;
  final bool useBanglaDigits;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final tokenColors = tokens.colors;
    final spacing = tokens.spacing;
    final l10n = context.l10n;

    final startLabel = AppFormatters.formatDate(
      summary.weekStart,
      locale: locale,
      pattern: 'd MMM',
      useBanglaDigits: useBanglaDigits,
    );
    final endLabel = AppFormatters.formatDate(
      summary.weekEnd,
      locale: locale,
      pattern: 'd MMM yyyy',
      useBanglaDigits: useBanglaDigits,
    );
    final suggestionText = NotificationMessageFormatter.formatWeeklySuggestion(
      summary: summary,
      l10n: l10n,
      locale: locale,
      useBanglaDigits: useBanglaDigits,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        FadeSlideIn(
          child: GlassCard(
            key: const ValueKey('weekly-review-header-card'),
            padding: spacing.insetsAllXl,
            child: Wrap(
              spacing: spacing.md,
              runSpacing: spacing.md,
              alignment: WrapAlignment.spaceBetween,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.insights_outlined,
                          size: spacing.xl,
                          color: tokenColors.goldAccent,
                        ),
                        SizedBox(width: spacing.sm),
                        Flexible(
                          child: Text(
                            l10n.weeklyReviewTitle,
                            style: tokens.textStyles.headlineMedium,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: spacing.xs),
                    Text(
                      l10n.weeklyReviewPeriodSubtitle(startLabel, endLabel),
                      style: tokens.textStyles.bodyMedium,
                    ),
                  ],
                ),
                GlassButton(
                  key: const ValueKey('weekly-review-back-today-btn'),
                  onPressed: () =>
                      GoRouter.maybeOf(context)?.go(AppRoutePaths.today),
                  leading: Icon(Icons.today_outlined, size: spacing.lg),
                  child: Text(l10n.weeklyReviewBackToToday),
                ),
              ],
            ),
          ),
        ),
        SizedBox(height: spacing.lg),
        FadeSlideIn(
          index: 1,
          child: WeeklyReviewMetricsGrid(
            summary: summary,
            replayKey: summary.weekEnd.toIso8601String(),
          ),
        ),
        SizedBox(height: spacing.lg),
        FadeSlideIn(
          index: 2,
          child: GlassCard(
            key: const ValueKey('weekly-review-suggestion-card'),
            padding: spacing.insetsAllXl,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: spacing.insetsAllSm,
                  decoration: BoxDecoration(
                    color: tokenColors.goldAccentSubtle,
                    borderRadius: tokens.radii.buttonRadius,
                  ),
                  child: Icon(
                    Icons.lightbulb_outline_rounded,
                    color: tokenColors.goldAccent,
                    size: spacing.xl,
                  ),
                ),
                SizedBox(width: spacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.weeklyReviewSuggestionTitle,
                        style: tokens.textStyles.titleMedium.copyWith(
                          color: tokenColors.goldAccent,
                        ),
                      ),
                      SizedBox(height: spacing.xs),
                      Text(
                        suggestionText,
                        key: const ValueKey('weekly-review-suggestion-text'),
                        style: tokens.textStyles.bodyLarge,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        SizedBox(height: spacing.lg),
        FadeSlideIn(
          index: 3,
          child: WeeklyReviewUpcomingCard(
            deadlines: summary.upcomingDeadlines,
            exams: summary.upcomingExams,
          ),
        ),
      ],
    );
  }
}
