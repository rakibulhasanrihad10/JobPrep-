import 'package:job_prep/features/circulars/domain/entities/circular_exam_date.dart';

/// Splits [examDates] into chronologically ordered upcoming exams (`examDate`
/// on or after [now]'s calendar day) and past exams (most recent first).
({List<CircularExamDate> upcoming, List<CircularExamDate> past})
    partitionExamDates(
  List<CircularExamDate> examDates, {
  required DateTime now,
}) {
  final today = DateTime.utc(now.year, now.month, now.day);
  final upcoming = <CircularExamDate>[];
  final past = <CircularExamDate>[];

  for (final item in examDates) {
    final aligned = now.isUtc ? item.examDate.toUtc() : item.examDate.toLocal();
    final examDay = DateTime.utc(aligned.year, aligned.month, aligned.day);
    if (examDay.isBefore(today)) {
      past.add(item);
    } else {
      upcoming.add(item);
    }
  }

  upcoming.sort((a, b) {
    final diff = a.examDate.compareTo(b.examDate);
    if (diff != 0) return diff;
    return a.stage.compareTo(b.stage);
  });

  past.sort((a, b) {
    final diff = b.examDate.compareTo(a.examDate);
    if (diff != 0) return diff;
    return a.stage.compareTo(b.stage);
  });

  return (
    upcoming: List.unmodifiable(upcoming),
    past: List.unmodifiable(past),
  );
}
