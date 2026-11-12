import 'dart:math' as math;

import 'package:job_prep/features/prep/domain/entities/mock_test.dart';

/// Pure analytics, filtering, and scoring helpers for [MockTest] entries.
abstract final class MockTestAnalytics {
  /// Computes net marks (`marksObtained - negativeMarks`) clamped within
  /// `[0, totalMarks]` (or `>= 0` if `totalMarks <= 0`).
  static double calculateNetMarks(MockTest test) {
    if (!test.marksObtained.isFinite) return 0;
    final penalty = (test.negativeMarks != null && test.negativeMarks!.isFinite)
        ? math.max(0, test.negativeMarks!).toDouble()
        : 0.0;
    final net = test.marksObtained - penalty;
    if (net <= 0) return 0;
    if (test.totalMarks.isFinite &&
        test.totalMarks > 0 &&
        net > test.totalMarks) {
      return test.totalMarks;
    }
    return net;
  }

  /// Calculates percentage score (`0.0..100.0`) after deducting negative marks,
  /// guarding cleanly against non-positive or non-finite [MockTest.totalMarks].
  static double calculateScorePercentage(MockTest test) {
    if (!test.totalMarks.isFinite || test.totalMarks <= 0) {
      return 0;
    }
    final net = calculateNetMarks(test);
    return ((net / test.totalMarks) * 100.0).clamp(0.0, 100.0);
  }

  /// Returns [tests] sorted chronologically ascending (`takenOn`, then
  /// `createdAt`, then `id`) for time-series and improvement analytics.
  static List<MockTest> sortChronologicalAscending(Iterable<MockTest> tests) {
    final sorted = List<MockTest>.of(tests)..sort(_compareChronological);
    return List<MockTest>.unmodifiable(sorted);
  }

  /// Filters [tests] by optional [subjectId] and inclusive calendar range
  /// `[startDate, endDate]`, sorted newest first for list presentation.
  static List<MockTest> filterMockTests(
    Iterable<MockTest> tests, {
    String? subjectId,
    DateTime? startDate,
    DateTime? endDate,
  }) {
    final startDay = startDate == null ? null : _dateOnly(startDate);
    final endDay = endDate == null ? null : _dateOnly(endDate);
    final filtered = <MockTest>[];

    for (final test in tests) {
      if (subjectId != null &&
          subjectId.isNotEmpty &&
          test.subjectId != subjectId) {
        continue;
      }
      final day = _dateOnly(test.takenOn);
      if (startDay != null && day.isBefore(startDay)) continue;
      if (endDay != null && day.isAfter(endDay)) continue;
      filtered.add(test);
    }

    filtered.sort((a, b) => _compareChronological(b, a));
    return List<MockTest>.unmodifiable(filtered);
  }

  /// Arithmetic mean percentage across [tests] (`0.0` when empty).
  static double calculateAverageScore(Iterable<MockTest> tests) {
    final list = tests.toList(growable: false);
    if (list.isEmpty) return 0;
    var sum = 0.0;
    for (final test in list) {
      sum += calculateScorePercentage(test);
    }
    return sum / list.length;
  }

  /// Highest percentage score across [tests] (`0.0` when empty).
  static double calculateBestScore(Iterable<MockTest> tests) {
    final list = tests.toList(growable: false);
    if (list.isEmpty) return 0;
    var best = 0.0;
    for (final test in list) {
      final score = calculateScorePercentage(test);
      if (score > best) best = score;
    }
    return best;
  }

  /// Percentage score of the chronologically latest test (`0.0` when empty).
  static double calculateLatestScore(Iterable<MockTest> tests) {
    final ordered = sortChronologicalAscending(tests);
    if (ordered.isEmpty) return 0;
    return calculateScorePercentage(ordered.last);
  }

  /// Percentage-point delta between earliest and latest tests (`0.0` when
  /// fewer than 2 tests exist).
  static double calculateImprovementFirstToLatest(Iterable<MockTest> tests) {
    final ordered = sortChronologicalAscending(tests);
    if (ordered.length < 2) return 0;
    return calculateScorePercentage(ordered.last) -
        calculateScorePercentage(ordered.first);
  }

  /// Percentage-point delta from earliest to latest within the most recent 5
  /// chronological tests (`0.0` when fewer than 2 tests exist).
  static double calculateImprovementLastFive(Iterable<MockTest> tests) {
    final ordered = sortChronologicalAscending(tests);
    if (ordered.length < 2) return 0;
    final window =
        ordered.length <= 5 ? ordered : ordered.sublist(ordered.length - 5);
    return calculateScorePercentage(window.last) -
        calculateScorePercentage(window.first);
  }

  /// Summarizes [tests] (optionally scoped to [subjectId]) into metrics and
  /// trend points ready for chart rendering.
  static MockTestSummary summarizeTests(
    Iterable<MockTest> tests, {
    String? subjectId,
  }) {
    final scoped = (subjectId == null || subjectId.isEmpty)
        ? tests
        : tests.where((t) => t.subjectId == subjectId);
    final ordered = sortChronologicalAscending(scoped);
    if (ordered.isEmpty) return MockTestSummary.empty;

    final points = <MockTestTrendPoint>[
      for (var i = 0; i < ordered.length; i++)
        MockTestTrendPoint(
          test: ordered[i],
          index: i,
          scorePercent: calculateScorePercentage(ordered[i]),
        ),
    ];

    var sum = 0.0;
    var best = 0.0;
    for (final point in points) {
      sum += point.scorePercent;
      if (point.scorePercent > best) best = point.scorePercent;
    }

    final latestScore = points.last.scorePercent;
    final averageScore = sum / points.length;
    final firstToLatest = points.length < 2
        ? 0.0
        : points.last.scorePercent - points.first.scorePercent;
    final lastFive = calculateImprovementLastFive(ordered);

    return MockTestSummary(
      testCount: points.length,
      latestScore: latestScore,
      bestScore: best,
      averageScore: averageScore,
      improvementFirstToLatest: firstToLatest,
      improvementLastFive: lastFive,
      trendPoints: List<MockTestTrendPoint>.unmodifiable(points),
    );
  }

  static int _compareChronological(MockTest a, MockTest b) {
    final dayDiff = _dateOnly(a.takenOn).compareTo(_dateOnly(b.takenOn));
    if (dayDiff != 0) return dayDiff;
    final aCreated = a.createdAt;
    final bCreated = b.createdAt;
    if (aCreated != null && bCreated != null) {
      final createdDiff = aCreated.compareTo(bCreated);
      if (createdDiff != 0) return createdDiff;
    }
    return a.id.compareTo(b.id);
  }

  static DateTime _dateOnly(DateTime source) =>
      DateTime.utc(source.year, source.month, source.day);
}
