import 'package:job_prep/features/prep/domain/entities/study_session.dart';
import 'package:job_prep/features/prep/domain/errors/prep_failure.dart';
import 'package:job_prep/features/prep/domain/repositories/study_session_repository.dart';

/// Fallback [StudySessionRepository] returned before Supabase initializes.
class UnconfiguredStudySessionRepository implements StudySessionRepository {
  /// Creates an [UnconfiguredStudySessionRepository].
  const UnconfiguredStudySessionRepository();

  static const _failure = UnknownPrepFailure(
    code: 'prep_unconfigured',
    message: 'Study timer storage is not configured.',
  );

  @override
  Future<List<StudySession>> getStudySessions() async => const <StudySession>[];

  @override
  Future<StudySession?> getActiveStudySession() async => null;

  @override
  Future<StudySession> createStudySession(StudySession session) =>
      Future<StudySession>.error(_failure);

  @override
  Future<StudySession> updateStudySession(StudySession session) =>
      Future<StudySession>.error(_failure);

  @override
  Future<void> deleteStudySession(String id) => Future<void>.error(_failure);
}
