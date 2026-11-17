import 'package:job_prep/features/prep/domain/entities/mock_test_topic.dart';
import 'package:job_prep/features/prep/domain/errors/prep_failure.dart';
import 'package:job_prep/features/prep/domain/repositories/mock_test_topic_repository.dart';

/// Fallback repository throwing [UnknownPrepFailure].
class UnconfiguredMockTestTopicRepository implements MockTestTopicRepository {
  const UnconfiguredMockTestTopicRepository();

  static const _failure = UnknownPrepFailure(
    code: 'prep_unconfigured',
    message: 'Mock test topics storage is not configured.',
  );

  Never _fail() => throw _failure;

  @override
  Future<List<MockTestTopic>> getTopicsForMockTest(
    String mockTestId,
  ) async =>
      const <MockTestTopic>[];

  @override
  Future<List<MockTestTopic>> getMockTestsForTopic(
    String topicId,
  ) async =>
      const <MockTestTopic>[];

  @override
  Future<void> setTopicsForMockTest(
    String mockTestId,
    List<String> topicIds,
  ) async =>
      _fail();

  @override
  Future<MockTestTopic> linkTopic({
    required String mockTestId,
    required String topicId,
    String? id,
  }) async =>
      _fail();

  @override
  Future<void> unlinkTopic({
    required String mockTestId,
    required String topicId,
  }) async =>
      _fail();

  @override
  Future<void> batchCreate(List<MockTestTopic> links) async => _fail();

  @override
  Future<List<MockTestTopic>> getAll() async => const <MockTestTopic>[];
}
