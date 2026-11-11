import 'dart:async' show unawaited;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:job_prep/core/localization/app_localizations_extension.dart';
import 'package:job_prep/core/localization/formatters.dart';
import 'package:job_prep/core/localization/locale_controller.dart';
import 'package:job_prep/core/theme/app_theme_tokens.dart';
import 'package:job_prep/core/widgets/glass_card.dart';
import 'package:job_prep/features/prep/domain/entities/prep_enums.dart';
import 'package:job_prep/features/prep/domain/entities/prep_material.dart';
import 'package:job_prep/features/prep/domain/entities/subject.dart';
import 'package:job_prep/features/prep/presentation/providers/prep_providers.dart';
import 'package:job_prep/features/prep/presentation/providers/study_session_providers.dart';
import 'package:job_prep/features/prep/presentation/providers/study_timer_controller.dart';
import 'package:job_prep/features/prep/presentation/providers/study_timer_state.dart';
import 'package:job_prep/features/prep/presentation/utils/prep_l10n.dart';
import 'package:job_prep/features/prep/presentation/utils/study_timer_l10n.dart';
import 'package:job_prep/features/prep/presentation/widgets/study_session_finish_sheet.dart';
import 'package:job_prep/features/prep/presentation/widgets/study_session_form_dialog.dart';
import 'package:job_prep/features/prep/presentation/widgets/study_timer_controls.dart';
import 'package:job_prep/features/prep/presentation/widgets/study_timer_dialogs.dart';
import 'package:job_prep/features/prep/presentation/widgets/study_timer_round_alert_banner.dart';
import 'package:job_prep/features/prep/presentation/widgets/study_timer_sections.dart';

/// Timestamp-driven Focus (Pomodoro) & Stopwatch study timer card.
class StudyTimer extends ConsumerWidget {
  /// Creates a [StudyTimer].
  const StudyTimer({
    super.key,
    this.replayKey = 'timer',
  });

  /// Key replaying progress ring entrance when opening the Timer tab.
  final Object replayKey;

  Future<void> _openFinish(
    BuildContext context,
    WidgetRef ref,
    StudyTimerState timerState,
    List<Subject> subjects,
    List<PrepMaterial> materials,
  ) async {
    final session = timerState.activeSession;
    if (session == null) return;
    final notifier = ref.read(studyTimerControllerProvider.notifier);
    if (timerState.isRunning) {
      await notifier.pause();
    }
    if (!context.mounted) return;
    final latest = ref.read(studyTimerControllerProvider);
    final latestSession = latest.activeSession ?? session;
    final studiedSeconds = latest.evaluation?.studiedSeconds ?? 0;

    final subject =
        subjects.where((s) => s.id == latestSession.subjectId).firstOrNull;
    final material = latestSession.materialId == null
        ? null
        : materials.where((m) => m.id == latestSession.materialId).firstOrNull;

    await showStudySessionFinishSheet(
      context,
      activeSession: latestSession,
      studiedSeconds: studiedSeconds,
      subject: subject,
      material: material,
    );
  }

  Future<void> _handleDiscard(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDiscardSessionDialog(context);
    if (confirmed && context.mounted) {
      await ref
          .read(studyTimerControllerProvider.notifier)
          .discardActiveSession();
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tokens = context.tokens;
    final colors = tokens.colors;
    final spacing = tokens.spacing;
    final l10n = context.l10n;
    final locale = ref.watch(localeProvider);
    final useBanglaDigits = ref.watch(useBanglaDigitsProvider);

    final timerState = ref.watch(studyTimerControllerProvider);
    final controller = ref.read(studyTimerControllerProvider.notifier);
    final config = ref.watch(pomodoroConfigProvider);
    final soundEnabled = ref.watch(timerSoundEnabledProvider);

    final subjects = List<Subject>.of(
      ref.watch(subjectsProvider).asData?.value ?? const <Subject>[],
    )..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
    final materials =
        ref.watch(allMaterialsProvider).asData?.value ?? const <PrepMaterial>[];

    final activeSession = timerState.activeSession;
    final eval = timerState.evaluation;
    final selectedMode = activeSession?.mode ?? timerState.selectedMode;
    final selectedSubjectId = activeSession?.subjectId ??
        (subjects.any((s) => s.id == timerState.selectedSubjectId)
            ? timerState.selectedSubjectId
            : (subjects.isNotEmpty ? subjects.first.id : null));
    final scopedMaterials = selectedSubjectId == null
        ? const <PrepMaterial>[]
        : materials
            .where((m) => m.subjectId == selectedSubjectId)
            .toList(growable: false);
    final selectedMaterialId = activeSession?.materialId ??
        (scopedMaterials.any((m) => m.id == timerState.selectedMaterialId)
            ? timerState.selectedMaterialId
            : null);

    final displaySeconds = activeSession == null
        ? (selectedMode == StudySessionMode.focus
            ? config.focusMinutes * 60
            : 0)
        : (activeSession.mode == StudySessionMode.focus
            ? (eval?.phaseRemainingSeconds ?? 0)
            : (eval?.studiedSeconds ?? 0));

    String fmtInt(int v) => AppFormatters.formatNumber(
          v,
          locale: locale,
          useBanglaDigits: useBanglaDigits,
        );

    final phaseLabel = activeSession == null
        ? StudyTimerL10n.modeLabel(selectedMode, l10n)
        : (activeSession.mode == StudySessionMode.stopwatch
            ? l10n.prepTimerModeStopwatch
            : StudyTimerL10n.phaseLabel(
                phase: activeSession.pomodoroPhase ?? PomodoroPhase.focus,
                round: activeSession.pomodoroRound ?? 1,
                l10n: l10n,
                locale: locale,
                useBanglaDigits: useBanglaDigits,
              ));

    final statusLabel = activeSession == null
        ? l10n.prepTimerStatusReady
        : (timerState.isPaused
            ? l10n.prepTimerStatusPaused
            : l10n.prepTimerStatusRunning);

    return GlassCard(
      key: const ValueKey('study-timer-card'),
      padding: spacing.insetsAllXl,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          StudyTimerHeaderBar(
            selectedMode: selectedMode,
            hasActiveSession: timerState.hasActiveSession,
            soundEnabled: soundEnabled,
            onSelectMode: controller.selectMode,
            onOpenConfig: () =>
                unawaited(showPomodoroConfigDialog(context, ref)),
            onToggleSound: (v) => unawaited(
              ref
                  .read(timerSoundEnabledProvider.notifier)
                  .setEnabled(enabled: v),
            ),
          ),
          if (selectedMode == StudySessionMode.focus) ...[
            SizedBox(height: spacing.xs),
            Text(
              l10n.prepTimerConfigSummary(
                fmtInt(config.focusMinutes),
                fmtInt(config.shortBreakMinutes),
                fmtInt(config.longBreakMinutes),
              ),
              style: tokens.textStyles.bodySmall.copyWith(
                color: colors.textSecondary,
              ),
            ),
          ],
          if (timerState.roundAlert != null) ...[
            SizedBox(height: spacing.md),
            StudyTimerRoundAlertBanner(
              alert: timerState.roundAlert!,
              config: activeSession?.pomodoroConfig ?? config,
              locale: locale,
              useBanglaDigits: useBanglaDigits,
              isBusy: timerState.isBusy,
              onAdvancePhase: () =>
                  unawaited(controller.advancePomodoroPhase()),
              onFinish: () => unawaited(
                _openFinish(context, ref, timerState, subjects, materials),
              ),
              onDismiss: controller.dismissRoundAlert,
            ),
          ],
          SizedBox(height: spacing.lg),
          StudyTimerClockRing(
            activeSession: activeSession,
            evaluation: eval,
            selectedMode: selectedMode,
            replayKey: replayKey,
            displaySeconds: displaySeconds,
            phaseLabel: phaseLabel,
            statusLabel: statusLabel,
            isPaused: timerState.isPaused,
            locale: locale,
            useBanglaDigits: useBanglaDigits,
          ),
          if (activeSession != null &&
              activeSession.mode == StudySessionMode.focus) ...[
            SizedBox(height: spacing.xs),
            Center(
              child: Text(
                l10n.prepTimerElapsedSummary(
                  StudyTimerL10n.formatClock(
                    eval?.studiedSeconds ?? 0,
                    locale: locale,
                    useBanglaDigits: useBanglaDigits,
                  ),
                ),
                style: tokens.textStyles.bodySmall.copyWith(
                  color: colors.textSecondary,
                ),
              ),
            ),
          ],
          SizedBox(height: spacing.lg),
          StudyTimerSubjectPickers(
            subjects: subjects,
            scopedMaterials: scopedMaterials,
            selectedSubjectId: selectedSubjectId,
            selectedMaterialId: selectedMaterialId,
            isLocked: timerState.hasActiveSession,
            onSelectSubject: controller.selectSubject,
            onSelectMaterial: controller.selectMaterial,
          ),
          if (timerState.error != null) ...[
            SizedBox(height: spacing.sm),
            Text(
              PrepL10n.failureMessage(timerState.error!, l10n),
              style: tokens.textStyles.bodySmall.copyWith(color: colors.danger),
            ),
          ],
          SizedBox(height: spacing.lg),
          StudyTimerActionBar(
            hasActiveSession: timerState.hasActiveSession,
            isRunning: timerState.isRunning,
            isBusy: timerState.isBusy,
            canStart: selectedSubjectId != null,
            canLogManual: subjects.isNotEmpty,
            onStart: () => unawaited(
              controller.startSession(
                subjectId: selectedSubjectId!,
                materialId: selectedMaterialId,
                mode: selectedMode,
              ),
            ),
            onManualEntry: () => unawaited(
              showStudySessionFormDialog(
                context,
                initialSubjectId: selectedSubjectId,
              ),
            ),
            onPause: () => unawaited(controller.pause()),
            onResume: () => unawaited(controller.resume()),
            onFinish: () => unawaited(
              _openFinish(context, ref, timerState, subjects, materials),
            ),
            onDiscard: () => unawaited(_handleDiscard(context, ref)),
          ),
          if (subjects.isEmpty) ...[
            SizedBox(height: spacing.sm),
            Text(
              l10n.prepTimerSubjectRequired,
              textAlign: TextAlign.center,
              style: tokens.textStyles.bodySmall.copyWith(
                color: colors.textMuted,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
