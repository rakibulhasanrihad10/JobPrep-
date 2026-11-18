import 'package:job_prep/features/prep/domain/entities/material_chapter.dart';
import 'package:job_prep/features/prep/domain/entities/mock_test_topic.dart';
import 'package:job_prep/features/prep/domain/repositories/material_chapter_repository.dart';
import 'package:job_prep/features/prep/domain/repositories/mock_test_topic_repository.dart';

/// In-memory fake implementation of [MockTestTopicRepository] for testing.
class FakeMockTestTopicRepository implements MockTestTopicRepository {
  final List<MockTestTopic> _items = [];

  @override
  Future<List<MockTestTopic>> getAll() async => List.unmodifiable(_items);

  @override
  Future<List<MockTestTopic>> getTopicsForMockTest(String mockTestId) async =>
      _items.where((i) => i.mockTestId == mockTestId).toList();

  @override
  Future<List<MockTestTopic>> getMockTestsForTopic(String topicId) async =>
      _items.where((i) => i.topicId == topicId).toList();

  @override
  Future<MockTestTopic> linkTopic({
    required String mockTestId,
    required String topicId,
    String? id,
  }) async {
    final existing = _items.where(
      (i) => i.mockTestId == mockTestId && i.topicId == topicId,
    );
    if (existing.isNotEmpty) {
      return existing.first;
    }
    final item = MockTestTopic(
      id: id ?? '${mockTestId}_$topicId',
      userId: 'test_user',
      mockTestId: mockTestId,
      topicId: topicId,
      createdAt: DateTime.now(),
    );
    _items.add(item);
    return item;
  }

  @override
  Future<void> unlinkTopic({
    required String mockTestId,
    required String topicId,
  }) async {
    _items.removeWhere(
      (i) => i.mockTestId == mockTestId && i.topicId == topicId,
    );
  }

  @override
  Future<void> setTopicsForMockTest(
    String mockTestId,
    List<String> topicIds,
  ) async {
    _items.removeWhere((i) => i.mockTestId == mockTestId);
    for (final topicId in topicIds) {
      await linkTopic(mockTestId: mockTestId, topicId: topicId);
    }
  }

  @override
  Future<void> batchCreate(List<MockTestTopic> links) async {
    for (final link in links) {
      await linkTopic(
        mockTestId: link.mockTestId,
        topicId: link.topicId,
        id: link.id,
      );
    }
  }
}

/// In-memory fake implementation of [MaterialChapterRepository] for testing.
class FakeMaterialChapterRepository implements MaterialChapterRepository {
  final List<MaterialChapter> _items = [];

  @override
  Future<List<MaterialChapter>> getAll() async => List.unmodifiable(_items);

  @override
  Future<List<MaterialChapter>> getChaptersForMaterial(
    String materialId,
  ) async =>
      _items.where((i) => i.materialId == materialId).toList();

  @override
  Future<List<MaterialChapter>> getMaterialsForChapter(
    String chapterId,
  ) async =>
      _items.where((i) => i.chapterId == chapterId).toList();

  @override
  Future<MaterialChapter> linkChapter({
    required String materialId,
    required String chapterId,
    String? id,
  }) async {
    final existing = _items.where(
      (i) => i.materialId == materialId && i.chapterId == chapterId,
    );
    if (existing.isNotEmpty) {
      return existing.first;
    }
    final item = MaterialChapter(
      id: id ?? '${materialId}_$chapterId',
      userId: 'test_user',
      materialId: materialId,
      chapterId: chapterId,
      createdAt: DateTime.now(),
    );
    _items.add(item);
    return item;
  }

  @override
  Future<void> unlinkChapter({
    required String materialId,
    required String chapterId,
  }) async {
    _items.removeWhere(
      (i) => i.materialId == materialId && i.chapterId == chapterId,
    );
  }

  @override
  Future<void> setChaptersForMaterial(
    String materialId,
    List<String> chapterIds,
  ) async {
    _items.removeWhere((i) => i.materialId == materialId);
    for (final chapterId in chapterIds) {
      await linkChapter(materialId: materialId, chapterId: chapterId);
    }
  }

  @override
  Future<void> batchCreate(List<MaterialChapter> links) async {
    for (final link in links) {
      await linkChapter(
        materialId: link.materialId,
        chapterId: link.chapterId,
        id: link.id,
      );
    }
  }
}
