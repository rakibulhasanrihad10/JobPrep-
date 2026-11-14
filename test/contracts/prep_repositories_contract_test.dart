import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:job_prep/core/local/database/app_database.dart';
import 'package:job_prep/features/prep/data/repositories/local_material_repository.dart';
import 'package:job_prep/features/prep/data/repositories/local_progress_log_repository.dart';
import 'package:job_prep/features/prep/data/repositories/local_subject_repository.dart';
import 'package:job_prep/features/prep/data/repositories/local_topic_repository.dart';
import 'package:job_prep/features/prep/domain/entities/prep_enums.dart';
import 'package:job_prep/features/prep/domain/entities/prep_material.dart';
import 'package:job_prep/features/prep/domain/entities/progress_log.dart';
import 'package:job_prep/features/prep/domain/entities/subject.dart';
import 'package:job_prep/features/prep/domain/entities/topic.dart';
import 'package:job_prep/features/prep/domain/repositories/material_repository.dart';
import 'package:job_prep/features/prep/domain/repositories/progress_log_repository.dart';
import 'package:job_prep/features/prep/domain/repositories/subject_repository.dart';
import 'package:job_prep/features/prep/domain/repositories/topic_repository.dart';
import 'package:job_prep/features/prep/domain/utils/prep_progress.dart';

void testPrepRepositoriesContract({
  required Future<
              ({
                SubjectRepository subjects,
                MaterialRepository materials,
                ProgressLogRepository logs,
                TopicRepository topics,
              })>
          Function()
      createRepositories,
  Future<void> Function()? tearDownRepositories,
}) {
  group('Prep Repositories Contract Tests', () {
    late SubjectRepository subjectsRepo;
    late MaterialRepository materialsRepo;
    late ProgressLogRepository logsRepo;
    late TopicRepository topicsRepo;

    setUp(() async {
      final repos = await createRepositories();
      subjectsRepo = repos.subjects;
      materialsRepo = repos.materials;
      logsRepo = repos.logs;
      topicsRepo = repos.topics;
    });

    tearDown(() async {
      if (tearDownRepositories != null) {
        await tearDownRepositories();
      }
    });

    test(
        'Subject, Materials, and Progress recalculation invariant: '
        '300, 300, 400 pages', () async {
      // 1. Create a subject.
      final subject = await subjectsRepo.createSubject(
        const Subject(name: 'Bangla Literature'),
      );
      expect(subject.id, isNotEmpty);

      // 2. Create three books of 300, 300 and 400 pages.
      final book1 = await materialsRepo.createMaterial(
        PrepMaterial(
          subjectId: subject.id,
          title: 'Book One',
          totalUnits: 300,
        ),
      );
      final book2 = await materialsRepo.createMaterial(
        PrepMaterial(
          subjectId: subject.id,
          title: 'Book Two',
          totalUnits: 300,
        ),
      );
      final book3 = await materialsRepo.createMaterial(
        PrepMaterial(
          subjectId: subject.id,
          title: 'Book Three',
          totalUnits: 400,
        ),
      );

      expect(book1.completedUnits, equals(0));
      expect(book2.completedUnits, equals(0));
      expect(book3.completedUnits, equals(0));

      // 3. Finishing book one: log 300 pages.
      await logsRepo.createLog(
        ProgressLog(
          materialId: book1.id,
          unitsDone: 300,
          loggedOn: DateTime.utc(2026, 11, 14),
        ),
      );

      // 4. Fetch updated materials.
      final updatedBook1 = await materialsRepo.getMaterialById(book1.id);
      final updatedBook2 = await materialsRepo.getMaterialById(book2.id);
      final updatedBook3 = await materialsRepo.getMaterialById(book3.id);

      expect(updatedBook1!.completedUnits, equals(300));
      expect(calculateMaterialProgress(updatedBook1), equals(1.0)); // 100%

      // 5. Subject progress: exactly 30% for the subject.
      final subjectProgress = calculateSubjectProgress([
        updatedBook1,
        updatedBook2!,
        updatedBook3!,
      ]);
      expect(subjectProgress, closeTo(0.30, 0.0001));

      // 6. Log 150 pages to book 2 (50% for book 2, 45% for subject).
      await logsRepo.createLog(
        ProgressLog(
          materialId: book2.id,
          unitsDone: 150,
          loggedOn: DateTime.utc(2026, 11, 15),
        ),
      );

      final book2After150 = await materialsRepo.getMaterialById(book2.id);
      expect(book2After150!.completedUnits, equals(150));
      expect(calculateMaterialProgress(book2After150), equals(0.50));

      final subjectProgress2 = calculateSubjectProgress([
        updatedBook1,
        book2After150,
        updatedBook3,
      ]);
      expect(subjectProgress2, closeTo(0.45, 0.0001));

      // 7. Over-logging is clamped to totalUnits (never exceeds totalUnits).
      await logsRepo.createLog(
        ProgressLog(
          materialId: book3.id,
          unitsDone: 500, // exceeds 400
          loggedOn: DateTime.utc(2026, 11, 16),
        ),
      );
      final book3Capped = await materialsRepo.getMaterialById(book3.id);
      expect(book3Capped!.completedUnits, equals(400)); // clamped to 400

      // 8. Correction log subtracts units cleanly.
      await logsRepo.createLog(
        ProgressLog(
          materialId: book2.id,
          unitsDone: -50,
          entryType: ProgressLogEntryType.correction,
          loggedOn: DateTime.utc(2026, 11, 17),
        ),
      );
      final book2Corrected = await materialsRepo.getMaterialById(book2.id);
      expect(book2Corrected!.completedUnits, equals(100));
    });

    test('Topic CRUD contract', () async {
      final subject = await subjectsRepo.createSubject(
        const Subject(name: 'General Science'),
      );

      final topic = await topicsRepo.createTopic(
        Topic(subjectId: subject.id, name: 'Physics basics'),
      );
      expect(topic.id, isNotEmpty);

      final topics = await topicsRepo.getTopicsForSubject(subject.id);
      expect(topics, hasLength(1));
      expect(topics.first.name, equals('Physics basics'));

      final updated = await topicsRepo.updateTopic(
        topic.copyWith(name: 'Modern Physics'),
      );
      expect(updated.name, equals('Modern Physics'));

      await topicsRepo.deleteTopic(topic.id);
      expect(await topicsRepo.getTopicsForSubject(subject.id), isEmpty);
    });
  });
}

void main() {
  late AppDatabase db;

  testPrepRepositoriesContract(
    createRepositories: () async {
      db = AppDatabase(NativeDatabase.memory());
      return (
        subjects: LocalSubjectRepository(db),
        materials: LocalMaterialRepository(db),
        logs: LocalProgressLogRepository(db),
        topics: LocalTopicRepository(db),
      );
    },
    tearDownRepositories: () async {
      await db.close();
    },
  );
}
