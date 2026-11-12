import 'package:flutter/foundation.dart' show immutable, listEquals;
import 'package:job_prep/features/circulars/domain/entities/circular.dart';
import 'package:job_prep/features/circulars/domain/entities/circular_exam_date.dart';
import 'package:job_prep/features/prep/domain/entities/prep_material.dart';
import 'package:job_prep/features/prep/domain/entities/study_plan.dart';
import 'package:job_prep/features/prep/domain/entities/subject.dart';

/// Calculated snapshot pairing a [StudyPlan] with live unit counts, daily
/// targets, catch-up metrics, schedule status, and pace warnings.
@immutable
class StudyPlanSnapshot {
  /// Creates a [StudyPlanSnapshot].
  const StudyPlanSnapshot({
    required this.plan,
    required this.totalUnits,
    required this.completedUnits,
    required this.remainingUnits,
    required this.todayCompletedUnits,
    required this.calendarDaysUntilExam,
    required this.calendarDaysLeft,
    required this.restDaysLeft,
    required this.studyDaysLeft,
    required this.exactDailyTarget,
    required this.dailyTarget,
    required this.todayExactTarget,
    required this.todayTarget,
    required this.todayProgress,
    required this.scheduleStatus,
    required this.baselineDailyPace,
    required this.idealCompletedBeforeToday,
    required this.missedUnits,
    required this.dailyCatchUpExtra,
    required this.isPastBufferOrTarget,
    required this.isOverPaceLimit,
    required this.hasConvertibleRestDays,
    required this.postponableMaterials,
    required this.postponedMaterials,
    this.subject,
    this.linkedCircular,
    this.linkedExamDate,
  });

  /// Underlying persisted [StudyPlan].
  final StudyPlan plan;

  /// Matching [Subject] when scoped to one subject, else `null` for combined.
  final Subject? subject;

  /// Linked [Circular] when `plan.circularId` resolves in the user's list.
  final Circular? linkedCircular;

  /// Linked [CircularExamDate] when `plan.examDateId` resolves cleanly.
  final CircularExamDate? linkedExamDate;

  /// Total planned units across active (non-postponed) materials.
  final int totalUnits;

  /// Clamped completed units across active materials.
  final int completedUnits;

  /// Remaining units across active materials (`>= 0`).
  final int remainingUnits;

  /// Units logged today across active materials.
  final int todayCompletedUnits;

  /// Whole calendar days remaining from today until `plan.targetDate`.
  final int calendarDaysUntilExam;

  /// Calendar days remaining until buffer finish date (`targetDate - buffer`).
  final int calendarDaysLeft;

  /// Remaining rest days after subtracting converted extra study days.
  final int restDaysLeft;

  /// Effective study days remaining before the finish buffer (`>= 0`).
  final int studyDaysLeft;

  /// Unrounded daily target from current `remainingUnits / studyDaysLeft`.
  final double exactDailyTarget;

  /// Whole-unit rounded daily target (`ceil(exactDailyTarget)`).
  final int dailyTarget;

  /// Exact today's quota including units logged earlier today (`0` finished).
  final double todayExactTarget;

  /// Rounded whole-unit target shown for today (`0` when syllabus is done).
  final int todayTarget;

  /// Clamped progress ratio (`0.0..1.0`) for today's target ring.
  final double todayProgress;

  /// Comparison against the ideal progress line from `startDate`.
  final StudyScheduleStatus scheduleStatus;

  /// Initial baseline daily pace across total plan study days.
  final double baselineDailyPace;

  /// Ideal cumulative units expected prior to today.
  final double idealCompletedBeforeToday;

  /// Unfinished units from missed past study days currently needing catch-up.
  final int missedUnits;

  /// Extra units per day added across `studyDaysLeft` due to [missedUnits].
  final double dailyCatchUpExtra;

  /// True when today is on/after the finish buffer date with units still left.
  final bool isPastBufferOrTarget;

  /// True when `plan.maxDailyPace` is set and recalculated target exceeds it.
  final bool isOverPaceLimit;

  /// True when at least one scheduled rest day can become a study day.
  final bool hasConvertibleRestDays;

  /// Unfinished active materials sorted lowest priority / least progress first.
  final List<PrepMaterial> postponableMaterials;

  /// Materials currently postponed for this plan.
  final List<PrepMaterial> postponedMaterials;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is StudyPlanSnapshot &&
        other.plan == plan &&
        other.subject == subject &&
        other.linkedCircular == linkedCircular &&
        other.linkedExamDate == linkedExamDate &&
        other.totalUnits == totalUnits &&
        other.completedUnits == completedUnits &&
        other.remainingUnits == remainingUnits &&
        other.todayCompletedUnits == todayCompletedUnits &&
        other.calendarDaysUntilExam == calendarDaysUntilExam &&
        other.calendarDaysLeft == calendarDaysLeft &&
        other.restDaysLeft == restDaysLeft &&
        other.studyDaysLeft == studyDaysLeft &&
        other.exactDailyTarget == exactDailyTarget &&
        other.dailyTarget == dailyTarget &&
        other.todayExactTarget == todayExactTarget &&
        other.todayTarget == todayTarget &&
        other.todayProgress == todayProgress &&
        other.scheduleStatus == scheduleStatus &&
        other.baselineDailyPace == baselineDailyPace &&
        other.idealCompletedBeforeToday == idealCompletedBeforeToday &&
        other.missedUnits == missedUnits &&
        other.dailyCatchUpExtra == dailyCatchUpExtra &&
        other.isPastBufferOrTarget == isPastBufferOrTarget &&
        other.isOverPaceLimit == isOverPaceLimit &&
        other.hasConvertibleRestDays == hasConvertibleRestDays &&
        listEquals(other.postponableMaterials, postponableMaterials) &&
        listEquals(other.postponedMaterials, postponedMaterials);
  }

  @override
  int get hashCode => Object.hashAll(<Object?>[
        plan,
        subject,
        linkedCircular,
        linkedExamDate,
        totalUnits,
        completedUnits,
        remainingUnits,
        todayCompletedUnits,
        calendarDaysUntilExam,
        calendarDaysLeft,
        restDaysLeft,
        studyDaysLeft,
        exactDailyTarget,
        dailyTarget,
        todayExactTarget,
        todayTarget,
        todayProgress,
        scheduleStatus,
        baselineDailyPace,
        idealCompletedBeforeToday,
        missedUnits,
        dailyCatchUpExtra,
        isPastBufferOrTarget,
        isOverPaceLimit,
        hasConvertibleRestDays,
        Object.hashAll(postponableMaterials),
        Object.hashAll(postponedMaterials),
      ]);
}
