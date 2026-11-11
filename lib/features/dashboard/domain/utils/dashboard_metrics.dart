import 'package:job_prep/features/circulars/domain/entities/circular.dart';
import 'package:job_prep/features/circulars/domain/entities/circular_enums.dart';
import 'package:job_prep/features/circulars/domain/utils/deadline_countdown.dart';
import 'package:job_prep/features/dashboard/domain/entities/dashboard_summary.dart';
import 'package:job_prep/features/prep/domain/entities/prep_material.dart';
import 'package:job_prep/features/prep/domain/entities/progress_log.dart';
import 'package:job_prep/features/prep/domain/entities/subject.dart';
import 'package:job_prep/features/prep/domain/utils/prep_progress.dart';

/// Pure aggregation helpers computing all Home Dashboard metrics and lists
/// outside widgets so presentation layers stay declarative and unit-testable.
abstract final class DashboardMetricsCalculator {
  /// Default maximum number of upcoming deadlines retained for dashboard lists.
  static const int defaultMaxDeadlines = 6;

  /// Default maximum number of upcoming exams retained for dashboard lists.
  static const int defaultMaxExams = 6;

  /// Computes the complete [DashboardSummary] from circulars, prep subjects,
  /// materials, and recent progress logs relative to [now].
  static DashboardSummary buildSummary({
    required List<Circular> circulars,
    required List<Subject> subjects,
    required List<PrepMaterial> materials,
    required List<ProgressLog> recentLogs,
    DateTime? now,
    int maxDeadlines = defaultMaxDeadlines,
    int maxExams = defaultMaxExams,
  }) {
    final referenceNow = now ?? DateTime.now();

    final deadlines = <({Circular circular, int days})>[];
    final exams = <DashboardExamEntry>[];

    var deadlinesThisWeek = 0;
    var inboxCount = 0;
    var examsNext14Days = 0;
    var submittedCount = 0;

    final todayCalendar = DateTime.utc(
      referenceNow.year,
      referenceNow.month,
      referenceNow.day,
    );

    for (final circular in circulars) {
      if (circular.workflowStatus == CircularWorkflowStatus.inbox) {
        inboxCount += 1;
      }

      if (isApplicationSubmitted(circular)) {
        submittedCount += 1;
      }

      if (circular.workflowStatus == CircularWorkflowStatus.archived) {
        continue;
      }

      final countdown = computeDeadlineCountdown(
        circular.deadline,
        now: referenceNow,
      );
      final daysRemaining = countdown.daysRemaining;
      if (!countdown.isOverdue && daysRemaining != null && daysRemaining >= 0) {
        if (daysRemaining <= 7) {
          deadlinesThisWeek += 1;
        }
        deadlines.add((circular: circular, days: daysRemaining));
      }

      for (final exam in circular.examDates) {
        final aligned = referenceNow.isUtc
            ? exam.examDate.toUtc()
            : exam.examDate.toLocal();
        final examCalendar = DateTime.utc(
          aligned.year,
          aligned.month,
          aligned.day,
        );
        final daysUntil = examCalendar.difference(todayCalendar).inDays;
        if (daysUntil >= 0) {
          if (daysUntil <= 14) {
            examsNext14Days += 1;
          }
          exams.add(
            DashboardExamEntry(
              circular: circular,
              examDate: exam,
              daysUntil: daysUntil,
              stage: ExamStage.fromValue(exam.stage),
            ),
          );
        }
      }
    }

    deadlines.sort((a, b) {
      final byDays = a.days.compareTo(b.days);
      if (byDays != 0) return byDays;

      final aDeadline = a.circular.deadline!;
      final bDeadline = b.circular.deadline!;
      final byExact = aDeadline.compareTo(bDeadline);
      if (byExact != 0) return byExact;

      final byPriority =
          b.circular.priority.weight.compareTo(a.circular.priority.weight);
      if (byPriority != 0) return byPriority;

      return a.circular.title
          .toLowerCase()
          .compareTo(b.circular.title.toLowerCase());
    });

    exams.sort((a, b) {
      final byTime = a.examDate.examDate.compareTo(b.examDate.examDate);
      if (byTime != 0) return byTime;

      final byStage = a.stage.index.compareTo(b.stage.index);
      if (byStage != 0) return byStage;

      final byTitle = a.circular.title
          .toLowerCase()
          .compareTo(b.circular.title.toLowerCase());
      if (byTitle != 0) return byTitle;

      return a.examDate.id.compareTo(b.examDate.id);
    });

    final cappedDeadlines = maxDeadlines >= 0
        ? deadlines.take(maxDeadlines).map((e) => e.circular).toList()
        : deadlines.map((e) => e.circular).toList();
    final cappedExams = maxExams >= 0 ? exams.take(maxExams).toList() : exams;

    final overallProgress = calculateOverallProgress(
      subjects: subjects,
      materials: materials,
    );

    final continueStudying = resolveContinueStudyingTarget(
      recentLogs: recentLogs,
      materials: materials,
      subjects: subjects,
    );

    final isBrandNewUser = circulars.isEmpty &&
        subjects.isEmpty &&
        materials.isEmpty &&
        recentLogs.isEmpty;

    return DashboardSummary(
      upcomingDeadlinesThisWeekCount: deadlinesThisWeek,
      inboxCount: inboxCount,
      upcomingExamsNext14DaysCount: examsNext14Days,
      applicationsSubmittedCount: submittedCount,
      overallPrepProgress: overallProgress,
      upcomingDeadlines: List<Circular>.unmodifiable(cappedDeadlines),
      upcomingExams: List<DashboardExamEntry>.unmodifiable(cappedExams),
      continueStudying: continueStudying,
      isBrandNewUser: isBrandNewUser,
    );
  }

  /// Returns whether a [circular] reflects a submitted job application.
  static bool isApplicationSubmitted(Circular circular) {
    return circular.applicationStatus == ApplicationStatus.applied ||
        circular.applicationStatus == ApplicationStatus.feePaid ||
        circular.checklist.submitted ||
        circular.workflowStatus == CircularWorkflowStatus.applied ||
        circular.workflowStatus == CircularWorkflowStatus.examUpcoming ||
        circular.workflowStatus == CircularWorkflowStatus.resultAwaited;
  }

  /// Resolves the most recently logged material alongside its parent [Subject].
  static DashboardContinueStudying? resolveContinueStudyingTarget({
    required List<ProgressLog> recentLogs,
    required List<PrepMaterial> materials,
    required List<Subject> subjects,
  }) {
    if (recentLogs.isEmpty || materials.isEmpty || subjects.isEmpty) {
      return null;
    }

    final materialById = <String, PrepMaterial>{
      for (final m in materials) m.id: m,
    };
    final subjectById = <String, Subject>{
      for (final s in subjects) s.id: s,
    };

    final orderedLogs = List<ProgressLog>.of(recentLogs)
      ..sort((a, b) {
        final byDay = b.loggedOn.compareTo(a.loggedOn);
        if (byDay != 0) return byDay;
        final aTimestamp = a.updatedAt ?? a.createdAt ?? _epochUtc;
        final bTimestamp = b.updatedAt ?? b.createdAt ?? _epochUtc;
        final byTimestamp = bTimestamp.compareTo(aTimestamp);
        if (byTimestamp != 0) return byTimestamp;
        return b.id.compareTo(a.id);
      });

    ProgressLog? fallbackMatch;
    for (final log in orderedLogs) {
      final material = materialById[log.materialId];
      if (material == null) continue;
      final subject = subjectById[material.subjectId];
      if (subject == null) continue;

      if (log.unitsDone > 0) {
        return DashboardContinueStudying(
          subject: subject,
          material: material,
          latestLog: log,
          materialProgress: calculateMaterialProgress(material),
        );
      }
      fallbackMatch ??= log;
    }

    if (fallbackMatch != null) {
      final material = materialById[fallbackMatch.materialId]!;
      final subject = subjectById[material.subjectId]!;
      return DashboardContinueStudying(
        subject: subject,
        material: material,
        latestLog: fallbackMatch,
        materialProgress: calculateMaterialProgress(material),
      );
    }

    return null;
  }

  static final DateTime _epochUtc = DateTime.fromMillisecondsSinceEpoch(
    0,
    isUtc: true,
  );
}
