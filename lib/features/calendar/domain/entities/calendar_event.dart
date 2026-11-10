import 'package:flutter/foundation.dart' show immutable;
import 'package:job_prep/features/circulars/domain/entities/circular.dart';
import 'package:job_prep/features/circulars/domain/entities/circular_exam_date.dart';

/// Category of an event plotted on the exam calendar.
enum CalendarEventKind {
  deadline,
  preliminary,
  written,
  viva,
  practical,
  other,
}

/// Immutable calendar schedule entry backed by either a circular's
/// `deadline` or a [CircularExamDate].
@immutable
class CalendarEvent {
  /// Creates a [CalendarEvent].
  const CalendarEvent({
    required this.id,
    required this.circular,
    required this.kind,
    required this.date,
    this.examDate,
  });

  /// Stable identifier (`deadline-<circularId>` or `exam-<examDateId>`).
  final String id;

  /// Parent circular opened when tapping this agenda item.
  final Circular circular;

  /// Semantic category determining badge label and color token.
  final CalendarEventKind kind;

  /// Aligned local or UTC date/time of the deadline or exam stage.
  final DateTime date;

  /// Associated exam date entity when [kind] is an exam stage.
  final CircularExamDate? examDate;

  /// Whether this entry represents an application deadline.
  bool get isDeadline => kind == CalendarEventKind.deadline;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CalendarEvent &&
        other.id == id &&
        other.circular == circular &&
        other.kind == kind &&
        other.date == date &&
        other.examDate == examDate;
  }

  @override
  int get hashCode => Object.hash(id, circular, kind, date, examDate);
}

/// Single day cell rendered in the 7-column month calendar grid.
@immutable
class CalendarDayCell {
  /// Creates a [CalendarDayCell].
  const CalendarDayCell({
    required this.date,
    required this.inCurrentMonth,
  });

  /// Date normalized at midnight (`year, month, day`).
  final DateTime date;

  /// Whether [date] belongs to the active displayed month.
  final bool inCurrentMonth;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CalendarDayCell &&
        other.date == date &&
        other.inCurrentMonth == inCurrentMonth;
  }

  @override
  int get hashCode => Object.hash(date, inCurrentMonth);
}

/// Returns [date] truncated to calendar year, month, and day at `00:00:00`.
DateTime normalizeCalendarDate(DateTime date) {
  return DateTime(date.year, date.month, date.day);
}

/// Returns whether [a] and [b] fall on the same year, month, and day.
bool isSameCalendarDate(DateTime a, DateTime b) {
  return a.year == b.year && a.month == b.month && a.day == b.day;
}
