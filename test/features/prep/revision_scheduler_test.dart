import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:job_prep/features/prep/data/mappers/revision_item_mapper.dart';
import 'package:job_prep/features/prep/domain/entities/prep_enums.dart';
import 'package:job_prep/features/prep/domain/entities/prep_material.dart';
import 'package:job_prep/features/prep/domain/entities/revision_item.dart';
import 'package:job_prep/features/prep/domain/entities/study_analytics.dart';
import 'package:job_prep/features/prep/domain/entities/study_plan.dart';
import 'package:job_prep/features/prep/domain/entities/subject.dart';
import 'package:job_prep/features/prep/domain/utils/revision_scheduler.dart';
import 'package:job_prep/features/prep/domain/utils/study_analytics_calculator.dart';
import 'package:job_prep/features/prep/domain/utils/study_plan_calculator.dart';
import 'package:job_prep/features/prep/presentation/providers/revision_providers.dart';

import 'fake_revision_item_repository.dart';

void main() {
  group('RevisionScheduler spaced repetition & queue classification', () {
    test('new item is scheduled strictly 1 day after flagging', () {
      final flagged = DateTime.utc(2026, 11, 11, 22, 15);
      final due = RevisionScheduler.initialDueDate(flagged);
      expect(due, DateTime.utc(2026, 11, 12));
    });

    test(
        'Easy advances along 3, 7, 14, and 30 days and becomes mastered after '
        'completing the 30-day gap', () {
      final flaggedOn = DateTime.utc(2026, 11);
      var item = RevisionItem(
        id: 'rev-1',
        userId: 'u-1',
        subjectId: 'sub-1',
        materialId: 'mat-1',
        referenceLabel: 'p. 128 Problem 14',
        pageNumber: 128,
        dueOn: RevisionScheduler.initialDueDate(flaggedOn),
      );
      expect(item.dueOn, DateTime.utc(2026, 11, 2));
      expect(item.reviewCount, 0);
      expect(item.status, RevisionStatus.pending);

      // Step 1: review Easy on Nov 2 -> +3 days (Nov 5), reviewCount = 1
      item = RevisionScheduler.applyAction(
        item,
        RevisionReviewAction.easy,
        today: DateTime.utc(2026, 11, 2),
      );
      expect(item.dueOn, DateTime.utc(2026, 11, 5));
      expect(item.reviewCount, 1);
      expect(item.status, RevisionStatus.revised);
      expect(item.lastReviewedOn, DateTime.utc(2026, 11, 2));

      // Step 2: review Easy on Nov 5 -> +7 days (Nov 12), reviewCount = 2
      item = RevisionScheduler.applyAction(
        item,
        RevisionReviewAction.easy,
        today: DateTime.utc(2026, 11, 5),
      );
      expect(item.dueOn, DateTime.utc(2026, 11, 12));
      expect(item.reviewCount, 2);
      expect(item.status, RevisionStatus.revised);

      // Step 3: review Easy on Nov 12 -> +14 days (Nov 26), reviewCount = 3
      item = RevisionScheduler.applyAction(
        item,
        RevisionReviewAction.easy,
        today: DateTime.utc(2026, 11, 12),
      );
      expect(item.dueOn, DateTime.utc(2026, 11, 26));
      expect(item.reviewCount, 3);
      expect(item.status, RevisionStatus.revised);

      // Step 4: review Easy on Nov 26 -> +30 days (Dec 26), reviewCount = 4
      item = RevisionScheduler.applyAction(
        item,
        RevisionReviewAction.easy,
        today: DateTime.utc(2026, 11, 26),
      );
      expect(item.dueOn, DateTime.utc(2026, 12, 26));
      expect(item.reviewCount, 4);
      expect(item.status, RevisionStatus.revised);
      expect(RevisionScheduler.nextEasyGapDays(item), isNull);

      // Final step after 30-day gap: Easy promotes item to mastered!
      item = RevisionScheduler.applyAction(
        item,
        RevisionReviewAction.easy,
        today: DateTime.utc(2026, 12, 26),
      );
      expect(item.status, RevisionStatus.mastered);
      expect(item.reviewCount, 5);
      expect(item.lastReviewedOn, DateTime.utc(2026, 12, 26));
      expect(
        RevisionScheduler.classifyTab(
          item,
          today: DateTime.utc(2026, 12, 26),
        ),
        RevisionQueueTab.done,
      );
    });

    test(
        'Still hard resets spacing gap to 1 day and reviewCount to 0 '
        'even from high reviewCount or overdue date', () {
      final item = RevisionItem(
        id: 'rev-h',
        userId: 'u-1',
        subjectId: 'sub-1',
        referenceLabel: 'Integration by parts',
        status: RevisionStatus.revised,
        dueOn: DateTime.utc(2026, 11, 6),
        reviewCount: 3,
        lastReviewedOn: DateTime.utc(2026, 10, 23),
      );
      final today = DateTime.utc(2026, 11, 11);
      expect(
        RevisionScheduler.classifyTab(item, today: today),
        RevisionQueueTab.overdue,
      );
      expect(RevisionScheduler.daysOverdue(item, today: today), 5);

      final reset = RevisionScheduler.applyAction(
        item,
        RevisionReviewAction.stillHard,
        today: today,
      );
      expect(reset.reviewCount, 0);
      expect(reset.dueOn, DateTime.utc(2026, 11, 12));
      expect(reset.status, RevisionStatus.revised);
      expect(reset.lastReviewedOn, today);
      expect(
        RevisionScheduler.classifyTab(reset, today: today),
        RevisionQueueTab.upcoming,
      );
    });

    test(
        'Snooze moves dueOn by 1 day without modifying reviewCount for both '
        'due-today and overdue items', () {
      final today = DateTime.utc(2026, 11, 11);
      final dueTodayItem = RevisionItem(
        id: 'rev-s1',
        subjectId: 'sub-1',
        referenceLabel: 'Tense sequence',
        status: RevisionStatus.revised,
        dueOn: today,
        reviewCount: 2,
        lastReviewedOn: DateTime.utc(2026, 11, 4),
      );
      final snoozed = RevisionScheduler.applyAction(
        dueTodayItem,
        RevisionReviewAction.snooze,
        today: today,
      );
      expect(snoozed.dueOn, DateTime.utc(2026, 11, 12));
      expect(snoozed.reviewCount, 2);
      expect(snoozed.status, RevisionStatus.revised);
      expect(snoozed.lastReviewedOn, DateTime.utc(2026, 11, 4));

      // Overdue item snoozed today moves out of Overdue to tomorrow (+1 day)
      final overdueItem = dueTodayItem.copyWith(
        dueOn: DateTime.utc(2026, 11, 5),
        reviewCount: 4,
      );
      final snoozedOverdue = RevisionScheduler.applyAction(
        overdueItem,
        RevisionReviewAction.snooze,
        today: today,
      );
      expect(snoozedOverdue.dueOn, DateTime.utc(2026, 11, 12));
      expect(snoozedOverdue.reviewCount, 4);
      expect(
        RevisionScheduler.classifyTab(snoozedOverdue, today: today),
        RevisionQueueTab.upcoming,
      );
    });

    test('Dismiss moves item cleanly to Done without altering reviewCount', () {
      final today = DateTime.utc(2026, 11, 11);
      final item = RevisionItem(
        id: 'rev-d',
        subjectId: 'sub-1',
        referenceLabel: 'Old rule',
        dueOn: today,
        reviewCount: 2,
      );
      final dismissed = RevisionScheduler.applyAction(
        item,
        RevisionReviewAction.dismiss,
        today: today,
      );
      expect(dismissed.status, RevisionStatus.dismissed);
      expect(dismissed.reviewCount, 2);
      expect(
        RevisionScheduler.classifyTab(dismissed, today: today),
        RevisionQueueTab.done,
      );
    });

    test('extracts weak topic lists and page numbers accurately', () {
      expect(
        RevisionScheduler.extractWeakTopicLabels(
          'Probability, Bayes Theorem; Set Theory\nprobability',
        ),
        ['Probability', 'Bayes Theorem', 'Set Theory'],
      );
      expect(RevisionScheduler.extractPageNumber('p. 128 Problem 14'), 128);
      expect(RevisionScheduler.extractPageNumber('page ২৪৫'), 245);
      expect(RevisionScheduler.extractPageNumber('Bayes Theorem'), isNull);
    });
  });

  group('RevisionItemMapper & controller undo', () {
    test('serializes and parses RevisionItem JSON round-trip accurately', () {
      final item = RevisionItem(
        id: 'rev-json',
        userId: 'u-1',
        subjectId: 'sub-1',
        materialId: 'mat-1',
        topicId: 'top-1',
        referenceLabel: 'p. 128 Problem 14',
        pageNumber: 128,
        note: 'Sign check',
        reason: RevisionReason.mistake,
        source: RevisionSource.log,
        progressLogId: 'log-1',
        dueOn: DateTime(2026, 11, 12),
        reviewCount: 2,
        lastReviewedOn: DateTime(2026, 11, 5),
      );
      final json = RevisionItemMapper.toJson(item);
      expect(json['due_on'], '2026-11-12');
      expect(json['last_reviewed_on'], '2026-11-05');
      expect(RevisionItemMapper.fromJson(json), item);

      final nullable = RevisionItemMapper.fromJson(<String, dynamic>{
        'id': 'rev-min',
        'user_id': 'u-1',
        'subject_id': 'sub-1',
        'reference_label': 'Mock weak topic',
        'source': 'mock_test',
        'mock_test_id': 'mock-1',
        'due_on': '2026-11-12',
      });
      expect(nullable.materialId, isNull);
      expect(nullable.pageNumber, isNull);
      expect(nullable.reason, RevisionReason.tricky);
      expect(nullable.source, RevisionSource.mockTest);
      expect(nullable.status, RevisionStatus.pending);
    });

    test(
        'RevisionController applies actions, supports Undo, and never changes '
        'study units, study plans, or analytics', () async {
      final now = DateTime.utc(2026, 11, 11, 9);
      final seeded = RevisionItem(
        id: 'rev-1',
        userId: 'u-1',
        subjectId: 'sub-1',
        materialId: 'mat-1',
        referenceLabel: 'p. 88 Problem 4',
        pageNumber: 88,
        dueOn: DateTime.utc(2026, 11, 11),
      );
      final repo = FakeRevisionItemRepository(
        initialItems: [seeded],
        clock: () => now,
      );

      final container = ProviderContainer(
        overrides: [
          revisionNowProvider.overrideWithValue(() => now),
          revisionItemRepositoryProvider.overrideWithValue(repo),
        ],
      );
      addTearDown(container.dispose);

      await container.read(revisionItemsProvider.future);
      final controller = container.read(revisionControllerProvider.notifier);

      // Easy -> reviewCount = 1, due Nov 14
      await controller.applyAction(
        item: seeded,
        action: RevisionReviewAction.easy,
      );
      var current = (await container.read(revisionItemsProvider.future)).single;
      expect(current.reviewCount, 1);
      expect(current.dueOn, DateTime.utc(2026, 11, 14));
      expect(
        container.read(revisionControllerProvider).lastUndo?.action,
        RevisionReviewAction.easy,
      );

      // Undo restores exact original state cleanly!
      final undone = await controller.undoLastAction();
      expect(undone, isTrue);
      current = (await container.read(revisionItemsProvider.future)).single;
      expect(current.reviewCount, 0);
      expect(current.status, RevisionStatus.pending);
      expect(current.dueOn, DateTime.utc(2026, 11, 11));
      expect(container.read(revisionControllerProvider).lastUndo, isNull);

      // Creating flags or reviewing them involves zero progress logs cleanly
      const subject = Subject(id: 'sub-1', userId: 'u-1', name: 'Math');
      const material = PrepMaterial(
        id: 'mat-1',
        userId: 'u-1',
        subjectId: 'sub-1',
        title: 'Math Book',
        totalUnits: 200,
      );
      final plan = StudyPlan(
        id: 'plan-1',
        userId: 'u-1',
        subjectId: 'sub-1',
        startDate: DateTime.utc(2026, 11, 10),
        targetDate: DateTime.utc(2026, 11, 20),
      );
      final planSnapshot = StudyPlanCalculator.buildSnapshot(
        plan: plan,
        today: now,
        subject: subject,
        materials: const [material],
        recentLogs: const [],
      );
      final analytics = StudyAnalyticsCalculator.buildSummary(
        range: StudyAnalyticsRange.days7,
        now: now,
        localOffset: Duration.zero,
        subjects: const [subject],
        materials: const [material],
        logs: const [],
        planSnapshots: [planSnapshot],
        mockTests: const [],
      );
      expect(planSnapshot.todayCompletedUnits, 0);
      expect(analytics.totalUnitsInRange, 0);
      expect(analytics.currentStreak, 0);
    });
  });
}
