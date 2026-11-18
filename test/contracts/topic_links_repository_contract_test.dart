import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:job_prep/core/local/database/app_database.dart';
import 'package:job_prep/features/prep/data/repositories/local_material_chapter_repository.dart';
import 'package:job_prep/features/prep/data/repositories/local_mock_test_topic_repository.dart';
import 'package:job_prep/features/prep/data/repositories/supabase_material_chapter_repository.dart';
import 'package:job_prep/features/prep/data/repositories/supabase_mock_test_topic_repository.dart';
import 'package:job_prep/features/prep/domain/entities/material_chapter.dart';
import 'package:job_prep/features/prep/domain/entities/mock_test_topic.dart';
import 'package:job_prep/features/prep/domain/repositories/material_chapter_repository.dart';
import 'package:job_prep/features/prep/domain/repositories/mock_test_topic_repository.dart';

import 'mock_supabase_http_client.dart';

void testTopicLinksRepositoriesContract({
  required Future<MockTestTopicRepository> Function() createMockTestTopicRepo,
  required Future<MaterialChapterRepository> Function()
      createMaterialChapterRepo,
  Future<void> Function()? tearDownRepositories,
}) {
  group('MockTestTopicRepository Contract Tests', () {
    late MockTestTopicRepository repo;

    setUp(() async {
      repo = await createMockTestTopicRepo();
    });

    tearDown(() async {
      if (tearDownRepositories != null) {
        await tearDownRepositories();
      }
    });

    test('linkTopic creates link with client id and retrieves it', () async {
      final link = await repo.linkTopic(
        mockTestId: 'mt-1',
        topicId: 'top-1',
        id: 'link-1',
      );
      expect(link.id, equals('link-1'));
      expect(link.mockTestId, equals('mt-1'));
      expect(link.topicId, equals('top-1'));

      final forMock = await repo.getTopicsForMockTest('mt-1');
      expect(forMock, hasLength(1));
      expect(forMock.first.topicId, equals('top-1'));

      final forTopic = await repo.getMockTestsForTopic('top-1');
      expect(forTopic, hasLength(1));
      expect(forTopic.first.mockTestId, equals('mt-1'));
    });

    test('saving same mockTestId and topicId twice produces 1 row', () async {
      await repo.linkTopic(mockTestId: 'mt-2', topicId: 'top-2', id: 'l2');
      await repo.linkTopic(mockTestId: 'mt-2', topicId: 'top-2', id: 'l2-alt');

      final forMock = await repo.getTopicsForMockTest('mt-2');
      expect(forMock, hasLength(1));
    });

    test('setTopicsForMockTest replaces linked topics', () async {
      await repo.setTopicsForMockTest('mt-3', ['top-a', 'top-b']);
      var forMock = await repo.getTopicsForMockTest('mt-3');
      expect(forMock.map((l) => l.topicId).toSet(), equals({'top-a', 'top-b'}));

      await repo.setTopicsForMockTest('mt-3', ['top-c']);
      forMock = await repo.getTopicsForMockTest('mt-3');
      expect(forMock.map((l) => l.topicId).toSet(), equals({'top-c'}));
    });

    test('unlinkTopic removes specific association', () async {
      await repo.linkTopic(mockTestId: 'mt-4', topicId: 'top-d');
      await repo.unlinkTopic(mockTestId: 'mt-4', topicId: 'top-d');

      final forMock = await repo.getTopicsForMockTest('mt-4');
      expect(forMock, isEmpty);
    });

    test('batchCreate creates links idempotently', () async {
      final batch = [
        const MockTestTopic(
          id: 'b-1',
          userId: '',
          mockTestId: 'mt-5',
          topicId: 'top-x',
        ),
        const MockTestTopic(
          id: 'b-2',
          userId: '',
          mockTestId: 'mt-5',
          topicId: 'top-y',
        ),
      ];
      await repo.batchCreate(batch);
      final forMock = await repo.getTopicsForMockTest('mt-5');
      expect(forMock, hasLength(2));
    });
  });

  group('MaterialChapterRepository Contract Tests', () {
    late MaterialChapterRepository repo;

    setUp(() async {
      repo = await createMaterialChapterRepo();
    });

    tearDown(() async {
      if (tearDownRepositories != null) {
        await tearDownRepositories();
      }
    });

    test('linkChapter creates link with client id and retrieves it', () async {
      final link = await repo.linkChapter(
        materialId: 'mat-1',
        chapterId: 'chap-1',
        id: 'mc-1',
      );
      expect(link.id, equals('mc-1'));
      expect(link.materialId, equals('mat-1'));
      expect(link.chapterId, equals('chap-1'));

      final forMat = await repo.getChaptersForMaterial('mat-1');
      expect(forMat, hasLength(1));
      expect(forMat.first.chapterId, equals('chap-1'));

      final forChap = await repo.getMaterialsForChapter('chap-1');
      expect(forChap, hasLength(1));
      expect(forChap.first.materialId, equals('mat-1'));
    });

    test('saving same materialId and chapterId twice produces 1 row', () async {
      await repo.linkChapter(
        materialId: 'mat-2',
        chapterId: 'chap-2',
        id: 'm2',
      );
      await repo.linkChapter(
        materialId: 'mat-2',
        chapterId: 'chap-2',
        id: 'm2b',
      );

      final forMat = await repo.getChaptersForMaterial('mat-2');
      expect(forMat, hasLength(1));
    });

    test('setChaptersForMaterial replaces linked chapters', () async {
      await repo.setChaptersForMaterial('mat-3', ['chap-a', 'chap-b']);
      var forMat = await repo.getChaptersForMaterial('mat-3');
      expect(
        forMat.map((l) => l.chapterId).toSet(),
        equals({'chap-a', 'chap-b'}),
      );

      await repo.setChaptersForMaterial('mat-3', ['chap-c']);
      forMat = await repo.getChaptersForMaterial('mat-3');
      expect(forMat.map((l) => l.chapterId).toSet(), equals({'chap-c'}));
    });

    test('unlinkChapter removes association', () async {
      await repo.linkChapter(materialId: 'mat-4', chapterId: 'chap-d');
      await repo.unlinkChapter(materialId: 'mat-4', chapterId: 'chap-d');

      final forMat = await repo.getChaptersForMaterial('mat-4');
      expect(forMat, isEmpty);
    });

    test('batchCreate creates links idempotently', () async {
      final batch = [
        const MaterialChapter(
          id: 'mb-1',
          userId: '',
          materialId: 'mat-5',
          chapterId: 'chap-x',
        ),
        const MaterialChapter(
          id: 'mb-2',
          userId: '',
          materialId: 'mat-5',
          chapterId: 'chap-y',
        ),
      ];
      await repo.batchCreate(batch);
      final forMat = await repo.getChaptersForMaterial('mat-5');
      expect(forMat, hasLength(2));
    });
  });
}

void main() {
  group('Local Implementation Contract', () {
    late AppDatabase db;

    setUp(() {
      db = AppDatabase(NativeDatabase.memory());
    });

    tearDown(() async {
      await db.close();
    });

    testTopicLinksRepositoriesContract(
      createMockTestTopicRepo: () async => LocalMockTestTopicRepository(db),
      createMaterialChapterRepo: () async => LocalMaterialChapterRepository(db),
    );
  });

  group('Supabase Implementation Contract', () {
    late MockSupabaseHttpClient mockHttp;
    late MockSupabaseClient client;

    setUp(() {
      mockHttp = MockSupabaseHttpClient();
      client = MockSupabaseClient(mockHttpClient: mockHttp);
    });

    tearDown(() async {
      mockHttp.clear();
    });

    testTopicLinksRepositoriesContract(
      createMockTestTopicRepo: () async =>
          SupabaseMockTestTopicRepository(client),
      createMaterialChapterRepo: () async =>
          SupabaseMaterialChapterRepository(client),
    );
  });
}
