import 'package:flutter/foundation.dart' show immutable, listEquals;
import 'package:job_prep/features/prep/domain/entities/prep_enums.dart';

/// Timestamp interval recording when an active timer session was paused and
/// optionally resumed.
@immutable
class PauseInterval {
  /// Creates a [PauseInterval].
  const PauseInterval({
    required this.pausedAt,
    this.resumedAt,
    this.isBreakOnly = false,
  });

  /// UTC timestamp when pausing began.
  final DateTime pausedAt;

  /// UTC timestamp when work resumed (`null` while still paused).
  final DateTime? resumedAt;

  /// When `true`, marks a pause taken within an active break phase without
  /// re-pausing study duration (which is already paused for the break).
  final bool isBreakOnly;

  /// Whether this pause interval is currently active (not yet resumed).
  bool get isOpen => resumedAt == null;

  /// Returns a copy with updated fields.
  PauseInterval copyWith({
    DateTime? pausedAt,
    Object? resumedAt = _unset,
    bool? isBreakOnly,
  }) {
    return PauseInterval(
      pausedAt: pausedAt ?? this.pausedAt,
      resumedAt: identical(resumedAt, _unset)
          ? this.resumedAt
          : resumedAt as DateTime?,
      isBreakOnly: isBreakOnly ?? this.isBreakOnly,
    );
  }

  static const Object _unset = Object();

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is PauseInterval &&
        other.pausedAt == pausedAt &&
        other.resumedAt == resumedAt &&
        other.isBreakOnly == isBreakOnly;
  }

  @override
  int get hashCode => Object.hash(pausedAt, resumedAt, isBreakOnly);
}

/// Configurable Pomodoro interval lengths persisted with user settings and
/// active focus sessions.
@immutable
class PomodoroConfig {
  /// Creates a [PomodoroConfig].
  const PomodoroConfig({
    this.focusMinutes = 25,
    this.shortBreakMinutes = 5,
    this.longBreakMinutes = 15,
    this.roundsBeforeLongBreak = 4,
  });

  /// Focus round duration in minutes (defaults to 25).
  final int focusMinutes;

  /// Short break duration in minutes (defaults to 5).
  final int shortBreakMinutes;

  /// Long break duration in minutes after 4 focus rounds (defaults to 15).
  final int longBreakMinutes;

  /// Number of completed focus rounds triggering a long break (defaults to 4).
  final int roundsBeforeLongBreak;

  /// Returns a validated copy clamping positive durations.
  PomodoroConfig copyWith({
    int? focusMinutes,
    int? shortBreakMinutes,
    int? longBreakMinutes,
    int? roundsBeforeLongBreak,
  }) {
    return PomodoroConfig(
      focusMinutes: (focusMinutes ?? this.focusMinutes).clamp(1, 240),
      shortBreakMinutes: (shortBreakMinutes ?? this.shortBreakMinutes).clamp(
        1,
        120,
      ),
      longBreakMinutes: (longBreakMinutes ?? this.longBreakMinutes).clamp(
        1,
        180,
      ),
      roundsBeforeLongBreak:
          (roundsBeforeLongBreak ?? this.roundsBeforeLongBreak).clamp(1, 12),
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is PomodoroConfig &&
        other.focusMinutes == focusMinutes &&
        other.shortBreakMinutes == shortBreakMinutes &&
        other.longBreakMinutes == longBreakMinutes &&
        other.roundsBeforeLongBreak == roundsBeforeLongBreak;
  }

  @override
  int get hashCode => Object.hash(
        focusMinutes,
        shortBreakMinutes,
        longBreakMinutes,
        roundsBeforeLongBreak,
      );
}

/// Domain entity representing one row in `public.study_sessions`.
@immutable
class StudySession {
  /// Creates a [StudySession].
  const StudySession({
    required this.id,
    required this.userId,
    required this.subjectId,
    required this.startedAt,
    this.materialId,
    this.endedAt,
    this.durationSeconds = 0,
    this.mode = StudySessionMode.focus,
    this.note,
    this.pauseIntervals = const <PauseInterval>[],
    this.phaseStartedAt,
    this.targetDurationSeconds,
    this.pomodoroRound,
    this.pomodoroPhase,
    this.focusMinutes = 25,
    this.shortBreakMinutes = 5,
    this.longBreakMinutes = 15,
    this.createdAt,
    this.updatedAt,
  });

  /// Primary UUID identifier.
  final String id;

  /// Owner user UUID (`auth.users.id`).
  final String userId;

  /// Associated subject ID (`subjects.id`).
  final String subjectId;

  /// Optional linked study material ID (`materials.id`).
  final String? materialId;

  /// Session start timestamp (UTC).
  final DateTime startedAt;

  /// Completion timestamp (`null` while open / active across reloads).
  final DateTime? endedAt;

  /// Studied duration in seconds (`>= 0`, excluding pause & break intervals).
  final int durationSeconds;

  /// Timer mode creating this session (`focus`, `stopwatch`, or `manual`).
  final StudySessionMode mode;

  /// Optional session note or summary.
  final String? note;

  /// Chronological pause/resume intervals recorded on this session.
  final List<PauseInterval> pauseIntervals;

  /// Start timestamp of the active Pomodoro focus or break phase (UTC).
  final DateTime? phaseStartedAt;

  /// Target duration in seconds for the current Focus or Break round.
  final int? targetDurationSeconds;

  /// Current Pomodoro round index (1-based).
  final int? pomodoroRound;

  /// Active Pomodoro phase (`focus`, `shortBreak`, or `longBreak`).
  final PomodoroPhase? pomodoroPhase;

  /// Configured Focus minutes for this session.
  final int focusMinutes;

  /// Configured Short Break minutes for this session.
  final int shortBreakMinutes;

  /// Configured Long Break minutes for this session.
  final int longBreakMinutes;

  /// Record creation timestamp.
  final DateTime? createdAt;

  /// Record last-update timestamp.
  final DateTime? updatedAt;

  /// True while the session has not yet been finished and saved.
  bool get isOpen => endedAt == null;

  /// True once the session is saved/completed (`endedAt != null`).
  bool get isCompleted => endedAt != null;

  /// True when an open session currently has an unclosed pause interval.
  bool get isPaused =>
      isOpen && pauseIntervals.any((interval) => interval.isOpen);

  /// True when an open session is actively counting right now.
  bool get isRunning => isOpen && !isPaused;

  /// True when Focus session is currently in a short or long break phase.
  bool get isOnBreak =>
      mode == StudySessionMode.focus &&
      pomodoroPhase != null &&
      pomodoroPhase != PomodoroPhase.focus;

  /// Configured Pomodoro intervals for this session.
  PomodoroConfig get pomodoroConfig => PomodoroConfig(
        focusMinutes: focusMinutes,
        shortBreakMinutes: shortBreakMinutes,
        longBreakMinutes: longBreakMinutes,
      );

  static const Object _unset = Object();

  /// Returns a copy with specified fields replaced.
  StudySession copyWith({
    String? id,
    String? userId,
    String? subjectId,
    Object? materialId = _unset,
    DateTime? startedAt,
    Object? endedAt = _unset,
    int? durationSeconds,
    StudySessionMode? mode,
    Object? note = _unset,
    List<PauseInterval>? pauseIntervals,
    Object? phaseStartedAt = _unset,
    Object? targetDurationSeconds = _unset,
    Object? pomodoroRound = _unset,
    Object? pomodoroPhase = _unset,
    int? focusMinutes,
    int? shortBreakMinutes,
    int? longBreakMinutes,
    Object? createdAt = _unset,
    Object? updatedAt = _unset,
  }) {
    return StudySession(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      subjectId: subjectId ?? this.subjectId,
      materialId: identical(materialId, _unset)
          ? this.materialId
          : materialId as String?,
      startedAt: startedAt ?? this.startedAt,
      endedAt: identical(endedAt, _unset) ? this.endedAt : endedAt as DateTime?,
      durationSeconds: durationSeconds ?? this.durationSeconds,
      mode: mode ?? this.mode,
      note: identical(note, _unset) ? this.note : note as String?,
      pauseIntervals: pauseIntervals ?? this.pauseIntervals,
      phaseStartedAt: identical(phaseStartedAt, _unset)
          ? this.phaseStartedAt
          : phaseStartedAt as DateTime?,
      targetDurationSeconds: identical(targetDurationSeconds, _unset)
          ? this.targetDurationSeconds
          : targetDurationSeconds as int?,
      pomodoroRound: identical(pomodoroRound, _unset)
          ? this.pomodoroRound
          : pomodoroRound as int?,
      pomodoroPhase: identical(pomodoroPhase, _unset)
          ? this.pomodoroPhase
          : pomodoroPhase as PomodoroPhase?,
      focusMinutes: focusMinutes ?? this.focusMinutes,
      shortBreakMinutes: shortBreakMinutes ?? this.shortBreakMinutes,
      longBreakMinutes: longBreakMinutes ?? this.longBreakMinutes,
      createdAt: identical(createdAt, _unset)
          ? this.createdAt
          : createdAt as DateTime?,
      updatedAt: identical(updatedAt, _unset)
          ? this.updatedAt
          : updatedAt as DateTime?,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is StudySession &&
        other.id == id &&
        other.userId == userId &&
        other.subjectId == subjectId &&
        other.materialId == materialId &&
        other.startedAt == startedAt &&
        other.endedAt == endedAt &&
        other.durationSeconds == durationSeconds &&
        other.mode == mode &&
        other.note == note &&
        listEquals(other.pauseIntervals, pauseIntervals) &&
        other.phaseStartedAt == phaseStartedAt &&
        other.targetDurationSeconds == targetDurationSeconds &&
        other.pomodoroRound == pomodoroRound &&
        other.pomodoroPhase == pomodoroPhase &&
        other.focusMinutes == focusMinutes &&
        other.shortBreakMinutes == shortBreakMinutes &&
        other.longBreakMinutes == longBreakMinutes &&
        other.createdAt == createdAt &&
        other.updatedAt == updatedAt;
  }

  @override
  int get hashCode => Object.hashAll([
        id,
        userId,
        subjectId,
        materialId,
        startedAt,
        endedAt,
        durationSeconds,
        mode,
        note,
        Object.hashAll(pauseIntervals),
        phaseStartedAt,
        targetDurationSeconds,
        pomodoroRound,
        pomodoroPhase,
        focusMinutes,
        shortBreakMinutes,
        longBreakMinutes,
        createdAt,
        updatedAt,
      ]);
}
