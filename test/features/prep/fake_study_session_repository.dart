import 'package:job_prep/features/prep/domain/entities/study_session.dart';
import 'package:job_prep/features/prep/domain/errors/prep_failure.dart';
import 'package:job_prep/features/prep/domain/repositories/study_session_repository.dart';

/// Deterministic in-memory [StudySessionRepository] for unit, widget, and
/// golden tests without Supabase calls.
class FakeStudySessionRepository implements StudySessionRepository {
  /// Creates a [FakeStudySessionRepository].
  FakeStudySessionRepository({
    List<StudySession> initialSessions = const <StudySession>[],
    DateTime Function()? clock,
    this.userId = 'u-1',
    this.throwOnLoad,
    this.throwOnWrite,
  })  : _sessions = List<StudySession>.of(initialSessions),
        _clock = clock ?? DateTime.now;

  final List<StudySession> _sessions;
  final DateTime Function() _clock;
  final String userId;
  int _counter = 0;

  /// Optional failure thrown from read queries.
  PrepFailure? throwOnLoad;

  /// Optional failure thrown from create, update, or delete mutations.
  PrepFailure? throwOnWrite;

  /// Read-only snapshot of stored sessions ordered newest first.
  List<StudySession> get sessions {
    final sorted = List<StudySession>.of(_sessions)
      ..sort((a, b) => b.startedAt.compareTo(a.startedAt));
    return List<StudySession>.unmodifiable(sorted);
  }

  /// Recorded created rows for assertions.
  final List<StudySession> createdSessions = <StudySession>[];

  /// Recorded updated rows for assertions.
  final List<StudySession> updatedSessions = <StudySession>[];

  /// Recorded deleted IDs for assertions.
  final List<String> deletedIds = <String>[];

  @override
  Future<List<StudySession>> getStudySessions() async {
    if (throwOnLoad != null) throw throwOnLoad!;
    return sessions;
  }

  @override
  Future<StudySession?> getActiveStudySession() async {
    if (throwOnLoad != null) throw throwOnLoad!;
    final open = _sessions.where((s) => s.endedAt == null).toList()
      ..sort((a, b) => b.startedAt.compareTo(a.startedAt));
    return open.isEmpty ? null : open.first;
  }

  @override
  Future<StudySession> createStudySession(StudySession session) async {
    if (throwOnWrite != null) throw throwOnWrite!;
    if (session.durationSeconds < 0) {
      throw const PrepValidationFailure(
        code: 'invalid_duration_seconds',
        message: 'Duration cannot be negative.',
      );
    }
    final now = _clock().toUtc();
    final created = session.copyWith(
      id: session.id.trim().isEmpty ? 'sess-${++_counter}' : session.id,
      userId: session.userId.trim().isEmpty ? userId : session.userId,
      createdAt: session.createdAt ?? now,
      updatedAt: now,
    );
    _sessions.add(created);
    createdSessions.add(created);
    return created;
  }

  @override
  Future<StudySession> updateStudySession(StudySession session) async {
    if (throwOnWrite != null) throw throwOnWrite!;
    final idx = _sessions.indexWhere((s) => s.id == session.id);
    if (idx < 0) {
      throw const PrepValidationFailure(
        code: 'not_found',
        message: 'Session not found.',
      );
    }
    final saved = session.copyWith(updatedAt: _clock().toUtc());
    _sessions[idx] = saved;
    updatedSessions.add(saved);
    return saved;
  }

  @override
  Future<void> deleteStudySession(String id) async {
    if (throwOnWrite != null) throw throwOnWrite!;
    _sessions.removeWhere((s) => s.id == id);
    deletedIds.add(id);
  }
}
