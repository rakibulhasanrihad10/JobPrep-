import 'package:job_prep/features/prep/domain/entities/prep_enums.dart';
import 'package:job_prep/features/prep/domain/entities/topic.dart';

/// Pure calculation functions for syllabus progress across topics, chapters,
/// and subjects, with zero-weight, empty-list, and disabled-checkpoint guards.
abstract final class SyllabusProgressCalculator {
  /// Default checkpoint weights (sum = 100).
  static const int studyWeight = 40;
  static const int practiceWeight = 30;
  static const int modelTestWeight = 20;
  static const int revisionWeight = 10;

  /// Calculates the completion fraction `[0.0 .. 1.0]` for a single [topic]
  /// evaluated solely against the [enabledCheckpoints] configured for its
  /// parent subject.
  static double calculateTopicProgress({
    required Topic topic,
    required List<String> enabledCheckpoints,
  }) {
    if (enabledCheckpoints.isEmpty) return 0;

    var totalPossibleWeight = 0;
    var completedWeight = 0;

    for (final rawKey in enabledCheckpoints) {
      final checkpoint = SyllabusCheckpoint.tryParse(rawKey);
      if (checkpoint == null) continue;

      totalPossibleWeight += checkpoint.weight;
      final isDone = switch (checkpoint) {
        SyllabusCheckpoint.study => topic.studyDoneAt != null,
        SyllabusCheckpoint.practice => topic.practiceDoneAt != null,
        SyllabusCheckpoint.modelTest => topic.modelTestDoneAt != null,
        SyllabusCheckpoint.revision => topic.revisionDoneAt != null,
      };

      if (isDone) {
        completedWeight += checkpoint.weight;
      }
    }

    if (totalPossibleWeight == 0) return 0;

    final ratio = completedWeight / totalPossibleWeight;
    return ratio.clamp(0, 1);
  }

  /// Calculates the weighted average progress `[0.0 .. 1.0]` of a chapter's
  /// [topics], weighted by each topic's `weight`.
  static double calculateChapterProgress({
    required List<Topic> topics,
    required List<String> enabledCheckpoints,
  }) {
    if (topics.isEmpty) return 0;

    var totalWeight = 0;
    var accumulatedProgress = 0.0;

    for (final topic in topics) {
      final weight = topic.weight < 0 ? 0 : topic.weight;
      if (weight == 0) continue;

      final progress = calculateTopicProgress(
        topic: topic,
        enabledCheckpoints: enabledCheckpoints,
      );
      accumulatedProgress += progress * weight;
      totalWeight += weight;
    }

    if (totalWeight == 0) return 0;

    final ratio = accumulatedProgress / totalWeight;
    return ratio.clamp(0, 1);
  }

  /// Calculates the total syllabus progress `[0.0 .. 1.0]` for a subject
  /// across all its [topics], weighted by topic weights.
  static double calculateSubjectSyllabusProgress({
    required List<Topic> topics,
    required List<String> enabledCheckpoints,
  }) {
    return calculateChapterProgress(
      topics: topics,
      enabledCheckpoints: enabledCheckpoints,
    );
  }

  /// Migrates a legacy [topic] with `status` into concrete checkpoint
  /// timestamps.
  ///
  /// - `learning` / `in_progress` -> study done
  /// - `revised` / `needs_revision` -> study and revision done
  /// - `mastered` / `completed` -> all four done
  /// - `not_started` -> none
  static Topic migrateTopicStatus(Topic topic, {DateTime? now}) {
    final timestamp = now ?? topic.updatedAt ?? DateTime.now().toUtc();
    final statusVal = topic.status.value.toLowerCase().trim();

    if (statusVal == 'learning' || statusVal == 'in_progress') {
      return topic.copyWith(
        studyDoneAt: topic.studyDoneAt ?? timestamp,
      );
    } else if (statusVal == 'revised' || statusVal == 'needs_revision') {
      return topic.copyWith(
        studyDoneAt: topic.studyDoneAt ?? timestamp,
        revisionDoneAt: topic.revisionDoneAt ?? timestamp,
      );
    } else if (statusVal == 'mastered' || statusVal == 'completed') {
      return topic.copyWith(
        studyDoneAt: topic.studyDoneAt ?? timestamp,
        practiceDoneAt: topic.practiceDoneAt ?? timestamp,
        modelTestDoneAt: topic.modelTestDoneAt ?? timestamp,
        revisionDoneAt: topic.revisionDoneAt ?? timestamp,
      );
    }

    return topic;
  }
}
