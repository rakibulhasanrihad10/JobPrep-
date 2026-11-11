import 'package:job_prep/features/prep/data/mappers/prep_error_mapper.dart';
import 'package:job_prep/features/prep/data/mappers/study_session_mapper.dart';
import 'package:job_prep/features/prep/domain/entities/study_session.dart';
import 'package:job_prep/features/prep/domain/errors/prep_failure.dart';
import 'package:job_prep/features/prep/domain/repositories/study_session_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supabase;

/// Supabase PostgREST implementation of [StudySessionRepository] backed by
/// `public.study_sessions`.
class SupabaseStudySessionRepository implements StudySessionRepository {
  /// Creates a [SupabaseStudySessionRepository].
  const SupabaseStudySessionRepository(this._client);

  static const String _table = 'study_sessions';

  final supabase.SupabaseClient _client;

  @override
  Future<List<StudySession>> getStudySessions() async {
    try {
      final rows = await _client
          .from(_table)
          .select()
          .order('started_at', ascending: false);
      return StudySessionMapper.fromJsonList(rows);
    } on Object catch (error) {
      throw PrepErrorMapper.map(error);
    }
  }

  @override
  Future<StudySession?> getActiveStudySession() async {
    try {
      final rows = await _client
          .from(_table)
          .select()
          .isFilter('ended_at', null)
          .order('started_at', ascending: false)
          .limit(1);
      final list = StudySessionMapper.fromJsonList(rows);
      return list.isEmpty ? null : list.first;
    } on Object catch (error) {
      throw PrepErrorMapper.map(error);
    }
  }

  @override
  Future<StudySession> createStudySession(StudySession session) async {
    _validateForWrite(session);

    try {
      final currentUserId = _client.auth.currentUser?.id;
      final payload = StudySessionMapper.toInsertJson(
        session,
        userId: session.userId.trim().isEmpty ? currentUserId : null,
      );
      final row = await _client.from(_table).insert(payload).select().single();
      return StudySessionMapper.fromJson(row);
    } on Object catch (error) {
      throw PrepErrorMapper.map(error);
    }
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

    try {
      final row = await _client
          .from(_table)
          .update(StudySessionMapper.toUpdateJson(session))
          .eq('id', trimmedId)
          .select()
          .single();
      return StudySessionMapper.fromJson(row);
    } on Object catch (error) {
      throw PrepErrorMapper.map(error);
    }
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

    try {
      await _client.from(_table).delete().eq('id', trimmedId);
    } on Object catch (error) {
      throw PrepErrorMapper.map(error);
    }
  }

  void _validateForWrite(StudySession session) {
    if (session.subjectId.trim().isEmpty) {
      throw const PrepValidationFailure(
        code: 'missing_subject_id',
        message: 'Study session requires a subject id.',
      );
    }
    if (session.durationSeconds < 0) {
      throw const PrepValidationFailure(
        code: 'invalid_duration_seconds',
        message: 'Study session duration cannot be negative.',
      );
    }
    if (session.endedAt != null &&
        session.endedAt!.isBefore(session.startedAt)) {
      throw const PrepValidationFailure(
        code: 'invalid_session_bounds',
        message: 'Study session end time cannot precede start time.',
      );
    }
  }
}
