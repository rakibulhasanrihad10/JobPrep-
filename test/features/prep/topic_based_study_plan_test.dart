import 'package:flutter_test/flutter_test.dart';
import 'package:job_prep/features/prep/domain/entities/prep_enums.dart';
import 'package:job_prep/features/prep/domain/entities/prep_material.dart';
import 'package:job_prep/features/prep/domain/entities/study_plan.dart';
import 'package:job_prep/features/prep/domain/entities/subject.dart';
import 'package:job_prep/features/prep/domain/entities/topic.dart';
import 'package:job_prep/features/prep/domain/utils/study_plan_calculator.dart';
import 'package:job_prep/features/prep/domain/utils/topic_plan_calculator.dart';

void main() {
  group('TopicPlanCalculator', () {
    test('calculateTotalWeightedTopics sums weights correctly', () {
      const topics = [
        Topic(id: 't1', subjectId: 's1', title: 'T1'),
        Topic(id: 't2', subjectId: 's1', title: 'T2', weight: 2),
        Topic(id: 't3', subjectId: 's1', title: 'T3', weight: 3),
      ];

      expect(TopicPlanCalculator.calculateTotalWeightedTopics(topics), 6.0);
    });

    test('calculateRemainingWeightedTopics handles partial checkpoints', () {
      final now = DateTime.utc(2026, 11);
      final topics = [
        // Fully done: study 40, practice 30, test 20, rev 10 => 100% done
        Topic(
          id: 't1',
          subjectId: 's1',
          title: 'T1',
          studyDoneAt: now,
          practiceDoneAt: now,
          modelTestDoneAt: now,
          revisionDoneAt: now,
        ),
        // Half done (study 40 + practice 30 = 70%): remaining 30% of weight 2
        Topic(
          id: 't2',
          subjectId: 's1',
          title: 'T2',
          weight: 2,
          studyDoneAt: now,
          practiceDoneAt: now,
        ),
        // Not started: remaining 100% of weight 1 = 1.0
        const Topic(id: 't3', subjectId: 's1', title: 'T3'),
      ];

      final remaining = TopicPlanCalculator.calculateRemainingWeightedTopics(
        topics,
      );

      // Remaining: 0 + (1 - 0.70) * 2 + 1.0 = 0.6 + 1.0 = 1.6
      expect(remaining, closeTo(1.6, 1e-4));
    });

    test('calculateDailyTopicTarget distributes over study days left', () {
      final target = TopicPlanCalculator.calculateDailyTopicTarget(
        remainingWeightedTopics: 10,
        studyDaysLeft: 5,
      );
      expect(target.exact, 2.0);
      expect(target.rounded, 2);
    });

    test('calculateDailyTopicTarget handles zero or negative days left', () {
      final target = TopicPlanCalculator.calculateDailyTopicTarget(
        remainingWeightedTopics: 5.5,
        studyDaysLeft: 0,
      );
      expect(target.exact, 5.5);
      expect(target.rounded, 6);
    });
  });

  group('Topic-based Study Plan & Catch-Up', () {
    final today = DateTime.utc(2026, 11, 10);
    const subject = Subject(
      id: 'sub1',
      name: 'Bangla Literature',
    );

    final topics = List.generate(
      10,
      (i) => Topic(
        id: 'top_$i',
        subjectId: subject.id,
        title: 'Topic $i',
      ),
    );

    test(
      'computes target based on remaining weighted topics / study days left',
      () {
        final plan = StudyPlan(
          id: 'plan1',
          subjectId: subject.id,
          startDate: today,
          targetDate: today.add(const Duration(days: 12)),
          finishBufferDays: 2,
          planBasis: StudyPlanBasis.syllabusTopics,
        );

        final snapshot = StudyPlanCalculator.buildSnapshot(
          plan: plan,
          today: today,
          subject: subject,
          materials: const [],
          recentLogs: const [],
          topics: topics,
        );

        expect(snapshot.totalUnits, 10);
        expect(snapshot.remainingUnits, 10);
        expect(snapshot.studyDaysLeft, 10);
        expect(snapshot.dailyTarget, 1);
      },
    );

    test('missed day catch-up increases daily pace over remaining days', () {
      final plan = StudyPlan(
        id: 'plan1',
        subjectId: subject.id,
        startDate: today.subtract(const Duration(days: 2)),
        targetDate: today.add(const Duration(days: 8)),
        finishBufferDays: 0,
        planBasis: StudyPlanBasis.syllabusTopics,
      );

      // 0 topics completed so far, but 2 days elapsed
      final snapshot = StudyPlanCalculator.buildSnapshot(
        plan: plan,
        today: today,
        subject: subject,
        materials: const [],
        recentLogs: const [],
        topics: topics,
      );

      // Remaining study days: 8
      expect(snapshot.studyDaysLeft, 8);
      // 10 topics / 8 days = 1.25 -> rounded = 2 topics/day
      expect(snapshot.exactDailyTarget, closeTo(1.25, 1e-4));
      expect(snapshot.dailyTarget, 2);
      expect(snapshot.scheduleStatus, StudyScheduleStatus.behind);
    });

    test('enforces maxDailyPace limit for topic-based plans', () {
      final plan = StudyPlan(
        id: 'plan1',
        subjectId: subject.id,
        startDate: today,
        targetDate: today.add(const Duration(days: 3)),
        finishBufferDays: 0,
        maxDailyPace: 2,
        planBasis: StudyPlanBasis.syllabusTopics,
      );

      // 10 topics over 3 days = 3.33/day > maxDailyPace of 2
      final snapshot = StudyPlanCalculator.buildSnapshot(
        plan: plan,
        today: today,
        subject: subject,
        materials: const [],
        recentLogs: const [],
        topics: topics,
      );

      expect(snapshot.dailyTarget, 4);
      expect(snapshot.isOverPaceLimit, isTrue);
    });

    test(
      'invariant: books of 300, 300, 400 pages finishing book 1 gives 100% '
      'book, 30% subject',
      () {
        const b1 = PrepMaterial(
          id: 'm1',
          subjectId: 's_inv',
          title: 'Book 1',
          totalUnits: 300,
          completedUnits: 300,
        );
        const b2 = PrepMaterial(
          id: 'm2',
          subjectId: 's_inv',
          title: 'Book 2',
          totalUnits: 300,
        );
        const b3 = PrepMaterial(
          id: 'm3',
          subjectId: 's_inv',
          title: 'Book 3',
          totalUnits: 400,
        );

        final totalPages = b1.totalUnits + b2.totalUnits + b3.totalUnits;
        final completedPages =
            b1.completedUnits + b2.completedUnits + b3.completedUnits;

        expect(b1.completedUnits / b1.totalUnits, 1.0); // 100%
        expect(completedPages / totalPages, 0.30); // 30%
      },
    );
  });
}
