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
import 'package:job_prep/features/calendar/domain/utils/calendar_grouping.dart';
import 'package:job_prep/features/calendar/presentation/utils/calendar_locale_l10n.dart';
import 'package:job_prep/features/circulars/presentation/providers/circulars_providers.dart';
import 'package:job_prep/features/circulars/presentation/utils/circular_l10n.dart';
import 'package:job_prep/features/dashboard/domain/entities/dashboard_summary.dart';

/// Card listing upcoming circular exam dates across Preliminary, Written,
/// Viva, Practical, and Other stages in chronological order.
class DashboardUpcomingExamsCard extends ConsumerWidget {
  /// Creates a [DashboardUpcomingExamsCard].
  const DashboardUpcomingExamsCard({
    required this.exams,
    super.key,
  });

  /// Chronologically ordered upcoming exam entries.
  final List<DashboardExamEntry> exams;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tokens = context.tokens;
    final colors = tokens.colors;
    final spacing = tokens.spacing;
    final radii = tokens.radii;
    final l10n = context.l10n;
    final locale = ref.watch(localeProvider);
    final useBanglaDigits = ref.watch(useBanglaDigitsProvider);
    final now = ref.watch(circularNowProvider)();
    final router = GoRouter.maybeOf(context);

    return FadeSlideIn(
      index: 7,
      child: GlassCard(
        key: const ValueKey('dashboard-upcoming-exams-card'),
        padding: spacing.insetsAllLg,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Icon(
                  Icons.school_outlined,
                  size: spacing.lg,
                  color: colors.goldAccent,
                ),
                SizedBox(width: spacing.sm),
                Expanded(
                  child: Text(
                    l10n.dashboardUpcomingExamsTitle,
                    style: tokens.textStyles.titleMedium,
                  ),
                ),
                TextButton(
                  key: const ValueKey('dashboard-view-calendar'),
                  onPressed: () => router?.go('/calendar'),
                  child: Text(l10n.dashboardOpenCalendarAction),
                ),
              ],
            ),
            SizedBox(height: spacing.md),
            if (exams.isEmpty)
              Container(
                key: const ValueKey('dashboard-exams-empty'),
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
                      l10n.dashboardUpcomingExamsEmptyTitle,
                      style: tokens.textStyles.labelLarge,
                    ),
                    SizedBox(height: spacing.xs),
                    Text(
                      l10n.dashboardUpcomingExamsEmptyBody,
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
                _ExamListRow(
                  entry: exams[i],
                  locale: locale,
                  useBanglaDigits: useBanglaDigits,
                  isUtcReference: now.isUtc,
                  onTap: () => router?.go('/circulars/${exams[i].circular.id}'),
                ),
              ],
          ],
        ),
      ),
    );
  }
}

class _ExamListRow extends StatelessWidget {
  const _ExamListRow({
    required this.entry,
    required this.locale,
    required this.useBanglaDigits,
    required this.isUtcReference,
    required this.onTap,
  });

  final DashboardExamEntry entry;
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
    final alignedDate = isUtcReference
        ? entry.examDate.examDate.toUtc()
        : entry.examDate.examDate.toLocal();
    final formattedDate = AppFormatters.formatDate(
      alignedDate,
      locale: locale,
      pattern: 'd MMM yyyy',
      useBanglaDigits: useBanglaDigits,
    );
    final formattedDays = AppFormatters.formatNumber(
      entry.daysUntil,
      locale: locale,
      useBanglaDigits: useBanglaDigits,
    );
    final countdownText = entry.daysUntil == 0
        ? l10n.dashboardExamToday
        : l10n.dashboardExamInDays(entry.daysUntil, formattedDays);

    final venue = entry.examDate.venue?.trim();

    return InkWell(
      key: ValueKey('dashboard-exam-row-${entry.examDate.id}'),
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
                  countdownText,
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
