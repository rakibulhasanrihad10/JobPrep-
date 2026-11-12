import 'dart:async' show unawaited;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:job_prep/core/localization/app_localizations_extension.dart';
import 'package:job_prep/core/localization/locale_controller.dart';
import 'package:job_prep/core/theme/app_theme_tokens.dart';
import 'package:job_prep/core/widgets/animated_progress_bar.dart';
import 'package:job_prep/core/widgets/glass_button.dart';
import 'package:job_prep/core/widgets/glass_card.dart';
import 'package:job_prep/features/prep/domain/entities/prep_enums.dart';
import 'package:job_prep/features/prep/presentation/providers/study_timer_controller.dart';
import 'package:job_prep/features/prep/presentation/utils/study_plan_ui_helpers.dart';
import 'package:job_prep/features/prep/presentation/widgets/study_plan_form_dialog.dart';
import 'package:job_prep/features/prep/presentation/widgets/study_plan_stat_pill.dart';
import 'package:job_prep/features/today/domain/entities/today_summary.dart';
import 'package:job_prep/features/today/presentation/utils/today_l10n.dart';
import 'package:job_prep/features/today/presentation/widgets/today_quick_log_dialog.dart';
import 'package:job_prep/features/today/presentation/widgets/today_section_header.dart';

/// Displays one row per active study plan scope with today's completed/target
/// units, an [AnimatedProgressBar], Quick log button, and Start timer button.
class TodayStudyTargetsCard extends ConsumerWidget {
  /// Creates a [TodayStudyTargetsCard].
  const TodayStudyTargetsCard({
    required this.targets,
    required this.visitId,
    super.key,
  });

  /// Ordered active study target rows from [TodaySummary.studyTargets].
  final List<TodayStudyTargetRow> targets;

  /// Monotonic visit counter replaying progress bars when Today opens.
  final int visitId;

  Future<void> _startTimer(
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

    return GlassCard(
      key: const ValueKey('today-targets-card'),
      padding: spacing.insetsAllLg,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TodaySectionHeader(
            icon: Icons.track_changes_rounded,
            title: l10n.todayTargetsTitle,
            action: TextButton(
              key: const ValueKey('today-targets-manage-btn'),
              onPressed: () => unawaited(showStudyPlanFormDialog(context)),
              child: Text(l10n.prepStudyPlanAddButton),
            ),
          ),
          SizedBox(height: spacing.md),
          if (targets.isEmpty)
            Container(
              key: const ValueKey('today-targets-empty'),
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
                    l10n.todayTargetsEmptyTitle,
                    style: tokens.textStyles.labelLarge,
                  ),
                  SizedBox(height: spacing.xs),
                  Text(
                    l10n.todayTargetsEmptyBody,
                    style: tokens.textStyles.bodySmall,
                  ),
                  SizedBox(height: spacing.md),
                  Align(
                    alignment: AlignmentDirectional.centerStart,
                    child: GlassButton(
                      key: const ValueKey('today-create-plan-btn'),
                      variant: GlassButtonVariant.primary,
                      onPressed: () =>
                          unawaited(showStudyPlanFormDialog(context)),
                      leading: Icon(Icons.add_task_rounded, size: spacing.lg),
                      child: Text(l10n.todayTargetsCreatePlanButton),
                    ),
                  ),
                ],
              ),
            )
          else
            for (var i = 0; i < targets.length; i++) ...[
              if (i > 0) SizedBox(height: spacing.sm),
              _TodayTargetRowTile(
                row: targets[i],
                visitId: visitId,
                locale: locale,
                useBanglaDigits: useBanglaDigits,
                onQuickLog: () => unawaited(
                  showTodayQuickLogDialog(context, row: targets[i]),
                ),
                onStartTimer: () => unawaited(
                  _startTimer(context, ref, targets[i]),
                ),
              ),
            ],
        ],
      ),
    );
  }
}

class _TodayTargetRowTile extends StatelessWidget {
  const _TodayTargetRowTile({
    required this.row,
    required this.visitId,
    required this.locale,
    required this.useBanglaDigits,
    required this.onQuickLog,
    required this.onStartTimer,
  });

  final TodayStudyTargetRow row;
  final int visitId;
  final Locale locale;
  final bool useBanglaDigits;
  final VoidCallback onQuickLog;
  final VoidCallback onStartTimer;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final colors = tokens.colors;
    final spacing = tokens.spacing;
    final radii = tokens.radii;
    final l10n = context.l10n;

    final slug = row.slug;
    final title = TodayL10n.planScopeTitle(
      isAllSubjects: row.isAllSubjects,
      subject: row.subject,
      l10n: l10n,
    );
    final statusColor =
        StudyPlanUiHelpers.statusColor(row.scheduleStatus, tokens);
    final statusLabel =
        StudyPlanUiHelpers.statusLabel(row.scheduleStatus, l10n);

    final fmtDone = TodayL10n.formatCount(
      row.todayDoneUnits,
      locale: locale,
      useBanglaDigits: useBanglaDigits,
    );
    final fmtTarget = TodayL10n.formatCount(
      row.todayTargetUnits,
      locale: locale,
      useBanglaDigits: useBanglaDigits,
    );
    final fmtRemaining = TodayL10n.formatCount(
      row.remainingTodayUnits,
      locale: locale,
      useBanglaDigits: useBanglaDigits,
    );

    final remainingLabel = row.remainingTodayUnits > 0
        ? l10n.todayTargetRowRemaining(fmtRemaining)
        : l10n.todayTargetRowComplete;

    return Container(
      key: ValueKey('today-target-row-$slug'),
      padding: spacing.insetsAllMd,
      decoration: BoxDecoration(
        color: colors.surfaceElevated,
        borderRadius: radii.cardRadius,
        border: Border.all(color: colors.glassBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Wrap(
                  spacing: spacing.xs,
                  runSpacing: spacing.xs,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Text(
                      title,
                      style: tokens.textStyles.titleMedium,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    StudyPlanStatusBadge(
                      label: statusLabel,
                      color: statusColor,
                    ),
                  ],
                ),
              ),
              SizedBox(width: spacing.sm),
              Text(
                l10n.todayTargetRowDoneTarget(fmtDone, fmtTarget),
                key: ValueKey('today-target-count-$slug'),
                style: tokens.textStyles.labelLarge.copyWith(
                  color: row.remainingTodayUnits == 0
                      ? colors.success
                      : colors.goldAccent,
                ),
              ),
            ],
          ),
          SizedBox(height: spacing.xs),
          AnimatedProgressBar(
            key: ValueKey('today-target-bar-$slug'),
            value: row.progress,
            replayKey: 'today-bar-$slug-$visitId',
            progressColor: statusColor,
          ),
          SizedBox(height: spacing.xs),
          Text(
            remainingLabel,
            style: tokens.textStyles.bodySmall.copyWith(
              color: colors.textSecondary,
            ),
          ),
          SizedBox(height: spacing.sm),
          Wrap(
            spacing: spacing.sm,
            runSpacing: spacing.xs,
            children: [
              GlassButton(
                key: ValueKey('today-target-quick-log-$slug'),
                onPressed: onQuickLog,
                leading: Icon(Icons.add_rounded, size: spacing.lg),
                child: Text(l10n.todayTargetQuickLogButton),
              ),
              GlassButton(
                key: ValueKey('today-target-start-timer-$slug'),
                variant: GlassButtonVariant.primary,
                onPressed: onStartTimer,
                leading: Icon(
                  Icons.play_arrow_rounded,
                  size: spacing.lg,
                  color: colors.goldAccent,
                ),
                child: Text(l10n.todayTargetStartTimerButton),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
