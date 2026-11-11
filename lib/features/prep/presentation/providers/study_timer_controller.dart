import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:job_prep/features/auth/presentation/providers/auth_providers.dart';
import 'package:job_prep/features/prep/domain/entities/prep_enums.dart';
import 'package:job_prep/features/prep/domain/entities/study_session.dart';
import 'package:job_prep/features/prep/domain/errors/prep_failure.dart';
import 'package:job_prep/features/prep/domain/repositories/study_session_repository.dart';
import 'package:job_prep/features/prep/domain/utils/study_session_transitions.dart';
import 'package:job_prep/features/prep/domain/utils/study_timer_calculator.dart';
import 'package:job_prep/features/prep/presentation/providers/study_session_providers.dart';
import 'package:job_prep/features/prep/presentation/providers/study_timer_effects.dart';
import 'package:job_prep/features/prep/presentation/providers/study_timer_state.dart';
import 'package:job_prep/features/prep/presentation/utils/timer_platform_adapter.dart';

export 'package:job_prep/features/prep/presentation/providers/study_timer_effects.dart'
    show StudyTimerTabTitleBuilder;

/// Controls the active timestamp-driven Study Timer, Pomodoro state machine,
/// browser tab title sync, pause/resume persistence, and soft sound alerts.
class StudyTimerController extends Notifier<StudyTimerState> {
  Timer? _ticker;
  bool _disposed = false;
  String? _lastAlertKey;
  StudyTimerTabTitleBuilder? _localizedTitleBuilder;
  StudyTimerPlatformAdapter? _platform;

  @override
  StudyTimerState build() {
    _disposed = false;
    ref.watch(currentUserProvider.select((user) => user?.id));
    final repo = ref.watch(studySessionRepositoryProvider);
    final platform = ref.watch(studyTimerPlatformProvider);
    _platform = platform;
    ref.onDispose(() {
      _disposed = true;
      _ticker?.cancel();
      _ticker = null;
      platform.restoreTabTitle();
    });

    unawaited(_restoreActiveSession(repo));
    return const StudyTimerState();
  }

  /// Registers a locale-aware tab title formatter from the mounted UI shell.
  void setTabTitleBuilder(StudyTimerTabTitleBuilder? builder) {
    _localizedTitleBuilder = builder;
    _syncTabTitle(state.activeSession, state.evaluation);
  }

  /// Updates draft timer mode (`focus` or `stopwatch`) while idle.
  void selectMode(StudySessionMode mode) {
    if (state.hasActiveSession || mode == StudySessionMode.manual) return;
    state = state.copyWith(selectedMode: mode, error: null);
  }

  /// Selects draft subject cleanly while idle, clearing mismatched material.
  void selectSubject(String? subjectId) {
    if (state.hasActiveSession) return;
    final clean = subjectId?.trim();
    state = state.copyWith(
      selectedSubjectId: (clean == null || clean.isEmpty) ? null : clean,
      selectedMaterialId: null,
      error: null,
    );
  }

  /// Selects optional draft material cleanly while idle.
  void selectMaterial(String? materialId) {
    if (state.hasActiveSession) return;
    final clean = materialId?.trim();
    state = state.copyWith(
      selectedMaterialId: (clean == null || clean.isEmpty) ? null : clean,
      error: null,
    );
  }

  /// Clears surfaced errors cleanly.
  void clearError() => state = state.copyWith(error: null);

  /// Dismisses the active round-complete banner cleanly.
  void dismissRoundAlert() => state = state.copyWith(roundAlert: null);

  /// Re-evaluates timestamps immediately (also called by 1s UI refresh tick).
  void refreshTick() {
    final session = state.activeSession;
    if (session == null || _disposed) return;

    final now = ref.read(studyTimerNowProvider)().toUtc();
    final eval = StudyTimerCalculator.evaluateSession(session, now: now);
    final alert = _maybeBuildRoundAlert(session, eval);
    state = state.copyWith(
      evaluation: eval,
      roundAlert: alert ?? state.roundAlert,
    );
    _syncTabTitle(session, eval);

    if (alert != null) {
      _playSoundIfEnabled();
      if (eval.isRoundComplete) {
        _ticker?.cancel();
        _ticker = null;
      }
    }
  }

  Future<void> _restoreActiveSession(StudySessionRepository repo) async {
    try {
      final restored = await repo.getActiveStudySession();
      if (_disposed || state.hasActiveSession || state.isBusy) return;
      if (restored == null) {
        state = state.copyWith(
          isRestoring: false,
          activeSession: null,
          evaluation: null,
          roundAlert: null,
        );
        _syncTabTitle(null, null);
        return;
      }
      _applySession(restored, isRestoring: false);
    } on Object catch (error) {
      if (_disposed) return;
      state = state.copyWith(isRestoring: false, error: error);
    }
  }

  /// Persists a new open (`ended_at = null`) session anchored to now.
  Future<bool> startSession({
    required String subjectId,
    String? materialId,
    StudySessionMode? mode,
  }) async {
    final cleanSubject = subjectId.trim();
    if (cleanSubject.isEmpty) {
      state = state.copyWith(
        error: const PrepValidationFailure(
          code: 'missing_subject_id',
          message: 'Please select a subject before starting the timer.',
        ),
      );
      return false;
    }

    final draft = StudySessionTransitions.buildStartedSession(
      subjectId: cleanSubject,
      materialId: materialId,
      mode: mode ?? state.selectedMode,
      startedAt: ref.read(studyTimerNowProvider)(),
      config: ref.read(pomodoroConfigProvider),
    );

    state = state.copyWith(isBusy: true, error: null, roundAlert: null);
    _lastAlertKey = null;
    try {
      final saved =
          await ref.read(studySessionRepositoryProvider).createStudySession(
                draft,
              );
      if (_disposed) return false;
      ref.read(studySessionsProvider.notifier).upsertLocal(saved);
      _applySession(saved, isRestoring: false);
      return true;
    } on Object catch (error) {
      if (_disposed) return false;
      state = state.copyWith(isBusy: false, error: error);
      return false;
    }
  }

  /// Records a pause interval at `now` and persists to storage.
  Future<bool> pause() {
    final session = state.activeSession;
    if (session == null || state.isBusy) return Future<bool>.value(false);
    final paused = StudySessionTransitions.buildPausedSession(
      session,
      pausedAt: ref.read(studyTimerNowProvider)(),
    );
    if (identical(paused, session)) return Future<bool>.value(true);
    return _persistActiveUpdate(paused);
  }

  /// Closes the open pause interval at `now` and resumes counting.
  Future<bool> resume() {
    final session = state.activeSession;
    if (session == null || state.isBusy) return Future<bool>.value(false);
    final resumed = StudySessionTransitions.buildResumedSession(
      session,
      resumedAt: ref.read(studyTimerNowProvider)(),
    );
    if (identical(resumed, session)) return Future<bool>.value(true);
    return _persistActiveUpdate(resumed);
  }

  /// Advances Focus -> Short/Long Break or Break -> Next Focus round cleanly.
  Future<bool> advancePomodoroPhase() {
    final session = state.activeSession;
    if (session == null ||
        session.mode != StudySessionMode.focus ||
        state.isBusy) {
      return Future<bool>.value(false);
    }

    final updated = StudySessionTransitions.buildNextPomodoroPhase(
      session,
      now: ref.read(studyTimerNowProvider)(),
    );
    _lastAlertKey = null;
    return _persistActiveUpdate(updated, clearAlert: true);
  }

  /// Finalizes and persists the completed session cleanly, returning the saved
  /// record (`null` on failure).
  Future<StudySession?> finishActiveSession({String? note}) async {
    final session = state.activeSession;
    if (session == null || state.isBusy) return null;

    final completed = StudySessionTransitions.buildCompletedSession(
      session,
      finishedAt: ref.read(studyTimerNowProvider)(),
      note: note,
    );

    state = state.copyWith(isBusy: true, error: null);
    try {
      final saved =
          await ref.read(studySessionRepositoryProvider).updateStudySession(
                completed,
              );
      if (_disposed) return null;
      _clearActiveTimerState();
      ref.read(studySessionsProvider.notifier).upsertLocal(saved);
      return saved;
    } on Object catch (error) {
      if (_disposed) return null;
      state = state.copyWith(isBusy: false, error: error);
      return null;
    }
  }

  /// Discards an unintended open session cleanly without recording study time.
  Future<bool> discardActiveSession() async {
    final session = state.activeSession;
    if (session == null || state.isBusy) return false;
    state = state.copyWith(isBusy: true, error: null);
    try {
      await ref
          .read(studySessionRepositoryProvider)
          .deleteStudySession(session.id);
      if (_disposed) return false;
      ref.read(studySessionsProvider.notifier).removeLocal(session.id);
      _clearActiveTimerState();
      return true;
    } on Object catch (error) {
      if (_disposed) return false;
      state = state.copyWith(isBusy: false, error: error);
      return false;
    }
  }

  void _clearActiveTimerState() {
    _ticker?.cancel();
    _ticker = null;
    _lastAlertKey = null;
    state = state.copyWith(
      isBusy: false,
      activeSession: null,
      evaluation: null,
      roundAlert: null,
    );
    _syncTabTitle(null, null);
  }

  Future<bool> _persistActiveUpdate(
    StudySession updated, {
    bool clearAlert = false,
  }) async {
    state = state.copyWith(isBusy: true, error: null);
    try {
      final saved =
          await ref.read(studySessionRepositoryProvider).updateStudySession(
                updated,
              );
      if (_disposed) return false;
      ref.read(studySessionsProvider.notifier).upsertLocal(saved);
      _applySession(saved, isRestoring: false, clearAlert: clearAlert);
      return true;
    } on Object catch (error) {
      if (_disposed) return false;
      state = state.copyWith(isBusy: false, error: error);
      return false;
    }
  }

  void _applySession(
    StudySession session, {
    required bool isRestoring,
    bool clearAlert = false,
  }) {
    final now = ref.read(studyTimerNowProvider)().toUtc();
    final eval = StudyTimerCalculator.evaluateSession(session, now: now);
    final alert = clearAlert ? null : _maybeBuildRoundAlert(session, eval);

    state = state.copyWith(
      isRestoring: isRestoring,
      isBusy: false,
      selectedMode: session.mode == StudySessionMode.manual
          ? StudySessionMode.focus
          : session.mode,
      selectedSubjectId: session.subjectId,
      selectedMaterialId: session.materialId,
      activeSession: session,
      evaluation: eval,
      roundAlert: clearAlert ? null : (alert ?? state.roundAlert),
    );
    _syncTabTitle(session, eval);

    _ticker?.cancel();
    if (!eval.isPaused && !eval.isRoundComplete) {
      _ticker = Timer.periodic(
        const Duration(seconds: 1),
        (_) => refreshTick(),
      );
    } else {
      _ticker = null;
    }
    if (alert != null) {
      _playSoundIfEnabled();
    }
  }

  StudyTimerRoundAlert? _maybeBuildRoundAlert(
    StudySession session,
    StudyTimerEvaluation eval,
  ) {
    final result = StudyTimerEffects.maybeBuildRoundAlert(
      session: session,
      evaluation: eval,
      lastAlertKey: _lastAlertKey,
      fallbackNow: ref.read(studyTimerNowProvider)(),
    );
    if (result == null) return null;
    _lastAlertKey = result.key;
    return result.alert;
  }

  void _playSoundIfEnabled() => StudyTimerEffects.playChimeIfEnabled(
        platform: _platform,
        soundEnabled: ref.read(timerSoundEnabledProvider),
      );

  void _syncTabTitle(StudySession? session, StudyTimerEvaluation? eval) =>
      StudyTimerEffects.syncTabTitle(
        platform: _platform,
        session: session,
        evaluation: eval,
        customBuilder: _localizedTitleBuilder,
      );
}

/// Provides live [StudyTimerState] driven purely by persisted timestamps.
final NotifierProvider<StudyTimerController, StudyTimerState>
    studyTimerControllerProvider =
    NotifierProvider<StudyTimerController, StudyTimerState>(
  StudyTimerController.new,
);
