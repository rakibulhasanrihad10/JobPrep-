import 'package:job_prep/features/circulars/domain/entities/circular_exam_date.dart';
import 'package:job_prep/features/circulars/domain/errors/circular_failure.dart';
import 'package:job_prep/features/circulars/domain/repositories/exam_date_repository.dart';

/// Safe fallback [ExamDateRepository] used when Supabase environment keys have
/// not been configured.
class UnconfiguredExamDateRepository implements ExamDateRepository {
  /// Creates an [UnconfiguredExamDateRepository].
  const UnconfiguredExamDateRepository();

  static const _notConfiguredError = UnknownCircularFailure(
    code: 'supabase_not_configured',
    message: 'Supabase is not configured. Provide SUPABASE_URL and '
        'SUPABASE_ANON_KEY via --dart-define.',
  );

  @override
  Future<List<CircularExamDate>> getExamDatesForCircular(
    String circularId,
  ) async =>
      const [];

  @override
  Future<CircularExamDate> createExamDate(CircularExamDate examDate) =>
      Future.error(_notConfiguredError);

  @override
  Future<CircularExamDate> updateExamDate(CircularExamDate examDate) =>
      Future.error(_notConfiguredError);

  @override
  Future<void> deleteExamDate(String id) => Future.error(_notConfiguredError);
}
