import 'package:job_prep/features/circulars/domain/entities/circular.dart';
import 'package:job_prep/features/circulars/domain/entities/circular_enums.dart';
import 'package:job_prep/features/circulars/domain/utils/deadline_countdown.dart';
import 'package:job_prep/features/prep/domain/entities/study_plan_snapshot.dart';
import 'package:job_prep/features/prep/domain/entities/study_session.dart';
import 'package:job_prep/features/prep/domain/utils/study_session_date_splitter.dart';
import 'package:job_prep/features/today/domain/entities/today_summary.dart';

/// Pure chronological window selectors and session-duration accumulators used
/// by `TodaySummaryCalculator`.
abstract final class TodayWindowSelectors {
  /// Default window in days for deadlines closing soon.
  static const int upcomingDeadlinesWindowDays = 7;

  /// Default window in days for upcoming circular exam dates.
  static const int upcomingExamsWindowDays = 14;

  /// Extracts active missed-day catch-up and past-buffer alerts ordered by
  /// urgency (past buffer first, then most missed units descending).
  static List<TodayCatchUpNotice> buildCatchUpNotices({
    required List<StudyPlanSnapshot> snapshots,
  }) {
    final notices = <TodayCatchUpNotice>[];
    for (final snapshot in snapshots) {
      final hasMissed =
          snapshot.missedUnits > 0 && !snapshot.isPastBufferOrTarget;
      if (!hasMissed && !snapshot.isPastBufferOrTarget) continue;
      notices.add(
        TodayCatchUpNotice(
          planSnapshot: snapshot,
          subject: snapshot.subject,
          missedUnits: snapshot.missedUnits,
          studyDaysLeft: snapshot.studyDaysLeft,
          dailyCatchUpExtra: snapshot.dailyCatchUpExtra,
          isPastBufferOrTarget: snapshot.isPastBufferOrTarget,
          remainingUnits: snapshot.remainingUnits,
        ),
      );
    }

    notices.sort((a, b) {
      if (a.isPastBufferOrTarget != b.isPastBufferOrTarget) {
        return a.isPastBufferOrTarget ? -1 : 1;
      }
      final byMissed = b.missedUnits.compareTo(a.missedUnits);
      if (byMissed != 0) return byMissed;
      return a.planSnapshot.plan.targetDate.compareTo(
        b.planSnapshot.plan.targetDate,
      );
    });
    return List<TodayCatchUpNotice>.unmodifiable(notices);
  }

  /// Selects and chronologically sorts circulars closing in `0..maxDays`.
  static List<TodayDeadlineEntry> selectDeadlinesWithinDays({
    required List<Circular> circulars,
    required DateTime now,
    int maxDays = upcomingDeadlinesWindowDays,
  }) {
    final entries = <TodayDeadlineEntry>[];
    for (final circular in circulars) {
      if (circular.workflowStatus == CircularWorkflowStatus.archived) continue;
      final countdown = computeDeadlineCountdown(circular.deadline, now: now);
      final days = countdown.daysRemaining;
      if (countdown.isOverdue || days == null || days < 0 || days > maxDays) {
        continue;
      }
      entries.add(
        TodayDeadlineEntry(
          circular: circular,
          daysRemaining: days,
          countdown: countdown,
        ),
      );
    }

    entries.sort((a, b) {
      final byDays = a.daysRemaining.compareTo(b.daysRemaining);
      if (byDays != 0) return byDays;
      final byExact = a.circular.deadline!.compareTo(b.circular.deadline!);
      if (byExact != 0) return byExact;
      final byPriority =
          b.circular.priority.weight.compareTo(a.circular.priority.weight);
      if (byPriority != 0) return byPriority;
      final byTitle = a.circular.title
          .toLowerCase()
          .compareTo(b.circular.title.toLowerCase());
      if (byTitle != 0) return byTitle;
      return a.circular.id.compareTo(b.circular.id);
    });
    return List<TodayDeadlineEntry>.unmodifiable(entries);
  }

  /// Selects and chronologically sorts non-archived exams within `0..maxDays`.
  static List<TodayExamEntry> selectExamsWithinDays({
    required List<Circular> circulars,
    required DateTime now,
    int maxDays = upcomingExamsWindowDays,
  }) {
    final todayCal = DateTime.utc(now.year, now.month, now.day);
    final entries = <TodayExamEntry>[];

    for (final circular in circulars) {
      if (circular.workflowStatus == CircularWorkflowStatus.archived) continue;
      for (final exam in circular.examDates) {
        final aligned =
            now.isUtc ? exam.examDate.toUtc() : exam.examDate.toLocal();
        final examCal = DateTime.utc(aligned.year, aligned.month, aligned.day);
        final daysUntil = examCal.difference(todayCal).inDays;
        if (daysUntil < 0 || daysUntil > maxDays) continue;
        entries.add(
          TodayExamEntry(
            circular: circular,
            examDate: exam,
            daysUntil: daysUntil,
            stage: ExamStage.fromValue(exam.stage),
          ),
        );
      }
    }

    entries.sort((a, b) {
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
    return List<TodayExamEntry>.unmodifiable(entries);
  }

  /// Computes total seconds studied today on the user's local calendar day
  /// across persisted and currently active study sessions.
  static ({int totalSeconds, int sessionCount, bool hasOpenToday})
      computeTimeStudiedToday({
    required List<StudySession> sessions,
    required DateTime now,
    Duration? localOffset,
  }) {
    final todayLocal = StudySessionDateSplitter.toLocalDate(
      now,
      localOffset: localOffset,
    );
    var totalSeconds = 0;
    var sessionCount = 0;
    var hasOpenToday = false;

    for (final session in sessions) {
      final slices = StudySessionDateSplitter.splitByLocalDate(
        session,
        now: now,
        localOffset: localOffset,
      );
      final todaySeconds = slices[todayLocal] ?? 0;
      final startLocal = StudySessionDateSplitter.toLocalDate(
        session.startedAt,
        localOffset: localOffset,
      );
      final touchesToday = todaySeconds > 0 || startLocal == todayLocal;
      if (todaySeconds > 0) {
        totalSeconds += todaySeconds;
      }
      if (touchesToday) {
        sessionCount += 1;
        if (session.endedAt == null) {
          hasOpenToday = true;
        }
      }
    }

    return (
      totalSeconds: totalSeconds,
      sessionCount: sessionCount,
      hasOpenToday: hasOpenToday,
    );
  }
}
