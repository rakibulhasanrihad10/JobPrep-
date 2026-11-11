import 'package:job_prep/features/prep/domain/entities/prep_enums.dart';
import 'package:job_prep/features/prep/domain/entities/study_session.dart';
import 'package:job_prep/features/prep/domain/utils/study_timer_calculator.dart';

/// Pure immutable state-transition helpers building persisted [StudySession]
/// snapshots for start, pause, resume, Pomodoro transitions, and completion.
abstract final class StudySessionTransitions {
  /// Builds an open (`endedAt: null`) [StudySession] anchored to [startedAt].
  static StudySession buildStartedSession({
    required String subjectId,
    required StudySessionMode mode,
    required DateTime startedAt,
    String? materialId,
    PomodoroConfig config = const PomodoroConfig(),
  }) {
    final startUtc = startedAt.toUtc();
    final isFocus = mode == StudySessionMode.focus;
    final cleanMat = (materialId == null || materialId.trim().isEmpty)
        ? null
        : materialId.trim();

    return StudySession(
      id: '',
      userId: '',
      subjectId: subjectId.trim(),
      materialId: cleanMat,
      startedAt: startUtc,
      mode: isFocus ? StudySessionMode.focus : StudySessionMode.stopwatch,
      phaseStartedAt: isFocus ? startUtc : null,
      targetDurationSeconds: isFocus ? config.focusMinutes * 60 : null,
      pomodoroRound: isFocus ? 1 : null,
      pomodoroPhase: isFocus ? PomodoroPhase.focus : null,
      focusMinutes: config.focusMinutes,
      shortBreakMinutes: config.shortBreakMinutes,
      longBreakMinutes: config.longBreakMinutes,
    );
  }

  /// Appends an open pause interval at [pausedAt] if not already paused.
  static StudySession buildPausedSession(
    StudySession session, {
    required DateTime pausedAt,
  }) {
    final eval = StudyTimerCalculator.evaluateSession(session, now: pausedAt);
    if (eval.isPaused) return session;
    final updatedIntervals = List<PauseInterval>.of(session.pauseIntervals)
      ..add(
        PauseInterval(
          pausedAt: pausedAt.toUtc(),
          isBreakOnly: session.isOnBreak,
        ),
      );
    return session.copyWith(
      pauseIntervals: List<PauseInterval>.unmodifiable(updatedIntervals),
    );
  }

  /// Closes active open pause interval matching current phase at [resumedAt].
  static StudySession buildResumedSession(
    StudySession session, {
    required DateTime resumedAt,
  }) {
    final nowUtc = resumedAt.toUtc();
    final isBreak = session.isOnBreak;
    var changed = false;
    final updatedIntervals = <PauseInterval>[
      for (final interval in session.pauseIntervals)
        if (interval.isOpen && interval.isBreakOnly == isBreak)
          (() {
            changed = true;
            return interval.copyWith(resumedAt: nowUtc);
          })()
        else
          interval,
    ];
    if (!changed) return session;
    return session.copyWith(
      pauseIntervals: List<PauseInterval>.unmodifiable(updatedIntervals),
    );
  }

  /// Transitions Focus -> Short/Long Break or Break -> Next Focus round cleanly
  /// while freezing study duration across breaks.
  static StudySession buildNextPomodoroPhase(
    StudySession session, {
    required DateTime now,
  }) {
    final nowUtc = now.toUtc();
    final eval = StudyTimerCalculator.evaluateSession(session, now: nowUtc);
    final currentRound = session.pomodoroRound ?? 1;
    final currentPhase = session.pomodoroPhase ?? PomodoroPhase.focus;
    final next = StudyTimerCalculator.nextPomodoroStep(
      currentRound: currentRound,
      currentPhase: currentPhase,
      config: session.pomodoroConfig,
    );

    final updatedIntervals = <PauseInterval>[
      for (final interval in session.pauseIntervals)
        if (interval.isOpen && interval.isBreakOnly)
          interval.copyWith(resumedAt: nowUtc)
        else
          interval,
    ];

    if (currentPhase == PomodoroPhase.focus) {
      final focusEndedAt = eval.phaseCompletedAt ?? nowUtc;
      final hasOpenStudyPause = updatedIntervals.any(
        (i) => i.isOpen && !i.isBreakOnly,
      );
      if (!hasOpenStudyPause) {
        updatedIntervals.add(PauseInterval(pausedAt: focusEndedAt));
      }
    } else {
      for (var i = 0; i < updatedIntervals.length; i++) {
        if (updatedIntervals[i].isOpen && !updatedIntervals[i].isBreakOnly) {
          updatedIntervals[i] = updatedIntervals[i].copyWith(resumedAt: nowUtc);
        }
      }
    }

    return session.copyWith(
      durationSeconds: eval.studiedSeconds,
      pauseIntervals: List<PauseInterval>.unmodifiable(updatedIntervals),
      phaseStartedAt: nowUtc,
      pomodoroRound: next.round,
      pomodoroPhase: next.phase,
      targetDurationSeconds: next.targetSeconds,
    );
  }

  /// Finalizes an active session (`endedAt` populated, open pauses closed,
  /// exact studied duration recorded).
  static StudySession buildCompletedSession(
    StudySession session, {
    required DateTime finishedAt,
    String? note,
  }) {
    final nowUtc = finishedAt.toUtc();
    final eval = StudyTimerCalculator.evaluateSession(session, now: nowUtc);

    var effectiveEnd = nowUtc;
    if (!session.isOnBreak && eval.phaseCompletedAt != null) {
      effectiveEnd = eval.phaseCompletedAt!;
    }

    final closedIntervals = <PauseInterval>[];
    for (final interval in session.pauseIntervals) {
      if (interval.isOpen) {
        if (!interval.isBreakOnly && !session.isOnBreak) {
          if (!interval.pausedAt.isBefore(session.startedAt) &&
              interval.pausedAt.isBefore(effectiveEnd)) {
            effectiveEnd = interval.pausedAt.toUtc();
          }
          closedIntervals.add(interval.copyWith(resumedAt: effectiveEnd));
        } else {
          closedIntervals.add(interval.copyWith(resumedAt: effectiveEnd));
        }
      } else {
        closedIntervals.add(interval);
      }
    }
    if (effectiveEnd.isBefore(session.startedAt)) {
      effectiveEnd = session.startedAt;
    }

    final cleanNote = note?.trim();
    return session.copyWith(
      endedAt: effectiveEnd,
      durationSeconds: eval.studiedSeconds,
      note: (cleanNote == null || cleanNote.isEmpty) ? null : cleanNote,
      pauseIntervals: List<PauseInterval>.unmodifiable(closedIntervals),
    );
  }
}
