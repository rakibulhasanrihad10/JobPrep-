import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:job_prep/core/localization/locale_controller.dart';
import 'package:job_prep/core/theme/app_theme.dart';
import 'package:job_prep/core/theme/reduce_effects_controller.dart';
import 'package:job_prep/core/theme/theme_controller.dart';
import 'package:job_prep/features/circulars/domain/entities/circular.dart';
import 'package:job_prep/features/circulars/domain/entities/circular_enums.dart';
import 'package:job_prep/features/circulars/presentation/providers/circulars_providers.dart';
import 'package:job_prep/features/circulars/presentation/screens/circulars_screen.dart';
import 'package:job_prep/l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'fake_circular_repository.dart';

void main() {
  final fixedNow = DateTime.utc(2026, 11, 10, 12);
  late SharedPreferences prefs;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    prefs = await SharedPreferences.getInstance();
  });

  List<Circular> sampleCirculars() {
    return [
      Circular(
        id: 'c-bcs',
        userId: 'u-1',
        title: '47th BCS General Cadre',
        sector: CircularSector.bcs,
        organizationName: 'BPSC',
        deadline: DateTime.utc(2026, 11, 12, 17), // +2 days -> red
        vacancies: 1200,
        priority: CircularPriority.urgent,
        applicationStatus: ApplicationStatus.applied,
        workflowStatus: CircularWorkflowStatus.preparing,
        createdAt: DateTime.utc(2026, 11, 1, 9),
      ),
      Circular(
        id: 'c-bank',
        userId: 'u-1',
        title: 'Assistant Director General',
        sector: CircularSector.bank,
        organizationName: 'Bangladesh Bank',
        deadline: DateTime.utc(2026, 11, 15, 17), // +5 days -> amber
        vacancies: 150,
        priority: CircularPriority.high,
        applicationStatus: ApplicationStatus.feePaid,
        workflowStatus: CircularWorkflowStatus.examUpcoming,
        createdAt: DateTime.utc(2026, 11, 9, 9),
      ),
      Circular(
        id: 'c-tech',
        userId: 'u-1',
        title: 'Senior Software Engineer',
        sector: CircularSector.private,
        organizationName: 'Brac IT',
        deadline: DateTime.utc(2026, 11, 25, 17), // +15 days -> green
        vacancies: 10,
        createdAt: DateTime.utc(2026, 11, 5, 9),
      ),
    ];
  }

  Future<void> pumpCircularsScreen(
    WidgetTester tester,
    FakeCircularRepository repository, {
    bool reduceEffects = true,
  }) async {
    tester.view.physicalSize = const Size(1280, 1000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await prefs.setBool(kReduceEffectsStorageKey, reduceEffects);
    await prefs.setString(kLocaleStorageKey, 'en');

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
          circularRepositoryProvider.overrideWithValue(repository),
          circularNowProvider.overrideWithValue(() => fixedNow),
        ],
        child: MaterialApp(
          theme: AppTheme.light(),
          darkTheme: AppTheme.dark(),
          themeMode: ThemeMode.dark,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const Scaffold(body: CircularsScreen()),
        ),
      ),
    );

    await tester.pumpAndSettle();
  }

  group('CircularsScreen - Searching, Filtering, and Sorting', () {
    testWidgets('searches by title and organization and handles empty matches',
        (tester) async {
      final repo = FakeCircularRepository(
        initialItems: sampleCirculars(),
        clock: () => fixedNow,
      );
      await pumpCircularsScreen(tester, repo);

      // Search by organization
      await tester.enterText(
        find.byKey(const ValueKey('circulars-search-field')),
        'Bangladesh Bank',
      );
      await tester.pumpAndSettle();

      expect(find.byKey(const ValueKey('circular-row-c-bank')), findsOneWidget);
      expect(find.byKey(const ValueKey('circular-row-c-bcs')), findsNothing);
      expect(find.byKey(const ValueKey('circular-row-c-tech')), findsNothing);

      // Search by title with zero matches -> filtered empty state
      await tester.enterText(
        find.byKey(const ValueKey('circulars-search-field')),
        'Nonexistent Role',
      );
      await tester.pumpAndSettle();

      expect(find.text('No matching circulars'), findsOneWidget);
      await tester.tap(find.byKey(const ValueKey('circulars-empty-clear-btn')));
      await tester.pumpAndSettle();

      expect(find.byKey(const ValueKey('circular-row-c-bcs')), findsOneWidget);
      expect(find.byKey(const ValueKey('circular-row-c-bank')), findsOneWidget);
      expect(find.byKey(const ValueKey('circular-row-c-tech')), findsOneWidget);
    });

    testWidgets(
        'filters by sector, application status, priority, workflow, and range',
        (tester) async {
      final repo = FakeCircularRepository(
        initialItems: sampleCirculars(),
        clock: () => fixedNow,
      );
      await pumpCircularsScreen(tester, repo);

      await tester.tap(
        find.byKey(const ValueKey('circulars-filter-toggle-btn')),
      );
      await tester.pumpAndSettle();

      // Sector = Bank
      await tester.tap(find.text('Bank').first);
      await tester.pumpAndSettle();
      expect(find.byKey(const ValueKey('circular-row-c-bank')), findsOneWidget);
      expect(find.byKey(const ValueKey('circular-row-c-bcs')), findsNothing);

      await tester
          .tap(find.byKey(const ValueKey('circulars-clear-filters-btn')));
      await tester.pumpAndSettle();

      // Application Status = Fee paid
      await tester.tap(find.text('Fee paid').first);
      await tester.pumpAndSettle();
      expect(find.byKey(const ValueKey('circular-row-c-bank')), findsOneWidget);
      expect(find.byKey(const ValueKey('circular-row-c-tech')), findsNothing);

      await tester
          .tap(find.byKey(const ValueKey('circulars-clear-filters-btn')));
      await tester.pumpAndSettle();

      // Priority = Urgent
      await tester.tap(find.text('Urgent').first);
      await tester.pumpAndSettle();
      expect(find.byKey(const ValueKey('circular-row-c-bcs')), findsOneWidget);
      expect(find.byKey(const ValueKey('circular-row-c-bank')), findsNothing);

      await tester
          .tap(find.byKey(const ValueKey('circulars-clear-filters-btn')));
      await tester.pumpAndSettle();

      // Workflow Status = Preparing
      await tester.tap(find.text('Preparing').first);
      await tester.pumpAndSettle();
      expect(find.byKey(const ValueKey('circular-row-c-bcs')), findsOneWidget);
      expect(find.byKey(const ValueKey('circular-row-c-tech')), findsNothing);

      await tester
          .tap(find.byKey(const ValueKey('circulars-clear-filters-btn')));
      await tester.pumpAndSettle();

      // Deadline range preset = 3 to 7 days
      await tester.tap(find.byKey(const ValueKey('filter-deadline-amber')));
      await tester.pumpAndSettle();
      expect(find.byKey(const ValueKey('circular-row-c-bank')), findsOneWidget);
      expect(find.byKey(const ValueKey('circular-row-c-bcs')), findsNothing);
      expect(find.byKey(const ValueKey('circular-row-c-tech')), findsNothing);
    });

    testWidgets('sorts circular rows by deadline, priority, and created date',
        (tester) async {
      final repo = FakeCircularRepository(
        initialItems: sampleCirculars(),
        clock: () => fixedNow,
      );
      await pumpCircularsScreen(tester, repo, reduceEffects: false);

      double dyFor(String id) =>
          tester.getTopLeft(find.byKey(ValueKey('circular-row-$id'))).dy;

      // Default deadlineAsc: c-bcs (Nov 12) < c-bank (Nov 15) < c-tech (Nov 25)
      expect(dyFor('c-bcs'), lessThan(dyFor('c-bank')));
      expect(dyFor('c-bank'), lessThan(dyFor('c-tech')));

      // Created date (newest): c-bank (Nov 9) < c-tech (Nov 5) < c-bcs (Nov 1)
      await tester.tap(find.byKey(const ValueKey('circulars-sort-dropdown')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Created date (newest)').last);
      await tester.pumpAndSettle();

      expect(dyFor('c-bank'), lessThan(dyFor('c-tech')));
      expect(dyFor('c-tech'), lessThan(dyFor('c-bcs')));

      // Priority (highest): c-bcs (urgent) < c-bank (high) < c-tech (medium)
      await tester.tap(find.byKey(const ValueKey('circulars-sort-dropdown')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Priority (highest)').last);
      await tester.pumpAndSettle();

      expect(dyFor('c-bcs'), lessThan(dyFor('c-bank')));
      expect(dyFor('c-bank'), lessThan(dyFor('c-tech')));
    });
  });
}
