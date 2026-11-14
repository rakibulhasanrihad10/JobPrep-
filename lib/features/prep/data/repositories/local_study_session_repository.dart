import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:job_prep/core/local/database/app_database.dart';
import 'package:job_prep/features/prep/domain/entities/prep_enums.dart';
import 'package:job_prep/features/prep/domain/entities/study_session.dart';
import 'package:job_prep/features/prep/domain/errors/prep_failure.dart';
import 'package:job_prep/features/prep/domain/repositories/study_session_repository.dart';
import 'package:uuid/uuid.dart';

/// Local Drift SQLite implementation of [StudySessionRepository].
class LocalStudySessionRepository implements StudySessionRepository {
  /// Creates a [LocalStudySessionRepository].
  const LocalStudySessionRepository(this._db);

  final AppDatabase _db;

  @override
  Future<List<StudySession>> getStudySessions() async {
    final query = _db.select(_db.localStudySessions)
      ..orderBy([(t) => OrderingTerm.desc(t.startedAt)]);
    final rows = await query.get();
    return List.unmodifiable(rows.map(_mapRow));
  }

  @override
  Future<StudySession?> getActiveStudySession() async {
    final query = _db.select(_db.localStudySessions)
      ..where((t) => t.endedAt.isNull())
      ..orderBy([(t) => OrderingTerm.desc(t.startedAt)])
      ..limit(1);
    final row = await query.getSingleOrNull();
    if (row == null) return null;
    return _mapRow(row);
  }

  @override
  Future<StudySession> createStudySession(StudySession session) async {
    _validateForWrite(session);

    final id =
        session.id.trim().isEmpty ? const Uuid().v4() : session.id.trim();
    final now = DateTime.now().toUtc();
    final entry = _toCompanion(session, id: id, now: now);

    await _db.into(_db.localStudySessions).insertOnConflictUpdate(entry);
    return session.copyWith(
      id: id,
      createdAt: session.createdAt ?? now,
      updatedAt: now,
    );
  }

  @override
  Future<StudySession> updateStudySession(StudySession session) async {
    final trimmedId = session.id.trim();
    if (trimmedId.isEmpty) {
      throw const PrepValidationFailure(
        code: 'missing_study_session_id',
        message: 'Cannot update a study session without an id.',
      );
    }
    _validateForWrite(session);

    final existing = await (_db.select(_db.localStudySessions)
          ..where((t) => t.id.equals(trimmedId)))
        .getSingleOrNull();
    if (existing == null) {
      throw const PrepNotFoundFailure(
        code: 'study_session_not_found',
        message: 'Study session not found.',
      );
    }

    final now = DateTime.now().toUtc();
    final entry = _toCompanion(
      session,
      id: trimmedId,
      now: now,
      createdAt: existing.createdAt,
    );

    await _db.update(_db.localStudySessions).replace(entry);
    return session.copyWith(
      id: trimmedId,
      createdAt: existing.createdAt,
      updatedAt: now,
    );
  }

  @override
  Future<void> deleteStudySession(String id) async {
    final trimmedId = id.trim();
    if (trimmedId.isEmpty) {
      throw const PrepValidationFailure(
        code: 'missing_study_session_id',
        message: 'Cannot delete a study session without an id.',
      );
    }

    await (_db.delete(_db.localStudySessions)
          ..where((t) => t.id.equals(trimmedId)))
        .go();
  }

  void _validateForWrite(StudySession session) {
    if (session.subjectId.trim().isEmpty) {
      throw const PrepValidationFailure(
        code: 'missing_subject_id',
        message: 'A study session must belong to a subject.',
      );
    }
    if (session.durationSeconds < 0) {
      throw const PrepValidationFailure(
        code: 'invalid_duration',
        message: 'Session duration cannot be negative.',
      );
    }
  }

  LocalStudySessionsCompanion _toCompanion(
    StudySession s, {
    required String id,
    required DateTime now,
    DateTime? createdAt,
  }) {
    final intervalsJson = jsonEncode([
      for (final i in s.pauseIntervals)
        {
          'paused_at': i.pausedAt.toUtc().toIso8601String(),
          'resumed_at': i.resumedAt?.toUtc().toIso8601String(),
          if (i.isBreakOnly) 'is_break_only': true,
        },
    ]);

    return LocalStudySessionsCompanion(
      id: Value(id),
      subjectId: Value(s.subjectId.trim()),
      materialId: Value(s.materialId?.trim()),
      startedAt: Value(s.startedAt.toUtc()),
      endedAt: Value(s.endedAt?.toUtc()),
      durationSeconds: Value(s.durationSeconds < 0 ? 0 : s.durationSeconds),
      mode: Value(s.mode.value),
      note: Value(s.note?.trim()),
      pauseIntervals: Value(intervalsJson),
      phaseStartedAt: Value(s.phaseStartedAt?.toUtc()),
      targetDurationSeconds: Value(s.targetDurationSeconds),
      pomodoroRound: Value(s.pomodoroRound),
      pomodoroPhase: Value(s.pomodoroPhase?.value),
      focusMinutes: Value(s.focusMinutes),
      shortBreakMinutes: Value(s.shortBreakMinutes),
      longBreakMinutes: Value(s.longBreakMinutes),
      createdAt: Value(s.createdAt ?? createdAt ?? now),
      updatedAt: Value(now),
    );
  }

  StudySession _mapRow(LocalStudySession row) {
    List<PauseInterval> intervals;
    try {
      final decoded = jsonDecode(row.pauseIntervals) as List;
      intervals = [
        for (final item in decoded)
          if (item is Map)
            PauseInterval(
              pausedAt: DateTime.parse(item['paused_at'] as String),
              resumedAt: item['resumed_at'] != null
                  ? DateTime.parse(item['resumed_at'] as String)
                  : null,
              isBreakOnly: item['is_break_only'] == true,
            ),
      ];
    } on Object catch (_) {
      intervals = const [];
    }

    return StudySession(
      id: row.id,
      userId: '',
      subjectId: row.subjectId,
      materialId: row.materialId,
      startedAt: row.startedAt,
      endedAt: row.endedAt,
      durationSeconds: row.durationSeconds,
      mode: StudySessionMode.fromValue(row.mode),
      note: row.note,
      pauseIntervals: intervals,
      phaseStartedAt: row.phaseStartedAt,
      targetDurationSeconds: row.targetDurationSeconds,
      pomodoroRound: row.pomodoroRound,
      pomodoroPhase: PomodoroPhase.tryParse(row.pomodoroPhase),
      focusMinutes: row.focusMinutes,
      shortBreakMinutes: row.shortBreakMinutes,
      longBreakMinutes: row.longBreakMinutes,
      createdAt: row.createdAt,
      updatedAt: row.updatedAt,
    );
  }
}
