import 'package:job_prep/features/prep/domain/entities/study_session.dart';

/// Persistence contract for timestamp-driven study sessions and manual entries.
abstract interface class StudySessionRepository {
  /// Returns all study sessions owned by the current user ordered newest first.
  Future<List<StudySession>> getStudySessions();

  /// Returns the newest open (`ended_at IS NULL`) study session if one exists.
  Future<StudySession?> getActiveStudySession();

  /// Creates and returns a new [StudySession] row.
  Future<StudySession> createStudySession(StudySession session);

  /// Updates pause intervals, Pomodoro transitions, completion, or edits.
  Future<StudySession> updateStudySession(StudySession session);

  /// Deletes the study session identified by [id].
  Future<void> deleteStudySession(String id);
}
