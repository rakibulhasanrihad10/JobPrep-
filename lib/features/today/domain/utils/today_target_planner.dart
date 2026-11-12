import 'dart:math' as math;

import 'package:job_prep/features/circulars/domain/entities/circular.dart';
import 'package:job_prep/features/prep/domain/entities/prep_material.dart';
import 'package:job_prep/features/prep/domain/entities/progress_log.dart';
import 'package:job_prep/features/prep/domain/entities/study_plan.dart';
import 'package:job_prep/features/prep/domain/entities/study_plan_snapshot.dart';
import 'package:job_prep/features/prep/domain/entities/subject.dart';
import 'package:job_prep/features/prep/domain/utils/study_plan_snapshot_builder.dart';
import 'package:job_prep/features/today/domain/entities/today_summary.dart';

/// Pure study-plan assembly, target-row ordering, and daily progress helpers
/// used by `TodaySummaryCalculator`.
abstract final class TodayTargetPlanner {
  static final DateTime _epochUtc =
      DateTime.fromMillisecondsSinceEpoch(0, isUtc: true);

  /// Builds ordered target rows (largest remaining target today first).
  static List<TodayStudyTargetRow> buildStudyTargetRows({
    required List<StudyPlanSnapshot> snapshots,
    required List<PrepMaterial> materials,
  }) {
    final rows = <TodayStudyTargetRow>[];
    for (final snapshot in snapshots) {
      final scopeId =
          snapshot.plan.isAllSubjects ? null : snapshot.plan.subjectId;
      final postponed = snapshot.plan.postponedMaterialIds.toSet();

      final scoped = materials.where((m) {
        if (postponed.contains(m.id)) return false;
        if (scopeId != null && m.subjectId != scopeId) return false;
        return true;
      }).toList()
        ..sort((a, b) {
          final aDone = a.completedUnits >= a.totalUnits;
          final bDone = b.completedUnits >= b.totalUnits;
          if (aDone != bDone) return aDone ? 1 : -1;
          final byCreated =
              (a.createdAt ?? _epochUtc).compareTo(b.createdAt ?? _epochUtc);
          if (byCreated != 0) return byCreated;
          final byTitle =
              a.title.toLowerCase().compareTo(b.title.toLowerCase());
          if (byTitle != 0) return byTitle;
          return a.id.compareTo(b.id);
        });

      final remainingToday = math.max(
        0,
        snapshot.todayTarget - snapshot.todayCompletedUnits,
      );

      rows.add(
        TodayStudyTargetRow(
          planSnapshot: snapshot,
          subject: snapshot.subject,
          isAllSubjects: snapshot.plan.isAllSubjects,
          todayDoneUnits: snapshot.todayCompletedUnits,
          todayTargetUnits: snapshot.todayTarget,
          remainingTodayUnits: remainingToday,
          progress: snapshot.todayProgress,
          scheduleStatus: snapshot.scheduleStatus,
          scopedMaterials: List<PrepMaterial>.unmodifiable(scoped),
          defaultLogMaterial: scoped.isEmpty ? null : scoped.first,
        ),
      );
    }

    rows.sort((a, b) {
      final byRem = b.remainingTodayUnits.compareTo(a.remainingTodayUnits);
      if (byRem != 0) return byRem;
      final byTarget = b.todayTargetUnits.compareTo(a.todayTargetUnits);
      if (byTarget != 0) return byTarget;
      final byDate = a.planSnapshot.plan.targetDate.compareTo(
        b.planSnapshot.plan.targetDate,
      );
      if (byDate != 0) return byDate;
      if (a.isAllSubjects != b.isAllSubjects) {
        return a.isAllSubjects ? 1 : -1;
      }
      final aName = a.subject?.name.toLowerCase() ?? '';
      final bName = b.subject?.name.toLowerCase() ?? '';
      return aName.compareTo(bName);
    });

    return List<TodayStudyTargetRow>.unmodifiable(rows);
  }

  /// Aggregates header daily progress across per-subject plans (avoiding
  /// double-counting if an all-subjects plan is also present alongside them).
  static ({int doneUnits, int targetUnits, double progress})
      computeDailyProgress({
    required List<TodayStudyTargetRow> targetRows,
  }) {
    if (targetRows.isEmpty) {
      return (doneUnits: 0, targetUnits: 0, progress: 0.0);
    }
    final perSubjectRows =
        targetRows.where((row) => !row.isAllSubjects).toList(growable: false);
    final basis = perSubjectRows.isNotEmpty ? perSubjectRows : targetRows;

    var done = 0;
    var target = 0;
    var credited = 0;
    var allSyllabusFinished = true;

    for (final row in basis) {
      done += row.todayDoneUnits;
      target += row.todayTargetUnits;
      if (row.planSnapshot.remainingUnits > 0) {
        allSyllabusFinished = false;
      }
      if (row.todayTargetUnits > 0) {
        credited += math.min(row.todayDoneUnits, row.todayTargetUnits);
      }
    }

    final progress = target <= 0
        ? (allSyllabusFinished ? 1.0 : 0.0)
        : (credited / target).clamp(0.0, 1.0);

    return (doneUnits: done, targetUnits: target, progress: progress);
  }

  /// Assembles [StudyPlanSnapshot]s from persisted [plans] cleanly outside UI.
  static List<StudyPlanSnapshot> assembleSnapshots({
    required List<StudyPlan> plans,
    required Map<String, Subject> subjectsById,
    required List<Circular> circulars,
    required List<PrepMaterial> materials,
    required List<ProgressLog> recentLogs,
    required DateTime today,
  }) {
    final circularsById = <String, Circular>{
      for (final c in circulars) c.id: c,
    };
    final snapshots = <StudyPlanSnapshot>[];
    for (final plan in plans) {
      final subject =
          plan.isAllSubjects ? null : subjectsById[plan.subjectId ?? ''];
      if (!plan.isAllSubjects && subject == null) continue;
      final circular =
          plan.circularId != null ? circularsById[plan.circularId!] : null;
      final examDate = (circular != null && plan.examDateId != null)
          ? circular.examDates.where((e) => e.id == plan.examDateId).firstOrNull
          : null;
      snapshots.add(
        assembleStudyPlanSnapshot(
          plan: plan,
          today: today,
          subject: subject,
          materials: materials,
          recentLogs: recentLogs,
          circular: circular,
          examDate: examDate,
        ),
      );
    }
    snapshots.sort((a, b) {
      if (a.plan.isAllSubjects != b.plan.isAllSubjects) {
        return a.plan.isAllSubjects ? -1 : 1;
      }
      return a.plan.targetDate.compareTo(b.plan.targetDate);
    });
    return snapshots;
  }
}
