import 'package:flutter/foundation.dart' show immutable;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:job_prep/features/prep/domain/entities/prep_material.dart';
import 'package:job_prep/features/prep/domain/entities/progress_log.dart';
import 'package:job_prep/features/prep/domain/errors/prep_failure.dart';
import 'package:job_prep/features/prep/presentation/providers/prep_providers.dart';

/// Injectable clock callback defaulting to `DateTime.now` for progress logs.
final Provider<DateTime Function()> prepNowProvider =
    Provider<DateTime Function()>((ref) => DateTime.now);

/// Immutable mutation status for logging, editing, or deleting study logs.
@immutable
class PrepProgressLogState {
  /// Creates a [PrepProgressLogState].
  const PrepProgressLogState({
    this.isSaving = false,
    this.activeMaterialId,
    this.activeLogId,
    this.error,
  });

  static const Object _unset = Object();

  /// Whether a log insert, update, or delete is currently in progress.
  final bool isSaving;

  /// Material ID currently mutating logs, if any.
  final String? activeMaterialId;

  /// Log entry ID currently updating or deleting, if any.
  final String? activeLogId;

  /// Last repository or validation error encountered.
  final Object? error;

  /// Returns a copy with specified fields replaced.
  PrepProgressLogState copyWith({
    bool? isSaving,
    Object? activeMaterialId = _unset,
    Object? activeLogId = _unset,
    Object? error = _unset,
  }) {
    return PrepProgressLogState(
      isSaving: isSaving ?? this.isSaving,
      activeMaterialId: identical(activeMaterialId, _unset)
          ? this.activeMaterialId
          : activeMaterialId as String?,
      activeLogId: identical(activeLogId, _unset)
          ? this.activeLogId
          : activeLogId as String?,
      error: identical(error, _unset) ? this.error : error,
    );
  }
}

/// Controller coordinating quick logs (`+10`, `+20`, `+50`), custom logs,
/// past log updates, deletions, and live provider refreshes.
class PrepProgressLogNotifier extends Notifier<PrepProgressLogState> {
  @override
  PrepProgressLogState build() => const PrepProgressLogState();

  /// Clears any previously surfaced log error.
  void clearError() {
    state = state.copyWith(error: null);
  }

  /// Logs [units] completed on [material] cleanly and refreshes derived
  /// material/subject/overall progress providers immediately.
  Future<bool> logUnits({
    required PrepMaterial material,
    required int units,
    DateTime? loggedOn,
    String? note,
  }) async {
    if (units <= 0) {
      state = state.copyWith(
        error: const PrepValidationFailure(
          code: 'invalid_log_units',
          message: 'Logged units must be greater than zero.',
        ),
      );
      return false;
    }

    state = state.copyWith(
      isSaving: true,
      activeMaterialId: material.id,
      activeLogId: null,
      error: null,
    );

    try {
      final repo = ref.read(progressLogRepositoryProvider);
      final effectiveDate = loggedOn ?? ref.read(prepNowProvider)();
      final trimmedNote = note?.trim();

      await repo.createLog(
        ProgressLog(
          materialId: material.id,
          unitsDone: units,
          loggedOn: _dateOnly(effectiveDate),
          note: (trimmedNote != null && trimmedNote.isNotEmpty)
              ? trimmedNote
              : null,
        ),
      );

      await _refreshAfterMutation(
        materialId: material.id,
        subjectId: material.subjectId,
      );
      state = state.copyWith(
        isSaving: false,
        activeMaterialId: null,
        activeLogId: null,
      );
      return true;
    } on Object catch (error) {
      state = state.copyWith(
        isSaving: false,
        activeMaterialId: null,
        activeLogId: null,
        error: error,
      );
      return false;
    }
  }

  /// Updates an existing past [existing] progress log entry.
  Future<bool> updateLog({
    required PrepMaterial material,
    required ProgressLog existing,
    required int unitsDone,
    required DateTime loggedOn,
    String? note,
  }) async {
    if (unitsDone <= 0) {
      state = state.copyWith(
        error: const PrepValidationFailure(
          code: 'invalid_log_units',
          message: 'Logged units must be greater than zero.',
        ),
      );
      return false;
    }

    state = state.copyWith(
      isSaving: true,
      activeMaterialId: material.id,
      activeLogId: existing.id,
      error: null,
    );

    try {
      final repo = ref.read(progressLogRepositoryProvider);
      final trimmedNote = note?.trim();

      await repo.updateLog(
        existing.copyWith(
          unitsDone: unitsDone,
          loggedOn: _dateOnly(loggedOn),
          note: (trimmedNote != null && trimmedNote.isNotEmpty)
              ? trimmedNote
              : null,
        ),
      );

      await _refreshAfterMutation(
        materialId: material.id,
        subjectId: material.subjectId,
      );
      state = state.copyWith(
        isSaving: false,
        activeMaterialId: null,
        activeLogId: null,
      );
      return true;
    } on Object catch (error) {
      state = state.copyWith(
        isSaving: false,
        activeMaterialId: null,
        activeLogId: null,
        error: error,
      );
      return false;
    }
  }

  /// Deletes a past [log] entry and updates material/subject percentages live.
  Future<bool> deleteLog({
    required PrepMaterial material,
    required ProgressLog log,
  }) async {
    state = state.copyWith(
      isSaving: true,
      activeMaterialId: material.id,
      activeLogId: log.id,
      error: null,
    );

    try {
      await ref.read(progressLogRepositoryProvider).deleteLog(log.id);
      await _refreshAfterMutation(
        materialId: material.id,
        subjectId: material.subjectId,
      );
      state = state.copyWith(
        isSaving: false,
        activeMaterialId: null,
        activeLogId: null,
      );
      return true;
    } on Object catch (error) {
      state = state.copyWith(
        isSaving: false,
        activeMaterialId: null,
        activeLogId: null,
        error: error,
      );
      return false;
    }
  }

  Future<void> _refreshAfterMutation({
    required String materialId,
    required String subjectId,
  }) async {
    ref
      ..invalidate(progressLogsForMaterialProvider(materialId))
      ..invalidate(recentProgressLogsProvider);
    await Future.wait(<Future<Object?>>[
      ref.refresh(materialsForSubjectProvider(subjectId).future),
      ref.refresh(allMaterialsProvider.future),
    ]);
  }

  static DateTime _dateOnly(DateTime source) {
    return DateTime.utc(source.year, source.month, source.day);
  }
}

/// Provides [PrepProgressLogNotifier] for study progress logging actions.
final NotifierProvider<PrepProgressLogNotifier, PrepProgressLogState>
    prepProgressLogControllerProvider =
    NotifierProvider<PrepProgressLogNotifier, PrepProgressLogState>(
  PrepProgressLogNotifier.new,
);
