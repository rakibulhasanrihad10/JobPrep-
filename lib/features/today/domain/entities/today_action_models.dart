import 'package:flutter/foundation.dart' show immutable, listEquals;
import 'package:job_prep/features/circulars/domain/entities/circular.dart';
import 'package:job_prep/features/prep/domain/entities/prep_material.dart';
import 'package:job_prep/features/prep/domain/entities/revision_item.dart';
import 'package:job_prep/features/prep/domain/entities/study_plan.dart';
import 'package:job_prep/features/prep/domain/entities/study_plan_snapshot.dart';
import 'package:job_prep/features/prep/domain/entities/subject.dart';

/// Fixed priority categories evaluated in order by
/// `TodaySummaryCalculator.selectDoThisNext`:
/// 1. Circular closing within 2 days
/// 2. Overdue spaced-revision item
/// 3. Biggest remaining daily study target
enum TodayDoThisNextKind {
  circularDeadline,
  overdueRevision,
  studyTarget,
}

/// Top prioritized action displayed in the "Do this next" card.
@immutable
class TodayDoThisNextItem {
  /// Creates a [TodayDoThisNextItem].
  const TodayDoThisNextItem({
    required this.kind,
    this.circular,
    this.daysUntilDeadline,
    this.overdueRevisionCount = 0,
    this.topOverdueRevision,
    this.overdueRevisionSubject,
    this.studyTargetRow,
  });

  /// Priority category matched.
  final TodayDoThisNextKind kind;

  /// Urgent circular when [kind] is [TodayDoThisNextKind.circularDeadline].
  final Circular? circular;

  /// Calendar days remaining until [circular] deadline (`0..2`).
  final int? daysUntilDeadline;

  /// Overdue count when [kind] is [TodayDoThisNextKind.overdueRevision].
  final int overdueRevisionCount;

  /// Most overdue revision mark shown first when reviewing.
  final RevisionItem? topOverdueRevision;

  /// Subject associated with [topOverdueRevision], if resolvable.
  final Subject? overdueRevisionSubject;

  /// Largest remaining target when [kind] is [TodayDoThisNextKind.studyTarget].
  final TodayStudyTargetRow? studyTargetRow;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is TodayDoThisNextItem &&
        other.kind == kind &&
        other.circular == circular &&
        other.daysUntilDeadline == daysUntilDeadline &&
        other.overdueRevisionCount == overdueRevisionCount &&
        other.topOverdueRevision == topOverdueRevision &&
        other.overdueRevisionSubject == overdueRevisionSubject &&
        other.studyTargetRow == studyTargetRow;
  }

  @override
  int get hashCode => Object.hash(
        kind,
        circular,
        daysUntilDeadline,
        overdueRevisionCount,
        topOverdueRevision,
        overdueRevisionSubject,
        studyTargetRow,
      );
}

/// Row representing one active study plan scope for Today's study targets.
@immutable
class TodayStudyTargetRow {
  /// Creates a [TodayStudyTargetRow].
  const TodayStudyTargetRow({
    required this.planSnapshot,
    required this.isAllSubjects,
    required this.todayDoneUnits,
    required this.todayTargetUnits,
    required this.remainingTodayUnits,
    required this.progress,
    required this.scheduleStatus,
    required this.scopedMaterials,
    this.subject,
    this.defaultLogMaterial,
  });

  /// Underlying live [StudyPlanSnapshot] from Phase 6C.
  final StudyPlanSnapshot planSnapshot;

  /// Associated [Subject], or `null` for an all-subjects plan.
  final Subject? subject;

  /// True when the backing study plan spans all active subjects.
  final bool isAllSubjects;

  /// Units logged today across active materials in scope.
  final int todayDoneUnits;

  /// Calculated target quota for today (`0` if syllabus finished).
  final int todayTargetUnits;

  /// Remaining whole units needed to satisfy today's quota (`>= 0`).
  final int remainingTodayUnits;

  /// Clamped completion ratio (`0.0..1.0`) for `AnimatedProgressBar`.
  final double progress;

  /// Phase 6C pace classification (`ahead`, `onTrack`, `behind`).
  final StudyScheduleStatus scheduleStatus;

  /// Ordered non-postponed materials within this plan's scope.
  final List<PrepMaterial> scopedMaterials;

  /// Pre-selected material offered first in Quick Log or Start Timer.
  final PrepMaterial? defaultLogMaterial;

  /// Unique key slug identifying this plan row deterministically in UI & tests.
  String get slug => planSnapshot.plan.isAllSubjects
      ? 'all'
      : (planSnapshot.plan.subjectId ?? planSnapshot.plan.id);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is TodayStudyTargetRow &&
        other.planSnapshot == planSnapshot &&
        other.subject == subject &&
        other.isAllSubjects == isAllSubjects &&
        other.todayDoneUnits == todayDoneUnits &&
        other.todayTargetUnits == todayTargetUnits &&
        other.remainingTodayUnits == remainingTodayUnits &&
        other.progress == progress &&
        other.scheduleStatus == scheduleStatus &&
        listEquals(other.scopedMaterials, scopedMaterials) &&
        other.defaultLogMaterial == defaultLogMaterial;
  }

  @override
  int get hashCode => Object.hash(
        planSnapshot,
        subject,
        isAllSubjects,
        todayDoneUnits,
        todayTargetUnits,
        remainingTodayUnits,
        progress,
        scheduleStatus,
        Object.hashAll(scopedMaterials),
        defaultLogMaterial,
      );
}

/// Phase 6C missed-day redistribution or past-buffer notice surfaced on Today.
@immutable
class TodayCatchUpNotice {
  /// Creates a [TodayCatchUpNotice].
  const TodayCatchUpNotice({
    required this.planSnapshot,
    required this.missedUnits,
    required this.studyDaysLeft,
    required this.dailyCatchUpExtra,
    required this.isPastBufferOrTarget,
    required this.remainingUnits,
    this.subject,
  });

  /// Underlying snapshot generating the catch-up math.
  final StudyPlanSnapshot planSnapshot;

  /// Scoped subject if applicable (`null` for all-subjects plan).
  final Subject? subject;

  /// Unfinished units carried forward from missed days.
  final int missedUnits;

  /// Study days left to redistribute [missedUnits] across.
  final int studyDaysLeft;

  /// Additional units/day needed to absorb [missedUnits].
  final double dailyCatchUpExtra;

  /// Whether today has entered/passed the finish buffer while units remain.
  final bool isPastBufferOrTarget;

  /// Total syllabus units remaining across active materials in scope.
  final int remainingUnits;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is TodayCatchUpNotice &&
        other.planSnapshot == planSnapshot &&
        other.subject == subject &&
        other.missedUnits == missedUnits &&
        other.studyDaysLeft == studyDaysLeft &&
        other.dailyCatchUpExtra == dailyCatchUpExtra &&
        other.isPastBufferOrTarget == isPastBufferOrTarget &&
        other.remainingUnits == remainingUnits;
  }

  @override
  int get hashCode => Object.hash(
        planSnapshot,
        subject,
        missedUnits,
        studyDaysLeft,
        dailyCatchUpExtra,
        isPastBufferOrTarget,
        remainingUnits,
      );
}
