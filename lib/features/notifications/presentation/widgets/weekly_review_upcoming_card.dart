import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:job_prep/core/localization/app_localizations_extension.dart';
import 'package:job_prep/core/localization/formatters.dart';
import 'package:job_prep/core/localization/locale_controller.dart';
import 'package:job_prep/core/theme/app_theme_tokens.dart';
import 'package:job_prep/core/widgets/glass_card.dart';
import 'package:job_prep/features/calendar/domain/utils/calendar_grouping.dart';
import 'package:job_prep/features/calendar/presentation/utils/calendar_locale_l10n.dart';
import 'package:job_prep/features/circulars/presentation/utils/circular_l10n.dart';
import 'package:job_prep/features/circulars/presentation/widgets/circular_badges.dart';
import 'package:job_prep/features/today/domain/entities/today_summary.dart';
import 'package:job_prep/features/today/presentation/widgets/today_section_header.dart';

/// Displays deadlines and exam dates falling within the next 7 days inside the
/// Weekly Review screen.
class WeeklyReviewUpcomingCard extends ConsumerWidget {
  /// Creates a [WeeklyReviewUpcomingCard].
  const WeeklyReviewUpcomingCard({
    required this.deadlines,
    required this.exams,
    super.key,
  });

  /// Application deadlines closing inside the upcoming 7 days.
  final List<TodayDeadlineEntry> deadlines;

  /// Scheduled circular exams falling inside the upcoming 7 days.
  final List<TodayExamEntry> exams;

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

    final isEmpty = deadlines.isEmpty && exams.isEmpty;

    return GlassCard(
      key: const ValueKey('weekly-review-upcoming-card'),
      padding: spacing.insetsAllLg,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TodaySectionHeader(
            icon: Icons.event_note_outlined,
            title: l10n.weeklyReviewUpcomingTitle,
          ),
          SizedBox(height: spacing.md),
          if (isEmpty)
            Container(
              key: const ValueKey('weekly-review-upcoming-empty'),
              padding: spacing.insetsAllMd,
              decoration: BoxDecoration(
                color: colors.surfaceElevated,
                borderRadius: radii.cardRadius,
                border: Border.all(color: colors.glassBorder),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    l10n.weeklyReviewUpcomingEmptyTitle,
                    style: tokens.textStyles.labelLarge,
                  ),
                  SizedBox(height: spacing.xs),
                  Text(
                    l10n.weeklyReviewUpcomingEmptyBody,
                    style: tokens.textStyles.bodySmall,
                  ),
                ],
              ),
            )
          else ...[
            for (var i = 0; i < deadlines.length; i++) ...[
              if (i > 0) SizedBox(height: spacing.sm),
              _UpcomingEventTile(
                key: ValueKey(
                  'weekly-review-deadline-${deadlines[i].circular.id}',
                ),
                title: deadlines[i].circular.title,
                subtitle: l10n.notificationTypeDeadlineSoon,
                trailing: CircularDeadlineCountdownBadge(
                  deadline: deadlines[i].circular.deadline,
                ),
                onTap: () =>
                    router?.go('/circulars/${deadlines[i].circular.id}'),
              ),
            ],
            for (var i = 0; i < exams.length; i++) ...[
              if (deadlines.isNotEmpty || i > 0) SizedBox(height: spacing.sm),
              _UpcomingEventTile(
                key: ValueKey('weekly-review-exam-${exams[i].examDate.id}'),
                title: exams[i].circular.title,
                subtitle: CircularL10n.examStageLabel(exams[i].stage, l10n),
                trailing: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: spacing.sm,
                    vertical: spacing.xs,
                  ),
                  decoration: BoxDecoration(
                    color: CalendarLocaleL10n.colorForKind(
                      calendarKindForExamStage(exams[i].stage),
                      colors,
                    ).withValues(alpha: 0.16),
                    borderRadius: radii.smRadius,
                  ),
                  child: Text(
                    AppFormatters.formatDate(
                      exams[i].examDate.examDate.toLocal(),
                      locale: locale,
                      pattern: 'd MMM',
                      useBanglaDigits: useBanglaDigits,
                    ),
                    style: tokens.textStyles.labelMedium.copyWith(
                      color: CalendarLocaleL10n.colorForKind(
                        calendarKindForExamStage(exams[i].stage),
                        colors,
                      ),
                    ),
                  ),
                ),
                onTap: () => router?.go('/circulars/${exams[i].circular.id}'),
              ),
            ],
          ],
        ],
      ),
    );
  }
}

class _UpcomingEventTile extends StatelessWidget {
  const _UpcomingEventTile({
    required this.title,
    required this.subtitle,
    required this.trailing,
    required this.onTap,
    super.key,
  });

  final String title;
  final String subtitle;
  final Widget trailing;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final colors = tokens.colors;
    final spacing = tokens.spacing;
    final radii = tokens.radii;

    return Material(
      color: colors.surfaceElevated,
      borderRadius: radii.cardRadius,
      child: InkWell(
        borderRadius: radii.cardRadius,
        onTap: onTap,
        child: Container(
          padding: spacing.insetsAllMd,
          decoration: BoxDecoration(
            borderRadius: radii.cardRadius,
            border: Border.all(color: colors.glassBorder),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: tokens.textStyles.labelLarge,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: spacing.xxs),
                    Text(
                      subtitle,
                      style: tokens.textStyles.bodySmall,
                    ),
                  ],
                ),
              ),
              SizedBox(width: spacing.sm),
              trailing,
            ],
          ),
        ),
      ),
    );
  }
}
