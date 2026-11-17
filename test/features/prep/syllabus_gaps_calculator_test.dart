import 'package:flutter_test/flutter_test.dart';
import 'package:job_prep/features/prep/domain/entities/topic.dart';
import 'package:job_prep/features/prep/domain/utils/syllabus_gaps_calculator.dart';

void main() {
  group('SyllabusGapsCalculator', () {
    final now = DateTime.utc(2026, 11, 10);

    test('flags missing practice when topic studied without practice', () {
      final topic = Topic(
        id: 't1',
        subjectId: 's1',
        title: 'Grammar',
        studyDoneAt: now,
        modelTestDoneAt: now,
      );

      final gaps = SyllabusGapsCalculator.findGaps([topic]);
      expect(gaps.length, 1);
      expect(gaps.first.topic.id, 't1');
      expect(gaps.first.isMissingPractice, isTrue);
      expect(gaps.first.isMissingModelTest, isFalse);
    });

    test(
      'flags missing model test when topic studied and practiced without test',
      () {
        final topic = Topic(
          id: 't2',
          subjectId: 's1',
          title: 'Vocabulary',
          studyDoneAt: now,
          practiceDoneAt: now,
        );

        final gaps = SyllabusGapsCalculator.findGaps([topic]);
        expect(gaps.length, 1);
        expect(gaps.first.isMissingPractice, isFalse);
        expect(gaps.first.isMissingModelTest, isTrue);
      },
    );

    test('flags both practice and model test when both missing', () {
      final topic = Topic(
        id: 't3',
        subjectId: 's1',
        title: 'Poetry',
        studyDoneAt: now,
      );

      final gaps = SyllabusGapsCalculator.findGaps([topic]);
      expect(gaps.length, 1);
      expect(gaps.first.isMissingPractice, isTrue);
      expect(gaps.first.isMissingModelTest, isTrue);
    });

    test('excludes topics that have not been studied yet', () {
      const topic = Topic(
        id: 't4',
        subjectId: 's1',
        title: 'Drama',
      );

      final gaps = SyllabusGapsCalculator.findGaps(const [topic]);
      expect(gaps, isEmpty);
    });

    test('excludes topics where all checkpoints are completed', () {
      final topic = Topic(
        id: 't5',
        subjectId: 's1',
        title: 'Essay',
        studyDoneAt: now,
        practiceDoneAt: now,
        modelTestDoneAt: now,
        revisionDoneAt: now,
      );

      final gaps = SyllabusGapsCalculator.findGaps([topic]);
      expect(gaps, isEmpty);
    });

    test('respects enabledCheckpoints when practice is disabled', () {
      final topic = Topic(
        id: 't6',
        subjectId: 's1',
        title: 'Novel',
        studyDoneAt: now,
        modelTestDoneAt: now,
      );

      // Only study and model_test enabled for this subject
      final gaps = SyllabusGapsCalculator.findGaps(
        [topic],
        enabledCheckpoints: const ['study', 'model_test'],
      );
      expect(gaps, isEmpty);
    });

    test('returns empty when neither practice nor model_test enabled', () {
      final topic = Topic(
        id: 't7',
        subjectId: 's1',
        title: 'History',
        studyDoneAt: now,
      );

      final gaps = SyllabusGapsCalculator.findGaps(
        [topic],
        enabledCheckpoints: const ['study', 'revision'],
      );
      expect(gaps, isEmpty);
    });
  });
}
