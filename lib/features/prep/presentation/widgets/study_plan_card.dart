import 'dart:async' show unawaited;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:job_prep/core/localization/app_localizations_extension.dart';
import 'package:job_prep/core/localization/formatters.dart';
import 'package:job_prep/core/localization/locale_controller.dart';
import 'package:job_prep/core/theme/app_theme_tokens.dart';
import 'package:job_prep/core/widgets/animated_progress_ring.dart';
import 'package:job_prep/core/widgets/glass_card.dart';
import 'package:job_prep/features/prep/domain/entities/study_plan_snapshot.dart';
import 'package:job_prep/features/prep/presentation/providers/study_plan_providers.dart';
import 'package:job_prep/features/prep/presentation/utils/study_plan_ui_helpers.dart';
import 'package:job_prep/features/prep/presentation/widgets/study_plan_form_dialog.dart';
import 'package:job_prep/features/prep/presentation/widgets/study_plan_pace_warning_box.dart';
import 'package:job_prep/features/prep/presentation/widgets/study_plan_stat_pill.dart';

/// Displays calculated targets, today's [AnimatedProgressRing], schedule
/// status, catch-up banner, and pace-limit options for a study plan.
class StudyPlanCard extends ConsumerWidget {
  /// Creates a [StudyPlanCard].
  const StudyPlanCard({
    required this.snapshot,
    required this.visitId,
    super.key,
  });

  /// Live computed snapshot pairing the persisted plan with syllabus totals.
  final StudyPlanSnapshot snapshot;

  /// Monotonic tab-visit counter replaying [AnimatedProgressRing] from zero.
  final int visitId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tokens = context.tokens;
    final colors = tokens.colors;
    final spacing = tokens.spacing;
    final l10n = context.l10n;
    final locale = ref.watch(localeProvider);
    final useBanglaDigits = ref.watch(useBanglaDigitsProvider);
    final mutationState = ref.watch(studyPlanControllerProvider);

    final plan = snapshot.plan;
    final cardKeySlug =
        plan.isAllSubjects ? 'all' : (plan.subjectId ?? plan.id);
    final statusColor =
        StudyPlanUiHelpers.statusColor(snapshot.scheduleStatus, tokens);
    final statusText =
        StudyPlanUiHelpers.statusLabel(snapshot.scheduleStatus, l10n);

    final title = plan.isAllSubjects
        ? l10n.prepStudyPlanAllSubjectsLabel
        : (snapshot.subject?.name ?? l10n.prepStudyPlanSectionTitle);

    final formattedRemaining = AppFormatters.formatNumber(
      snapshot.remainingUnits,
      locale: locale,
      useBanglaDigits: useBanglaDigits,
    );
    final formattedDays = AppFormatters.formatNumber(
      snapshot.studyDaysLeft,
      locale: locale,
      useBanglaDigits: useBanglaDigits,
    );
    final formattedTarget = AppFormatters.formatNumber(
      snapshot.todayTarget,
      locale: locale,
      useBanglaDigits: useBanglaDigits,
    );
    final formattedDone = AppFormatters.formatNumber(
      snapshot.todayCompletedUnits,
      locale: locale,
      useBanglaDigits: useBanglaDigits,
    );
    final formattedBuffer = AppFormatters.formatNumber(
      plan.finishBufferDays,
      locale: locale,
      useBanglaDigits: useBanglaDigits,
    );
    final formattedExamDate = AppFormatters.formatDate(
      plan.targetDate,
      locale: locale,
      pattern: 'd MMM yyyy',
      useBanglaDigits: useBanglaDigits,
    );
    final percentFormatted = AppFormatters.formatNumber(
      (snapshot.todayProgress * 100).round(),
      locale: locale,
      useBanglaDigits: useBanglaDigits,
    );

    return GlassCard(
      key: ValueKey('study-plan-card-$cardKeySlug'),
      padding: spacing.insetsAllLg,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(title, style: tokens.textStyles.titleMedium),
              ),
              IconButton(
                key: ValueKey('edit-study-plan-$cardKeySlug'),
                tooltip: l10n.prepStudyPlanEditTooltip,
                visualDensity: VisualDensity.compact,
                onPressed: mutationState.isBusy
                    ? null
                    : () => unawaited(
                          showStudyPlanFormDialog(context, existing: plan),
                        ),
                icon: const Icon(Icons.edit_outlined),
              ),
              IconButton(
                key: ValueKey('delete-study-plan-$cardKeySlug'),
                tooltip: l10n.prepStudyPlanDeleteTooltip,
                visualDensity: VisualDensity.compact,
                onPressed: mutationState.isBusy
                    ? null
                    : () => unawaited(
                          StudyPlanUiHelpers.confirmDeletePlan(
                            context,
                            ref,
                            plan,
                          ),
                        ),
                icon: const Icon(Icons.delete_outline_rounded),
              ),
            ],
          ),
          SizedBox(height: spacing.sm),
          Row(
            children: [
              AnimatedProgressRing(
                key: ValueKey('study-plan-ring-$cardKeySlug'),
                value: snapshot.todayProgress,
                replayKey: 'study-plan-$cardKeySlug-$visitId',
                size: spacing.xxxl + spacing.md,
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
                    Wrap(
                      spacing: spacing.xs,
                      runSpacing: spacing.xs,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        StudyPlanStatusBadge(
                          key: ValueKey('study-plan-status-badge-$cardKeySlug'),
                          label: statusText,
                          color: statusColor,
                        ),
                        if (snapshot.linkedCircular != null)
                          Builder(
                            builder: (_) {
                              final circularTitle =
                                  snapshot.linkedCircular!.title;
                              final examStage = snapshot.linkedExamDate?.stage;
                              return Text(
                                examStage != null
                                    ? '$circularTitle ($examStage)'
                                    : circularTitle,
                                style: tokens.textStyles.bodySmall,
                              );
                            },
                          ),
                      ],
                    ),
                    SizedBox(height: spacing.xs),
                    Text(
                      l10n.prepStudyPlanBufferSummary(
                        formattedBuffer,
                        formattedExamDate,
                      ),
                      style: tokens.textStyles.bodySmall,
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: spacing.md),
          Wrap(
            spacing: spacing.sm,
            runSpacing: spacing.sm,
            children: [
              StudyPlanStatPill(
                label: l10n.prepStudyPlanTodayTargetLabel,
                value: l10n.prepStudyPlanUnitsCount(formattedTarget),
                sublabel: l10n.prepStudyPlanTodayDoneOfTarget(
                  formattedDone,
                  formattedTarget,
                ),
                accent: colors.goldAccent,
              ),
              StudyPlanStatPill(
                label: l10n.prepStudyPlanRemainingLabel,
                value: l10n.prepStudyPlanUnitsCount(formattedRemaining),
                accent: colors.textPrimary,
              ),
              StudyPlanStatPill(
                label: l10n.prepStudyPlanDaysLeftLabel,
                value: l10n.prepStudyPlanDaysCount(
                  snapshot.studyDaysLeft,
                  formattedDays,
                ),
                accent: colors.textPrimary,
              ),
            ],
          ),
          if (snapshot.remainingUnits <= 0) ...[
            SizedBox(height: spacing.sm),
            Text(
              l10n.prepStudyPlanFinishedComplete,
              style:
                  tokens.textStyles.bodySmall.copyWith(color: colors.success),
            ),
          ] else if (snapshot.isPastBufferOrTarget) ...[
            SizedBox(height: spacing.sm),
            StudyPlanAlertBox(
              boxKey: ValueKey('study-plan-past-notice-$cardKeySlug'),
              accent: colors.warning,
              icon: Icons.event_busy_outlined,
              message: l10n.prepStudyPlanPastTargetNotice(formattedRemaining),
            ),
          ] else if (snapshot.missedUnits > 0) ...[
            SizedBox(height: spacing.sm),
            StudyPlanAlertBox(
              boxKey: ValueKey('study-plan-catch-up-$cardKeySlug'),
              accent: colors.info,
              icon: Icons.autorenew_rounded,
              message: l10n.prepStudyPlanMissedRedistributed(
                snapshot.studyDaysLeft,
                AppFormatters.formatNumber(
                  snapshot.missedUnits,
                  locale: locale,
                  useBanglaDigits: useBanglaDigits,
                ),
                formattedDays,
                StudyPlanUiHelpers.formatDecimalPace(
                  snapshot.dailyCatchUpExtra,
                  locale: locale,
                  useBanglaDigits: useBanglaDigits,
                ),
              ),
            ),
          ],
          if (snapshot.isOverPaceLimit && plan.maxDailyPace != null) ...[
            SizedBox(height: spacing.sm),
            StudyPlanPaceWarningBox(
              cardKeySlug: cardKeySlug,
              snapshot: snapshot,
              locale: locale,
              useBanglaDigits: useBanglaDigits,
              isBusy: mutationState.isBusy,
            ),
          ],
          if (snapshot.postponedMaterials.isNotEmpty) ...[
            SizedBox(height: spacing.sm),
            Wrap(
              spacing: spacing.xs,
              runSpacing: spacing.xs,
              children: [
                for (final mat in snapshot.postponedMaterials)
                  Chip(
                    key: ValueKey('postponed-chip-${mat.id}'),
                    label: Text(
                      l10n.prepStudyPlanPostponedChip(mat.title),
                      style: tokens.textStyles.bodySmall,
                    ),
                    deleteIcon: Tooltip(
                      message: l10n.prepStudyPlanRestoreTooltip,
                      child: const Icon(Icons.restore_rounded),
                    ),
                    onDeleted: mutationState.isBusy
                        ? null
                        : () => unawaited(
                              ref
                                  .read(studyPlanControllerProvider.notifier)
                                  .restoreMaterial(plan, mat.id),
                            ),
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
