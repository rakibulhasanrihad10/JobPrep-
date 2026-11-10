import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:job_prep/core/localization/locale_controller.dart';
import 'package:job_prep/core/router/app_router.dart';
import 'package:job_prep/core/theme/app_colors.dart';
import 'package:job_prep/core/theme/app_theme.dart';
import 'package:job_prep/core/theme/reduce_effects_controller.dart';
import 'package:job_prep/core/theme/theme_controller.dart';
import 'package:job_prep/features/auth/presentation/providers/auth_providers.dart';
import 'package:job_prep/features/calendar/presentation/screens/calendar_screen.dart';
import 'package:job_prep/features/circulars/domain/entities/circular.dart';
import 'package:job_prep/features/circulars/domain/entities/circular_enums.dart';
import 'package:job_prep/features/circulars/domain/entities/circular_exam_date.dart';
import 'package:job_prep/features/circulars/presentation/providers/circulars_providers.dart';
import 'package:job_prep/features/circulars/presentation/providers/exam_date_providers.dart';
import 'package:job_prep/features/circulars/presentation/widgets/circular_detail_view.dart';
import 'package:job_prep/l10n/app_localizations.dart';
import 'package:job_prep/main.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../auth/fake_auth_repository.dart';
import '../circulars/fake_circular_repository.dart';
import '../circulars/fake_exam_date_repository.dart';

void main() {
  final fixedNow = DateTime.utc(2026, 11, 10, 12);
  late SharedPreferences prefs;

  setUpAll(() async {
    await initializeDateFormatting('en');
    await initializeDateFormatting('bn');
    await initializeDateFormatting('en_GB');
  });

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    prefs = await SharedPreferences.getInstance();
  });

  List<Circular> sampleCalendarCirculars() {
    return [
      Circular(
        id: 'c-bcs',
        userId: 'u-1',
        title: '47th BCS General Cadre',
        organizationName: 'BPSC',
        sector: CircularSector.bcs,
        deadline: DateTime.utc(2026, 11, 10, 17),
        workflowStatus: CircularWorkflowStatus.preparing,
        examDates: [
          CircularExamDate(
            id: 'ed-1',
            circularId: 'c-bcs',
            stage: 'preliminary',
            examDate: DateTime.utc(2026, 11, 10, 10),
            venue: 'Dhaka College',
          ),
          CircularExamDate(
            id: 'ed-2',
            circularId: 'c-bcs',
            stage: 'written',
            examDate: DateTime.utc(2026, 11, 18, 10),
          ),
          CircularExamDate(
            id: 'ed-3',
            circularId: 'c-bcs',
            stage: 'viva',
            examDate: DateTime.utc(2026, 12, 5, 11),
            venue: 'BPSC Agargaon',
          ),
        ],
      ),
      Circular(
        id: 'c-bb',
        userId: 'u-1',
        title: 'Bangladesh Bank AD',
        organizationName: 'Bangladesh Bank',
        sector: CircularSector.bank,
        deadline: DateTime.utc(2026, 11, 15, 17),
        workflowStatus: CircularWorkflowStatus.applied,
        examDates: [
          CircularExamDate(
            id: 'ed-4',
            circularId: 'c-bb',
            stage: 'written',
            examDate: DateTime.utc(2026, 11, 10, 14),
          ),
          CircularExamDate(
            id: 'ed-5',
            circularId: 'c-bb',
            stage: 'viva',
            examDate: DateTime.utc(2026, 11, 10, 16),
          ),
        ],
      ),
    ];
  }

  Future<void> pumpStandaloneCalendar(
    WidgetTester tester, {
    required FakeCircularRepository circularRepo,
    Size viewportSize = const Size(1280, 900),
    ThemeMode themeMode = ThemeMode.dark,
    Locale locale = const Locale('en'),
    ValueChanged<Circular>? onOpenCircular,
  }) async {
    tester.view.physicalSize = viewportSize;
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await prefs.setBool(kReduceEffectsStorageKey, true);
    await prefs.setString(kLocaleStorageKey, locale.languageCode);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
          circularRepositoryProvider.overrideWithValue(circularRepo),
          circularNowProvider.overrideWithValue(() => fixedNow),
        ],
        child: MaterialApp(
          theme: AppTheme.light(),
          darkTheme: AppTheme.dark(),
          themeMode: themeMode,
          locale: locale,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: const [
            Locale('en', 'GB'),
            Locale('en'),
            Locale('bn'),
          ],
          home: Scaffold(
            body: CalendarScreen(onOpenCircular: onOpenCircular),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  group('CalendarScreen Widget & Navigation Tests', () {
    testWidgets(
        'renders desktop month view with distinct stage/deadline colors, day '
        'selection, and month navigation', (tester) async {
      final repo = FakeCircularRepository(
        initialItems: sampleCalendarCirculars(),
        clock: () => fixedNow,
      );
      Circular? openedCircular;

      await pumpStandaloneCalendar(
        tester,
        circularRepo: repo,
        onOpenCircular: (c) => openedCircular = c,
      );

      expect(
        find.byKey(const ValueKey('calendar-desktop-layout')),
        findsOneWidget,
      );
      expect(find.byKey(const ValueKey('calendar-month-title')), findsOne);
      expect(find.text('November 2026'), findsOneWidget);

      // Default en locale starts week on Sunday.
      expect(
        find.descendant(
          of: find.byKey(const ValueKey('calendar-weekday-col-0')),
          matching: find.text('Sun'),
        ),
        findsOneWidget,
      );
      expect(
        find.descendant(
          of: find.byKey(const ValueKey('calendar-weekday-col-6')),
          matching: find.text('Sat'),
        ),
        findsOneWidget,
      );

      // Nov 10 has all 4 event types with distinct token colors.
      final darkColors = AppColorsToken.dark();
      Color dotColor(String kind) {
        final box = tester.widget<Container>(
          find.byKey(ValueKey('calendar-dot-2026-11-10-$kind')),
        );
        return (box.decoration! as BoxDecoration).color!;
      }

      expect(dotColor('deadline'), darkColors.danger);
      expect(dotColor('preliminary'), darkColors.goldAccent);
      expect(dotColor('written'), darkColors.info);
      expect(dotColor('viva'), darkColors.success);

      // Default selected day (Nov 10) lists 4 agenda events.
      expect(find.text('4 events'), findsOneWidget);
      expect(
        find.byKey(const ValueKey('calendar-agenda-item-deadline-c-bcs')),
        findsOneWidget,
      );

      // Tapping Nov 15 switches agenda card to Nov 15 deadline.
      await tester.tap(find.byKey(const ValueKey('calendar-day-2026-11-15')));
      await tester.pumpAndSettle();
      expect(find.text('1 event'), findsOneWidget);
      expect(
        find.byKey(const ValueKey('calendar-agenda-item-deadline-c-bb')),
        findsOneWidget,
      );

      // Tapping an agenda item opens its parent circular.
      await tester.tap(
        find.byKey(const ValueKey('calendar-agenda-item-deadline-c-bb')),
      );
      await tester.pumpAndSettle();
      expect(openedCircular?.id, 'c-bb');

      // Tapping empty day shows empty agenda copy.
      await tester.tap(find.byKey(const ValueKey('calendar-day-2026-11-12')));
      await tester.pumpAndSettle();
      expect(
        find.byKey(const ValueKey('calendar-agenda-empty-text')),
        findsOneWidget,
      );

      // Navigating to December 2026 shows viva on Dec 5;
      // Today returns to Nov 10.
      await tester.tap(find.byKey(const ValueKey('calendar-next-month-btn')));
      await tester.pumpAndSettle();
      expect(find.text('December 2026'), findsOneWidget);
      await tester.tap(find.byKey(const ValueKey('calendar-day-2026-12-5')));
      await tester.pumpAndSettle();
      expect(
        find.byKey(const ValueKey('calendar-agenda-item-exam-ed-3')),
        findsOneWidget,
      );

      await tester.tap(find.byKey(const ValueKey('calendar-today-btn')));
      await tester.pumpAndSettle();
      expect(find.text('November 2026'), findsOneWidget);
      expect(find.text('4 events'), findsOneWidget);
    });

    testWidgets(
        'uses compact month view stacked above agenda on mobile and opens '
        'full-screen circular detail via GoRouter', (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await prefs.setBool(kReduceEffectsStorageKey, true);
      final authRepo = FakeAuthRepository.authenticated();
      addTearDown(authRepo.dispose);

      final circulars = sampleCalendarCirculars();
      final circularRepo = FakeCircularRepository(
        initialItems: circulars,
        clock: () => fixedNow,
      );
      final examRepo = FakeExamDateRepository(
        initialItems: circulars.expand((c) => c.examDates).toList(),
        clock: () => fixedNow,
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            sharedPreferencesProvider.overrideWithValue(prefs),
            authRepositoryProvider.overrideWithValue(authRepo),
            circularRepositoryProvider.overrideWithValue(circularRepo),
            examDateRepositoryProvider.overrideWithValue(examRepo),
            circularNowProvider.overrideWithValue(() => fixedNow),
            initialRouteLocationProvider.overrideWithValue('/calendar'),
          ],
          child: const JobPrepApp(),
        ),
      );
      await tester.pumpAndSettle();

      expect(
        find.byKey(const ValueKey('calendar-mobile-layout')),
        findsOneWidget,
      );
      expect(
        find.byKey(const ValueKey('calendar-month-card-compact')),
        findsOneWidget,
      );

      final monthRect = tester.getRect(
        find.byKey(const ValueKey('calendar-month-card-compact')),
      );
      final agendaRect = tester.getRect(
        find.byKey(const ValueKey('calendar-agenda-card')),
      );
      expect(monthRect.bottom, lessThanOrEqualTo(agendaRect.top));

      // Scroll to Nov 10 agenda item and tap it to open CircularDetailView.
      final itemFinder =
          find.byKey(const ValueKey('calendar-agenda-item-deadline-c-bcs'));
      await tester.ensureVisible(itemFinder);
      await tester.pumpAndSettle();
      await tester.tap(itemFinder);
      await tester.pumpAndSettle();

      expect(find.byType(CircularDetailView), findsOneWidget);
      expect(find.text('47th BCS General Cadre'), findsOneWidget);

      // Back button returns to CalendarScreen cleanly.
      await tester.tap(find.byKey(const ValueKey('circular-detail-back-btn')));
      await tester.pumpAndSettle();
      expect(find.byType(CalendarScreen), findsOneWidget);
    });

    testWidgets('starts week on locale start day (en_GB Monday vs bn Sunday)',
        (tester) async {
      final repo = FakeCircularRepository(
        initialItems: sampleCalendarCirculars(),
        clock: () => fixedNow,
      );

      // en_GB starts weeks on Monday.
      await pumpStandaloneCalendar(
        tester,
        circularRepo: repo,
        locale: const Locale('en', 'GB'),
      );
      expect(
        find.descendant(
          of: find.byKey(const ValueKey('calendar-weekday-col-0')),
          matching: find.text('Mon'),
        ),
        findsOneWidget,
      );
      expect(
        find.descendant(
          of: find.byKey(const ValueKey('calendar-weekday-col-6')),
          matching: find.text('Sun'),
        ),
        findsOneWidget,
      );
      expect(find.text('Week starts on Monday'), findsOneWidget);

      // Bangla on tight 360px mobile in light mode renders Bangla month,
      // weekday names, and Bangla digits cleanly without overflow.
      await pumpStandaloneCalendar(
        tester,
        circularRepo: repo,
        viewportSize: const Size(360, 812),
        themeMode: ThemeMode.light,
        locale: const Locale('bn'),
      );
      expect(find.text('নভেম্বর ২০২৬'), findsOneWidget);
      expect(
        find.descendant(
          of: find.byKey(const ValueKey('calendar-weekday-col-0')),
          matching: find.text('রবি'),
        ),
        findsOneWidget,
      );
      expect(
        find.descendant(
          of: find.byKey(const ValueKey('calendar-weekday-col-6')),
          matching: find.text('শনি'),
        ),
        findsOneWidget,
      );
      expect(find.text('৪টি ইভেন্ট'), findsOneWidget);
      expect(find.text('আবেদনের শেষ দিন'), findsWidgets);
    });
  });
}
