import 'package:flutter_test/flutter_test.dart';
import 'package:job_prep/features/prep/data/mappers/study_plan_mapper.dart';
import 'package:job_prep/features/prep/data/repositories/unconfigured_study_plan_repository.dart';
import 'package:job_prep/features/prep/domain/entities/prep_enums.dart';
import 'package:job_prep/features/prep/domain/entities/prep_material.dart';
import 'package:job_prep/features/prep/domain/entities/progress_log.dart';
import 'package:job_prep/features/prep/domain/entities/study_plan.dart';
import 'package:job_prep/features/prep/domain/entities/subject.dart';
import 'package:job_prep/features/prep/domain/errors/prep_failure.dart';
import 'package:job_prep/features/prep/domain/utils/study_plan_calculator.dart';

void main() {
  group('Phase 6C - StudyPlanCalculator Pure Math & Edge Cases', () {
    test('calculates remaining units for one subject and all subjects', () {
      const materials = [
        PrepMaterial(
          id: 'm1',
          subjectId: 'sub-1',
          title: 'Bangla Grammar',
          totalUnits: 300,
          completedUnits: 120,
        ),
        PrepMaterial(
          id: 'm2',
          subjectId: 'sub-1',
          title: 'Bangla Literature',
          totalUnits: 300,
        ),
        PrepMaterial(
          id: 'm3',
          subjectId: 'sub-2',
          title: 'Math',
          totalUnits: 200,
          completedUnits: 50,
        ),
      ];

      expect(
        StudyPlanCalculator.calculateRemainingUnits(
          materials,
          subjectId: 'sub-1',
        ),
        480,
      );
      expect(
        StudyPlanCalculator.calculateRemainingUnits(materials),
        630,
      );
      expect(
        StudyPlanCalculator.calculateRemainingUnits(
          materials,
          postponedMaterialIds: const {'m2'},
        ),
        330,
      );
    });

    test('600 pages remaining with 60 study days gives 10 pages a day', () {
      final today = DateTime.utc(2026, 11);
      // 67 calendar days minus default 7-day buffer = exact 60 study days.
      final targetDate = today.add(const Duration(days: 67));
      final days = StudyPlanCalculator.calculateStudyDaysLeft(
        today: today,
        targetDate: targetDate,
      );
      expect(days.calendarDaysLeft, 60);
      expect(days.studyDaysLeft, 60);

      final result = StudyPlanCalculator.calculateDailyTarget(
        remainingUnits: 600,
        studyDaysLeft: days.studyDaysLeft,
      );
      expect(result.exact, 10.0);
      expect(result.rounded, 10);
    });

    test('finished subject gives a daily target of 0', () {
      final result = StudyPlanCalculator.calculateDailyTarget(
        remainingUnits: 0,
        studyDaysLeft: 25,
      );
      expect(result.exact, 0.0);
      expect(result.rounded, 0);

      final snapshot = StudyPlanCalculator.buildSnapshot(
        plan: StudyPlan(
          id: 'p-fin',
          subjectId: 'sub-1',
          startDate: DateTime.utc(2026, 11),
          targetDate: DateTime.utc(2026, 12, 15),
        ),
        today: DateTime.utc(2026, 11, 10),
        subject: const Subject(id: 'sub-1', name: 'Bengali'),
        materials: const [
          PrepMaterial(
            id: 'm-1',
            subjectId: 'sub-1',
            title: 'Done Book',
            totalUnits: 300,
            completedUnits: 300,
          ),
        ],
        recentLogs: const [],
      );
      expect(snapshot.remainingUnits, 0);
      expect(snapshot.dailyTarget, 0);
      expect(snapshot.todayTarget, 0);
      expect(snapshot.todayProgress, 1.0);
      expect(snapshot.missedUnits, 0);
    });

    test(
      'target date in the past or inside the buffer is handled without '
      'crashing or dividing by zero',
      () {
        final today = DateTime.utc(2026, 11, 20);
        // Inside 7-day buffer (exam is 4 days away).
        final insideBufferDays = StudyPlanCalculator.calculateStudyDaysLeft(
          today: today,
          targetDate: DateTime.utc(2026, 11, 24),
        );
        expect(insideBufferDays.studyDaysLeft, 0);
        expect(insideBufferDays.isInsideBufferOrPast, isTrue);

        // Target date in the past.
        final pastDays = StudyPlanCalculator.calculateStudyDaysLeft(
          today: today,
          targetDate: DateTime.utc(2026, 11, 5),
        );
        expect(pastDays.studyDaysLeft, 0);
        expect(pastDays.calendarDaysUntilExam, 0);
        expect(pastDays.isInsideBufferOrPast, isTrue);

        final pastTarget = StudyPlanCalculator.calculateDailyTarget(
          remainingUnits: 50,
          studyDaysLeft: 0,
        );
        expect(pastTarget.exact.isFinite, isTrue);
        expect(pastTarget.exact, 50.0);
        expect(pastTarget.rounded, 50);

        final pastSnapshot = StudyPlanCalculator.buildSnapshot(
          plan: StudyPlan(
            id: 'p-past',
            startDate: DateTime.utc(2026, 10),
            targetDate: DateTime.utc(2026, 11, 5),
          ),
          today: today,
          materials: const [
            PrepMaterial(
              id: 'm-p',
              subjectId: 's-1',
              title: 'Delayed Book',
              totalUnits: 200,
              completedUnits: 120,
            ),
          ],
          recentLogs: const [],
        );
        expect(pastSnapshot.studyDaysLeft, 0);
        expect(pastSnapshot.todayTarget, 80);
        expect(pastSnapshot.scheduleStatus, StudyScheduleStatus.behind);
        expect(pastSnapshot.isPastBufferOrTarget, isTrue);
      },
    );

    test(
      'calculates study days left after subtracting buffer and weekly rest '
      'days, and falling behind raises tomorrow target',
      () {
        final daysWithRest = StudyPlanCalculator.calculateStudyDaysLeft(
          today: DateTime.utc(2026, 11),
          targetDate: DateTime.utc(2026, 11, 22), // 21 days - 7 buffer = 14
          restDaysPerWeek: 1, // 14 * 1 / 7 = 2 rest days -> 12 study days
        );
        expect(daysWithRest.calendarDaysLeft, 14);
        expect(daysWithRest.restDaysLeft, 2);
        expect(daysWithRest.studyDaysLeft, 12);

        // Day 0: 600 pages over 60 days -> 10 pages/day.
        final plan = StudyPlan(
          id: 'p-1',
          startDate: DateTime.utc(2026, 11),
          targetDate: DateTime.utc(2027, 1, 7),
        );
        const materials = [
          PrepMaterial(
            id: 'm-1',
            subjectId: 's-1',
            title: 'Core Book',
            totalUnits: 600,
          ),
        ];

        final day0 = StudyPlanCalculator.buildSnapshot(
          plan: plan,
          today: DateTime.utc(2026, 11),
          materials: materials,
          recentLogs: const [],
        );
        expect(day0.todayTarget, 10);
        expect(day0.scheduleStatus, StudyScheduleStatus.onTrack);

        // Day 1 after logging 0 pages: 600 / 59 = 10.17 -> target rises to 11.
        final day1Behind = StudyPlanCalculator.buildSnapshot(
          plan: plan,
          today: DateTime.utc(2026, 11, 2),
          materials: materials,
          recentLogs: const [],
        );
        expect(day1Behind.exactDailyTarget, closeTo(600 / 59, 1e-6));
        expect(day1Behind.todayTarget, 11);
        expect(day1Behind.scheduleStatus, StudyScheduleStatus.behind);
      },
    );

    test(
      'computes ahead, on track, and behind schedule statuses accurately',
      () {
        final start = DateTime.utc(2026, 11);
        final target = DateTime.utc(2026, 12, 8); // 37d - 7 = 30 study days
        final today = DateTime.utc(2026, 11, 6); // 5 days elapsed -> ideal 50
        final plan = StudyPlan(id: 'p-s', startDate: start, targetDate: target);

        final behind = StudyPlanCalculator.buildSnapshot(
          plan: plan,
          today: today,
          materials: const [
            PrepMaterial(
              id: 'm1',
              subjectId: 's1',
              title: 'B1',
              totalUnits: 300,
              completedUnits: 40,
            ),
          ],
          recentLogs: const [],
        );
        expect(behind.scheduleStatus, StudyScheduleStatus.behind);

        final onTrack = StudyPlanCalculator.buildSnapshot(
          plan: plan,
          today: today,
          materials: const [
            PrepMaterial(
              id: 'm1',
              subjectId: 's1',
              title: 'B1',
              totalUnits: 300,
              completedUnits: 50,
            ),
          ],
          recentLogs: const [],
        );
        expect(onTrack.scheduleStatus, StudyScheduleStatus.onTrack);

        final ahead = StudyPlanCalculator.buildSnapshot(
          plan: plan,
          today: today,
          materials: const [
            PrepMaterial(
              id: 'm1',
              subjectId: 's1',
              title: 'B1',
              totalUnits: 300,
              completedUnits: 70,
            ),
          ],
          recentLogs: const [],
        );
        expect(ahead.scheduleStatus, StudyScheduleStatus.ahead);
      },
    );
  });

  group('Phase 6C - Automatic Missed-Day Redistribution & Pace Limits', () {
    test('one missed day spreads shortfall evenly across remaining days', () {
      // Total 300 over 30 study days -> 10/day.
      // After 5 study days (25 left): 40 completed => 10 missed -> +0.4/day!
      final plan = StudyPlan(
        id: 'p-miss1',
        startDate: DateTime.utc(2026, 11),
        targetDate: DateTime.utc(2026, 12, 8), // buffer 7 => finish Dec 1
      );
      final snapshot = StudyPlanCalculator.buildSnapshot(
        plan: plan,
        today: DateTime.utc(2026, 11, 6), // 25 days left
        materials: const [
          PrepMaterial(
            id: 'm1',
            subjectId: 's1',
            title: 'Book',
            totalUnits: 300,
            completedUnits: 40,
          ),
        ],
        recentLogs: const [],
      );

      expect(snapshot.studyDaysLeft, 25);
      expect(snapshot.missedUnits, 10);
      expect(snapshot.dailyCatchUpExtra, closeTo(0.4, 1e-6));
      expect(snapshot.exactDailyTarget, closeTo(10.4, 1e-6));
      expect(snapshot.todayTarget, 11);
      expect(snapshot.scheduleStatus, StudyScheduleStatus.behind);
    });

    test('several missed days redistribute across remaining days cleanly', () {
      final plan = StudyPlan(
        id: 'p-miss-many',
        startDate: DateTime.utc(2026, 11),
        targetDate: DateTime.utc(2026, 12, 8), // 30 total study days
      );
      // 10 days elapsed, 0 completed -> missed 100 units across 20 left (+5/day).
      final snapshot = StudyPlanCalculator.buildSnapshot(
        plan: plan,
        today: DateTime.utc(2026, 11, 11),
        materials: const [
          PrepMaterial(
            id: 'm1',
            subjectId: 's1',
            title: 'Book',
            totalUnits: 300,
          ),
        ],
        recentLogs: const [],
      );

      expect(snapshot.studyDaysLeft, 20);
      expect(snapshot.missedUnits, 100);
      expect(snapshot.dailyCatchUpExtra, closeTo(5.0, 1e-6));
      expect(snapshot.exactDailyTarget, closeTo(15.0, 1e-6));
      expect(snapshot.todayTarget, 15);
    });

    test(
      'missed day with only one study day left puts full remainder today',
      () {
        final plan = StudyPlan(
          id: 'p-last-day',
          startDate: DateTime.utc(2026, 11),
          targetDate: DateTime.utc(2026, 11, 18), // finish Nov 11 (10 days)
        );
        // Nov 10 => 1 study day left (Nov 10 -> Nov 11), elapsed 9, ideal 90.
        // Only 80 completed -> missed 10, remaining 20 on last 1 study day!
        final snapshot = StudyPlanCalculator.buildSnapshot(
          plan: plan,
          today: DateTime.utc(2026, 11, 10),
          materials: const [
            PrepMaterial(
              id: 'm1',
              subjectId: 's1',
              title: 'Book',
              totalUnits: 100,
              completedUnits: 80,
            ),
          ],
          recentLogs: const [],
        );

        expect(snapshot.studyDaysLeft, 1);
        expect(snapshot.missedUnits, 10);
        expect(snapshot.dailyCatchUpExtra, closeTo(10.0, 1e-6));
        expect(snapshot.exactDailyTarget, 20.0);
        expect(snapshot.todayTarget, 20);
      },
    );

    test(
      'flags target above pace limit without hiding the realistic target',
      () {
        final plan = StudyPlan(
          id: 'p-cap',
          startDate: DateTime.utc(2026, 11),
          targetDate: DateTime.utc(2026, 11, 29), // finish Nov 22 -> 21d
          restDaysPerWeek: 2,
          maxDailyPace: 15,
        );
        // Remaining 300 over 15 study days (21 - 6 rest = 15) -> 20/day > 15 cap!
        final snapshot = StudyPlanCalculator.buildSnapshot(
          plan: plan,
          today: DateTime.utc(2026, 11),
          materials: const [
            PrepMaterial(
              id: 'm1',
              subjectId: 's1',
              title: 'Core Textbook',
              totalUnits: 200,
            ),
            PrepMaterial(
              id: 'm2',
              subjectId: 's1',
              title: 'Optional Notes',
              kind: MaterialKind.notes,
              totalUnits: 100,
            ),
          ],
          recentLogs: const [],
        );

        expect(snapshot.todayTarget, 20);
        expect(snapshot.isOverPaceLimit, isTrue);
        expect(snapshot.hasConvertibleRestDays, isTrue);
        expect(snapshot.postponableMaterials.first.id, 'm2');

        // Converting a rest day adds +1 study day and lowers exact daily pace.
        final converted = StudyPlanCalculator.buildSnapshot(
          plan: plan.copyWith(extraStudyDays: 1),
          today: DateTime.utc(2026, 11),
          materials: snapshot.postponableMaterials,
          recentLogs: const [],
        );
        expect(converted.studyDaysLeft, 16);
        expect(converted.exactDailyTarget, closeTo(300 / 16, 1e-6));

        // Postponing lower-priority material lowers target below the 15 cap.
        final postponed = StudyPlanCalculator.buildSnapshot(
          plan: plan.copyWith(postponedMaterialIds: const ['m2']),
          today: DateTime.utc(2026, 11),
          materials: snapshot.postponableMaterials,
          recentLogs: const [],
        );
        expect(postponed.remainingUnits, 200);
        expect(postponed.todayTarget, 14);
        expect(postponed.isOverPaceLimit, isFalse);
      },
    );

    test('catching up early lowers the following days targets', () {
      final plan = StudyPlan(
        id: 'p-catchup',
        startDate: DateTime.utc(2026, 11),
        targetDate: DateTime.utc(2026, 12, 8), // finish Dec 1 -> 30d
      );
      final today = DateTime.utc(2026, 11, 6); // 25 days left

      // User starts Nov 6 behind by 10 pages (40 completed, 260 left -> 11/day).
      final morning = StudyPlanCalculator.buildSnapshot(
        plan: plan,
        today: today,
        materials: const [
          PrepMaterial(
            id: 'm1',
            subjectId: 's1',
            title: 'Book',
            totalUnits: 300,
            completedUnits: 40,
          ),
        ],
        recentLogs: const [],
      );
      expect(morning.todayTarget, 11);
      expect(morning.missedUnits, 10);

      // User completes 50 pages today (total 90 done, 210 remaining)!
      final afterStudy = StudyPlanCalculator.buildSnapshot(
        plan: plan,
        today: today,
        materials: const [
          PrepMaterial(
            id: 'm1',
            subjectId: 's1',
            title: 'Book',
            totalUnits: 300,
            completedUnits: 90,
          ),
        ],
        recentLogs: [
          ProgressLog(
            id: 'l1',
            materialId: 'm1',
            unitsDone: 50,
            loggedOn: today,
          ),
        ],
      );
      expect(afterStudy.missedUnits, 0);
      expect(afterStudy.todayCompletedUnits, 50);
      expect(afterStudy.todayProgress, 1.0);
      expect(afterStudy.scheduleStatus, StudyScheduleStatus.ahead);

      // Next day (Nov 7, 24 study days left): 210 / 24 = 8.75 -> 9/day (< 11)!
      final tomorrow = StudyPlanCalculator.buildSnapshot(
        plan: plan,
        today: DateTime.utc(2026, 11, 7),
        materials: const [
          PrepMaterial(
            id: 'm1',
            subjectId: 's1',
            title: 'Book',
            totalUnits: 300,
            completedUnits: 90,
          ),
        ],
        recentLogs: [
          ProgressLog(
            id: 'l1',
            materialId: 'm1',
            unitsDone: 50,
            loggedOn: today,
          ),
        ],
      );
      expect(tomorrow.todayTarget, 9);
      expect(tomorrow.scheduleStatus, StudyScheduleStatus.ahead);
    });
  });

  group('Phase 6C - StudyPlanMapper & Unconfigured Repository', () {
    test('StudyPlanMapper round-trips full JSON payload accurately', () {
      final json = <String, dynamic>{
        'id': 'plan-1',
        'user_id': 'u-1',
        'subject_id': 'sub-1',
        'circular_id': 'circ-1',
        'exam_date_id': 'exam-1',
        'start_date': '2026-11-01',
        'target_date': '2026-12-20',
        'finish_buffer_days': 7,
        'rest_days_per_week': 1,
        'extra_study_days': 2,
        'max_daily_pace': 30,
        'initial_completed_units': 15,
        'postponed_material_ids': ['mat-9'],
        'created_at': '2026-11-01T08:00:00Z',
        'updated_at': '2026-11-02T09:00:00Z',
      };
      final parsed = StudyPlanMapper.fromJson(json);
      expect(parsed.id, 'plan-1');
      expect(parsed.subjectId, 'sub-1');
      expect(parsed.circularId, 'circ-1');
      expect(parsed.examDateId, 'exam-1');
      expect(parsed.finishBufferDays, 7);
      expect(parsed.restDaysPerWeek, 1);
      expect(parsed.extraStudyDays, 2);
      expect(parsed.maxDailyPace, 30);
      expect(parsed.initialCompletedUnits, 15);
      expect(parsed.postponedMaterialIds, ['mat-9']);

      final insertPayload = StudyPlanMapper.toInsertJson(parsed, userId: 'u-1');
      expect(insertPayload['user_id'], 'u-1');
      expect(insertPayload['start_date'], '2026-11-01');
      expect(insertPayload['target_date'], '2026-12-20');
      expect(insertPayload['postponed_material_ids'], ['mat-9']);
    });

    test(
      'UnconfiguredStudyPlanRepository returns empty list and rejects writes',
      () async {
        const repo = UnconfiguredStudyPlanRepository();
        expect(await repo.getPlans(), isEmpty);
        await expectLater(
          () => repo.savePlan(
            StudyPlan(
              startDate: DateTime.utc(2026, 11),
              targetDate: DateTime.utc(2026, 12),
            ),
          ),
          throwsA(isA<UnknownPrepFailure>()),
        );
        await expectLater(
          () => repo.deletePlan('plan-1'),
          throwsA(isA<UnknownPrepFailure>()),
        );
      },
    );
  });
}
