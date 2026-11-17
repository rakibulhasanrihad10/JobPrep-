import 'package:job_prep/features/prep/domain/entities/mock_test_topic.dart';

/// Repository interface for mock test to topic associations.
abstract interface class MockTestTopicRepository {
  /// Fetches all topic links for a given [mockTestId].
  Future<List<MockTestTopic>> getTopicsForMockTest(String mockTestId);

  /// Fetches all mock test links for a given [topicId].
  Future<List<MockTestTopic>> getMockTestsForTopic(String topicId);

  /// Replaces the set of linked topics for [mockTestId].
  Future<void> setTopicsForMockTest(
    String mockTestId,
    List<String> topicIds,
  );

  /// Creates a single link between [mockTestId] and [topicId].
  Future<MockTestTopic> linkTopic({
    required String mockTestId,
    required String topicId,
    String? id,
  });

  /// Removes link between [mockTestId] and [topicId].
  Future<void> unlinkTopic({
    required String mockTestId,
    required String topicId,
  });

  /// Inserts multiple links in batch (idempotent upsert).
  Future<void> batchCreate(List<MockTestTopic> links);

  /// Fetches all links for the current user.
  Future<List<MockTestTopic>> getAll();
}
