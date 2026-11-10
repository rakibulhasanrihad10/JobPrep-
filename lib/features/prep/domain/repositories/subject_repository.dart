import 'package:job_prep/features/prep/domain/entities/subject.dart';

/// Contract for reading and mutating user-owned subjects (`public.subjects`)
/// and optional links to job circulars (`public.circular_subjects`).
abstract interface class SubjectRepository {
  /// Fetches all subjects for the current user sorted by `sortOrder` ascending.
  Future<List<Subject>> getSubjects();

  /// Fetches a single [Subject] by [id], or `null` if absent.
  Future<Subject?> getSubjectById(String id);

  /// Inserts a new [subject] and returns the persisted record.
  Future<Subject> createSubject(Subject subject);

  /// Updates an existing [subject] and returns the persisted record.
  Future<Subject> updateSubject(Subject subject);

  /// Permanently deletes the subject identified by [id].
  Future<void> deleteSubject(String id);

  /// Fetches subject IDs linked to [circularId] via `public.circular_subjects`.
  Future<List<String>> getSubjectIdsForCircular(String circularId);

  /// Links [subjectId] to [circularId] inside `public.circular_subjects`.
  Future<void> linkSubjectToCircular({
    required String circularId,
    required String subjectId,
  });

  /// Removes the `public.circular_subjects` link between [circularId] and
  /// [subjectId].
  Future<void> unlinkSubjectFromCircular({
    required String circularId,
    required String subjectId,
  });
}
