import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:job_prep/core/theme/app_colors.dart';
import 'package:job_prep/features/calendar/domain/entities/calendar_event.dart';
import 'package:job_prep/features/calendar/domain/utils/calendar_grouping.dart';
import 'package:job_prep/features/calendar/presentation/providers/calendar_providers.dart';
import 'package:job_prep/features/calendar/presentation/utils/calendar_locale_l10n.dart';
import 'package:job_prep/features/circulars/domain/entities/circular.dart';
import 'package:job_prep/features/circulars/domain/entities/circular_enums.dart';
import 'package:job_prep/features/circulars/domain/entities/circular_exam_date.dart';
import 'package:job_prep/features/circulars/presentation/providers/circulars_providers.dart';

import '../circulars/fake_circular_repository.dart';

void main() {
  setUpAll(() async {
    await initializeDateFormatting('en');
    await initializeDateFormatting('bn');
    await initializeDateFormatting('en_GB');
    await initializeDateFormatting('fr');
  });

  group('groupCircularEventsByDate & helpers', () {
    test(
        'groups deadlines and all exam stages by normalized day sorted '
        'deterministically', () {
      final circulars = [
        Circular(
          id: 'c-bcs',
          title: '47th BCS',
          deadline: DateTime.utc(2026, 11, 10, 17),
          examDates: [
            CircularExamDate(
              id: 'ed-viva',
              circularId: 'c-bcs',
              stage: 'viva',
              examDate: DateTime.utc(2026, 11, 10, 15),
            ),
            CircularExamDate(
              id: 'ed-prelim',
              circularId: 'c-bcs',
              stage: 'preliminary',
              examDate: DateTime.utc(2026, 11, 10, 10),
            ),
          ],
        ),
        Circular(
          id: 'c-bank',
          title: 'Bangladesh Bank AD',
          deadline: DateTime.utc(2026, 11, 15, 17),
          examDates: [
            CircularExamDate(
              id: 'ed-written',
              circularId: 'c-bank',
              stage: 'written',
              examDate: DateTime.utc(2026, 11, 10, 10),
            ),
            CircularExamDate(
              id: 'ed-practical',
              circularId: 'c-bank',
              stage: 'practical',
              examDate: DateTime.utc(2026, 12, 2, 9),
            ),
          ],
        ),
        Circular(
          id: 'c-archived',
          title: 'Archived Circular',
          workflowStatus: CircularWorkflowStatus.archived,
          deadline: DateTime.utc(2026, 11, 10, 12),
        ),
      ];

      final grouped = groupCircularEventsByDate(circulars, useUtc: true);

      // Archived omitted by default.
      final nov10 = eventsForCalendarDay(grouped, DateTime(2026, 11, 10));
      expect(nov10, hasLength(4));
      // Sorted by time ascending: 10:00 preliminary, 10:00 written, 15:00 viva,
      // 17:00 deadline.
      expect(
        nov10.map((e) => e.kind),
        [
          CalendarEventKind.preliminary,
          CalendarEventKind.written,
          CalendarEventKind.viva,
          CalendarEventKind.deadline,
        ],
      );
      expect(nov10[0].circular.id, 'c-bcs');
      expect(nov10[1].circular.id, 'c-bank');

      // Same-day unique kinds sorted in CalendarEventKind order.
      expect(
        kindsForCalendarDay(grouped, DateTime(2026, 11, 10)),
        [
          CalendarEventKind.deadline,
          CalendarEventKind.preliminary,
          CalendarEventKind.written,
          CalendarEventKind.viva,
        ],
      );

      final nov15 = eventsForCalendarDay(grouped, DateTime(2026, 11, 15));
      expect(nov15.single.isDeadline, isTrue);

      final dec2 = eventsForCalendarDay(grouped, DateTime(2026, 12, 2));
      expect(dec2.single.kind, CalendarEventKind.practical);

      // Monthly count aggregates strictly for November 2026.
      final novCounts = countMonthlyEventsByKind(
        grouped,
        year: 2026,
        month: 11,
      );
      expect(novCounts, {
        CalendarEventKind.preliminary: 1,
        CalendarEventKind.written: 1,
        CalendarEventKind.viva: 1,
        CalendarEventKind.deadline: 2,
      });

      // includeArchived: true retains archived circulars.
      final withArchived = groupCircularEventsByDate(
        circulars,
        includeArchived: true,
        useUtc: true,
      );
      expect(
        eventsForCalendarDay(withArchived, DateTime(2026, 11, 10)),
        hasLength(5),
      );
    });
  });

  group('buildCalendarMonthGrid & orderedWeekdaysFrom', () {
    test('orders weekdays starting at any locale start day', () {
      expect(
        orderedWeekdaysFrom(firstDayOfWeek: DateTime.sunday),
        [7, 1, 2, 3, 4, 5, 6],
      );
      expect(
        orderedWeekdaysFrom(firstDayOfWeek: DateTime.monday),
        [1, 2, 3, 4, 5, 6, 7],
      );
      expect(
        orderedWeekdaysFrom(firstDayOfWeek: DateTime.saturday),
        [6, 7, 1, 2, 3, 4, 5],
      );
    });

    test(
        'builds November 2026 month grid accurately for Sunday, Monday, and '
        'Saturday week starts', () {
      // Nov 1, 2026 is Sunday.
      final sundayStart = buildCalendarMonthGrid(
        year: 2026,
        month: 11,
        firstDayOfWeek: DateTime.sunday,
      );
      expect(sundayStart, hasLength(35));
      expect(sundayStart.first.date, DateTime(2026, 11));
      expect(sundayStart.first.inCurrentMonth, isTrue);
      expect(sundayStart[30].date, DateTime(2026, 12));
      expect(sundayStart[30].inCurrentMonth, isFalse);
      expect(sundayStart.last.date, DateTime(2026, 12, 5));

      final mondayStart = buildCalendarMonthGrid(
        year: 2026,
        month: 11,
        firstDayOfWeek: DateTime.monday,
      );
      expect(mondayStart, hasLength(42));
      expect(mondayStart.first.date, DateTime(2026, 10, 26));
      expect(mondayStart.first.inCurrentMonth, isFalse);
      expect(mondayStart[6].date, DateTime(2026, 11));
      expect(mondayStart[6].inCurrentMonth, isTrue);

      final saturdayStart = buildCalendarMonthGrid(
        year: 2026,
        month: 11,
        firstDayOfWeek: DateTime.saturday,
      );
      expect(saturdayStart, hasLength(35));
      expect(saturdayStart.first.date, DateTime(2026, 10, 31));
      expect(saturdayStart.first.inCurrentMonth, isFalse);
      expect(saturdayStart[1].date, DateTime(2026, 11));
    });

    test('handles leap year February and exact 4-week February cleanly', () {
      // Feb 2026 starts on Sunday with 28 days -> exact 28 cells (4 rows).
      final feb2026 = buildCalendarMonthGrid(
        year: 2026,
        month: 2,
        firstDayOfWeek: DateTime.sunday,
      );
      expect(feb2026, hasLength(28));
      expect(feb2026.every((c) => c.inCurrentMonth), isTrue);

      // Feb 2024 is leap year (29 days) starting Thursday.
      final feb2024 = buildCalendarMonthGrid(
        year: 2024,
        month: 2,
        firstDayOfWeek: DateTime.monday,
      );
      expect(feb2024.where((c) => c.inCurrentMonth), hasLength(29));
      expect(feb2024.first.date, DateTime(2024, 1, 29));
    });
  });

  group('CalendarLocaleL10n & CalendarController', () {
    test('resolves locale week starts, localized month/day names, and colors',
        () {
      expect(
        CalendarLocaleL10n.firstDayOfWeekFromLocale(const Locale('en')),
        DateTime.sunday,
      );
      expect(
        CalendarLocaleL10n.firstDayOfWeekFromLocale(const Locale('bn')),
        DateTime.sunday,
      );
      expect(
        CalendarLocaleL10n.firstDayOfWeekFromLocale(const Locale('en', 'GB')),
        DateTime.monday,
      );
      expect(
        CalendarLocaleL10n.firstDayOfWeekFromLocale(const Locale('fr')),
        DateTime.monday,
      );

      expect(
        CalendarLocaleL10n.monthYearTitle(
          DateTime(2026, 11),
          locale: const Locale('en'),
          useBanglaDigits: false,
        ),
        'November 2026',
      );
      expect(
        CalendarLocaleL10n.monthYearTitle(
          DateTime(2026, 11),
          locale: const Locale('bn'),
          useBanglaDigits: true,
        ),
        'নভেম্বর ২০২৬',
      );
      expect(
        CalendarLocaleL10n.weekdayShortLabel(
          DateTime.sunday,
          locale: const Locale('bn'),
        ),
        'রবি',
      );

      // Distinct colors for deadline, preliminary, written, and viva in both
      // dark and light tokens.
      for (final palette in [AppColorsToken.dark(), AppColorsToken.light()]) {
        final distinctColors = {
          CalendarLocaleL10n.colorForKind(CalendarEventKind.deadline, palette),
          CalendarLocaleL10n.colorForKind(
            CalendarEventKind.preliminary,
            palette,
          ),
          CalendarLocaleL10n.colorForKind(CalendarEventKind.written, palette),
          CalendarLocaleL10n.colorForKind(CalendarEventKind.viva, palette),
        };
        expect(distinctColors, hasLength(4));
      }
    });

    test('CalendarController handles month wrapping, selection, and goToToday',
        () {
      var now = DateTime.utc(2026, 1, 15, 10);
      final container = ProviderContainer(
        overrides: [
          circularRepositoryProvider.overrideWithValue(
            FakeCircularRepository(),
          ),
          circularNowProvider.overrideWithValue(() => now),
        ],
      );
      addTearDown(container.dispose);

      final initial = container.read(calendarControllerProvider);
      expect(initial.displayedMonth, DateTime(2026));
      expect(initial.selectedDate, DateTime(2026, 1, 15));

      final controller = container.read(calendarControllerProvider.notifier)
        ..previousMonth();
      expect(
        container.read(calendarControllerProvider).displayedMonth,
        DateTime(2025, 12),
      );

      controller.nextMonth();
      expect(
        container.read(calendarControllerProvider).displayedMonth,
        DateTime(2026),
      );

      // Selecting adjacent-month cell switches displayedMonth cleanly.
      controller.selectDay(DateTime(2026, 2, 3));
      expect(
        container.read(calendarControllerProvider).selectedDate,
        DateTime(2026, 2, 3),
      );
      expect(
        container.read(calendarControllerProvider).displayedMonth,
        DateTime(2026, 2),
      );

      now = DateTime.utc(2026, 11, 20, 8);
      controller.goToToday();
      expect(
        container.read(calendarControllerProvider).displayedMonth,
        DateTime(2026, 11),
      );
      expect(
        container.read(calendarControllerProvider).selectedDate,
        DateTime(2026, 11, 20),
      );
    });
  });
}
