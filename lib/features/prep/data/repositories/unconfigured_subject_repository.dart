import 'package:job_prep/features/prep/domain/entities/subject.dart';
import 'package:job_prep/features/prep/domain/errors/prep_failure.dart';
import 'package:job_prep/features/prep/domain/repositories/subject_repository.dart';

/// Safe fallback [SubjectRepository] used when Supabase is not configured
/// (e.g. smoke widget tests without backend `--dart-define` credentials).
class UnconfiguredSubjectRepository implements SubjectRepository {
  /// Creates an [UnconfiguredSubjectRepository].
  const UnconfiguredSubjectRepository();

  static const _failure = UnknownPrepFailure(
    code: 'supabase_not_configured',
    message: 'Supabase environment variables are not configured.',
  );

  @override
  Future<List<Subject>> getSubjects() async => const [];

  @override
  Future<Subject?> getSubjectById(String id) async => null;

  @override
  Future<Subject> createSubject(Subject subject) => Future.error(_failure);

  @override
  Future<Subject> updateSubject(Subject subject) => Future.error(_failure);

  @override
  Future<void> deleteSubject(String id) => Future.error(_failure);

  @override
  Future<List<String>> getSubjectIdsForCircular(String circularId) async =>
      const [];

  @override
  Future<void> linkSubjectToCircular({
    required String circularId,
    required String subjectId,
  }) =>
      Future.error(_failure);

  @override
  Future<void> unlinkSubjectFromCircular({
    required String circularId,
    required String subjectId,
  }) =>
      Future.error(_failure);
}
