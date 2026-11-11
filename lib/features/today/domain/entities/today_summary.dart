import 'package:flutter/foundation.dart' show immutable, listEquals;
import 'package:job_prep/features/circulars/domain/entities/circular.dart';
import 'package:job_prep/features/circulars/domain/entities/circular_enums.dart';
import 'package:job_prep/features/circulars/domain/entities/circular_exam_date.dart';
import 'package:job_prep/features/circulars/domain/utils/deadline_countdown.dart';
import 'package:job_prep/features/prep/domain/entities/prep_material.dart';
import 'package:job_prep/features/prep/domain/entities/revision_item.dart';
import 'package:job_prep/features/prep/domain/entities/subject.dart';
import 'package:job_prep/features/today/domain/entities/today_action_models.dart';

export 'package:job_prep/features/today/domain/entities/today_action_models.dart';

/// Enriched revision preview row displayed inside Revision due today.
@immutable
class TodayRevisionPreviewEntry {
  /// Creates a [TodayRevisionPreviewEntry].
  const TodayRevisionPreviewEntry({
    required this.item,
    required this.daysOverdue,
    required this.isOverdue,
    this.subject,
    this.material,
  });

  /// Underlying spaced revision mark.
  final RevisionItem item;

  /// Positive days overdue (`0` when due strictly today).
  final int daysOverdue;

  /// True when `item.dueOn` is strictly before today.
  final bool isOverdue;

  /// Resolved subject for [item], if any.
  final Subject? subject;

  /// Resolved study material for [item], if any.
  final PrepMaterial? material;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is TodayRevisionPreviewEntry &&
        other.item == item &&
        other.daysOverdue == daysOverdue &&
        other.isOverdue == isOverdue &&
        other.subject == subject &&
        other.material == material;
  }

  @override
  int get hashCode =>
      Object.hash(item, daysOverdue, isOverdue, subject, material);
}

/// Summary counts and first few actionable marks for Today's revision section.
@immutable
class TodayRevisionSummary {
  /// Creates a [TodayRevisionSummary].
  const TodayRevisionSummary({
    this.dueTodayCount = 0,
    this.overdueCount = 0,
    this.previewItems = const <TodayRevisionPreviewEntry>[],
  });

  /// Active marks due strictly today.
  final int dueTodayCount;

  /// Active marks whose `dueOn` already passed prior to today.
  final int overdueCount;

  /// Total actionable items awaiting review today (`dueToday + overdue`).
  int get totalDueCount => dueTodayCount + overdueCount;

  /// First few actionable items (overdue oldest-first, then due today).
  final List<TodayRevisionPreviewEntry> previewItems;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is TodayRevisionSummary &&
        other.dueTodayCount == dueTodayCount &&
        other.overdueCount == overdueCount &&
        listEquals(other.previewItems, previewItems);
  }

  @override
  int get hashCode => Object.hash(
        dueTodayCount,
        overdueCount,
        Object.hashAll(previewItems),
      );
}

/// Circular deadline closing within the 7-day window.
@immutable
class TodayDeadlineEntry {
  /// Creates a [TodayDeadlineEntry].
  const TodayDeadlineEntry({
    required this.circular,
    required this.daysRemaining,
    required this.countdown,
  });

  /// Non-archived circular with upcoming deadline (`0..7` days).
  final Circular circular;

  /// Calendar days remaining (`0..7`).
  final int daysRemaining;

  /// Computed urgency color band & countdown metadata.
  final DeadlineCountdown countdown;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is TodayDeadlineEntry &&
        other.circular == circular &&
        other.daysRemaining == daysRemaining &&
        other.countdown == countdown;
  }

  @override
  int get hashCode => Object.hash(circular, daysRemaining, countdown);
}

/// Exam scheduled within the next 14 days.
@immutable
class TodayExamEntry {
  /// Creates a [TodayExamEntry].
  const TodayExamEntry({
    required this.circular,
    required this.examDate,
    required this.daysUntil,
    required this.stage,
  });

  /// Parent circular containing [examDate].
  final Circular circular;

  /// Upcoming exam record.
  final CircularExamDate examDate;

  /// Whole calendar days until [examDate] (`0..14`).
  final int daysUntil;

  /// Parsed [ExamStage].
  final ExamStage stage;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is TodayExamEntry &&
        other.circular == circular &&
        other.examDate == examDate &&
        other.daysUntil == daysUntil &&
        other.stage == stage;
  }

  @override
  int get hashCode => Object.hash(circular, examDate, daysUntil, stage);
}

/// Aggregated view model powering the Phase 6I Today screen.
@immutable
class TodaySummary {
  /// Creates a [TodaySummary].
  const TodaySummary({
    required this.date,
    required this.hasActiveStudyPlans,
    required this.dailyDoneUnits,
    required this.dailyTargetUnits,
    required this.dailyProgress,
    required this.studyTargets,
    required this.catchUpNotices,
    required this.revision,
    required this.deadlinesNext7Days,
    required this.examsNext14Days,
    required this.inboxCount,
    required this.studiedSecondsToday,
    required this.sessionsTodayCount,
    required this.hasActiveSessionToday,
    this.doThisNext,
  });

  /// Reference date/time for greeting, date formatting, and windows.
  final DateTime date;

  /// Whether at least one active study plan exists.
  final bool hasActiveStudyPlans;

  /// Total units logged today across primary study plan targets.
  final int dailyDoneUnits;

  /// Total quota target units for today across primary study plan targets.
  final int dailyTargetUnits;

  /// Clamped aggregate daily progress ratio (`0.0..1.0`) for header ring.
  final double dailyProgress;

  /// Highest-priority next action (`null` when completely caught up).
  final TodayDoThisNextItem? doThisNext;

  /// Ordered study target rows per active study plan.
  final List<TodayStudyTargetRow> studyTargets;

  /// Missed-day catch-up and past-buffer alerts from Phase 6C snapshots.
  final List<TodayCatchUpNotice> catchUpNotices;

  /// Due-today and overdue spaced revision summary.
  final TodayRevisionSummary revision;

  /// Chronologically sorted non-archived deadlines closing within `0..7` days.
  final List<TodayDeadlineEntry> deadlinesNext7Days;

  /// Chronologically sorted non-archived exams within `0..14` days.
  final List<TodayExamEntry> examsNext14Days;

  /// Count of circulars currently in Inbox workflow status.
  final int inboxCount;

  /// Total seconds studied during the current local calendar day.
  final int studiedSecondsToday;

  /// Number of sessions contributing to today's studied time or started today.
  final int sessionsTodayCount;

  /// Whether an active (uncompleted) study session exists today.
  final bool hasActiveSessionToday;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is TodaySummary &&
        other.date == date &&
        other.hasActiveStudyPlans == hasActiveStudyPlans &&
        other.dailyDoneUnits == dailyDoneUnits &&
        other.dailyTargetUnits == dailyTargetUnits &&
        other.dailyProgress == dailyProgress &&
        other.doThisNext == doThisNext &&
        listEquals(other.studyTargets, studyTargets) &&
        listEquals(other.catchUpNotices, catchUpNotices) &&
        other.revision == revision &&
        listEquals(other.deadlinesNext7Days, deadlinesNext7Days) &&
        listEquals(other.examsNext14Days, examsNext14Days) &&
        other.inboxCount == inboxCount &&
        other.studiedSecondsToday == studiedSecondsToday &&
        other.sessionsTodayCount == sessionsTodayCount &&
        other.hasActiveSessionToday == hasActiveSessionToday;
  }

  @override
  int get hashCode => Object.hash(
        date,
        hasActiveStudyPlans,
        dailyDoneUnits,
        dailyTargetUnits,
        dailyProgress,
        doThisNext,
        Object.hashAll(studyTargets),
        Object.hashAll(catchUpNotices),
        revision,
        Object.hashAll(deadlinesNext7Days),
        Object.hashAll(examsNext14Days),
        inboxCount,
        studiedSecondsToday,
        sessionsTodayCount,
        hasActiveSessionToday,
      );
}
