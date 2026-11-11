import 'package:flutter/foundation.dart' show immutable;
import 'package:job_prep/features/prep/domain/entities/prep_enums.dart';
import 'package:job_prep/features/prep/domain/entities/study_session.dart';
import 'package:job_prep/features/prep/domain/utils/study_timer_calculator.dart';

/// Notification payload describing a completed Pomodoro focus or break round.
@immutable
class StudyTimerRoundAlert {
  /// Creates a [StudyTimerRoundAlert].
  const StudyTimerRoundAlert({
    required this.round,
    required this.completedPhase,
    required this.suggestedNextPhase,
    required this.suggestedNextRound,
    required this.completedAt,
  });

  /// Round index that just completed.
  final int round;

  /// Phase that reached 0:00 (`focus`, `shortBreak`, or `longBreak`).
  final PomodoroPhase completedPhase;

  /// Recommended follow-up Pomodoro phase.
  final PomodoroPhase suggestedNextPhase;

  /// Round number associated with [suggestedNextPhase].
  final int suggestedNextRound;

  /// UTC timestamp at which the completed phase reached target.
  final DateTime completedAt;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is StudyTimerRoundAlert &&
        other.round == round &&
        other.completedPhase == completedPhase &&
        other.suggestedNextPhase == suggestedNextPhase &&
        other.suggestedNextRound == suggestedNextRound &&
        other.completedAt == completedAt;
  }

  @override
  int get hashCode => Object.hash(
        round,
        completedPhase,
        suggestedNextPhase,
        suggestedNextRound,
        completedAt,
      );
}

/// Live reactive state backing `StudyTimerController` and the floating bar.
@immutable
class StudyTimerState {
  /// Creates a [StudyTimerState].
  const StudyTimerState({
    this.isRestoring = true,
    this.isBusy = false,
    this.selectedMode = StudySessionMode.focus,
    this.selectedSubjectId,
    this.selectedMaterialId,
    this.activeSession,
    this.evaluation,
    this.roundAlert,
    this.error,
  });

  static const Object _unset = Object();

  /// True while querying persistence for an interrupted `ended_at IS NULL` row.
  final bool isRestoring;

  /// True while a database write is in flight.
  final bool isBusy;

  /// Selected timer mode when starting or running a session.
  final StudySessionMode selectedMode;

  /// Draft/active subject selection.
  final String? selectedSubjectId;

  /// Optional draft/active material selection.
  final String? selectedMaterialId;

  /// Active (`ended_at IS NULL`) persisted session restored across refreshes.
  final StudySession? activeSession;

  /// Timestamp-derived elapsed/remaining evaluation for [activeSession].
  final StudyTimerEvaluation? evaluation;

  /// Gentle in-app alert surfaced when the active Pomodoro round completes.
  final StudyTimerRoundAlert? roundAlert;

  /// Latest validation or repository error encountered.
  final Object? error;

  /// True when an open session exists (either running or paused).
  bool get hasActiveSession => activeSession != null;

  /// True when an open session is actively counting right now.
  bool get isRunning =>
      activeSession != null && !(evaluation?.isPaused ?? false);

  /// True when an open session is paused.
  bool get isPaused =>
      activeSession != null &&
      (evaluation?.isPaused ?? activeSession!.isPaused);

  /// Returns a copy with specified fields replaced.
  StudyTimerState copyWith({
    bool? isRestoring,
    bool? isBusy,
    StudySessionMode? selectedMode,
    Object? selectedSubjectId = _unset,
    Object? selectedMaterialId = _unset,
    Object? activeSession = _unset,
    Object? evaluation = _unset,
    Object? roundAlert = _unset,
    Object? error = _unset,
  }) {
    return StudyTimerState(
      isRestoring: isRestoring ?? this.isRestoring,
      isBusy: isBusy ?? this.isBusy,
      selectedMode: selectedMode ?? this.selectedMode,
      selectedSubjectId: identical(selectedSubjectId, _unset)
          ? this.selectedSubjectId
          : selectedSubjectId as String?,
      selectedMaterialId: identical(selectedMaterialId, _unset)
          ? this.selectedMaterialId
          : selectedMaterialId as String?,
      activeSession: identical(activeSession, _unset)
          ? this.activeSession
          : activeSession as StudySession?,
      evaluation: identical(evaluation, _unset)
          ? this.evaluation
          : evaluation as StudyTimerEvaluation?,
      roundAlert: identical(roundAlert, _unset)
          ? this.roundAlert
          : roundAlert as StudyTimerRoundAlert?,
      error: identical(error, _unset) ? this.error : error,
    );
  }
}
