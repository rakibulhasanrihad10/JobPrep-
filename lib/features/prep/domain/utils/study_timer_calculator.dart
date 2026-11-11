import 'dart:math' as math;

import 'package:flutter/foundation.dart' show immutable;
import 'package:job_prep/features/prep/domain/entities/prep_enums.dart';
import 'package:job_prep/features/prep/domain/entities/study_session.dart';
import 'package:job_prep/features/prep/domain/utils/study_session_date_splitter.dart';

/// Minimum study session slice (in seconds) that counts a local calendar day
/// as studied on streaks and consistency metrics (`10 minutes = 600s`).
const int kMinimumQualifyingSessionSeconds = 600;

/// Snapshot evaluating live or completed elapsed/remaining timer metrics from
/// pure timestamps and pause intervals.
@immutable
class StudyTimerEvaluation {
  /// Creates a [StudyTimerEvaluation].
  const StudyTimerEvaluation({
    required this.studiedSeconds,
    required this.phaseElapsedSeconds,
    required this.phaseRemainingSeconds,
    required this.targetSeconds,
    required this.isRoundComplete,
    required this.isOnBreak,
    required this.isPaused,
    this.phaseCompletedAt,
  });

  /// Total active studied seconds accumulated (excludes pauses & breaks).
  final int studiedSeconds;

  /// Seconds elapsed in the current Pomodoro phase (or full stopwatch elapsed).
  final int phaseElapsedSeconds;

  /// Seconds remaining in the current Pomodoro phase (`0` for stopwatch mode).
  final int phaseRemainingSeconds;

  /// Configured target duration for the current Pomodoro phase (`0` stopwatch).
  final int targetSeconds;

  /// Whether the active Focus or Break round has reached [targetSeconds].
  final bool isRoundComplete;

  /// Whether the timer is currently in a short or long Pomodoro break.
  final bool isOnBreak;

  /// Whether the active timer phase is currently paused.
  final bool isPaused;

  /// Exact UTC instant when the active Focus/Break phase completed target, if
  /// [isRoundComplete] is true.
  final DateTime? phaseCompletedAt;
}

/// Pure, side-effect-free timestamp arithmetic, pause-interval subtraction,
/// Pomodoro round state machine, and local-midnight splitting helpers.
abstract final class StudyTimerCalculator {
  /// Merges and clips study-affecting pause intervals within
  /// `[windowStart, windowEnd]`.
  static List<({DateTime start, DateTime end})> mergePauseWindows(
    Iterable<PauseInterval> intervals, {
    required DateTime windowStart,
    required DateTime windowEnd,
    bool includeBreakOnly = false,
  }) {
    final startUtc = windowStart.toUtc();
    final endUtc = windowEnd.toUtc();
    if (!endUtc.isAfter(startUtc)) return const [];

    final clipped = <({DateTime start, DateTime end})>[];
    for (final interval in intervals) {
      if (!includeBreakOnly && interval.isBreakOnly) continue;
      final rawStart = interval.pausedAt.toUtc();
      final rawEnd = (interval.resumedAt ?? endUtc).toUtc();
      final s = rawStart.isBefore(startUtc) ? startUtc : rawStart;
      final e = rawEnd.isAfter(endUtc) ? endUtc : rawEnd;
      if (e.isAfter(s)) {
        clipped.add((start: s, end: e));
      }
    }
    if (clipped.isEmpty) return const [];

    clipped.sort((a, b) => a.start.compareTo(b.start));
    final merged = <({DateTime start, DateTime end})>[clipped.first];
    for (final item in clipped.skip(1)) {
      final last = merged.last;
      if (!item.start.isAfter(last.end)) {
        merged[merged.length - 1] = (
          start: last.start,
          end: item.end.isAfter(last.end) ? item.end : last.end,
        );
      } else {
        merged.add(item);
      }
    }
    return merged;
  }

  /// Calculates active (non-paused) seconds within
  /// `[startedAt, endedAt ?? now]` from recorded timestamps and
  /// [pauseIntervals].
  static int calculateActiveSeconds({
    required DateTime startedAt,
    required DateTime now,
    DateTime? endedAt,
    List<PauseInterval> pauseIntervals = const <PauseInterval>[],
    bool includeBreakOnly = false,
  }) {
    final startUtc = startedAt.toUtc();
    final endUtc = (endedAt ?? now).toUtc();
    if (!endUtc.isAfter(startUtc)) return 0;

    final totalSeconds = endUtc.difference(startUtc).inSeconds;
    final pauses = mergePauseWindows(
      pauseIntervals,
      windowStart: startUtc,
      windowEnd: endUtc,
      includeBreakOnly: includeBreakOnly,
    );
    var pausedSeconds = 0;
    for (final pause in pauses) {
      pausedSeconds += pause.end.difference(pause.start).inSeconds;
    }
    return math.max(0, totalSeconds - pausedSeconds);
  }

  /// Calculates remaining seconds for a countdown target, clamped `>= 0`.
  static int calculateRemainingSeconds({
    required int elapsedSeconds,
    required int targetSeconds,
  }) {
    if (targetSeconds <= 0) return 0;
    return (targetSeconds - elapsedSeconds).clamp(0, targetSeconds);
  }

  /// Resolves the exact UTC timestamp at which active time starting from
  /// [phaseStart] reaches [targetSeconds], skipping over [pauseIntervals].
  static DateTime resolveCompletionTimestamp({
    required DateTime phaseStart,
    required int targetSeconds,
    required DateTime fallbackEnd,
    List<PauseInterval> pauseIntervals = const <PauseInterval>[],
    bool includeBreakOnly = false,
  }) {
    if (targetSeconds <= 0) return phaseStart.toUtc();
    final startUtc = phaseStart.toUtc();
    final endUtc = fallbackEnd.toUtc();
    final pauses = mergePauseWindows(
      pauseIntervals,
      windowStart: startUtc,
      windowEnd: endUtc,
      includeBreakOnly: includeBreakOnly,
    );

    var cursor = startUtc;
    var remaining = targetSeconds;
    for (final pause in pauses) {
      final activeBeforePause = pause.start.difference(cursor).inSeconds;
      if (activeBeforePause >= remaining) {
        return cursor.add(Duration(seconds: remaining));
      }
      remaining -= activeBeforePause;
      cursor = pause.end;
    }
    return cursor.add(Duration(seconds: remaining));
  }

  /// Evaluates live or completed [session] timing relative to [now].
  static StudyTimerEvaluation evaluateSession(
    StudySession session, {
    required DateTime now,
  }) {
    final endRef = (session.endedAt ?? now).toUtc();

    if (session.mode == StudySessionMode.manual) {
      return StudyTimerEvaluation(
        studiedSeconds: math.max(0, session.durationSeconds),
        phaseElapsedSeconds: math.max(0, session.durationSeconds),
        phaseRemainingSeconds: 0,
        targetSeconds: 0,
        isRoundComplete: false,
        isOnBreak: false,
        isPaused: false,
      );
    }

    if (session.mode == StudySessionMode.stopwatch) {
      final studied = calculateActiveSeconds(
        startedAt: session.startedAt,
        endedAt: session.endedAt,
        pauseIntervals: session.pauseIntervals,
        now: endRef,
      );
      return StudyTimerEvaluation(
        studiedSeconds: studied,
        phaseElapsedSeconds: studied,
        phaseRemainingSeconds: 0,
        targetSeconds: 0,
        isRoundComplete: false,
        isOnBreak: false,
        isPaused: session.isPaused,
      );
    }

    final phase = session.pomodoroPhase ?? PomodoroPhase.focus;
    final phaseStart = (session.phaseStartedAt ?? session.startedAt).toUtc();
    final target = session.targetDurationSeconds ??
        phaseDurationSeconds(phase, config: session.pomodoroConfig);
    final isBreak = phase != PomodoroPhase.focus;

    final relevantPauses = session.pauseIntervals
        .where(
          (p) =>
              p.isBreakOnly == isBreak &&
              (p.resumedAt == null || p.resumedAt!.toUtc().isAfter(phaseStart)),
        )
        .toList(growable: false);

    final rawPhaseElapsed = calculateActiveSeconds(
      startedAt: phaseStart,
      endedAt: session.endedAt,
      pauseIntervals: relevantPauses,
      now: endRef,
      includeBreakOnly: isBreak,
    );
    final clampedPhaseElapsed =
        target > 0 ? rawPhaseElapsed.clamp(0, target) : rawPhaseElapsed;
    final complete = target > 0 && rawPhaseElapsed >= target;
    final completedAt = complete
        ? resolveCompletionTimestamp(
            phaseStart: phaseStart,
            targetSeconds: target,
            fallbackEnd: endRef,
            pauseIntervals: relevantPauses,
            includeBreakOnly: isBreak,
          )
        : null;

    final studied = isBreak
        ? calculateActiveSeconds(
            startedAt: session.startedAt,
            endedAt: phaseStart,
            pauseIntervals: session.pauseIntervals,
            now: phaseStart,
          )
        : calculateActiveSeconds(
            startedAt: session.startedAt,
            endedAt: complete ? completedAt : session.endedAt,
            pauseIntervals: session.pauseIntervals,
            now: complete ? (completedAt ?? endRef) : endRef,
          );

    return StudyTimerEvaluation(
      studiedSeconds: studied,
      phaseElapsedSeconds: clampedPhaseElapsed,
      phaseRemainingSeconds: calculateRemainingSeconds(
        elapsedSeconds: clampedPhaseElapsed,
        targetSeconds: target,
      ),
      targetSeconds: target,
      isRoundComplete: complete,
      isOnBreak: isBreak,
      isPaused: relevantPauses.any((p) => p.isOpen),
      phaseCompletedAt: completedAt,
    );
  }

  /// Returns configured duration in seconds for a [PomodoroPhase].
  static int phaseDurationSeconds(
    PomodoroPhase phase, {
    PomodoroConfig config = const PomodoroConfig(),
  }) {
    return switch (phase) {
      PomodoroPhase.focus => config.focusMinutes * 60,
      PomodoroPhase.shortBreak => config.shortBreakMinutes * 60,
      PomodoroPhase.longBreak => config.longBreakMinutes * 60,
    };
  }

  /// Advances a Pomodoro timer along Focus -> Short Break / Long Break (after
  /// 4 rounds by default) -> Next Focus round.
  static ({int round, PomodoroPhase phase, int targetSeconds})
      nextPomodoroStep({
    required int currentRound,
    required PomodoroPhase currentPhase,
    PomodoroConfig config = const PomodoroConfig(),
  }) {
    final safeRound = math.max(1, currentRound);
    if (currentPhase == PomodoroPhase.focus) {
      final isLong = safeRound % config.roundsBeforeLongBreak == 0;
      final nextPhase =
          isLong ? PomodoroPhase.longBreak : PomodoroPhase.shortBreak;
      return (
        round: safeRound,
        phase: nextPhase,
        targetSeconds: phaseDurationSeconds(nextPhase, config: config),
      );
    }

    final nextRound = safeRound + 1;
    return (
      round: nextRound,
      phase: PomodoroPhase.focus,
      targetSeconds: phaseDurationSeconds(PomodoroPhase.focus, config: config),
    );
  }

  /// Splits [session] active duration across the user's local calendar dates,
  /// excluding pause intervals and summing to the total duration.
  static Map<DateTime, int> splitSessionByLocalDate(
    StudySession session, {
    DateTime? now,
    Duration? localOffset,
  }) =>
      StudySessionDateSplitter.splitByLocalDate(
        session,
        now: now,
        localOffset: localOffset,
      );

  /// Formats [totalSeconds] cleanly as `MM:SS` or `H:MM:SS`.
  static String formatTimerClock(int totalSeconds) {
    final safe = math.max(0, totalSeconds);
    final hours = safe ~/ 3600;
    final minutes = (safe % 3600) ~/ 60;
    final seconds = safe % 60;
    final mm = minutes.toString().padLeft(2, '0');
    final ss = seconds.toString().padLeft(2, '0');
    if (hours > 0) {
      return '$hours:$mm:$ss';
    }
    return '$mm:$ss';
  }
}
