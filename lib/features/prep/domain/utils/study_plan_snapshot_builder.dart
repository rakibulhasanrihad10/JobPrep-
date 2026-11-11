import 'dart:math' as math;

import 'package:job_prep/features/circulars/domain/entities/circular.dart';
import 'package:job_prep/features/circulars/domain/entities/circular_exam_date.dart';
import 'package:job_prep/features/prep/domain/entities/prep_material.dart';
import 'package:job_prep/features/prep/domain/entities/progress_log.dart';
import 'package:job_prep/features/prep/domain/entities/study_plan.dart';
import 'package:job_prep/features/prep/domain/entities/study_plan_snapshot.dart';
import 'package:job_prep/features/prep/domain/entities/subject.dart';
import 'package:job_prep/features/prep/domain/utils/study_plan_calculator.dart';

/// Builds a live [StudyPlanSnapshot] from [plan], [today], active materials,
/// recent progress logs, and optional subject or circular metadata.
StudyPlanSnapshot assembleStudyPlanSnapshot({
  required StudyPlan plan,
  required DateTime today,
  required Iterable<PrepMaterial> materials,
  required Iterable<ProgressLog> recentLogs,
  Subject? subject,
  Circular? circular,
  CircularExamDate? examDate,
}) {
  final todayDay = StudyPlanCalculator.normalizeUtcDate(today);
  final postponedSet = plan.postponedMaterialIds.toSet();
  final scopeId = plan.isAllSubjects ? null : plan.subjectId;

  var totalUnits = 0;
  var completedUnits = 0;
  var remainingUnits = 0;
  final activeMaterialIds = <String>{};
  final postponedMaterials = <PrepMaterial>[];

  for (final material in materials) {
    if (scopeId != null && material.subjectId != scopeId) {
      continue;
    }
    if (postponedSet.contains(material.id)) {
      postponedMaterials.add(material);
      continue;
    }
    activeMaterialIds.add(material.id);
    final total = math.max(0, material.totalUnits);
    final completed = math.max(0, material.completedUnits);
    totalUnits += total;
    completedUnits += math.min(total, completed);
    if (total > completed) {
      remainingUnits += total - completed;
    }
  }

  var todayCompletedRaw = 0;
  for (final log in recentLogs) {
    if (!activeMaterialIds.contains(log.materialId)) continue;
    if (!log.isStudy) continue;
    if (StudyPlanCalculator.normalizeUtcDate(log.loggedOn) == todayDay &&
        log.unitsDone > 0) {
      todayCompletedRaw += log.unitsDone;
    }
  }
  final todayCompletedUnits = math.min(completedUnits, todayCompletedRaw);

  final days = StudyPlanCalculator.calculateStudyDaysLeft(
    today: todayDay,
    targetDate: plan.targetDate,
    finishBufferDays: plan.finishBufferDays,
    restDaysPerWeek: plan.restDaysPerWeek,
    extraStudyDays: plan.extraStudyDays,
  );

  final startDay = StudyPlanCalculator.normalizeUtcDate(plan.startDate);
  final effectiveFinishDay =
      StudyPlanCalculator.normalizeUtcDate(plan.targetDate).subtract(
    Duration(days: math.max(0, plan.finishBufferDays)),
  );
  final totalCalendarDays = math.max(
    0,
    effectiveFinishDay.difference(startDay).inDays,
  );
  final totalRestDays = StudyPlanCalculator.countRestDays(
    totalCalendarDays,
    plan.restDaysPerWeek,
  );
  final totalStudyDays = math.max(0, totalCalendarDays - totalRestDays);

  final baselineRemainingRest = StudyPlanCalculator.countRestDays(
    days.calendarDaysLeft,
    plan.restDaysPerWeek,
  );
  final baselineRemainingStudy = math.max(
    0,
    days.calendarDaysLeft - baselineRemainingRest,
  );
  final elapsedStudyDays = !todayDay.isAfter(startDay)
      ? 0
      : math.max(0, totalStudyDays - baselineRemainingStudy);

  final baselineDone = math.min(plan.initialCompletedUnits, completedUnits);
  final completedSinceStart = math.max(0, completedUnits - baselineDone);
  final completedBeforeToday =
      math.max(0, completedSinceStart - todayCompletedUnits);
  final totalSpanUnits = completedSinceStart + remainingUnits;

  final baselineDailyPace = totalStudyDays > 0
      ? totalSpanUnits / totalStudyDays
      : (totalSpanUnits > 0 ? totalSpanUnits.toDouble() : 0.0);
  final idealCompletedBeforeToday = math.min(
    totalSpanUnits.toDouble(),
    elapsedStudyDays * baselineDailyPace,
  );

  final missedUnits = remainingUnits <= 0
      ? 0
      : math.max(0, (idealCompletedBeforeToday - completedSinceStart).round());
  final dailyCatchUpExtra = (missedUnits > 0 && days.studyDaysLeft > 0)
      ? missedUnits / days.studyDaysLeft
      : 0.0;

  final dailyTargetResult = StudyPlanCalculator.calculateDailyTarget(
    remainingUnits: remainingUnits,
    studyDaysLeft: days.studyDaysLeft,
  );
  final unitsAtStartOfToday =
      remainingUnits <= 0 ? 0 : remainingUnits + todayCompletedUnits;
  final todayTargetResult = StudyPlanCalculator.calculateDailyTarget(
    remainingUnits: unitsAtStartOfToday,
    studyDaysLeft: days.studyDaysLeft,
  );

  final todayProgress = remainingUnits <= 0
      ? 1.0
      : (todayTargetResult.rounded <= 0
          ? 0.0
          : (todayCompletedUnits / todayTargetResult.rounded).clamp(0.0, 1.0));

  final scheduleStatus = StudyPlanCalculator.determineScheduleStatus(
    totalSpanUnits: totalSpanUnits,
    completedSinceStart: completedSinceStart,
    completedBeforeToday: completedBeforeToday,
    remainingUnits: remainingUnits,
    studyDaysLeft: days.studyDaysLeft,
    elapsedStudyDays: elapsedStudyDays,
    baselineDailyPace: baselineDailyPace,
  );

  final maxPace = plan.maxDailyPace;
  final isOverPaceLimit = maxPace != null &&
      (todayTargetResult.rounded > maxPace ||
          dailyTargetResult.rounded > maxPace);

  final postponable = StudyPlanCalculator.prioritizePostponableMaterials(
    materials,
    subjectId: scopeId,
    postponedMaterialIds: postponedSet,
  );

  return StudyPlanSnapshot(
    plan: plan,
    subject: subject,
    linkedCircular: circular,
    linkedExamDate: examDate,
    totalUnits: totalUnits,
    completedUnits: completedUnits,
    remainingUnits: remainingUnits,
    todayCompletedUnits: todayCompletedUnits,
    calendarDaysUntilExam: days.calendarDaysUntilExam,
    calendarDaysLeft: days.calendarDaysLeft,
    restDaysLeft: days.restDaysLeft,
    studyDaysLeft: days.studyDaysLeft,
    exactDailyTarget: dailyTargetResult.exact,
    dailyTarget: dailyTargetResult.rounded,
    todayExactTarget: todayTargetResult.exact,
    todayTarget: todayTargetResult.rounded,
    todayProgress: todayProgress,
    scheduleStatus: scheduleStatus,
    baselineDailyPace: baselineDailyPace,
    idealCompletedBeforeToday: idealCompletedBeforeToday,
    missedUnits: missedUnits,
    dailyCatchUpExtra: dailyCatchUpExtra,
    isPastBufferOrTarget: days.isInsideBufferOrPast && remainingUnits > 0,
    isOverPaceLimit: isOverPaceLimit,
    hasConvertibleRestDays: days.restDaysLeft > 0,
    postponableMaterials: postponable,
    postponedMaterials: List<PrepMaterial>.unmodifiable(postponedMaterials),
  );
}
