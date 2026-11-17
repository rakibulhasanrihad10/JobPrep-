import 'package:job_prep/features/prep/data/mappers/prep_json_helpers.dart';
import 'package:job_prep/features/prep/domain/entities/mock_test_topic.dart';

/// Maps between PostgreSQL `public.mock_test_topics` rows and [MockTestTopic].
abstract final class MockTestTopicMapper {
  static MockTestTopic fromJson(Map<String, dynamic> json) {
    return MockTestTopic(
      id: PrepJsonHelpers.readRequiredString(json, 'id'),
      userId: PrepJsonHelpers.readRequiredString(json, 'user_id'),
      mockTestId: PrepJsonHelpers.readRequiredString(json, 'mock_test_id'),
      topicId: PrepJsonHelpers.readRequiredString(json, 'topic_id'),
      createdAt: PrepJsonHelpers.readOptionalDateTime(json, 'created_at'),
    );
  }

  static List<MockTestTopic> fromJsonList(List<dynamic> rows) {
    return rows
        .whereType<Map<String, dynamic>>()
        .map(fromJson)
        .toList(growable: false);
  }

  static Map<String, dynamic> toInsertJson(
    MockTestTopic link, {
    String? userId,
  }) {
    final resolvedUser =
        userId?.trim().isNotEmpty == true ? userId!.trim() : link.userId.trim();
    return <String, dynamic>{
      if (link.id.trim().isNotEmpty) 'id': link.id.trim(),
      if (resolvedUser.isNotEmpty) 'user_id': resolvedUser,
      'mock_test_id': link.mockTestId.trim(),
      'topic_id': link.topicId.trim(),
    };
  }
}
