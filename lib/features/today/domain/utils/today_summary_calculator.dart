import 'dart:math' as math;

import 'package:job_prep/features/circulars/domain/entities/circular.dart';
import 'package:job_prep/features/circulars/domain/entities/circular_enums.dart';
import 'package:job_prep/features/prep/domain/entities/prep_material.dart';
import 'package:job_prep/features/prep/domain/entities/progress_log.dart';
import 'package:job_prep/features/prep/domain/entities/revision_item.dart';
import 'package:job_prep/features/prep/domain/entities/study_plan.dart';
import 'package:job_prep/features/prep/domain/entities/study_plan_snapshot.dart';
import 'package:job_prep/features/prep/domain/entities/study_session.dart';
import 'package:job_prep/features/prep/domain/entities/subject.dart';
import 'package:job_prep/features/prep/domain/utils/revision_scheduler.dart';
import 'package:job_prep/features/today/domain/entities/today_summary.dart';
import 'package:job_prep/features/today/domain/utils/today_target_planner.dart';
import 'package:job_prep/features/today/domain/utils/today_window_selectors.dart';

/// Time-of-day greeting bucket resolved purely from local hour (`0..23`).
enum TodayGreetingPeriod {
  morning,
  afternoon,
  evening,
}

/// Pure, side-effect-free selection, ordering, priority, and metric math for
/// the Phase 6I Today screen.
abstract final class TodaySummaryCalculator {
  /// Maximum number of days ahead for urgent circular deadline priority.
  static const int urgentDeadlineMaxDays = 2;

  /// Default number of due/overdue revision preview entries shown inline.
  static const int defaultMaxRevisionPreview = 4;

  /// Resolves time-of-day greeting period from [referenceNow] hour.
  static TodayGreetingPeriod greetingPeriodFor(DateTime referenceNow) {
    final hour = referenceNow.hour;
    if (hour < 12) return TodayGreetingPeriod.morning;
    if (hour < 17) return TodayGreetingPeriod.afternoon;
    return TodayGreetingPeriod.evening;
  }

  /// Builds complete [TodaySummary] from circulars, prep subjects/materials,
  /// progress logs, study plans, revision marks, and study sessions.
  static TodaySummary buildSummary({
    required List<Circular> circulars,
    required List<Subject> subjects,
    required List<PrepMaterial> materials,
    required List<ProgressLog> recentLogs,
    required List<StudyPlan> plans,
    required List<RevisionItem> revisionItems,
    required List<StudySession> sessions,
    List<StudyPlanSnapshot>? planSnapshots,
    DateTime? now,
    Duration? localOffset,
    int maxRevisionPreview = defaultMaxRevisionPreview,
  }) {
    final referenceNow = now ?? DateTime.now();
    final subjectsById = <String, Subject>{
      for (final s in subjects) s.id: s,
    };
    final materialsById = <String, PrepMaterial>{
      for (final m in materials) m.id: m,
    };

    final resolvedSnapshots = planSnapshots ??
        TodayTargetPlanner.assembleSnapshots(
          plans: plans,
          subjectsById: subjectsById,
          circulars: circulars,
          materials: materials,
          recentLogs: recentLogs,
          today: referenceNow,
        );

    final studyTargets = TodayTargetPlanner.buildStudyTargetRows(
      snapshots: resolvedSnapshots,
      materials: materials,
    );
    final dailyProgress = TodayTargetPlanner.computeDailyProgress(
      targetRows: studyTargets,
    );
    final catchUpNotices = TodayWindowSelectors.buildCatchUpNotices(
      snapshots: resolvedSnapshots,
    );
    final revisionSummary = buildRevisionSummary(
      items: revisionItems,
      subjectsById: subjectsById,
      materialsById: materialsById,
      today: referenceNow,
      maxPreview: maxRevisionPreview,
    );
    final deadlines = TodayWindowSelectors.selectDeadlinesWithinDays(
      circulars: circulars,
      now: referenceNow,
    );
    final exams = TodayWindowSelectors.selectExamsWithinDays(
      circulars: circulars,
      now: referenceNow,
    );
    final inboxCount = circulars
        .where((c) => c.workflowStatus == CircularWorkflowStatus.inbox)
        .length;
    final studied = TodayWindowSelectors.computeTimeStudiedToday(
      sessions: sessions,
      now: referenceNow,
      localOffset: localOffset,
    );

    final doThisNext = selectDoThisNext(
      deadlinesNext7Days: deadlines,
      revision: revisionSummary,
      studyTargets: studyTargets,
    );

    return TodaySummary(
      date: referenceNow,
      hasActiveStudyPlans: resolvedSnapshots.isNotEmpty,
      dailyDoneUnits: dailyProgress.doneUnits,
      dailyTargetUnits: dailyProgress.targetUnits,
      dailyProgress: dailyProgress.progress,
      doThisNext: doThisNext,
      studyTargets: studyTargets,
      catchUpNotices: catchUpNotices,
      revision: revisionSummary,
      deadlinesNext7Days: deadlines,
      examsNext14Days: exams,
      inboxCount: inboxCount,
      studiedSecondsToday: studied.totalSeconds,
      sessionsTodayCount: studied.sessionCount,
      hasActiveSessionToday: studied.hasOpenToday,
    );
  }

  /// Fixed-priority selector for the "Do this next" card:
  /// 1) Non-archived circular closing within `0..2` days
  /// 2) Overdue revision items (oldest overdue first)
  /// 3) Biggest remaining daily study target for today
  static TodayDoThisNextItem? selectDoThisNext({
    required List<TodayDeadlineEntry> deadlinesNext7Days,
    required TodayRevisionSummary revision,
    required List<TodayStudyTargetRow> studyTargets,
  }) {
    for (final entry in deadlinesNext7Days) {
      if (entry.daysRemaining >= 0 &&
          entry.daysRemaining <= urgentDeadlineMaxDays) {
        return TodayDoThisNextItem(
          kind: TodayDoThisNextKind.circularDeadline,
          circular: entry.circular,
          daysUntilDeadline: entry.daysRemaining,
        );
      }
    }

    if (revision.overdueCount > 0) {
      TodayRevisionPreviewEntry? topOverdue;
      for (final preview in revision.previewItems) {
        if (preview.isOverdue) {
          topOverdue = preview;
          break;
        }
      }
      return TodayDoThisNextItem(
        kind: TodayDoThisNextKind.overdueRevision,
        overdueRevisionCount: revision.overdueCount,
        topOverdueRevision: topOverdue?.item,
        overdueRevisionSubject: topOverdue?.subject,
      );
    }

    TodayStudyTargetRow? bestTarget;
    for (final row in studyTargets) {
      if (row.remainingTodayUnits <= 0) continue;
      if (bestTarget == null ||
          row.remainingTodayUnits > bestTarget.remainingTodayUnits) {
        bestTarget = row;
      } else if (row.remainingTodayUnits == bestTarget.remainingTodayUnits) {
        if (row.todayTargetUnits > bestTarget.todayTargetUnits) {
          bestTarget = row;
        } else if (row.todayTargetUnits == bestTarget.todayTargetUnits &&
            bestTarget.isAllSubjects &&
            !row.isAllSubjects) {
          bestTarget = row;
        }
      }
    }
    if (bestTarget != null) {
      return TodayDoThisNextItem(
        kind: TodayDoThisNextKind.studyTarget,
        studyTargetRow: bestTarget,
      );
    }

    return null;
  }

  /// Counts due-today & overdue revision marks and orders preview entries with
  /// overdue items oldest-first ahead of today's items.
  static TodayRevisionSummary buildRevisionSummary({
    required List<RevisionItem> items,
    required Map<String, Subject> subjectsById,
    required Map<String, PrepMaterial> materialsById,
    required DateTime today,
    int maxPreview = defaultMaxRevisionPreview,
  }) {
    final overdueItems = RevisionScheduler.filterItems(
      items,
      today: today,
      tab: RevisionQueueTab.overdue,
    );
    final dueTodayItems = RevisionScheduler.filterItems(
      items,
      today: today,
      tab: RevisionQueueTab.dueToday,
    );

    final combined = <RevisionItem>[...overdueItems, ...dueTodayItems];
    final preview = <TodayRevisionPreviewEntry>[];
    for (final item in combined.take(math.max(0, maxPreview))) {
      final overdueDays = RevisionScheduler.daysOverdue(item, today: today);
      preview.add(
        TodayRevisionPreviewEntry(
          item: item,
          daysOverdue: overdueDays,
          isOverdue: overdueDays > 0,
          subject: subjectsById[item.subjectId],
          material:
              item.materialId == null ? null : materialsById[item.materialId!],
        ),
      );
    }

    return TodayRevisionSummary(
      dueTodayCount: dueTodayItems.length,
      overdueCount: overdueItems.length,
      previewItems: List<TodayRevisionPreviewEntry>.unmodifiable(preview),
    );
  }
}
