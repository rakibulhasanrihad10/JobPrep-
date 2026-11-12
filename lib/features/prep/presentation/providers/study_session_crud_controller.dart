import 'package:flutter/foundation.dart' show immutable;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:job_prep/features/prep/domain/entities/prep_enums.dart';
import 'package:job_prep/features/prep/domain/entities/study_session.dart';
import 'package:job_prep/features/prep/domain/errors/prep_failure.dart';
import 'package:job_prep/features/prep/presentation/providers/study_session_providers.dart';

/// Immutable mutation status for manual session logs, edits, and deletions.
@immutable
class StudySessionCrudState {
  /// Creates a [StudySessionCrudState].
  const StudySessionCrudState({
    this.isSaving = false,
    this.activeSessionId,
    this.error,
  });

  static const Object _unset = Object();

  /// Whether a write operation is running.
  final bool isSaving;

  /// ID of session currently being updated or deleted, if any.
  final String? activeSessionId;

  /// Latest validation or persistence error.
  final Object? error;

  /// Returns a copy with updated fields.
  StudySessionCrudState copyWith({
    bool? isSaving,
    Object? activeSessionId = _unset,
    Object? error = _unset,
  }) {
    return StudySessionCrudState(
      isSaving: isSaving ?? this.isSaving,
      activeSessionId: identical(activeSessionId, _unset)
          ? this.activeSessionId
          : activeSessionId as String?,
      error: identical(error, _unset) ? this.error : error,
    );
  }
}

/// Coordinates manual session entry, completed session editing, and deletion.
class StudySessionCrudController extends Notifier<StudySessionCrudState> {
  @override
  StudySessionCrudState build() => const StudySessionCrudState();

  /// Clears any surfaced mutation error.
  void clearError() {
    state = state.copyWith(error: null);
  }

  /// Creates a manual study session recorded outside the live timer.
  Future<StudySession?> createManualSession({
    required String subjectId,
    required DateTime startedAt,
    required int durationSeconds,
    String? materialId,
    String? note,
  }) async {
    final cleanSubject = subjectId.trim();
    if (cleanSubject.isEmpty) {
      state = state.copyWith(
        error: const PrepValidationFailure(
          code: 'missing_subject_id',
          message: 'Select a subject for this study session.',
        ),
      );
      return null;
    }
    if (durationSeconds <= 0) {
      state = state.copyWith(
        error: const PrepValidationFailure(
          code: 'invalid_duration',
          message: 'Duration must be greater than zero.',
        ),
      );
      return null;
    }

    final startUtc = startedAt.toUtc();
    final endUtc = startUtc.add(Duration(seconds: durationSeconds));
    final cleanMat =
        materialId?.trim().isEmpty ?? true ? null : materialId!.trim();
    final cleanNote = note?.trim().isEmpty ?? true ? null : note!.trim();

    state = state.copyWith(isSaving: true, activeSessionId: null, error: null);
    try {
      final created =
          await ref.read(studySessionRepositoryProvider).createStudySession(
                StudySession(
                  id: '',
                  userId: '',
                  subjectId: cleanSubject,
                  materialId: cleanMat,
                  startedAt: startUtc,
                  endedAt: endUtc,
                  durationSeconds: durationSeconds,
                  mode: StudySessionMode.manual,
                  note: cleanNote,
                ),
              );
      ref.read(studySessionsProvider.notifier).upsertLocal(created);
      state = const StudySessionCrudState();
      return created;
    } on Object catch (error) {
      state = state.copyWith(isSaving: false, error: error);
      return null;
    }
  }

  /// Updates an existing completed session cleanly.
  Future<StudySession?> updateCompletedSession({
    required StudySession existing,
    required String subjectId,
    required DateTime startedAt,
    required int durationSeconds,
    String? materialId,
    String? note,
  }) async {
    final cleanSubject = subjectId.trim();
    if (cleanSubject.isEmpty || durationSeconds < 0) {
      state = state.copyWith(
        error: const PrepValidationFailure(
          code: 'invalid_session_update',
          message: 'Valid subject and non-negative duration are required.',
        ),
      );
      return null;
    }

    final startUtc = startedAt.toUtc();
    final endUtc = startUtc.add(Duration(seconds: durationSeconds));
    final cleanMat =
        materialId?.trim().isEmpty ?? true ? null : materialId!.trim();
    final cleanNote = note?.trim().isEmpty ?? true ? null : note!.trim();

    final updated = existing.copyWith(
      subjectId: cleanSubject,
      materialId: cleanMat,
      startedAt: startUtc,
      endedAt: endUtc,
      durationSeconds: durationSeconds,
      note: cleanNote,
      pauseIntervals: existing.mode == StudySessionMode.manual
          ? const <PauseInterval>[]
          : existing.pauseIntervals,
    );

    state = state.copyWith(
      isSaving: true,
      activeSessionId: existing.id,
      error: null,
    );
    try {
      final saved = await ref
          .read(studySessionRepositoryProvider)
          .updateStudySession(updated);
      ref.read(studySessionsProvider.notifier).upsertLocal(saved);
      state = const StudySessionCrudState();
      return saved;
    } on Object catch (error) {
      state = state.copyWith(
        isSaving: false,
        activeSessionId: null,
        error: error,
      );
      return null;
    }
  }

  /// Permanently deletes a completed or saved study session.
  Future<bool> deleteSession(String id) async {
    final cleanId = id.trim();
    if (cleanId.isEmpty) return false;

    state = state.copyWith(
      isSaving: true,
      activeSessionId: cleanId,
      error: null,
    );
    try {
      await ref
          .read(studySessionRepositoryProvider)
          .deleteStudySession(cleanId);
      ref.read(studySessionsProvider.notifier).removeLocal(cleanId);
      state = const StudySessionCrudState();
      return true;
    } on Object catch (error) {
      state = state.copyWith(
        isSaving: false,
        activeSessionId: null,
        error: error,
      );
      return false;
    }
  }
}

/// Provides manual entry, edit, and delete operations for [StudySession].
final NotifierProvider<StudySessionCrudController, StudySessionCrudState>
    studySessionCrudControllerProvider =
    NotifierProvider<StudySessionCrudController, StudySessionCrudState>(
  StudySessionCrudController.new,
);
