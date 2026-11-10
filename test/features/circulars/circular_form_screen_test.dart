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
import 'package:job_prep/features/circulars/presentation/screens/circular_form_screen.dart';
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

  Future<void> pumpFormScreen(
    WidgetTester tester, {
    required FakeCircularRepository repo,
    String? circularId,
    Circular? initialCircular,
    ThemeMode themeMode = ThemeMode.dark,
    Locale locale = const Locale('en'),
    Size size = const Size(1100, 1600),
    ValueChanged<Circular>? onSaved,
    VoidCallback? onDiscarded,
  }) async {
    tester.view.physicalSize = size;
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
          circularRepositoryProvider.overrideWithValue(repo),
          circularNowProvider.overrideWithValue(() => fixedNow),
        ],
        child: MaterialApp(
          theme: AppTheme.light(),
          darkTheme: AppTheme.dark(),
          themeMode: themeMode,
          locale: locale,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            body: CircularFormScreen(
              circularId: circularId,
              initialCircular: initialCircular,
              onSaved: onSaved,
              onDiscarded: onDiscarded,
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  group('CircularFormScreen - Create, Edit, and Validation', () {
    testWidgets('creates a circular across sections in dark mode',
        (tester) async {
      final repo = FakeCircularRepository(clock: () => fixedNow);
      Circular? savedResult;

      await pumpFormScreen(
        tester,
        repo: repo,
        onSaved: (c) => savedResult = c,
      );

      expect(find.text('Add Job Circular'), findsOneWidget);
      expect(find.text('Basics'), findsOneWidget);
      expect(find.text('Links'), findsOneWidget);
      expect(find.text('Dates & Numbers'), findsOneWidget);
      expect(find.text('Status'), findsOneWidget);
      expect(find.text('Instructions & Notes'), findsOneWidget);

      await tester.enterText(
        find.byKey(const ValueKey('circular-form-title')),
        '47th BCS Executive',
      );
      await tester.enterText(
        find.byKey(const ValueKey('circular-form-org-name')),
        'BPSC',
      );
      await tester.enterText(
        find.byKey(const ValueKey('circular-form-org-website')),
        'https://bpsc.gov.bd',
      );
      await tester.enterText(
        find.byKey(const ValueKey('circular-form-circular-url')),
        'https://bpsc.gov.bd/47bcs',
      );
      await tester.enterText(
        find.byKey(const ValueKey('circular-form-application-url')),
        'https://bpsc.teletalk.com.bd',
      );
      await tester.enterText(
        find.byKey(const ValueKey('circular-form-vacancies')),
        '450',
      );
      await tester.enterText(
        find.byKey(const ValueKey('circular-form-salary-min')),
        '22000',
      );
      await tester.enterText(
        find.byKey(const ValueKey('circular-form-salary-max')),
        '53060',
      );
      await tester.enterText(
        find.byKey(const ValueKey('circular-form-fee')),
        '700',
      );
      await tester.enterText(
        find.byKey(const ValueKey('circular-form-notes')),
        'Double check NID info',
      );

      final submitBtn = find.byKey(const ValueKey('circular-form-submit-btn'));
      await tester.ensureVisible(submitBtn);
      await tester.tap(submitBtn);
      await tester.pumpAndSettle();

      expect(savedResult, isNotNull);
      expect(savedResult!.title, equals('47th BCS Executive'));
      expect(savedResult!.vacancies, equals(450));
      expect(savedResult!.salaryMin, equals(22000));
      expect(savedResult!.salaryMax, equals(53060));
      expect(savedResult!.applicationFee, equals(700));
      expect(savedResult!.notes, equals('Double check NID info'));
      expect(repo.createdItems.length, equals(1));
    });

    testWidgets('edits existing circular prefilled and renders light Bangla',
        (tester) async {
      final existing = Circular(
        id: 'c-edit-1',
        userId: 'u-1',
        title: 'Assistant Director',
        sector: CircularSector.bank,
        organizationName: 'Bangladesh Bank',
        vacancies: 150,
        salaryMin: 22000,
        salaryMax: 53060,
        applicationStatus: ApplicationStatus.applied,
        admitCardStatus: AdmitCardStatus.available,
        priority: CircularPriority.high,
        workflowStatus: CircularWorkflowStatus.examUpcoming,
        notes: 'Original note',
        deadline: DateTime.utc(2026, 11, 20),
      );
      final repo = FakeCircularRepository(
        initialItems: [existing],
        clock: () => fixedNow,
      );
      Circular? updatedResult;

      await pumpFormScreen(
        tester,
        repo: repo,
        circularId: existing.id,
        themeMode: ThemeMode.light,
        locale: const Locale('bn'),
        size: const Size(390, 2200),
        onSaved: (c) => updatedResult = c,
      );

      expect(find.text('সার্কুলার সম্পাদনা করুন'), findsOneWidget);
      expect(find.text('Assistant Director'), findsOneWidget);
      expect(find.text('Original note'), findsOneWidget);

      await tester.enterText(
        find.byKey(const ValueKey('circular-form-notes')),
        'Updated bank prep note',
      );

      final submitBtn = find.byKey(const ValueKey('circular-form-submit-btn'));
      await tester.ensureVisible(submitBtn);
      await tester.tap(submitBtn);
      await tester.pumpAndSettle();

      expect(updatedResult, isNotNull);
      expect(updatedResult!.id, equals('c-edit-1'));
      expect(updatedResult!.notes, equals('Updated bank prep note'));
      expect(repo.updatedItems.length, equals(1));
    });

    testWidgets('shows validation errors & duplicate warning without saving',
        (tester) async {
      final repo = FakeCircularRepository(
        initialItems: const [
          Circular(
            id: 'c-dup',
            title: 'Existing Bank AD',
            circularUrl: 'https://bb.org.bd/circular/ad',
          ),
        ],
        clock: () => fixedNow,
      );
      await pumpFormScreen(tester, repo: repo);

      await tester.enterText(
        find.byKey(const ValueKey('circular-form-org-website')),
        'not-a-valid-url',
      );
      await tester.enterText(
        find.byKey(const ValueKey('circular-form-circular-url')),
        'https://bb.org.bd/circular/ad/',
      );
      await tester.enterText(
        find.byKey(const ValueKey('circular-form-salary-min')),
        '60000',
      );
      await tester.enterText(
        find.byKey(const ValueKey('circular-form-salary-max')),
        '40000',
      );
      await tester.pumpAndSettle();

      expect(
        find.byKey(const ValueKey('circular-form-duplicate-warning')),
        findsOneWidget,
      );

      final submitBtn = find.byKey(const ValueKey('circular-form-submit-btn'));
      await tester.ensureVisible(submitBtn);
      await tester.tap(submitBtn);
      await tester.pumpAndSettle();

      expect(find.text('Please enter a circular title.'), findsOneWidget);
      expect(
        find.text('Enter a valid URL starting with http:// or https://.'),
        findsOneWidget,
      );
      expect(
        find.text('Maximum salary cannot be lower than minimum salary.'),
        findsOneWidget,
      );
      expect(repo.createdItems, isEmpty);
    });

    testWidgets('prompts confirmation before discarding unsaved edits',
        (tester) async {
      final repo = FakeCircularRepository(clock: () => fixedNow);
      var discardedCount = 0;

      await pumpFormScreen(
        tester,
        repo: repo,
        onDiscarded: () => discardedCount += 1,
      );

      // Clean form cancels immediately without confirmation dialog
      await tester.tap(find.byKey(const ValueKey('circular-form-back-btn')));
      await tester.pumpAndSettle();
      expect(discardedCount, equals(1));

      // Dirty form shows confirmation dialog before discarding
      await tester.enterText(
        find.byKey(const ValueKey('circular-form-title')),
        'Unsaved Circular Draft',
      );
      await tester.pumpAndSettle();

      final cancelBtn = find.byKey(const ValueKey('circular-form-cancel-btn'));
      await tester.ensureVisible(cancelBtn);
      await tester.tap(cancelBtn);
      await tester.pumpAndSettle();

      expect(find.text('Discard unsaved changes?'), findsOneWidget);

      await tester.tap(find.byKey(const ValueKey('circular-discard-keep-btn')));
      await tester.pumpAndSettle();
      expect(discardedCount, equals(1));
      expect(find.text('Unsaved Circular Draft'), findsOneWidget);

      await tester.tap(cancelBtn);
      await tester.pumpAndSettle();
      await tester.tap(
        find.byKey(const ValueKey('circular-discard-confirm-btn')),
      );
      await tester.pumpAndSettle();
      expect(discardedCount, equals(2));
    });
  });
}
