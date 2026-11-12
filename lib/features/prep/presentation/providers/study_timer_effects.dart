import 'dart:async' show unawaited;

import 'package:job_prep/features/prep/domain/entities/prep_enums.dart';
import 'package:job_prep/features/prep/domain/entities/study_session.dart';
import 'package:job_prep/features/prep/domain/utils/study_timer_calculator.dart';
import 'package:job_prep/features/prep/presentation/providers/study_timer_state.dart';
import 'package:job_prep/features/prep/presentation/utils/timer_platform_adapter.dart';

/// Callback producing a localized browser tab title for an open session.
typedef StudyTimerTabTitleBuilder = String Function(
  StudySession session,
  StudyTimerEvaluation evaluation,
);

/// UI & platform side-effect helpers for StudyTimerController:
/// builds once-per-phase completion alerts, plays chimes, & syncs tab title.
abstract final class StudyTimerEffects {
  /// Builds an alert when a Focus/Break countdown reaches zero and returns the
  /// dedup key alongside the alert (or `null` when already alerted / incomplete).
  static ({StudyTimerRoundAlert alert, String key})? maybeBuildRoundAlert({
    required StudySession session,
    required StudyTimerEvaluation evaluation,
    required String? lastAlertKey,
    required DateTime fallbackNow,
  }) {
    if (session.mode != StudySessionMode.focus || !evaluation.isRoundComplete) {
      return null;
    }
    final round = session.pomodoroRound ?? 1;
    final phase = session.pomodoroPhase ?? PomodoroPhase.focus;
    final key = '${session.id}:$round:${phase.value}';
    if (lastAlertKey == key) return null;

    final next = StudyTimerCalculator.nextPomodoroStep(
      currentRound: round,
      currentPhase: phase,
      config: session.pomodoroConfig,
    );
    return (
      key: key,
      alert: StudyTimerRoundAlert(
        round: round,
        completedPhase: phase,
        suggestedNextPhase: next.phase,
        suggestedNextRound: next.round,
        completedAt: evaluation.phaseCompletedAt ?? fallbackNow,
      ),
    );
  }

  /// Syncs the browser tab title to the active countdown / elapsed readout.
  static void syncTabTitle({
    required StudyTimerPlatformAdapter? platform,
    required StudySession? session,
    required StudyTimerEvaluation? evaluation,
    required StudyTimerTabTitleBuilder? customBuilder,
  }) {
    if (platform == null) return;
    if (session == null || evaluation == null) {
      platform.restoreTabTitle();
      return;
    }
    if (customBuilder != null) {
      platform.setTabTitle(customBuilder(session, evaluation));
      return;
    }
    final shownSeconds = session.mode == StudySessionMode.focus
        ? evaluation.phaseRemainingSeconds
        : evaluation.studiedSeconds;
    final clockText = StudyTimerCalculator.formatTimerClock(shownSeconds);
    platform.setTabTitle('$clockText — JobPrep');
  }

  /// Plays the soft completion chime when sound is enabled.
  static void playChimeIfEnabled({
    required StudyTimerPlatformAdapter? platform,
    required bool soundEnabled,
  }) {
    if (platform != null && soundEnabled) {
      unawaited(platform.playGentleChime());
    }
  }
}
