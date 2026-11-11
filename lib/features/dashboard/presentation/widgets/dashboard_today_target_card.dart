import 'dart:async' show unawaited;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:job_prep/core/localization/app_localizations_extension.dart';
import 'package:job_prep/core/localization/formatters.dart';
import 'package:job_prep/core/localization/locale_controller.dart';
import 'package:job_prep/core/theme/app_theme_tokens.dart';
import 'package:job_prep/core/widgets/animated_progress_ring.dart';
import 'package:job_prep/core/widgets/fade_slide_in.dart';
import 'package:job_prep/core/widgets/glass_button.dart';
import 'package:job_prep/core/widgets/glass_card.dart';
import 'package:job_prep/features/prep/presentation/providers/study_plan_providers.dart';
import 'package:job_prep/features/prep/presentation/utils/study_plan_ui_helpers.dart';
import 'package:job_prep/features/prep/presentation/widgets/study_plan_form_dialog.dart';
import 'package:job_prep/features/prep/presentation/widgets/study_plan_stat_pill.dart';

/// Home Dashboard card highlighting today's study target, daily completion
/// ring, schedule status badge, and catch-up/pace alerts from Phase 6C plans.
class DashboardTodayTargetCard extends ConsumerWidget {
  /// Creates a [DashboardTodayTargetCard].
  const DashboardTodayTargetCard({
    required this.visitId,
    super.key,
  });

  /// Monotonic tab visit counter replaying [AnimatedProgressRing] from zero.
  final int visitId;

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
    final snapshots =
        ref.watch(studyPlanSnapshotsProvider).asData?.value ?? const [];

    if (snapshots.isEmpty) {
      return FadeSlideIn(
        index: 5,
        child: GlassCard(
          key: const ValueKey('dashboard-today-target-card'),
          padding: spacing.insetsAllLg,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.track_changes_rounded,
                    size: spacing.lg,
                    color: colors.goldAccent,
                  ),
                  SizedBox(width: spacing.sm),
                  Expanded(
                    child: Text(
                      l10n.dashboardTodayTargetTitle,
                      style: tokens.textStyles.titleMedium,
                    ),
                  ),
                ],
              ),
              SizedBox(height: spacing.md),
              Container(
                key: const ValueKey('dashboard-today-target-empty'),
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
                      l10n.dashboardTodayTargetEmptyTitle,
                      style: tokens.textStyles.labelLarge,
                    ),
                    SizedBox(height: spacing.xs),
                    Text(
                      l10n.dashboardTodayTargetEmptyBody,
                      style: tokens.textStyles.bodySmall,
                    ),
                    SizedBox(height: spacing.md),
                    Align(
                      alignment: AlignmentDirectional.centerStart,
                      child: GlassButton(
                        key: const ValueKey('dashboard-set-study-plan-button'),
                        onPressed: () =>
                            unawaited(showStudyPlanFormDialog(context)),
                        child: Text(l10n.dashboardTodayTargetEmptyAction),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    }

    // Prefer the combined All Subjects plan when present; otherwise focus the
    // nearest exam plan (sorted earliest targetDate first).
    final primary = snapshots.first;
    final statusColor =
        StudyPlanUiHelpers.statusColor(primary.scheduleStatus, tokens);
    final statusLabel =
        StudyPlanUiHelpers.statusLabel(primary.scheduleStatus, l10n);

    final formattedTarget = AppFormatters.formatNumber(
      primary.todayTarget,
      locale: locale,
      useBanglaDigits: useBanglaDigits,
    );
    final formattedDone = AppFormatters.formatNumber(
      primary.todayCompletedUnits,
      locale: locale,
      useBanglaDigits: useBanglaDigits,
    );
    final formattedRemaining = AppFormatters.formatNumber(
      primary.remainingUnits,
      locale: locale,
      useBanglaDigits: useBanglaDigits,
    );
    final formattedDays = AppFormatters.formatNumber(
      primary.studyDaysLeft,
      locale: locale,
      useBanglaDigits: useBanglaDigits,
    );
    final percentFormatted = AppFormatters.formatNumber(
      (primary.todayProgress * 100).round(),
      locale: locale,
      useBanglaDigits: useBanglaDigits,
    );
    final scopeTitle = primary.plan.isAllSubjects
        ? l10n.prepStudyPlanAllSubjectsLabel
        : (primary.subject?.name ?? l10n.prepStudyPlanSectionTitle);

    return FadeSlideIn(
      index: 5,
      child: GlassCard(
        key: const ValueKey('dashboard-today-target-card'),
        padding: spacing.insetsAllLg,
        onTap: router == null ? null : () => router.go('/prep'),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Icon(
                  Icons.track_changes_rounded,
                  size: spacing.lg,
                  color: colors.goldAccent,
                ),
                SizedBox(width: spacing.sm),
                Expanded(
                  child: Text(
                    l10n.dashboardTodayTargetTitle,
                    style: tokens.textStyles.titleMedium,
                  ),
                ),
                StudyPlanStatusBadge(
                  key: const ValueKey('dashboard-today-target-status'),
                  label: statusLabel,
                  color: statusColor,
                ),
              ],
            ),
            SizedBox(height: spacing.md),
            Row(
              children: [
                AnimatedProgressRing(
                  key: const ValueKey('dashboard-today-target-ring'),
                  value: primary.todayProgress,
                  replayKey: 'dashboard-today-target-$visitId',
                  size: spacing.xxxl + spacing.sm,
                  strokeWidth: spacing.xs + spacing.xxs,
                  progressColor: statusColor,
                  child: Text(
                    '$percentFormatted%',
                    style: tokens.textStyles.labelMedium.copyWith(
                      color: colors.textPrimary,
                    ),
                  ),
                ),
                SizedBox(width: spacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(scopeTitle, style: tokens.textStyles.labelLarge),
                      SizedBox(height: spacing.xxs),
                      Text(
                        l10n.prepStudyPlanTodayDoneOfTarget(
                          formattedDone,
                          formattedTarget,
                        ),
                        style: tokens.textStyles.bodyMedium.copyWith(
                          color: colors.goldAccent,
                        ),
                      ),
                      SizedBox(height: spacing.xxs),
                      Builder(
                        builder: (_) {
                          final unitsText = l10n.prepStudyPlanUnitsCount(
                            formattedRemaining,
                          );
                          final daysText = l10n.prepStudyPlanDaysCount(
                            primary.studyDaysLeft,
                            formattedDays,
                          );
                          return Text(
                            '$unitsText · $daysText',
                            style: tokens.textStyles.bodySmall,
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (primary.missedUnits > 0 && !primary.isPastBufferOrTarget) ...[
              SizedBox(height: spacing.sm),
              Text(
                l10n.prepStudyPlanMissedRedistributed(
                  primary.studyDaysLeft,
                  AppFormatters.formatNumber(
                    primary.missedUnits,
                    locale: locale,
                    useBanglaDigits: useBanglaDigits,
                  ),
                  formattedDays,
                  StudyPlanUiHelpers.formatDecimalPace(
                    primary.dailyCatchUpExtra,
                    locale: locale,
                    useBanglaDigits: useBanglaDigits,
                  ),
                ),
                style: tokens.textStyles.bodySmall.copyWith(color: colors.info),
              ),
            ],
            if (primary.isOverPaceLimit &&
                primary.plan.maxDailyPace != null) ...[
              SizedBox(height: spacing.xs),
              Text(
                l10n.prepStudyPlanPaceWarning(
                  formattedTarget,
                  AppFormatters.formatNumber(
                    primary.plan.maxDailyPace!,
                    locale: locale,
                    useBanglaDigits: useBanglaDigits,
                  ),
                ),
                style: tokens.textStyles.bodySmall.copyWith(
                  color: colors.warning,
                ),
              ),
            ],
            SizedBox(height: spacing.md),
            Wrap(
              spacing: spacing.sm,
              runSpacing: spacing.xs,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                Text(
                  l10n.dashboardTodayTargetPlansSummary(
                    snapshots.length,
                    AppFormatters.formatNumber(
                      snapshots.length,
                      locale: locale,
                      useBanglaDigits: useBanglaDigits,
                    ),
                  ),
                  style: tokens.textStyles.bodySmall,
                ),
                GlassButton(
                  key: const ValueKey('dashboard-open-plans-button'),
                  onPressed: () {
                    if (router != null) {
                      router.go('/prep');
                    } else {
                      unawaited(
                        showStudyPlanFormDialog(
                          context,
                          existing: primary.plan,
                        ),
                      );
                    }
                  },
                  child: Text(l10n.dashboardTodayTargetManageAction),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
