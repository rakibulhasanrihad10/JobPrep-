import 'package:job_prep/features/calendar/domain/entities/calendar_event.dart';
import 'package:job_prep/features/circulars/domain/entities/circular.dart';
import 'package:job_prep/features/circulars/domain/entities/circular_enums.dart';

/// Maps an [ExamStage] to its corresponding [CalendarEventKind].
CalendarEventKind calendarKindForExamStage(ExamStage stage) {
  return switch (stage) {
    ExamStage.preliminary => CalendarEventKind.preliminary,
    ExamStage.written => CalendarEventKind.written,
    ExamStage.viva => CalendarEventKind.viva,
    ExamStage.practical => CalendarEventKind.practical,
    ExamStage.other => CalendarEventKind.other,
  };
}

/// Groups application deadlines and scheduled exam dates from [circulars] by
/// normalized calendar day (`DateTime(year, month, day)`).
///
/// By default, archived circulars (`workflowStatus == archived`) are omitted
/// unless [includeArchived] is `true`. When [useUtc] is `true`, timestamps are
/// normalized in UTC; otherwise they are converted to local calendar dates.
///
/// Events within each day are sorted deterministically by exact time, then
/// [CalendarEventKind] order, then circular title.
Map<DateTime, List<CalendarEvent>> groupCircularEventsByDate(
  List<Circular> circulars, {
  bool includeArchived = false,
  bool useUtc = false,
}) {
  final grouped = <DateTime, List<CalendarEvent>>{};

  void addEvent(DateTime rawDate, CalendarEvent event) {
    final aligned = useUtc ? rawDate.toUtc() : rawDate.toLocal();
    final dayKey = normalizeCalendarDate(aligned);
    grouped.putIfAbsent(dayKey, () => <CalendarEvent>[]).add(
          CalendarEvent(
            id: event.id,
            circular: event.circular,
            kind: event.kind,
            date: aligned,
            examDate: event.examDate,
          ),
        );
  }

  for (final circular in circulars) {
    if (!includeArchived &&
        circular.workflowStatus == CircularWorkflowStatus.archived) {
      continue;
    }

    final deadline = circular.deadline;
    if (deadline != null) {
      addEvent(
        deadline,
        CalendarEvent(
          id: 'deadline-${circular.id}',
          circular: circular,
          kind: CalendarEventKind.deadline,
          date: deadline,
        ),
      );
    }

    for (var i = 0; i < circular.examDates.length; i++) {
      final exam = circular.examDates[i];
      final stage = ExamStage.fromValue(exam.stage);
      final examId = exam.id.trim().isNotEmpty
          ? exam.id
          : '${circular.id}-$i-${stage.value}';
      addEvent(
        exam.examDate,
        CalendarEvent(
          id: 'exam-$examId',
          circular: circular,
          kind: calendarKindForExamStage(stage),
          date: exam.examDate,
          examDate: exam,
        ),
      );
    }
  }

  return Map<DateTime, List<CalendarEvent>>.unmodifiable({
    for (final entry in grouped.entries)
      entry.key: List<CalendarEvent>.unmodifiable(
        List<CalendarEvent>.of(entry.value)..sort(_compareEvents),
      ),
  });
}

int _compareEvents(CalendarEvent a, CalendarEvent b) {
  final timeCmp = a.date.compareTo(b.date);
  if (timeCmp != 0) return timeCmp;

  final kindCmp = a.kind.index.compareTo(b.kind.index);
  if (kindCmp != 0) return kindCmp;

  final titleCmp =
      a.circular.title.toLowerCase().compareTo(b.circular.title.toLowerCase());
  if (titleCmp != 0) return titleCmp;

  return a.id.compareTo(b.id);
}

/// Returns all sorted [CalendarEvent]s falling on [day], or an empty list.
List<CalendarEvent> eventsForCalendarDay(
  Map<DateTime, List<CalendarEvent>> groupedEvents,
  DateTime day,
) {
  final key = normalizeCalendarDate(day);
  return groupedEvents[key] ?? const [];
}

/// Returns unique [CalendarEventKind]s scheduled on [day] in display order.
List<CalendarEventKind> kindsForCalendarDay(
  Map<DateTime, List<CalendarEvent>> groupedEvents,
  DateTime day,
) {
  final dayEvents = eventsForCalendarDay(groupedEvents, day);
  if (dayEvents.isEmpty) return const [];

  final seen = <CalendarEventKind>{};
  for (final event in dayEvents) {
    seen.add(event.kind);
  }
  final ordered = CalendarEventKind.values.where(seen.contains).toList();
  return List<CalendarEventKind>.unmodifiable(ordered);
}

/// Counts total events per [CalendarEventKind] falling within [year]/[month].
Map<CalendarEventKind, int> countMonthlyEventsByKind(
  Map<DateTime, List<CalendarEvent>> groupedEvents, {
  required int year,
  required int month,
}) {
  final counts = <CalendarEventKind, int>{};
  for (final entry in groupedEvents.entries) {
    if (entry.key.year == year && entry.key.month == month) {
      for (final event in entry.value) {
        counts[event.kind] = (counts[event.kind] ?? 0) + 1;
      }
    }
  }
  return Map<CalendarEventKind, int>.unmodifiable(counts);
}

/// Returns 7 Dart weekday constants (`DateTime.monday = 1` ..
/// `DateTime.sunday = 7`) ordered starting at [firstDayOfWeek].
List<int> orderedWeekdaysFrom({required int firstDayOfWeek}) {
  final safeStart = ((firstDayOfWeek - 1) % 7 + 7) % 7 + 1;
  return List<int>.unmodifiable(
    List<int>.generate(7, (offset) => ((safeStart - 1 + offset) % 7) + 1),
  );
}

/// Builds a complete 7-column month grid of [CalendarDayCell] items for
/// [year]/[month], starting each week on [firstDayOfWeek] (`1..7`).
///
/// Uses calendar constructor arithmetic (`DateTime(year, month, day)`) rather
/// than fixed `Duration` offsets so Daylight Saving Time changes never skew
/// dates.
List<CalendarDayCell> buildCalendarMonthGrid({
  required int year,
  required int month,
  required int firstDayOfWeek,
}) {
  final safeStart = ((firstDayOfWeek - 1) % 7 + 7) % 7 + 1;
  final firstOfMonth = DateTime(year, month);
  final daysInMonth = DateTime(year, month + 1, 0).day;
  final leadingDays = (firstOfMonth.weekday - safeStart + 7) % 7;
  final totalCells = ((leadingDays + daysInMonth + 6) ~/ 7) * 7;

  return List<CalendarDayCell>.unmodifiable(
    List<CalendarDayCell>.generate(totalCells, (index) {
      final dayOffset = index - leadingDays + 1;
      final cellDate = DateTime(year, month, dayOffset);
      return CalendarDayCell(
        date: cellDate,
        inCurrentMonth: cellDate.year == year && cellDate.month == month,
      );
    }),
  );
}
