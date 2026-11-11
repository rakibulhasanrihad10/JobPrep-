import 'dart:async' show unawaited;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:job_prep/core/localization/app_localizations_extension.dart';
import 'package:job_prep/core/localization/locale_controller.dart';
import 'package:job_prep/core/theme/app_theme_tokens.dart';
import 'package:job_prep/core/widgets/glass_button.dart';
import 'package:job_prep/core/widgets/glass_card.dart';
import 'package:job_prep/features/circulars/presentation/widgets/circular_badges.dart';
import 'package:job_prep/features/prep/domain/entities/prep_enums.dart';
import 'package:job_prep/features/prep/domain/utils/revision_scheduler.dart';
import 'package:job_prep/features/prep/presentation/providers/revision_providers.dart';
import 'package:job_prep/features/prep/presentation/providers/study_timer_controller.dart';
import 'package:job_prep/features/prep/presentation/widgets/study_plan_form_dialog.dart';
import 'package:job_prep/features/today/domain/entities/today_summary.dart';
import 'package:job_prep/features/today/presentation/utils/today_l10n.dart';
import 'package:job_prep/features/today/presentation/widgets/today_quick_log_dialog.dart';

/// Highlighted "Do this next" card chosen strictly by pure priority logic:
/// deadline <= 2d > overdue revision > biggest remaining study target.
class TodayDoNextCard extends ConsumerWidget {
  /// Creates a [TodayDoNextCard].
  const TodayDoNextCard({
    required this.summary,
    super.key,
  });

  /// Live computed Today summary containing optional [TodaySummary.doThisNext].
  final TodaySummary summary;

  void _openRevision(BuildContext context, WidgetRef ref) {
    ref.read(revisionFilterProvider.notifier).clear();
    ref
        .read(revisionQueueTabProvider.notifier)
        .selectTab(RevisionQueueTab.overdue);
    GoRouter.maybeOf(context)?.go('/prep/revision');
  }

  Future<void> _startTimerForTarget(
    BuildContext context,
    WidgetRef ref,
    TodayStudyTargetRow row,
  ) async {
    final timerState = ref.read(studyTimerControllerProvider);
    final subject = row.subject;
    if (!timerState.hasActiveSession && subject != null) {
      await ref.read(studyTimerControllerProvider.notifier).startSession(
            subjectId: subject.id,
            materialId: row.defaultLogMaterial?.id,
            mode: StudySessionMode.focus,
          );
    }
    if (context.mounted) {
      GoRouter.maybeOf(context)?.go('/prep/timer');
    }
  }

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
    final item = summary.doThisNext;

    if (item == null) {
      return GlassCard(
        key: const ValueKey('today-do-next-card'),
        padding: spacing.insetsAllLg,
        borderColor: colors.success.withValues(alpha: 0.45),
        child: Column(
          key: const ValueKey('today-do-next-caught-up'),
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Icon(
                  Icons.check_circle_outline_rounded,
                  size: spacing.lg,
                  color: colors.success,
                ),
                SizedBox(width: spacing.sm),
                Expanded(
                  child: Text(
                    l10n.todayDoNextTitle,
                    style: tokens.textStyles.titleMedium,
                  ),
                ),
              ],
            ),
            SizedBox(height: spacing.sm),
            Text(
              l10n.todayDoNextAllCaughtUpTitle,
              style: tokens.textStyles.labelLarge,
            ),
            SizedBox(height: spacing.xxs),
            Text(
              l10n.todayDoNextAllCaughtUpBody,
              style: tokens.textStyles.bodySmall,
            ),
            if (!summary.hasActiveStudyPlans) ...[
              SizedBox(height: spacing.md),
              Align(
                alignment: AlignmentDirectional.centerStart,
                child: GlassButton(
                  key: const ValueKey('today-do-next-create-plan-btn'),
                  onPressed: () => unawaited(showStudyPlanFormDialog(context)),
                  leading: Icon(Icons.add_task_rounded, size: spacing.lg),
                  child: Text(l10n.todayTargetsCreatePlanButton),
                ),
              ),
            ],
          ],
        ),
      );
    }

    final Color accent;
    final IconData icon;
    final String priorityLabel;
    final String headline;
    final String detail;
    final Widget? trailingBadge;
    final List<Widget> actions;

    switch (item.kind) {
      case TodayDoThisNextKind.circularDeadline:
        final circular = item.circular!;
        accent = colors.danger;
        icon = Icons.priority_high_rounded;
        priorityLabel = l10n.todayDoNextPriorityDeadline;
        headline = circular.title;
        detail = circular.organizationName?.trim().isNotEmpty == true
            ? circular.organizationName!.trim()
            : l10n.todayDeadlinesTitle;
        trailingBadge = CircularDeadlineCountdownBadge(
          deadline: circular.deadline,
        );
        actions = [
          GlassButton(
            key: const ValueKey('today-do-next-action-btn'),
            variant: GlassButtonVariant.primary,
            onPressed: () => router?.go('/circulars/${circular.id}'),
            child: Text(l10n.todayDoNextOpenCircularAction),
          ),
        ];

      case TodayDoThisNextKind.overdueRevision:
        accent = colors.warning;
        icon = Icons.flag_rounded;
        priorityLabel = l10n.todayDoNextPriorityRevision;
        final top = item.topOverdueRevision;
        final subjectName = item.overdueRevisionSubject?.name;
        headline = top?.referenceLabel ?? l10n.todayRevisionTitle;
        final fmtOverdue = TodayL10n.formatCount(
          item.overdueRevisionCount,
          locale: locale,
          useBanglaDigits: useBanglaDigits,
        );
        detail = subjectName != null && top != null
            ? l10n.todayDoNextOverdueSummary(
                item.overdueRevisionCount,
                fmtOverdue,
                subjectName,
              )
            : l10n.todayDoNextOverdueSummary(
                item.overdueRevisionCount,
                fmtOverdue,
                top?.referenceLabel ?? l10n.todayRevisionTitle,
              );
        trailingBadge = null;
        actions = [
          GlassButton(
            key: const ValueKey('today-do-next-action-btn'),
            variant: GlassButtonVariant.primary,
            onPressed: () => _openRevision(context, ref),
            child: Text(l10n.todayDoNextStartRevisionAction),
          ),
        ];

      case TodayDoThisNextKind.studyTarget:
        final row = item.studyTargetRow!;
        accent = colors.goldAccent;
        icon = Icons.bolt_rounded;
        priorityLabel = l10n.todayDoNextPriorityStudy;
        headline = TodayL10n.planScopeTitle(
          isAllSubjects: row.isAllSubjects,
          subject: row.subject,
          l10n: l10n,
        );
        detail = l10n.todayDoNextStudySummary(
          TodayL10n.formatCount(
            row.remainingTodayUnits,
            locale: locale,
            useBanglaDigits: useBanglaDigits,
          ),
          TodayL10n.formatCount(
            row.todayDoneUnits,
            locale: locale,
            useBanglaDigits: useBanglaDigits,
          ),
          TodayL10n.formatCount(
            row.todayTargetUnits,
            locale: locale,
            useBanglaDigits: useBanglaDigits,
          ),
        );
        trailingBadge = null;
        actions = [
          GlassButton(
            key: const ValueKey('today-do-next-action-btn'),
            variant: GlassButtonVariant.primary,
            onPressed: () => unawaited(_startTimerForTarget(context, ref, row)),
            leading: Icon(Icons.timer_outlined, size: spacing.lg),
            child: Text(l10n.todayDoNextStartStudyAction),
          ),
          GlassButton(
            key: const ValueKey('today-do-next-log-btn'),
            onPressed: () =>
                unawaited(showTodayQuickLogDialog(context, row: row)),
            leading: Icon(Icons.edit_note_rounded, size: spacing.lg),
            child: Text(l10n.todayTargetQuickLogButton),
          ),
        ];
    }

    return GlassCard(
      key: const ValueKey('today-do-next-card'),
      padding: spacing.insetsAllLg,
      borderColor: accent.withValues(alpha: 0.65),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Wrap(
            spacing: spacing.sm,
            runSpacing: spacing.xs,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(icon, size: spacing.lg, color: accent),
                  SizedBox(width: spacing.xs),
                  Text(
                    l10n.todayDoNextTitle,
                    style: tokens.textStyles.titleMedium,
                  ),
                ],
              ),
              Container(
                key: ValueKey('today-do-next-priority-${item.kind.name}'),
                padding: EdgeInsets.symmetric(
                  horizontal: spacing.sm,
                  vertical: spacing.xxs,
                ),
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.14),
                  borderRadius: radii.smRadius,
                  border: Border.all(color: accent.withValues(alpha: 0.5)),
                ),
                child: Text(
                  priorityLabel,
                  style: tokens.textStyles.labelSmall.copyWith(color: accent),
                ),
              ),
            ],
          ),
          SizedBox(height: spacing.md),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      headline,
                      key: const ValueKey('today-do-next-headline'),
                      style: tokens.textStyles.titleLarge,
                    ),
                    SizedBox(height: spacing.xxs),
                    Text(
                      detail,
                      style: tokens.textStyles.bodyMedium.copyWith(
                        color: colors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              if (trailingBadge != null) ...[
                SizedBox(width: spacing.sm),
                trailingBadge,
              ],
            ],
          ),
          SizedBox(height: spacing.md),
          Wrap(
            spacing: spacing.sm,
            runSpacing: spacing.xs,
            children: actions,
          ),
        ],
      ),
    );
  }
}
