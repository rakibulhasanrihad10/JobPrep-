import 'package:flutter/foundation.dart' show immutable, listEquals;

/// Immutable domain entity representing a logged model or mock test result
/// (`public.mock_tests`).
@immutable
class MockTest {
  /// Creates a [MockTest].
  const MockTest({
    required this.subjectId,
    required this.title,
    required this.takenOn,
    required this.marksObtained,
    required this.totalMarks,
    this.id = '',
    this.userId = '',
    this.circularId,
    this.materialId,
    this.topicId,
    this.source,
    this.negativeMarks,
    this.timeTakenMinutes,
    this.timeLimitMinutes,
    this.weakTopics,
    this.notes,
    this.createdAt,
    this.updatedAt,
  });

  static const Object _unset = Object();

  /// Unique identifier (`mock_tests.id`).
  final String id;

  /// Owner user identifier (`mock_tests.user_id`).
  final String userId;

  /// Required parent subject identifier (`mock_tests.subject_id`).
  final String subjectId;

  /// Optional attached circular identifier (`mock_tests.circular_id`).
  final String? circularId;

  /// Optional attached study material identifier (`mock_tests.material_id`).
  final String? materialId;

  /// Optional attached syllabus topic identifier (`mock_tests.topic_id`).
  final String? topicId;

  /// Title of the mock test (e.g. "LiveMCQ Model 12").
  final String title;

  /// Optional platform or guidebook source name.
  final String? source;

  /// Calendar date when the test was taken (`mock_tests.taken_on`).
  final DateTime takenOn;

  /// Positive marks obtained before deducting negative marks.
  final double marksObtained;

  /// Maximum possible marks on the test (`> 0`).
  final double totalMarks;

  /// Optional penalty marks deducted for incorrect answers (`>= 0`).
  final double? negativeMarks;

  /// Optional actual duration spent in minutes (`>= 0`).
  final int? timeTakenMinutes;

  /// Optional allocated time limit in minutes (`> 0`).
  final int? timeLimitMinutes;

  /// Optional comma-separated or free-text weak topics identified.
  final String? weakTopics;

  /// Optional review notes for post-test analysis.
  final String? notes;

  /// Record creation timestamp managed by PostgreSQL.
  final DateTime? createdAt;

  /// Record last-update timestamp managed by PostgreSQL.
  final DateTime? updatedAt;

  /// Returns a copy with specified fields overridden cleanly.
  MockTest copyWith({
    String? id,
    String? userId,
    String? subjectId,
    Object? circularId = _unset,
    Object? materialId = _unset,
    Object? topicId = _unset,
    String? title,
    Object? source = _unset,
    DateTime? takenOn,
    double? marksObtained,
    double? totalMarks,
    Object? negativeMarks = _unset,
    Object? timeTakenMinutes = _unset,
    Object? timeLimitMinutes = _unset,
    Object? weakTopics = _unset,
    Object? notes = _unset,
    Object? createdAt = _unset,
    Object? updatedAt = _unset,
  }) {
    return MockTest(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      subjectId: subjectId ?? this.subjectId,
      circularId: identical(circularId, _unset)
          ? this.circularId
          : circularId as String?,
      materialId: identical(materialId, _unset)
          ? this.materialId
          : materialId as String?,
      topicId: identical(topicId, _unset) ? this.topicId : topicId as String?,
      title: title ?? this.title,
      source: identical(source, _unset) ? this.source : source as String?,
      takenOn: takenOn ?? this.takenOn,
      marksObtained: marksObtained ?? this.marksObtained,
      totalMarks: totalMarks ?? this.totalMarks,
      negativeMarks: identical(negativeMarks, _unset)
          ? this.negativeMarks
          : negativeMarks as double?,
      timeTakenMinutes: identical(timeTakenMinutes, _unset)
          ? this.timeTakenMinutes
          : timeTakenMinutes as int?,
      timeLimitMinutes: identical(timeLimitMinutes, _unset)
          ? this.timeLimitMinutes
          : timeLimitMinutes as int?,
      weakTopics: identical(weakTopics, _unset)
          ? this.weakTopics
          : weakTopics as String?,
      notes: identical(notes, _unset) ? this.notes : notes as String?,
      createdAt: identical(createdAt, _unset)
          ? this.createdAt
          : createdAt as DateTime?,
      updatedAt: identical(updatedAt, _unset)
          ? this.updatedAt
          : updatedAt as DateTime?,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is MockTest &&
        other.id == id &&
        other.userId == userId &&
        other.subjectId == subjectId &&
        other.circularId == circularId &&
        other.materialId == materialId &&
        other.topicId == topicId &&
        other.title == title &&
        other.source == source &&
        other.takenOn == takenOn &&
        other.marksObtained == marksObtained &&
        other.totalMarks == totalMarks &&
        other.negativeMarks == negativeMarks &&
        other.timeTakenMinutes == timeTakenMinutes &&
        other.timeLimitMinutes == timeLimitMinutes &&
        other.weakTopics == weakTopics &&
        other.notes == notes &&
        other.createdAt == createdAt &&
        other.updatedAt == updatedAt;
  }

  @override
  int get hashCode => Object.hash(
        id,
        userId,
        subjectId,
        circularId,
        materialId,
        topicId,
        title,
        source,
        takenOn,
        marksObtained,
        totalMarks,
        negativeMarks,
        timeTakenMinutes,
        timeLimitMinutes,
        weakTopics,
        notes,
        createdAt,
        updatedAt,
      );
}

/// Chronological score point plotted on the subject mock test trend chart.
@immutable
class MockTestTrendPoint {
  /// Creates a [MockTestTrendPoint].
  const MockTestTrendPoint({
    required this.test,
    required this.index,
    required this.scorePercent,
  });

  /// Underlying logged mock test entry.
  final MockTest test;

  /// Zero-based chronological position on the X-axis.
  final int index;

  /// Net percentage score (`0.0..100.0`) after negative marks.
  final double scorePercent;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is MockTestTrendPoint &&
        other.test == test &&
        other.index == index &&
        other.scorePercent == scorePercent;
  }

  @override
  int get hashCode => Object.hash(test, index, scorePercent);
}

/// Aggregated mock test statistics and trend series for a subject or scope.
@immutable
class MockTestSummary {
  /// Creates a [MockTestSummary].
  const MockTestSummary({
    required this.testCount,
    required this.latestScore,
    required this.bestScore,
    required this.averageScore,
    required this.improvementFirstToLatest,
    required this.improvementLastFive,
    required this.trendPoints,
  });

  /// Empty default summary when zero tests are available.
  static const MockTestSummary empty = MockTestSummary(
    testCount: 0,
    latestScore: 0,
    bestScore: 0,
    averageScore: 0,
    improvementFirstToLatest: 0,
    improvementLastFive: 0,
    trendPoints: <MockTestTrendPoint>[],
  );

  /// Total number of tests summarized.
  final int testCount;

  /// Percentage score of the chronologically latest test.
  final double latestScore;

  /// Highest percentage score across summarized tests.
  final double bestScore;

  /// Arithmetic mean percentage across summarized tests.
  final double averageScore;

  /// Percentage-point delta between first and latest test.
  final double improvementFirstToLatest;

  /// Percentage-point delta from earliest to latest in the last 5 tests.
  final double improvementLastFive;

  /// Chronologically ordered points for trend plotting.
  final List<MockTestTrendPoint> trendPoints;

  /// Whether at least one test has been recorded.
  bool get hasTests => testCount > 0;

  /// Whether improvement comparison across `>= 2` tests exists.
  bool get hasImprovementComparison => testCount >= 2;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is MockTestSummary &&
        other.testCount == testCount &&
        other.latestScore == latestScore &&
        other.bestScore == bestScore &&
        other.averageScore == averageScore &&
        other.improvementFirstToLatest == improvementFirstToLatest &&
        other.improvementLastFive == improvementLastFive &&
        listEquals(other.trendPoints, trendPoints);
  }

  @override
  int get hashCode => Object.hash(
        testCount,
        latestScore,
        bestScore,
        averageScore,
        improvementFirstToLatest,
        improvementLastFive,
        Object.hashAll(trendPoints),
      );
}
