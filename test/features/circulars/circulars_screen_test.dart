import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:job_prep/core/localization/locale_controller.dart';
import 'package:job_prep/core/theme/app_theme.dart';
import 'package:job_prep/core/theme/app_theme_tokens.dart';
import 'package:job_prep/core/theme/reduce_effects_controller.dart';
import 'package:job_prep/core/theme/theme_controller.dart';
import 'package:job_prep/features/circulars/domain/entities/circular.dart';
import 'package:job_prep/features/circulars/domain/entities/circular_enums.dart';
import 'package:job_prep/features/circulars/domain/entities/circular_filter.dart';
import 'package:job_prep/features/circulars/domain/errors/circular_failure.dart';
import 'package:job_prep/features/circulars/domain/repositories/circular_repository.dart';
import 'package:job_prep/features/circulars/presentation/providers/circulars_providers.dart';
import 'package:job_prep/features/circulars/presentation/screens/circulars_screen.dart';
import 'package:job_prep/features/circulars/presentation/widgets/circular_badges.dart';
import 'package:job_prep/l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'fake_circular_repository.dart';

class _CompleterCircularRepository implements CircularRepository {
  _CompleterCircularRepository(this.completer);

  final Completer<List<Circular>> completer;

  @override
  Future<List<Circular>> getCirculars({CircularFilter? filter}) =>
      completer.future;

  @override
  Future<Circular?> getCircularById(String id) async => null;

  @override
  Future<Circular> createCircular(Circular circular) =>
      throw UnimplementedError();

  @override
  Future<Circular> updateCircular(Circular circular) =>
      throw UnimplementedError();

  @override
  Future<void> deleteCircular(String id) => throw UnimplementedError();
}

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
        id: 'c-green',
        userId: 'u-1',
        title: 'Senior Software Engineer',
        sector: CircularSector.private,
        organizationName: 'Brac IT',
        deadline: DateTime.utc(2026, 11, 25, 17), // +15 days -> green
        vacancies: 12,
        applicationStatus: ApplicationStatus.applied,
        workflowStatus: CircularWorkflowStatus.applied,
        createdAt: DateTime.utc(2026, 11, 1, 9),
      ),
      Circular(
        id: 'c-amber',
        userId: 'u-1',
        title: 'Assistant Director General',
        sector: CircularSector.bank,
        organizationName: 'Bangladesh Bank',
        deadline: DateTime.utc(2026, 11, 15, 17), // +5 days -> amber
        vacancies: 150,
        applicationStatus: ApplicationStatus.feePaid,
        workflowStatus: CircularWorkflowStatus.examUpcoming,
        priority: CircularPriority.high,
        createdAt: DateTime.utc(2026, 11, 5, 9),
      ),
      Circular(
        id: 'c-red',
        userId: 'u-1',
        title: '47th BCS General Cadre',
        sector: CircularSector.bcs,
        organizationName: 'Bangladesh Public Service Commission',
        deadline: DateTime.utc(2026, 11, 12, 17), // +2 days -> red
        vacancies: 1250,
        applicationStatus: ApplicationStatus.inProgress,
        workflowStatus: CircularWorkflowStatus.preparing,
        priority: CircularPriority.urgent,
        createdAt: DateTime.utc(2026, 11, 9, 9),
      ),
      Circular(
        id: 'c-overdue',
        userId: 'u-1',
        title: 'Field Officer',
        sector: CircularSector.ngo,
        organizationName: 'ASA Bangladesh',
        deadline: DateTime.utc(2026, 11, 9, 17), // -1 day -> red & overdue
        applicationStatus: ApplicationStatus.missed,
        workflowStatus: CircularWorkflowStatus.archived,
        priority: CircularPriority.low,
        createdAt: DateTime.utc(2026, 10, 20, 9),
      ),
      Circular(
        id: 'c-none',
        userId: 'u-1',
        title: 'Research Associate',
        sector: CircularSector.autonomous,
        organizationName: 'BIDS',
        createdAt: DateTime.utc(2026, 11, 10, 8),
      ),
    ];
  }

  Future<void> pumpCircularsScreen(
    WidgetTester tester, {
    required CircularRepository repository,
    Size size = const Size(1280, 900),
    ThemeMode themeMode = ThemeMode.dark,
    Locale locale = const Locale('en'),
    bool reduceEffects = true,
    bool settle = true,
  }) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await prefs.setBool(kReduceEffectsStorageKey, reduceEffects);
    await prefs.setString(kLocaleStorageKey, locale.languageCode);

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
          themeMode: themeMode,
          locale: locale,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const Scaffold(body: CircularsScreen()),
        ),
      ),
    );

    if (settle) {
      await tester.pumpAndSettle();
    } else {
      await tester.pump();
    }
  }

  group('CircularsScreen - Responsive Layout & Countdown Bands', () {
    testWidgets('renders table view on desktop with countdown bands and fields',
        (tester) async {
      final repo = FakeCircularRepository(
        initialItems: sampleCirculars(),
        clock: () => fixedNow,
      );

      await pumpCircularsScreen(tester, repository: repo);

      expect(
        find.byKey(const ValueKey('circulars-desktop-table')),
        findsOneWidget,
      );
      expect(
        find.byKey(const ValueKey('circulars-mobile-list')),
        findsNothing,
      );

      expect(find.text('47th BCS General Cadre'), findsOneWidget);
      expect(find.text('Bangladesh Bank'), findsOneWidget);
      expect(find.text('15 days left'), findsOneWidget);
      expect(find.text('5 days left'), findsOneWidget);
      expect(find.text('2 days left'), findsOneWidget);
      expect(find.text('1 day overdue'), findsOneWidget);
      expect(find.text('No deadline'), findsOneWidget);
      expect(find.text('150 posts'), findsOneWidget);

      final tokens = AppThemeTokens.dark();
      final badges = tester
          .widgetList<CircularDeadlineCountdownBadge>(
            find.byType(CircularDeadlineCountdownBadge),
          )
          .toList();
      expect(badges.length, equals(5));

      final redText = tester.widget<Text>(find.text('2 days left'));
      final amberText = tester.widget<Text>(find.text('5 days left'));
      final greenText = tester.widget<Text>(find.text('15 days left'));
      final overdueText = tester.widget<Text>(find.text('1 day overdue'));

      expect(greenText.style?.color, equals(tokens.colors.success));
      expect(amberText.style?.color, equals(tokens.colors.warning));
      expect(redText.style?.color, equals(tokens.colors.danger));
      expect(overdueText.style?.color, equals(tokens.colors.danger));
    });

    testWidgets('renders card list on mobile in light theme and Bangla',
        (tester) async {
      final repo = FakeCircularRepository(
        initialItems: sampleCirculars(),
        clock: () => fixedNow,
      );

      await pumpCircularsScreen(
        tester,
        repository: repo,
        size: const Size(390, 844),
        themeMode: ThemeMode.light,
        locale: const Locale('bn'),
      );

      expect(
        find.byKey(const ValueKey('circulars-mobile-list')),
        findsOneWidget,
      );
      expect(
        find.byKey(const ValueKey('circulars-desktop-table')),
        findsNothing,
      );

      expect(find.text('Senior Software Engineer'), findsOneWidget);
      expect(find.text('১৫০টি পদ'), findsOneWidget);
      expect(find.text('১৫ দিন বাকি'), findsOneWidget);
      expect(find.text('১ দিন মেয়াদোত্তীর্ণ'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });

  group('CircularsScreen - Loading, Empty, and Error States', () {
    testWidgets('renders loading state while repository future is pending',
        (tester) async {
      final completer = Completer<List<Circular>>();
      await pumpCircularsScreen(
        tester,
        repository: _CompleterCircularRepository(completer),
        settle: false,
      );

      expect(
        find.byKey(const ValueKey('circulars-loading-state')),
        findsOneWidget,
      );
      expect(find.text('Loading job circulars...'), findsOneWidget);

      completer.complete(sampleCirculars());
      await tester.pumpAndSettle();

      expect(
        find.byKey(const ValueKey('circulars-loading-state')),
        findsNothing,
      );
      expect(
        find.byKey(const ValueKey('circulars-desktop-table')),
        findsOneWidget,
      );
    });

    testWidgets('renders empty state when user has zero circulars',
        (tester) async {
      await pumpCircularsScreen(
        tester,
        repository: FakeCircularRepository(clock: () => fixedNow),
      );

      expect(
        find.byKey(const ValueKey('circulars-empty-state')),
        findsOneWidget,
      );
      expect(find.text('No job circulars yet'), findsOneWidget);
      expect(
        find.byKey(const ValueKey('circulars-empty-clear-btn')),
        findsNothing,
      );
    });

    testWidgets('renders error state and reloads cleanly on retry',
        (tester) async {
      final repo = FakeCircularRepository(
        initialItems: sampleCirculars(),
        clock: () => fixedNow,
      )..nextError = const CircularNetworkFailure();

      await pumpCircularsScreen(tester, repository: repo);

      expect(
        find.byKey(const ValueKey('circulars-error-state')),
        findsOneWidget,
      );
      expect(find.text('Unable to load circulars'), findsOneWidget);

      await tester.tap(find.byKey(const ValueKey('circulars-retry-btn')));
      await tester.pumpAndSettle();

      expect(
        find.byKey(const ValueKey('circulars-error-state')),
        findsNothing,
      );
      expect(find.text('47th BCS General Cadre'), findsOneWidget);
    });
  });
}
