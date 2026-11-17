import 'package:drift/drift.dart';
import 'package:job_prep/core/local/database/app_database.dart';
import 'package:job_prep/features/prep/domain/entities/mock_test_topic.dart';
import 'package:job_prep/features/prep/domain/repositories/mock_test_topic_repository.dart';
import 'package:uuid/uuid.dart';

const _uuid = Uuid();

/// Local Drift SQLite implementation of [MockTestTopicRepository].
class LocalMockTestTopicRepository implements MockTestTopicRepository {
  const LocalMockTestTopicRepository(this._db);

  final AppDatabase _db;

  @override
  Future<List<MockTestTopic>> getTopicsForMockTest(String mockTestId) async {
    final rows = await (_db.select(_db.localMockTestTopics)
          ..where((t) => t.mockTestId.equals(mockTestId)))
        .get();
    return rows.map(_toEntity).toList();
  }

  @override
  Future<List<MockTestTopic>> getMockTestsForTopic(String topicId) async {
    final rows = await (_db.select(_db.localMockTestTopics)
          ..where((t) => t.topicId.equals(topicId)))
        .get();
    return rows.map(_toEntity).toList();
  }

  @override
  Future<void> setTopicsForMockTest(
    String mockTestId,
    List<String> topicIds,
  ) async {
    await _db.transaction(() async {
      await (_db.delete(_db.localMockTestTopics)
            ..where((t) => t.mockTestId.equals(mockTestId)))
          .go();
      final now = DateTime.now().toUtc();
      for (final topicId in topicIds) {
        await _db.into(_db.localMockTestTopics).insert(
              LocalMockTestTopic(
                id: _uuid.v4(),
                mockTestId: mockTestId,
                topicId: topicId,
                createdAt: now,
              ),
            );
      }
    });
  }

  @override
  Future<MockTestTopic> linkTopic({
    required String mockTestId,
    required String topicId,
    String? id,
  }) async {
    final existing = await (_db.select(_db.localMockTestTopics)
          ..where(
            (t) => t.mockTestId.equals(mockTestId) & t.topicId.equals(topicId),
          ))
        .getSingleOrNull();
    if (existing != null) {
      return _toEntity(existing);
    }
    final now = DateTime.now().toUtc();
    final link = LocalMockTestTopic(
      id: id ?? _uuid.v4(),
      mockTestId: mockTestId,
      topicId: topicId,
      createdAt: now,
    );
    await _db.into(_db.localMockTestTopics).insert(link);
    return _toEntity(link);
  }

  @override
  Future<void> unlinkTopic({
    required String mockTestId,
    required String topicId,
  }) async {
    await (_db.delete(_db.localMockTestTopics)
          ..where(
            (t) => t.mockTestId.equals(mockTestId) & t.topicId.equals(topicId),
          ))
        .go();
  }

  @override
  Future<void> batchCreate(List<MockTestTopic> links) async {
    await _db.transaction(() async {
      for (final link in links) {
        final existing = await (_db.select(_db.localMockTestTopics)
              ..where(
                (t) =>
                    t.mockTestId.equals(link.mockTestId) &
                    t.topicId.equals(link.topicId),
              ))
            .getSingleOrNull();
        if (existing == null) {
          await _db.into(_db.localMockTestTopics).insert(
                LocalMockTestTopic(
                  id: link.id.trim().isNotEmpty ? link.id : _uuid.v4(),
                  mockTestId: link.mockTestId,
                  topicId: link.topicId,
                  createdAt: link.createdAt ?? DateTime.now().toUtc(),
                ),
              );
        }
      }
    });
  }

  @override
  Future<List<MockTestTopic>> getAll() async {
    final rows = await _db.select(_db.localMockTestTopics).get();
    return rows.map(_toEntity).toList();
  }

  MockTestTopic _toEntity(LocalMockTestTopic row) {
    return MockTestTopic(
      id: row.id,
      userId: '',
      mockTestId: row.mockTestId,
      topicId: row.topicId,
      createdAt: row.createdAt,
    );
  }
}
