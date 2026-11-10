import 'package:job_prep/features/circulars/domain/entities/circular_exam_date.dart';

/// Contract for persisting and querying exam stages stored in
/// `public.circular_exam_dates`.
abstract interface class ExamDateRepository {
  /// Fetches all exam dates linked to [circularId], ordered earliest first.
  Future<List<CircularExamDate>> getExamDatesForCircular(String circularId);

  /// Inserts a new [examDate] row and returns the persisted record.
  Future<CircularExamDate> createExamDate(CircularExamDate examDate);

  /// Updates an existing [examDate] row and returns the updated record.
  Future<CircularExamDate> updateExamDate(CircularExamDate examDate);

  /// Deletes the exam date row identified by [id].
  Future<void> deleteExamDate(String id);
}
