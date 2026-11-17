import 'package:flutter_test/flutter_test.dart';
import 'package:job_prep/features/notifications/domain/utils/weekly_review_calculator.dart';
import 'package:job_prep/features/prep/domain/entities/topic.dart';
import 'package:job_prep/features/prep/domain/utils/weekly_topic_counts_calculator.dart';

void main() {
  group('WeeklyTopicCountsCalculator', () {
    final t1 = DateTime.utc(2026, 11, 1, 10);
    final t2 = DateTime.utc(2026, 11, 3, 14);
    final t3 = DateTime.utc(2026, 11, 5, 9);
    final t4 = DateTime.utc(2026, 11, 8, 16);

    test('getCompletionDate returns null if any checkpoint missing', () {
      final topic = Topic(
        id: 'top1',
        subjectId: 's1',
        title: 'T1',
        studyDoneAt: t1,
        practiceDoneAt: t2,
        revisionDoneAt: t4,
      );

      final date = WeeklyTopicCountsCalculator.getCompletionDate(topic);
      expect(date, isNull);
    });

    test(
      'getCompletionDate returns latest timestamp when all checkpoints done',
      () {
        final topic = Topic(
          id: 'top2',
          subjectId: 's1',
          title: 'T2',
          studyDoneAt: t1,
          practiceDoneAt: t2,
          modelTestDoneAt: t3,
          revisionDoneAt: t4,
        );

        final date = WeeklyTopicCountsCalculator.getCompletionDate(topic);
        expect(date, t4);
      },
    );

    test('getCompletionDate respects custom enabled checkpoints', () {
      final topic = Topic(
        id: 'top3',
        subjectId: 's1',
        title: 'T3',
        studyDoneAt: t1,
        practiceDoneAt: t2,
      );

      // Only study and practice enabled
      final date = WeeklyTopicCountsCalculator.getCompletionDate(
        topic,
        enabledCheckpoints: const ['study', 'practice'],
      );
      expect(date, t2);
    });

    test('calculateWeeklyBuckets aggregates counts into week buckets', () {
      final now = DateTime.utc(2026, 11, 15);
      final topics = [
        // Completed this week (Nov 9 - Nov 15)
        Topic(
          id: 'top_w1_1',
          subjectId: 's1',
          title: 'W1',
          studyDoneAt: DateTime.utc(2026, 11, 10),
          practiceDoneAt: DateTime.utc(2026, 11, 11),
          modelTestDoneAt: DateTime.utc(2026, 11, 12),
          revisionDoneAt: DateTime.utc(2026, 11, 12),
        ),
        Topic(
          id: 'top_w1_2',
          subjectId: 's1',
          title: 'W2',
          studyDoneAt: DateTime.utc(2026, 11, 13),
          practiceDoneAt: DateTime.utc(2026, 11, 13),
          modelTestDoneAt: DateTime.utc(2026, 11, 14),
          revisionDoneAt: DateTime.utc(2026, 11, 14),
        ),
        // Completed previous week (Nov 2 - Nov 8)
        Topic(
          id: 'top_w0_1',
          subjectId: 's1',
          title: 'W0',
          studyDoneAt: DateTime.utc(2026, 11, 4),
          practiceDoneAt: DateTime.utc(2026, 11, 4),
          modelTestDoneAt: DateTime.utc(2026, 11, 5),
          revisionDoneAt: DateTime.utc(2026, 11, 6),
        ),
      ];

      final buckets = WeeklyTopicCountsCalculator.calculateWeeklyBuckets(
        topics: topics,
        weekCount: 4,
        now: now,
      );

      expect(buckets.length, 4);
      // Last bucket is the current week
      expect(buckets.last.completedCount, 2);
      // Second-to-last bucket is previous week
      expect(buckets[buckets.length - 2].completedCount, 1);
    });
  });

  group('WeeklyReviewCalculator with Topics', () {
    test(
      'buildSummary includes topics completed this week and previous week',
      () {
        final now = DateTime.utc(2026, 11, 15, 12);
        final topics = [
          Topic(
            id: 'top_curr',
            subjectId: 's1',
            title: 'Current Week Topic',
            studyDoneAt: DateTime.utc(2026, 11, 11),
            practiceDoneAt: DateTime.utc(2026, 11, 12),
            modelTestDoneAt: DateTime.utc(2026, 11, 12),
            revisionDoneAt: DateTime.utc(2026, 11, 12),
          ),
          Topic(
            id: 'top_prev',
            subjectId: 's1',
            title: 'Previous Week Topic',
            studyDoneAt: DateTime.utc(2026, 11, 5),
            practiceDoneAt: DateTime.utc(2026, 11, 5),
            modelTestDoneAt: DateTime.utc(2026, 11, 5),
            revisionDoneAt: DateTime.utc(2026, 11, 6),
          ),
        ];

        final summary = WeeklyReviewCalculator.buildSummary(
          logs: const [],
          sessions: const [],
          mockTests: const [],
          revisionItems: const [],
          circulars: const [],
          planSnapshots: const [],
          now: now,
          topics: topics,
        );

        expect(summary.topicsCompletedThisWeek, 1);
        expect(summary.topicsCompletedPreviousWeek, 1);
      },
    );
  });
}
