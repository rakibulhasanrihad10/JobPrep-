import 'dart:math' as math;

import 'package:job_prep/features/prep/domain/entities/study_plan.dart';
import 'package:job_prep/features/prep/domain/entities/topic.dart';
import 'package:job_prep/features/prep/domain/utils/study_plan_calculator.dart';
import 'package:job_prep/features/prep/domain/utils/syllabus_progress_calculator.dart';

/// Pure mathematical calculation helper for topic-based study plans.
abstract final class TopicPlanCalculator {
  /// Sums total weighted topic count across [topics].
  static double calculateTotalWeightedTopics(Iterable<Topic> topics) {
    var total = 0.0;
    for (final topic in topics) {
      final weight = math.max(0, topic.weight);
      total += weight;
    }
    return total;
  }

  /// Calculates remaining weighted topic units across [topics] taking into
  /// account completed checkpoints for [enabledCheckpoints].
  static double calculateRemainingWeightedTopics(
    Iterable<Topic> topics, {
    List<String> enabledCheckpoints = const [
      'study',
      'practice',
      'model_test',
      'revision',
    ],
  }) {
    var remaining = 0.0;
    for (final topic in topics) {
      final weight = math.max(0, topic.weight);
      if (weight == 0) continue;

      final progress = SyllabusProgressCalculator.calculateTopicProgress(
        topic: topic,
        enabledCheckpoints: enabledCheckpoints,
      );
      remaining += (1.0 - progress) * weight;
    }
    return remaining;
  }

  /// Calculates exact fractional and ceiling whole daily target for
  /// [remainingWeightedTopics] over [studyDaysLeft].
  ///
  /// Reuses [DailyTargetResult] guarantee: returns 0 when remaining is 0 or
  /// less, and gracefully avoids division by zero when studyDaysLeft <= 0.
  static DailyTargetResult calculateDailyTopicTarget({
    required double remainingWeightedTopics,
    required int studyDaysLeft,
  }) {
    if (remainingWeightedTopics <= 0) {
      return (exact: 0.0, rounded: 0);
    }
    if (studyDaysLeft <= 0) {
      return (
        exact: remainingWeightedTopics,
        rounded: remainingWeightedTopics.ceil(),
      );
    }
    final exact = remainingWeightedTopics / studyDaysLeft;
    return (exact: exact, rounded: exact.ceil());
  }

  /// Evaluates schedule status for a topic-based study plan.
  static StudyScheduleStatus determineTopicScheduleStatus({
    required double totalWeightedTopics,
    required double completedWeightedTopics,
    required double remainingWeightedTopics,
    required int studyDaysLeft,
    required int elapsedStudyDays,
    required double baselineDailyPace,
  }) {
    if (remainingWeightedTopics <= 0) {
      return studyDaysLeft > 0
          ? StudyScheduleStatus.ahead
          : StudyScheduleStatus.onTrack;
    }
    if (studyDaysLeft <= 0) {
      return StudyScheduleStatus.behind;
    }

    final idealBeforeToday = math.min(
      totalWeightedTopics,
      math.max(0, elapsedStudyDays) * baselineDailyPace,
    );
    final idealThroughToday = math.min(
      totalWeightedTopics,
      (math.max(0, elapsedStudyDays) + 1) * baselineDailyPace,
    );

    const epsilon = 1e-6;
    if (completedWeightedTopics < idealBeforeToday - epsilon) {
      return StudyScheduleStatus.behind;
    }
    if (completedWeightedTopics > idealThroughToday + epsilon) {
      return StudyScheduleStatus.ahead;
    }
    return StudyScheduleStatus.onTrack;
  }
}
