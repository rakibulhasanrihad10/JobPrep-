import 'package:flutter_test/flutter_test.dart';
import 'package:job_prep/features/prep/domain/entities/prep_enums.dart';
import 'package:job_prep/features/prep/domain/entities/topic.dart';
import 'package:job_prep/features/prep/domain/utils/syllabus_progress_calculator.dart';

void main() {
  final fixedDate = DateTime.utc(2026, 11, 15, 10);

  Topic createWithStatus(TopicStatus status) {
    return Topic(
      id: 'topic-legacy-1',
      subjectId: 'sub-1',
      title: 'Legacy Topic',
      status: status,
      updatedAt: fixedDate,
    );
  }

  group('Topic Status Migration Pure Function', () {
    test('notStarted produces no checkpoint timestamps', () {
      final topic = createWithStatus(TopicStatus.notStarted);
      final migrated =
          SyllabusProgressCalculator.migrateTopicStatus(topic, now: fixedDate);

      expect(migrated.studyDoneAt, isNull);
      expect(migrated.practiceDoneAt, isNull);
      expect(migrated.modelTestDoneAt, isNull);
      expect(migrated.revisionDoneAt, isNull);
    });

    test('inProgress / learning sets studyDoneAt only', () {
      final topic = createWithStatus(TopicStatus.inProgress);
      final migrated =
          SyllabusProgressCalculator.migrateTopicStatus(topic, now: fixedDate);

      expect(migrated.studyDoneAt, fixedDate);
      expect(migrated.practiceDoneAt, isNull);
      expect(migrated.modelTestDoneAt, isNull);
      expect(migrated.revisionDoneAt, isNull);
    });

    test('needsRevision / revised sets studyDoneAt and revisionDoneAt', () {
      final topic = createWithStatus(TopicStatus.needsRevision);
      final migrated =
          SyllabusProgressCalculator.migrateTopicStatus(topic, now: fixedDate);

      expect(migrated.studyDoneAt, fixedDate);
      expect(migrated.practiceDoneAt, isNull);
      expect(migrated.modelTestDoneAt, isNull);
      expect(migrated.revisionDoneAt, fixedDate);
    });

    test('mastered / completed sets all four checkpoint timestamps', () {
      final topic = createWithStatus(TopicStatus.completed);
      final migrated =
          SyllabusProgressCalculator.migrateTopicStatus(topic, now: fixedDate);

      expect(migrated.studyDoneAt, fixedDate);
      expect(migrated.practiceDoneAt, fixedDate);
      expect(migrated.modelTestDoneAt, fixedDate);
      expect(migrated.revisionDoneAt, fixedDate);
    });

    test('preserves existing timestamps if already present', () {
      final earlier = DateTime.utc(2026, 11, 1, 8);
      final topic = Topic(
        id: 't-preserved',
        subjectId: 'sub-1',
        title: 'Preserved Topic',
        status: TopicStatus.completed,
        studyDoneAt: earlier,
      );

      final migrated =
          SyllabusProgressCalculator.migrateTopicStatus(topic, now: fixedDate);
      expect(migrated.studyDoneAt, earlier);
      expect(migrated.practiceDoneAt, fixedDate);
      expect(migrated.modelTestDoneAt, fixedDate);
      expect(migrated.revisionDoneAt, fixedDate);
    });
  });
}
