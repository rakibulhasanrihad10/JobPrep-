import 'package:job_prep/features/prep/domain/entities/prep_enums.dart';
import 'package:job_prep/features/prep/domain/entities/topic.dart';

/// Representation of completed topic counts for a specific calendar week.
class WeeklyTopicBucket {
  /// Creates a [WeeklyTopicBucket].
  const WeeklyTopicBucket({
    required this.weekStart,
    required this.weekEnd,
    required this.completedCount,
  });

  /// Inclusive start date of the week (UTC midnight).
  final DateTime weekStart;

  /// Inclusive end date of the week (UTC midnight).
  final DateTime weekEnd;

  /// Number of syllabus topics completed within this week.
  final int completedCount;
}

/// Pure helper aggregating completed topics per calendar week from checkpoint
/// timestamps.
abstract final class WeeklyTopicCountsCalculator {
  /// Evaluates whether a topic is completed according to [enabledCheckpoints]
  /// and returns its completion timestamp (the latest timestamp among the
  /// required checkpoints), or `null` if any required checkpoint is incomplete.
  static DateTime? getCompletionDate(
    Topic topic, {
    List<String>? enabledCheckpoints,
  }) {
    final checkpoints = enabledCheckpoints ??
        const ['study', 'practice', 'model_test', 'revision'];

    if (checkpoints.isEmpty) return null;

    final dates = <DateTime>[];

    for (final rawKey in checkpoints) {
      final cp = SyllabusCheckpoint.tryParse(rawKey);
      if (cp == null) continue;

      final date = switch (cp) {
        SyllabusCheckpoint.study => topic.studyDoneAt,
        SyllabusCheckpoint.practice => topic.practiceDoneAt,
        SyllabusCheckpoint.modelTest => topic.modelTestDoneAt,
        SyllabusCheckpoint.revision => topic.revisionDoneAt,
      };

      if (date == null) {
        return null; // A required checkpoint is missing
      }
      dates.add(date);
    }

    if (dates.isEmpty) return null;
    return dates.reduce((a, b) => a.isAfter(b) ? a : b);
  }

  /// Buckets syllabus topics completed across [weekCount] consecutive weeks
  /// ending on [now].
  static List<WeeklyTopicBucket> calculateWeeklyBuckets({
    required List<Topic> topics,
    int weekCount = 8,
    DateTime? now,
    List<String>? enabledCheckpoints,
  }) {
    final reference = now ?? DateTime.now().toUtc();
    final today = DateTime.utc(reference.year, reference.month, reference.day);

    final completedDates = <DateTime>[];
    for (final topic in topics) {
      final date = getCompletionDate(
        topic,
        enabledCheckpoints: enabledCheckpoints,
      );
      if (date != null) {
        completedDates.add(DateTime.utc(date.year, date.month, date.day));
      }
    }

    final buckets = <WeeklyTopicBucket>[];

    for (var i = weekCount - 1; i >= 0; i--) {
      final weekEnd = today.subtract(Duration(days: i * 7));
      final weekStart = weekEnd.subtract(const Duration(days: 6));

      var count = 0;
      for (final date in completedDates) {
        if (!date.isBefore(weekStart) && !date.isAfter(weekEnd)) {
          count++;
        }
      }

      buckets.add(
        WeeklyTopicBucket(
          weekStart: weekStart,
          weekEnd: weekEnd,
          completedCount: count,
        ),
      );
    }

    return List<WeeklyTopicBucket>.unmodifiable(buckets);
  }
}
