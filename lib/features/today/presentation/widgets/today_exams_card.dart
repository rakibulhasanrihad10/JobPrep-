import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:job_prep/core/localization/app_localizations_extension.dart';
import 'package:job_prep/core/localization/formatters.dart';
import 'package:job_prep/core/localization/locale_controller.dart';
import 'package:job_prep/core/theme/app_theme_tokens.dart';
import 'package:job_prep/core/widgets/glass_button.dart';
import 'package:job_prep/core/widgets/glass_card.dart';
import 'package:job_prep/features/calendar/domain/utils/calendar_grouping.dart';
import 'package:job_prep/features/calendar/presentation/utils/calendar_locale_l10n.dart';
import 'package:job_prep/features/circulars/presentation/utils/circular_l10n.dart';
import 'package:job_prep/features/today/domain/entities/today_summary.dart';
import 'package:job_prep/features/today/presentation/utils/today_l10n.dart';
import 'package:job_prep/features/today/presentation/widgets/today_section_header.dart';

/// Displays scheduled exam dates occurring within the next 14 days in
/// chronological order.
class TodayExamsCard extends ConsumerWidget {
  /// Creates a [TodayExamsCard].
  const TodayExamsCard({
    required this.exams,
    required this.isUtcReference,
    super.key,
  });

  /// Chronologically ordered exam entries in the next 14 days.
  final List<TodayExamEntry> exams;

  /// Whether date calculations align timestamps to UTC cleanly.
  final bool isUtcReference;

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

    return GlassCard(
      key: const ValueKey('today-exams-card'),
      padding: spacing.insetsAllLg,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TodaySectionHeader(
            icon: Icons.school_outlined,
            title: l10n.todayExamsTitle,
            action: TextButton(
              key: const ValueKey('today-open-calendar-btn'),
              onPressed: () => router?.go('/calendar'),
              child: Text(l10n.dashboardOpenCalendarAction),
            ),
          ),
          SizedBox(height: spacing.md),
          if (exams.isEmpty)
            Container(
              key: const ValueKey('today-exams-empty'),
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
                    l10n.todayExamsEmptyTitle,
                    style: tokens.textStyles.labelLarge,
                  ),
                  SizedBox(height: spacing.xs),
                  Text(
                    l10n.todayExamsEmptyBody,
                    style: tokens.textStyles.bodySmall,
                  ),
                  SizedBox(height: spacing.md),
                  Align(
                    alignment: AlignmentDirectional.centerStart,
                    child: GlassButton(
                      onPressed: () => router?.go('/calendar'),
                      child: Text(l10n.dashboardOpenCalendarAction),
                    ),
                  ),
                ],
              ),
            )
          else
            for (var i = 0; i < exams.length; i++) ...[
              if (i > 0) SizedBox(height: spacing.sm),
              _TodayExamRow(
                entry: exams[i],
                locale: locale,
                useBanglaDigits: useBanglaDigits,
                isUtcReference: isUtcReference,
                onTap: () => router?.go('/circulars/${exams[i].circular.id}'),
              ),
            ],
        ],
      ),
    );
  }
}

class _TodayExamRow extends StatelessWidget {
  const _TodayExamRow({
    required this.entry,
    required this.locale,
    required this.useBanglaDigits,
    required this.isUtcReference,
    required this.onTap,
  });

  final TodayExamEntry entry;
  final Locale locale;
  final bool useBanglaDigits;
  final bool isUtcReference;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final colors = tokens.colors;
    final spacing = tokens.spacing;
    final radii = tokens.radii;
    final l10n = context.l10n;

    final kind = calendarKindForExamStage(entry.stage);
    final stageColor = CalendarLocaleL10n.colorForKind(kind, colors);
    final stageLabel = CircularL10n.examStageLabel(entry.stage, l10n);
    final aligned = isUtcReference
        ? entry.examDate.examDate.toUtc()
        : entry.examDate.examDate.toLocal();
    final formattedDate = AppFormatters.formatDate(
      aligned,
      locale: locale,
      pattern: 'd MMM yyyy',
      useBanglaDigits: useBanglaDigits,
    );
    final fmtDays = TodayL10n.formatCount(
      entry.daysUntil,
      locale: locale,
      useBanglaDigits: useBanglaDigits,
    );
    final countdown = entry.daysUntil == 0
        ? l10n.dashboardExamToday
        : l10n.dashboardExamInDays(entry.daysUntil, fmtDays);
    final venue = entry.examDate.venue?.trim();

    return InkWell(
      key: ValueKey('today-exam-row-${entry.examDate.id}'),
      borderRadius: radii.cardRadius,
      onTap: onTap,
      child: Container(
        padding: spacing.insetsAllMd,
        decoration: BoxDecoration(
          color: colors.surfaceElevated,
          borderRadius: radii.cardRadius,
          border: Border.all(color: colors.glassBorder),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: spacing.sm,
                      vertical: spacing.xxs,
                    ),
                    decoration: BoxDecoration(
                      color: stageColor.withValues(alpha: 0.14),
                      borderRadius: radii.smRadius,
                      border: Border.all(
                        color: stageColor.withValues(alpha: 0.45),
                      ),
                    ),
                    child: Text(
                      stageLabel,
                      style: tokens.textStyles.labelSmall.copyWith(
                        color: colors.textPrimary,
                      ),
                    ),
                  ),
                  SizedBox(height: spacing.xs),
                  Text(
                    entry.circular.title,
                    style: tokens.textStyles.labelLarge,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (venue != null && venue.isNotEmpty) ...[
                    SizedBox(height: spacing.xxs),
                    Text(
                      venue,
                      style: tokens.textStyles.bodySmall,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
            SizedBox(width: spacing.sm),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  formattedDate,
                  style: tokens.textStyles.bodySmall.copyWith(
                    color: colors.textSecondary,
                  ),
                ),
                SizedBox(height: spacing.xs),
                Text(
                  countdown,
                  style: tokens.textStyles.labelSmall.copyWith(
                    color: stageColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
