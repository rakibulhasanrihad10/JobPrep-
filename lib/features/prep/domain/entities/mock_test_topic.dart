import 'package:flutter/foundation.dart' show immutable;

/// Immutable domain entity representing a link between a mock test and a
/// syllabus topic (`public.mock_test_topics`).
@immutable
class MockTestTopic {
  const MockTestTopic({
    required this.id,
    required this.userId,
    required this.mockTestId,
    required this.topicId,
    this.createdAt,
  });

  /// Unique link identifier.
  final String id;

  /// Owning user identifier.
  final String userId;

  /// Linked mock test identifier.
  final String mockTestId;

  /// Linked syllabus topic identifier.
  final String topicId;

  /// Creation timestamp.
  final DateTime? createdAt;

  MockTestTopic copyWith({
    String? id,
    String? userId,
    String? mockTestId,
    String? topicId,
    DateTime? createdAt,
  }) {
    return MockTestTopic(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      mockTestId: mockTestId ?? this.mockTestId,
      topicId: topicId ?? this.topicId,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is MockTestTopic &&
        other.id == id &&
        other.userId == userId &&
        other.mockTestId == mockTestId &&
        other.topicId == topicId;
  }

  @override
  int get hashCode => Object.hash(id, userId, mockTestId, topicId);
}
