import 'package:flutter_test/flutter_test.dart';
import 'package:job_prep/features/prep/domain/entities/prep_enums.dart';
import 'package:job_prep/features/prep/domain/entities/prep_material.dart';
import 'package:job_prep/features/prep/domain/entities/progress_log.dart';
import 'package:job_prep/features/prep/domain/entities/subject.dart';
import 'package:job_prep/features/prep/domain/entities/topic.dart';
import 'package:job_prep/features/prep/domain/utils/prep_progress.dart';

void main() {
  group('Prep Progress Calculations', () {
    test(
        'passes three books (300, 300, 400 pages) example: finishing book one '
        'is 100% book & 30% subject, plus 150 pages of book two gives 45%', () {
      const subject = Subject(id: 'sub-bcs', name: 'Bangladesh Affairs');
      var book1 = const PrepMaterial(
        id: 'book-1',
        subjectId: 'sub-bcs',
        title: 'Book One',
        totalUnits: 300,
      );
      var book2 = const PrepMaterial(
        id: 'book-2',
        subjectId: 'sub-bcs',
        title: 'Book Two',
        totalUnits: 300,
      );
      const book3 = PrepMaterial(
        id: 'book-3',
        subjectId: 'sub-bcs',
        title: 'Book Three',
        totalUnits: 400,
      );

      // Initially 0% across books, subject, and overall.
      expect(calculateMaterialProgress(book1), 0.0);
      expect(calculateSubjectProgress([book1, book2, book3]), 0.0);
      expect(
        calculateOverallProgress(
          subjects: const [subject],
          materials: [book1, book2, book3],
        ),
        0.0,
      );

      // Finish Book One (300/300) -> 100% for Book One and 30% for Subject.
      book1 = book1.copyWith(completedUnits: 300);
      expect(calculateMaterialProgress(book1), closeTo(1.0, 1e-9));
      expect(
        calculateSubjectProgress([book1, book2, book3]),
        closeTo(0.30, 1e-9),
      );
      expect(
        calculateOverallProgress(
          subjects: const [subject],
          materials: [book1, book2, book3],
        ),
        closeTo(0.30, 1e-9),
      );

      // Finish 150 pages of Book Two (150/300) -> 50% Book Two, 45% Subject.
      book2 = book2.copyWith(completedUnits: 150);
      expect(calculateMaterialProgress(book2), closeTo(0.50, 1e-9));
      expect(
        calculateSubjectProgress([book1, book2, book3]),
        closeTo(0.45, 1e-9),
      );
      expect(
        calculateOverallProgress(
          subjects: const [subject],
          materials: [book1, book2, book3],
        ),
        closeTo(0.45, 1e-9),
      );
    });

    test('guards against division by zero on empty subject and zero-unit items',
        () {
      const emptySubject = Subject(id: 'sub-empty', name: 'Empty Subject');
      const zeroMaterial = PrepMaterial(
        id: 'mat-zero',
        subjectId: 'sub-empty',
        title: 'Zero Planned Units',
      );

      expect(calculateMaterialProgress(zeroMaterial), 0.0);
      expect(calculateSubjectProgress(const []), 0.0);
      expect(calculateSubjectProgress(const [zeroMaterial]), 0.0);
      expect(
        calculateOverallProgress(
          subjects: const [],
          materials: const [],
        ),
        0.0,
      );
      expect(
        calculateOverallProgress(
          subjects: const [emptySubject],
          materials: const [],
        ),
        0.0,
      );

      // Multi-subject overall average includes empty subjects safely as 0.
      const doneSubject = Subject(id: 'sub-done', name: 'Done');
      const doneBook = PrepMaterial(
        id: 'mat-done',
        subjectId: 'sub-done',
        title: 'Finished Book',
        totalUnits: 100,
        completedUnits: 100,
      );
      expect(
        calculateOverallProgress(
          subjects: const [doneSubject, emptySubject],
          materials: const [doneBook],
        ),
        closeTo(0.50, 1e-9),
      );
    });

    test('clamps over-logged and negative materials strictly within [0, 1]',
        () {
      const overLogged = PrepMaterial(
        id: 'mat-over',
        subjectId: 'sub-1',
        title: 'Over-logged Book',
        totalUnits: 300,
        completedUnits: 450,
      );
      const negativeLogged = PrepMaterial(
        id: 'mat-neg',
        subjectId: 'sub-1',
        title: 'Negative Book',
        totalUnits: 300,
        completedUnits: -40,
      );
      const siblingUnstarted = PrepMaterial(
        id: 'mat-sibling',
        subjectId: 'sub-1',
        title: 'Unstarted Sibling',
        totalUnits: 300,
      );

      expect(calculateMaterialProgress(overLogged), 1.0);
      expect(calculateMaterialProgress(negativeLogged), 0.0);
      expect(calculateSubjectProgress(const [overLogged]), 1.0);
      expect(calculateSubjectProgress(const [negativeLogged]), 0.0);

      // Over-logged Book 1 capped at its 300 planned units when combined with
      // unstarted 300-page sibling -> 300/600 = 0.50.
      expect(
        calculateSubjectProgress(const [overLogged, siblingUnstarted]),
        closeTo(0.50, 1e-9),
      );

      expect(
        calculateUnitRatioProgress(completedUnits: 10, totalUnits: 0),
        0.0,
      );
      expect(
        calculateUnitRatioProgress(
          completedUnits: double.infinity,
          totalUnits: 100,
        ),
        0.0,
      );
    });
  });

  group('Prep Domain Entities & Enums', () {
    test('supports immutable value equality, copyWith null clearing, and enums',
        () {
      expect(MaterialKind.fromValue('video_course'), MaterialKind.videoCourse);
      expect(MaterialKind.fromValue('unknown'), MaterialKind.book);
      expect(MaterialKind.tryParse('bad'), isNull);

      expect(
        TopicStatus.fromValue('needs_revision'),
        TopicStatus.needsRevision,
      );
      expect(TopicStatus.fromValue('bad'), TopicStatus.notStarted);
      expect(TopicStatus.tryParse(''), isNull);

      final subject = Subject(
        id: 'sub-1',
        userId: 'u-1',
        name: 'Math',
        createdAt: DateTime.utc(2026, 11),
      );
      expect(subject.copyWith(name: 'Mental Ability').name, 'Mental Ability');
      expect(subject.copyWith(createdAt: null).createdAt, isNull);
      expect(subject, equals(subject.copyWith()));

      const material = PrepMaterial(
        id: 'mat-1',
        subjectId: 'sub-1',
        title: 'Digest',
        coverImagePath: 'u/mat/cover.png',
        coverImageUrl: 'https://example.test/cover.png',
      );
      final clearedMaterial = material.copyWith(
        coverImagePath: null,
        coverImageUrl: null,
      );
      expect(clearedMaterial.coverImagePath, isNull);
      expect(clearedMaterial.coverImageUrl, isNull);

      final log = ProgressLog(
        id: 'log-1',
        materialId: 'mat-1',
        unitsDone: 25,
        loggedOn: DateTime(2026, 11, 10),
        note: 'Chapter 1',
      );
      expect(log.copyWith(note: null).note, isNull);
      expect(log, equals(log.copyWith()));

      const topic = Topic(
        id: 'top-1',
        subjectId: 'sub-1',
        name: 'Constitution',
      );
      expect(
        topic.copyWith(status: TopicStatus.completed).status,
        TopicStatus.completed,
      );
      expect(topic, equals(topic.copyWith()));
    });
  });
}
