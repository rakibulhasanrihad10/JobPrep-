import 'package:flutter/foundation.dart' show immutable;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:job_prep/features/calendar/domain/entities/calendar_event.dart';
import 'package:job_prep/features/calendar/domain/utils/calendar_grouping.dart';
import 'package:job_prep/features/circulars/presentation/providers/circulars_providers.dart';

/// Immutable active month and selected day state for `CalendarScreen`.
@immutable
class CalendarViewState {
  /// Creates a [CalendarViewState].
  const CalendarViewState({
    required this.displayedMonth,
    required this.selectedDate,
  });

  /// First day of the currently visible month (`DateTime(year, month)`).
  final DateTime displayedMonth;

  /// Currently selected calendar day (`DateTime(year, month, day)`).
  final DateTime selectedDate;

  /// Returns an updated copy of this [CalendarViewState].
  CalendarViewState copyWith({
    DateTime? displayedMonth,
    DateTime? selectedDate,
  }) {
    return CalendarViewState(
      displayedMonth: displayedMonth ?? this.displayedMonth,
      selectedDate: selectedDate ?? this.selectedDate,
    );
  }
}

/// Manages active month navigation and day selection on the Calendar screen.
class CalendarController extends Notifier<CalendarViewState> {
  @override
  CalendarViewState build() {
    final today = _normalizedToday();
    return CalendarViewState(
      displayedMonth: DateTime(today.year, today.month),
      selectedDate: today,
    );
  }

  DateTime _normalizedToday() {
    final now = ref.read(circularNowProvider)();
    final aligned = now.isUtc ? now.toUtc() : now.toLocal();
    return normalizeCalendarDate(aligned);
  }

  /// Selects [day] for the agenda list, also updating
  /// [CalendarViewState.displayedMonth] when the tapped cell belongs to an
  /// adjacent month.
  void selectDay(DateTime day) {
    final normalized = normalizeCalendarDate(day);
    state = state.copyWith(
      selectedDate: normalized,
      displayedMonth: DateTime(normalized.year, normalized.month),
    );
  }

  /// Navigates one month backward.
  void previousMonth() {
    final current = state.displayedMonth;
    state = state.copyWith(
      displayedMonth: DateTime(current.year, current.month - 1),
    );
  }

  /// Navigates one month forward.
  void nextMonth() {
    final current = state.displayedMonth;
    state = state.copyWith(
      displayedMonth: DateTime(current.year, current.month + 1),
    );
  }

  /// Jumps the visible month and active day selection back to today.
  void goToToday() {
    final today = _normalizedToday();
    state = state.copyWith(
      displayedMonth: DateTime(today.year, today.month),
      selectedDate: today,
    );
  }
}

/// Provides the calendar month & selected-day state controller.
final NotifierProvider<CalendarController, CalendarViewState>
    calendarControllerProvider =
    NotifierProvider<CalendarController, CalendarViewState>(
  CalendarController.new,
);

/// Groups all deadlines and exam dates across active circulars by calendar
/// day.
final Provider<AsyncValue<Map<DateTime, List<CalendarEvent>>>>
    calendarEventsByDateProvider =
    Provider<AsyncValue<Map<DateTime, List<CalendarEvent>>>>((ref) {
  final now = ref.watch(circularNowProvider)();
  final circularsAsync = ref.watch(circularsListProvider);
  return circularsAsync.whenData(
    (circulars) => groupCircularEventsByDate(
      circulars,
      useUtc: now.isUtc,
    ),
  );
});

/// Resolves the ordered list of [CalendarEvent]s matching the currently
/// selected calendar day.
final Provider<AsyncValue<List<CalendarEvent>>> selectedDayEventsProvider =
    Provider<AsyncValue<List<CalendarEvent>>>((ref) {
  final eventsAsync = ref.watch(calendarEventsByDateProvider);
  final selectedDate = ref.watch(
    calendarControllerProvider.select((s) => s.selectedDate),
  );
  return eventsAsync.whenData(
    (grouped) => eventsForCalendarDay(grouped, selectedDate),
  );
});
