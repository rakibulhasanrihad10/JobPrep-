import 'package:job_prep/features/prep/domain/entities/prep_enums.dart';
import 'package:job_prep/features/prep/domain/entities/topic.dart';

/// Item representing a topic that was studied but lacks practice or model test
/// checkpoints.
class SyllabusTopicGap {
  /// Creates a [SyllabusTopicGap].
  const SyllabusTopicGap({
    required this.topic,
    required this.isMissingPractice,
    required this.isMissingModelTest,
  });

  /// The underlying syllabus topic.
  final Topic topic;

  /// Whether practice checkpoint is enabled and not yet completed.
  final bool isMissingPractice;

  /// Whether model test checkpoint is enabled and not yet completed.
  final bool isMissingModelTest;
}

/// Pure calculation helper finding topics that have completed study but
/// are missing practice or model testing.
abstract final class SyllabusGapsCalculator {
  /// Analyzes [topics] against [enabledCheckpoints] and extracts all gaps.
  static List<SyllabusTopicGap> findGaps(
    List<Topic> topics, {
    List<String>? enabledCheckpoints,
  }) {
    final checkpoints = enabledCheckpoints ??
        const ['study', 'practice', 'model_test', 'revision'];

    final practiceEnabled =
        checkpoints.contains(SyllabusCheckpoint.practice.value);
    final modelTestEnabled =
        checkpoints.contains(SyllabusCheckpoint.modelTest.value);

    if (!practiceEnabled && !modelTestEnabled) {
      return const <SyllabusTopicGap>[];
    }

    final gaps = <SyllabusTopicGap>[];

    for (final topic in topics) {
      if (topic.studyDoneAt == null) continue;

      final missingPractice = practiceEnabled && topic.practiceDoneAt == null;
      final missingModelTest =
          modelTestEnabled && topic.modelTestDoneAt == null;

      if (missingPractice || missingModelTest) {
        gaps.add(
          SyllabusTopicGap(
            topic: topic,
            isMissingPractice: missingPractice,
            isMissingModelTest: missingModelTest,
          ),
        );
      }
    }

    return List<SyllabusTopicGap>.unmodifiable(gaps);
  }
}
