import 'package:flutter/foundation.dart' show immutable, listEquals;
import 'package:job_prep/features/circulars/domain/entities/circular.dart';
import 'package:job_prep/features/circulars/domain/entities/circular_enums.dart';
import 'package:job_prep/features/circulars/domain/entities/circular_exam_date.dart';
import 'package:job_prep/features/prep/domain/entities/prep_material.dart';
import 'package:job_prep/features/prep/domain/entities/progress_log.dart';
import 'package:job_prep/features/prep/domain/entities/subject.dart';

/// Scheduled exam date entry surfaced on the Home Dashboard alongside its
/// owning [Circular] and whole-day countdown relative to today.
@immutable
class DashboardExamEntry {
  /// Creates a [DashboardExamEntry].
  const DashboardExamEntry({
    required this.circular,
    required this.examDate,
    required this.daysUntil,
    required this.stage,
  });

  /// Parent circular containing navigation context and title.
  final Circular circular;

  /// Scheduled exam date record.
  final CircularExamDate examDate;

  /// Whole calendar days remaining until [examDate] (`0` means today).
  final int daysUntil;

  /// Normalized [ExamStage] for color/icon rendering.
  final ExamStage stage;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is DashboardExamEntry &&
        other.circular == circular &&
        other.examDate == examDate &&
        other.daysUntil == daysUntil &&
        other.stage == stage;
  }

  @override
  int get hashCode => Object.hash(circular, examDate, daysUntil, stage);
}

/// Shortcut target pointing to the most recently logged study material.
@immutable
class DashboardContinueStudying {
  /// Creates a [DashboardContinueStudying].
  const DashboardContinueStudying({
    required this.subject,
    required this.material,
    required this.latestLog,
    required this.materialProgress,
  });

  /// Owning study subject for [material].
  final Subject subject;

  /// Most recently logged study material.
  final PrepMaterial material;

  /// Latest progress log entry recorded on [material].
  final ProgressLog latestLog;

  /// Current clamped progress (`0.0` to `1.0`) for [material].
  final double materialProgress;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is DashboardContinueStudying &&
        other.subject == subject &&
        other.material == material &&
        other.latestLog == latestLog &&
        other.materialProgress == materialProgress;
  }

  @override
  int get hashCode =>
      Object.hash(subject, material, latestLog, materialProgress);
}

/// Complete aggregated view model computed for the Home Dashboard.
@immutable
class DashboardSummary {
  /// Creates a [DashboardSummary].
  const DashboardSummary({
    required this.upcomingDeadlinesThisWeekCount,
    required this.inboxCount,
    required this.upcomingExamsNext14DaysCount,
    required this.applicationsSubmittedCount,
    required this.overallPrepProgress,
    required this.upcomingDeadlines,
    required this.upcomingExams,
    required this.isBrandNewUser,
    this.continueStudying,
  });

  /// Number of non-archived circulars with deadlines 0..7 days ahead.
  final int upcomingDeadlinesThisWeekCount;

  /// Quick-captured circulars waiting in the Inbox.
  final int inboxCount;

  /// Number of upcoming exams falling within the next 0..14 days.
  final int upcomingExamsNext14DaysCount;

  /// Circulars whose applications have been submitted.
  final int applicationsSubmittedCount;

  /// Weighted overall preparation progress across subjects (`0.0` to `1.0`).
  final double overallPrepProgress;

  /// Ordered non-archived circulars with upcoming deadlines.
  final List<Circular> upcomingDeadlines;

  /// Chronologically ordered upcoming exam stages across circulars.
  final List<DashboardExamEntry> upcomingExams;

  /// Most recently logged material shortcut, or `null` if none logged yet.
  final DashboardContinueStudying? continueStudying;

  /// True when the user has not created any circulars, subjects, materials,
  /// or progress logs yet.
  final bool isBrandNewUser;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is DashboardSummary &&
        other.upcomingDeadlinesThisWeekCount ==
            upcomingDeadlinesThisWeekCount &&
        other.inboxCount == inboxCount &&
        other.upcomingExamsNext14DaysCount == upcomingExamsNext14DaysCount &&
        other.applicationsSubmittedCount == applicationsSubmittedCount &&
        other.overallPrepProgress == overallPrepProgress &&
        listEquals(other.upcomingDeadlines, upcomingDeadlines) &&
        listEquals(other.upcomingExams, upcomingExams) &&
        other.continueStudying == continueStudying &&
        other.isBrandNewUser == isBrandNewUser;
  }

  @override
  int get hashCode => Object.hash(
        upcomingDeadlinesThisWeekCount,
        inboxCount,
        upcomingExamsNext14DaysCount,
        applicationsSubmittedCount,
        overallPrepProgress,
        Object.hashAll(upcomingDeadlines),
        Object.hashAll(upcomingExams),
        continueStudying,
        isBrandNewUser,
      );
}
