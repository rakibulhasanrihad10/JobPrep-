import 'package:flutter_test/flutter_test.dart';
import 'package:job_prep/features/prep/data/mappers/mock_test_mapper.dart';
import 'package:job_prep/features/prep/data/repositories/unconfigured_mock_test_repository.dart';
import 'package:job_prep/features/prep/domain/entities/mock_test.dart';
import 'package:job_prep/features/prep/domain/errors/prep_failure.dart';
import 'package:job_prep/features/prep/domain/utils/mock_test_analytics.dart';

void main() {
  MockTest buildTest({
    String id = 't-1',
    String subjectId = 'sub-1',
    DateTime? takenOn,
    double marksObtained = 80,
    double totalMarks = 100,
    double? negativeMarks,
    DateTime? createdAt,
  }) {
    return MockTest(
      id: id,
      userId: 'user-1',
      subjectId: subjectId,
      title: 'Model $id',
      takenOn: takenOn ?? DateTime.utc(2026, 11),
      marksObtained: marksObtained,
      totalMarks: totalMarks,
      negativeMarks: negativeMarks,
      createdAt: createdAt,
    );
  }

  group('MockTestAnalytics calculations', () {
    test('calculates net marks and score percentage after negative marks', () {
      final withoutPenalty = buildTest(marksObtained: 40, totalMarks: 50);
      expect(MockTestAnalytics.calculateNetMarks(withoutPenalty), 40);
      expect(
        MockTestAnalytics.calculateScorePercentage(withoutPenalty),
        closeTo(80.0, 0.0001),
      );

      final withPenalty = buildTest(
        marksObtained: 82.5,
        negativeMarks: 4.5,
      );
      expect(MockTestAnalytics.calculateNetMarks(withPenalty), 78.0);
      expect(
        MockTestAnalytics.calculateScorePercentage(withPenalty),
        closeTo(78.0, 0.0001),
      );

      final customOutOf = buildTest(
        marksObtained: 38,
        totalMarks: 45,
        negativeMarks: 2,
      );
      expect(
        MockTestAnalytics.calculateScorePercentage(customOutOf),
        closeTo(80.0, 0.0001),
      );
    });

    test('guards against negative net marks, zero totalMarks, and empty lists',
        () {
      final overPenalized = buildTest(
        marksObtained: 10,
        negativeMarks: 25,
      );
      expect(MockTestAnalytics.calculateNetMarks(overPenalized), 0);
      expect(MockTestAnalytics.calculateScorePercentage(overPenalized), 0);

      final zeroTotal = buildTest(marksObtained: 0, totalMarks: 0);
      expect(MockTestAnalytics.calculateScorePercentage(zeroTotal), 0);

      final negativeTotal = buildTest(marksObtained: 10, totalMarks: -5);
      expect(MockTestAnalytics.calculateScorePercentage(negativeTotal), 0);

      expect(MockTestAnalytics.calculateAverageScore(const []), 0);
      expect(MockTestAnalytics.calculateBestScore(const []), 0);
      expect(MockTestAnalytics.calculateLatestScore(const []), 0);
      expect(MockTestAnalytics.calculateImprovementFirstToLatest(const []), 0);
      expect(MockTestAnalytics.calculateImprovementLastFive(const []), 0);
      expect(
        MockTestAnalytics.summarizeTests(const []),
        MockTestSummary.empty,
      );
    });

    test('computes average, best, latest, and improvement chronologically', () {
      final unordered = [
        buildTest(
          id: 't3',
          takenOn: DateTime.utc(2026, 11, 8),
          marksObtained: 88,
          negativeMarks: 4, // 84%
        ),
        buildTest(
          id: 't1',
          takenOn: DateTime.utc(2026, 11),
          marksObtained: 64,
          negativeMarks: 4, // 60%
        ),
        buildTest(
          id: 't2',
          takenOn: DateTime.utc(2026, 11, 5),
          marksObtained: 95,
          negativeMarks: 5, // 90%
        ),
      ];

      expect(
        MockTestAnalytics.calculateAverageScore(unordered),
        closeTo(78.0, 0.0001),
      );
      expect(
        MockTestAnalytics.calculateBestScore(unordered),
        closeTo(90.0, 0.0001),
      );
      expect(
        MockTestAnalytics.calculateLatestScore(unordered),
        closeTo(84.0, 0.0001),
      );
      expect(
        MockTestAnalytics.calculateImprovementFirstToLatest(unordered),
        closeTo(24.0, 0.0001),
      );
    });

    test('improvement returns 0 for single test and scopes last-5 window', () {
      final single = [buildTest(marksObtained: 70)];
      expect(MockTestAnalytics.calculateImprovementFirstToLatest(single), 0);
      expect(MockTestAnalytics.calculateImprovementLastFive(single), 0);

      final sevenTests = [
        buildTest(id: '1', takenOn: DateTime.utc(2026, 11), marksObtained: 40),
        buildTest(
          id: '2',
          takenOn: DateTime.utc(2026, 11, 2),
          marksObtained: 50,
        ),
        buildTest(
          id: '3',
          takenOn: DateTime.utc(2026, 11, 3),
          marksObtained: 60,
        ),
        buildTest(
          id: '4',
          takenOn: DateTime.utc(2026, 11, 4),
          marksObtained: 65,
        ),
        buildTest(
          id: '5',
          takenOn: DateTime.utc(2026, 11, 5),
          marksObtained: 72,
        ),
        buildTest(id: '6', takenOn: DateTime.utc(2026, 11, 6)),
        buildTest(
          id: '7',
          takenOn: DateTime.utc(2026, 11, 7),
          marksObtained: 75,
        ),
      ];

      expect(
        MockTestAnalytics.calculateImprovementFirstToLatest(sevenTests),
        closeTo(35.0, 0.0001),
      );
      // Last 5 tests are ids 3..7 (60 -> 75 = +15.0)
      expect(
        MockTestAnalytics.calculateImprovementLastFive(sevenTests),
        closeTo(15.0, 0.0001),
      );
    });

    test('filterMockTests scopes by subject and inclusive date range', () {
      final list = [
        buildTest(id: 'a', takenOn: DateTime.utc(2026, 11)),
        buildTest(
          id: 'b',
          subjectId: 'sub-2',
          takenOn: DateTime.utc(2026, 11, 5),
        ),
        buildTest(
          id: 'c',
          takenOn: DateTime.utc(2026, 11, 9),
        ),
      ];

      final sub1 = MockTestAnalytics.filterMockTests(list, subjectId: 'sub-1');
      expect(sub1.map((t) => t.id), ['c', 'a']);

      final ranged = MockTestAnalytics.filterMockTests(
        list,
        subjectId: 'sub-1',
        startDate: DateTime.utc(2026, 11, 2),
        endDate: DateTime.utc(2026, 11, 9, 23, 59),
      );
      expect(ranged.map((t) => t.id), ['c']);
    });

    test('summarizeTests scopes by subject and generates trend points', () {
      final list = [
        buildTest(
          id: '1',
          takenOn: DateTime.utc(2026, 11),
          marksObtained: 60,
        ),
        buildTest(
          id: '2',
          subjectId: 'sub-2',
          takenOn: DateTime.utc(2026, 11, 2),
          marksObtained: 95,
        ),
        buildTest(
          id: '3',
          takenOn: DateTime.utc(2026, 11, 4),
          negativeMarks: 5, // 75%
        ),
      ];

      final summary = MockTestAnalytics.summarizeTests(
        list,
        subjectId: 'sub-1',
      );
      expect(summary.testCount, 2);
      expect(summary.latestScore, closeTo(75.0, 0.0001));
      expect(summary.bestScore, closeTo(75.0, 0.0001));
      expect(summary.averageScore, closeTo(67.5, 0.0001));
      expect(summary.improvementFirstToLatest, closeTo(15.0, 0.0001));
      expect(summary.trendPoints.length, 2);
      expect(summary.trendPoints[0].index, 0);
      expect(summary.trendPoints[0].scorePercent, closeTo(60.0, 0.0001));
      expect(summary.trendPoints[1].index, 1);
      expect(summary.trendPoints[1].scorePercent, closeTo(75.0, 0.0001));
    });
  });

  group('MockTestMapper & UnconfiguredMockTestRepository', () {
    test('round-trips database row with optional attachments cleanly', () {
      final row = <String, dynamic>{
        'id': 'mt-1',
        'user_id': 'u-1',
        'subject_id': 'sub-1',
        'circular_id': 'circ-1',
        'material_id': 'mat-1',
        'topic_id': 'top-1',
        'title': '46th BCS Full Live',
        'source': 'Live MCQ',
        'taken_on': '2026-11-08',
        'marks_obtained': 142.5,
        'total_marks': 200,
        'negative_marks': 7.5,
        'time_taken_minutes': 98,
        'time_limit_minutes': 120,
        'weak_topics': 'Grammar, Geometry',
        'notes': 'Revise traps',
        'created_at': '2026-11-08T10:00:00Z',
        'updated_at': '2026-11-08T10:05:00Z',
      };

      final entity = MockTestMapper.fromJson(row);
      expect(entity.id, 'mt-1');
      expect(entity.circularId, 'circ-1');
      expect(entity.materialId, 'mat-1');
      expect(entity.topicId, 'top-1');
      expect(entity.takenOn, DateTime(2026, 11, 8));
      expect(entity.negativeMarks, 7.5);
      expect(entity.timeTakenMinutes, 98);
      expect(entity.timeLimitMinutes, 120);

      final insertMap = MockTestMapper.toInsertJson(entity, userId: 'u-1');
      expect(insertMap['taken_on'], '2026-11-08');
      expect(insertMap['user_id'], 'u-1');
      expect(insertMap['material_id'], 'mat-1');
      expect(insertMap['topic_id'], 'top-1');

      final updateMap = MockTestMapper.toUpdateJson(entity);
      expect(updateMap.containsKey('user_id'), isFalse);
      expect(updateMap['weak_topics'], 'Grammar, Geometry');
    });

    test('unconfigured repository returns empty reads and errors on writes',
        () async {
      const repo = UnconfiguredMockTestRepository();
      expect(await repo.getTests(), isEmpty);
      expect(await repo.getTestsForSubject('sub-1'), isEmpty);
      await expectLater(
        repo.createTest(buildTest()),
        throwsA(isA<UnknownPrepFailure>()),
      );
      await expectLater(
        repo.updateTest(buildTest()),
        throwsA(isA<UnknownPrepFailure>()),
      );
      await expectLater(
        repo.deleteTest('t-1'),
        throwsA(isA<UnknownPrepFailure>()),
      );
    });
  });
}
