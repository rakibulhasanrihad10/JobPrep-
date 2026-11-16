import 'package:flutter_test/flutter_test.dart';
import 'package:job_prep/features/prep/domain/entities/topic.dart';
import 'package:job_prep/features/prep/domain/utils/syllabus_progress_calculator.dart';

void main() {
  final now = DateTime.utc(2026, 11, 15, 12);

  Topic createTopic({
    String id = 'topic-1',
    String title = 'Algebra',
    int weight = 1,
    DateTime? studyDoneAt,
    DateTime? practiceDoneAt,
    DateTime? modelTestDoneAt,
    DateTime? revisionDoneAt,
  }) {
    return Topic(
      id: id,
      subjectId: 'sub-1',
      title: title,
      weight: weight,
      studyDoneAt: studyDoneAt,
      practiceDoneAt: practiceDoneAt,
      modelTestDoneAt: modelTestDoneAt,
      revisionDoneAt: revisionDoneAt,
    );
  }

  group('SyllabusProgressCalculator - calculateTopicProgress', () {
    test('returns 0.0 when no checkpoints enabled', () {
      final topic = createTopic(studyDoneAt: now);
      final progress = SyllabusProgressCalculator.calculateTopicProgress(
        topic: topic,
        enabledCheckpoints: const [],
      );
      expect(progress, 0.0);
    });

    test(
        'calculates correct weighted fraction with all four checkpoints '
        'enabled (40, 30, 20, 10)', () {
      const allFour = ['study', 'practice', 'model_test', 'revision'];

      final noneDone = createTopic();
      expect(
        SyllabusProgressCalculator.calculateTopicProgress(
          topic: noneDone,
          enabledCheckpoints: allFour,
        ),
        0.0,
      );

      final studyOnly = createTopic(studyDoneAt: now);
      expect(
        SyllabusProgressCalculator.calculateTopicProgress(
          topic: studyOnly,
          enabledCheckpoints: allFour,
        ),
        0.4,
      );

      final studyAndPractice = createTopic(
        studyDoneAt: now,
        practiceDoneAt: now,
      );
      expect(
        SyllabusProgressCalculator.calculateTopicProgress(
          topic: studyAndPractice,
          enabledCheckpoints: allFour,
        ),
        0.7,
      );

      final studyPracticeModelTest = createTopic(
        studyDoneAt: now,
        practiceDoneAt: now,
        modelTestDoneAt: now,
      );
      expect(
        SyllabusProgressCalculator.calculateTopicProgress(
          topic: studyPracticeModelTest,
          enabledCheckpoints: allFour,
        ),
        0.9,
      );

      final allDone = createTopic(
        studyDoneAt: now,
        practiceDoneAt: now,
        modelTestDoneAt: now,
        revisionDoneAt: now,
      );
      expect(
        SyllabusProgressCalculator.calculateTopicProgress(
          topic: allDone,
          enabledCheckpoints: allFour,
        ),
        1.0,
      );
    });

    test('recalculates solely over enabled checkpoints', () {
      // Only study (40) and practice (30) enabled -> total possible weight = 70
      const studyAndPractice = ['study', 'practice'];

      final studyOnly = createTopic(
        studyDoneAt: now,
        revisionDoneAt: now, // revision is disabled, must not contribute
      );
      final progress = SyllabusProgressCalculator.calculateTopicProgress(
        topic: studyOnly,
        enabledCheckpoints: studyAndPractice,
      );
      expect(progress, closeTo(40 / 70, 0.0001));

      final bothDone = createTopic(
        studyDoneAt: now,
        practiceDoneAt: now,
      );
      final fullProgress = SyllabusProgressCalculator.calculateTopicProgress(
        topic: bothDone,
        enabledCheckpoints: studyAndPractice,
      );
      expect(fullProgress, 1.0);
    });

    test('ignores unrecognized checkpoint keys gracefully', () {
      final topic = createTopic(studyDoneAt: now);
      final progress = SyllabusProgressCalculator.calculateTopicProgress(
        topic: topic,
        enabledCheckpoints: const ['invalid_key', 'unknown'],
      );
      expect(progress, 0.0);
    });
  });

  group(
      'SyllabusProgressCalculator - calculateChapterProgress & SubjectProgress',
      () {
    const allCheckpoints = ['study', 'practice', 'model_test', 'revision'];

    test('returns 0.0 for empty topic list', () {
      expect(
        SyllabusProgressCalculator.calculateChapterProgress(
          topics: const [],
          enabledCheckpoints: allCheckpoints,
        ),
        0.0,
      );
    });

    test('averages topics equally when weights are default 1', () {
      final t1 = createTopic(
        id: '1',
        studyDoneAt: now,
        practiceDoneAt: now,
        modelTestDoneAt: now,
        revisionDoneAt: now, // 100%
      );
      final t2 = createTopic(id: '2'); // 0%

      final progress = SyllabusProgressCalculator.calculateChapterProgress(
        topics: [t1, t2],
        enabledCheckpoints: allCheckpoints,
      );
      expect(progress, 0.5);
    });

    test('respects topic weights correctly', () {
      // t1: 100% complete, weight 3
      // t2: 0% complete, weight 1
      // Expected = (3*1.0 + 1*0.0) / (3+1) = 3/4 = 0.75
      final t1 = createTopic(
        id: '1',
        weight: 3,
        studyDoneAt: now,
        practiceDoneAt: now,
        modelTestDoneAt: now,
        revisionDoneAt: now,
      );
      final t2 = createTopic(id: '2');

      final progress = SyllabusProgressCalculator.calculateChapterProgress(
        topics: [t1, t2],
        enabledCheckpoints: allCheckpoints,
      );
      expect(progress, 0.75);
    });

    test('guards against zero weights and negative weights', () {
      final t1 = createTopic(
        id: '1',
        weight: 0,
        studyDoneAt: now,
        practiceDoneAt: now,
        modelTestDoneAt: now,
        revisionDoneAt: now,
      );
      final t2 = createTopic(id: '2', weight: -2);

      final progress = SyllabusProgressCalculator.calculateChapterProgress(
        topics: [t1, t2],
        enabledCheckpoints: allCheckpoints,
      );
      expect(progress, 0.0);
    });

    test(
        'calculateSubjectSyllabusProgress matches chapter aggregation behavior',
        () {
      final t1 = createTopic(
        id: '1',
        studyDoneAt: now,
        practiceDoneAt: now, // 70%
      );
      final t2 = createTopic(
        id: '2',
        studyDoneAt: now, // 40%
      );

      final progress =
          SyllabusProgressCalculator.calculateSubjectSyllabusProgress(
        topics: [t1, t2],
        enabledCheckpoints: allCheckpoints,
      );
      expect(progress, closeTo((0.7 + 0.4) / 2, 0.0001));
    });
  });
}
