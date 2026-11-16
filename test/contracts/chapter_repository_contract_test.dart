import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:job_prep/core/local/database/app_database.dart';
import 'package:job_prep/features/prep/data/repositories/local_chapter_repository.dart';
import 'package:job_prep/features/prep/data/repositories/supabase_chapter_repository.dart';
import 'package:job_prep/features/prep/domain/entities/chapter.dart';
import 'package:job_prep/features/prep/domain/errors/prep_failure.dart';
import 'package:job_prep/features/prep/domain/repositories/chapter_repository.dart';

import 'mock_supabase_http_client.dart';

void testChapterRepositoryContract({
  required Future<ChapterRepository> Function() createRepository,
  Future<void> Function()? tearDownRepository,
}) {
  group('ChapterRepository Contract Tests', () {
    late ChapterRepository repo;

    setUp(() async {
      repo = await createRepository();
    });

    tearDown(() async {
      if (tearDownRepository != null) {
        await tearDownRepository();
      }
    });

    test('creates chapter with client-generated id and retrieves it', () async {
      const chapter = Chapter(
        subjectId: 'sub-1',
        title: 'Mechanics',
        sortOrder: 1,
      );

      final created = await repo.createChapter(chapter);
      expect(created.id, isNotEmpty);
      expect(created.title, equals('Mechanics'));
      expect(created.sortOrder, equals(1));

      final fetched = await repo.getChapterById(created.id);
      expect(fetched, isNotNull);
      expect(fetched!.id, equals(created.id));
      expect(fetched.title, equals('Mechanics'));
    });

    test('saving same id twice results in 1 row (upsert idempotency)',
        () async {
      final initial = await repo.createChapter(
        const Chapter(
          id: 'chap-fixed-1',
          subjectId: 'sub-1',
          title: 'Initial Title',
        ),
      );
      expect(initial.id, equals('chap-fixed-1'));

      final updated = await repo.createChapter(
        const Chapter(
          id: 'chap-fixed-1',
          subjectId: 'sub-1',
          title: 'Updated Title',
          sortOrder: 2,
        ),
      );
      expect(updated.id, equals('chap-fixed-1'));

      final list = await repo.getChaptersForSubject('sub-1');
      expect(list.length, equals(1));
      expect(list.first.title, equals('Updated Title'));
      expect(list.first.sortOrder, equals(2));
    });

    test('getChaptersForSubject filters by subjectId and sorts correctly',
        () async {
      await repo.createChapter(
        const Chapter(
          id: 'chap-a1',
          subjectId: 'sub-a',
          title: 'Chapter 2',
          sortOrder: 2,
        ),
      );
      await repo.createChapter(
        const Chapter(
          id: 'chap-a2',
          subjectId: 'sub-a',
          title: 'Chapter 1',
          sortOrder: 1,
        ),
      );
      await repo.createChapter(
        const Chapter(
          id: 'chap-b1',
          subjectId: 'sub-b',
          title: 'Other Subject Chapter',
        ),
      );

      final chaptersA = await repo.getChaptersForSubject('sub-a');
      expect(chaptersA.length, equals(2));
      expect(chaptersA[0].title, equals('Chapter 1'));
      expect(chaptersA[1].title, equals('Chapter 2'));

      final chaptersB = await repo.getChaptersForSubject('sub-b');
      expect(chaptersB.length, equals(1));
      expect(chaptersB.first.title, equals('Other Subject Chapter'));
    });

    test('updateChapter mutates title and sort order', () async {
      final chapter = await repo.createChapter(
        const Chapter(
          id: 'chap-mod-1',
          subjectId: 'sub-x',
          title: 'Draft Chapter',
        ),
      );

      final modified = await repo.updateChapter(
        chapter.copyWith(title: 'Final Chapter', sortOrder: 5),
      );
      expect(modified.title, equals('Final Chapter'));
      expect(modified.sortOrder, equals(5));

      final fetched = await repo.getChapterById('chap-mod-1');
      expect(fetched!.title, equals('Final Chapter'));
      expect(fetched.sortOrder, equals(5));
    });

    test('deleteChapter deletes existing record', () async {
      final chapter = await repo.createChapter(
        const Chapter(
          id: 'chap-del-1',
          subjectId: 'sub-y',
          title: 'To Be Deleted',
        ),
      );

      await repo.deleteChapter(chapter.id);
      final fetched = await repo.getChapterById('chap-del-1');
      expect(fetched, isNull);
    });

    test('reorderChapters updates sequential sort orders', () async {
      await repo.createChapter(
        const Chapter(id: 'c1', subjectId: 'sub-z', title: 'One'),
      );
      await repo.createChapter(
        const Chapter(id: 'c2', subjectId: 'sub-z', title: 'Two', sortOrder: 1),
      );
      await repo.createChapter(
        const Chapter(
          id: 'c3',
          subjectId: 'sub-z',
          title: 'Three',
          sortOrder: 2,
        ),
      );

      await repo.reorderChapters(['c3', 'c1', 'c2']);

      final ordered = await repo.getChaptersForSubject('sub-z');
      expect(ordered.map((c) => c.id).toList(), equals(['c3', 'c1', 'c2']));
    });

    test('empty title throws PrepValidationFailure', () async {
      expect(
        () => repo.createChapter(
          const Chapter(subjectId: 'sub-1', title: '   '),
        ),
        throwsA(isA<PrepValidationFailure>()),
      );
    });
  });
}

void main() {
  group('Local Implementation Contract', () {
    late AppDatabase db;

    testChapterRepositoryContract(
      createRepository: () async {
        db = AppDatabase(NativeDatabase.memory());
        return LocalChapterRepository(db);
      },
      tearDownRepository: () async {
        await db.close();
      },
    );
  });

  group('Supabase Implementation Contract', () {
    late MockSupabaseHttpClient mockHttp;
    late MockSupabaseClient client;

    testChapterRepositoryContract(
      createRepository: () async {
        mockHttp = MockSupabaseHttpClient();
        client = MockSupabaseClient(mockHttpClient: mockHttp);
        return SupabaseChapterRepository(client);
      },
      tearDownRepository: () async {
        mockHttp.clear();
      },
    );
  });
}
