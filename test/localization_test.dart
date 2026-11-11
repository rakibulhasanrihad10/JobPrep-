import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:job_prep/core/localization/formatters.dart';
import 'package:job_prep/core/localization/locale_controller.dart';
import 'package:job_prep/core/router/app_router.dart';
import 'package:job_prep/core/storage/preferences_provider.dart';
import 'package:job_prep/features/auth/presentation/providers/auth_providers.dart';
import 'package:job_prep/features/dashboard/presentation/widgets/language_switcher_card.dart';
import 'package:job_prep/main.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../scripts/check_hardcoded_strings.dart';
import 'features/auth/fake_auth_repository.dart';

void main() {
  setUpAll(() async {
    await initializeDateFormatting();
  });

  group('Locale Formatters Unit Tests', () {
    test('toBanglaDigits converts ASCII numbers to Bangla numerals', () {
      expect(
        AppFormatters.toBanglaDigits('0123456789'),
        equals('০১২৩৪৫৬৭৮৯'),
      );
      expect(
        AppFormatters.toBanglaDigits('Fee: 1500 BDT on 2026/12/31'),
        equals('Fee: ১৫০০ BDT on ২০২৬/১২/৩১'),
      );
    });

    test('toEnglishDigits converts Bangla numerals to ASCII numbers', () {
      expect(
        AppFormatters.toEnglishDigits('০১২৩৪৫৬৭৮৯'),
        equals('0123456789'),
      );
    });

    test('formatNumber formats numbers for en and bn locales', () {
      final enFormatted = AppFormatters.formatNumber(
        15000,
        locale: const Locale('en'),
      );
      expect(enFormatted, equals('15,000'));

      final bnFormatted = AppFormatters.formatNumber(
        15000,
        locale: const Locale('bn'),
      );
      expect(bnFormatted, equals('১৫,০০০'));
    });

    test('formatCurrency formats currency with symbol and locale digits', () {
      final enCurrency = AppFormatters.formatCurrency(
        1500,
        locale: const Locale('en'),
      );
      expect(enCurrency, equals('৳ 1,500'));

      final bnCurrency = AppFormatters.formatCurrency(
        1500,
        locale: const Locale('bn'),
      );
      expect(bnCurrency, equals('৳ ১,৫০০'));
    });

    test('formatDate formats DateTime for en and bn locales', () {
      final testDate = DateTime(2026, 12, 15);
      final enDate = AppFormatters.formatDate(
        testDate,
        locale: const Locale('en'),
        pattern: 'yyyy-MM-dd',
      );
      expect(enDate, equals('2026-12-15'));

      final bnDate = AppFormatters.formatDate(
        testDate,
        locale: const Locale('bn'),
        pattern: 'yyyy-MM-dd',
      );
      expect(bnDate, equals('২০২৬-১২-১৫'));
    });
  });

  group('Locale Controller & Persistence Unit Tests', () {
    test('defaults to English when storage is uninitialized', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();

      final container = ProviderContainer(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
        ],
      );
      addTearDown(container.dispose);

      final locale = container.read(localeProvider);
      expect(locale.languageCode, equals('en'));
    });

    test('loads persisted Bangla locale from SharedPreferences', () async {
      SharedPreferences.setMockInitialValues({
        kLocaleStorageKey: 'bn',
      });
      final prefs = await SharedPreferences.getInstance();

      final container = ProviderContainer(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
        ],
      );
      addTearDown(container.dispose);

      final locale = container.read(localeProvider);
      expect(locale.languageCode, equals('bn'));
    });

    test('setLocale persists choice to SharedPreferences', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();

      final container = ProviderContainer(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
        ],
      );
      addTearDown(container.dispose);

      await container
          .read(localeProvider.notifier)
          .setLocale(const Locale('bn'));
      expect(container.read(localeProvider), equals(const Locale('bn')));
      expect(prefs.getString(kLocaleStorageKey), equals('bn'));

      await container
          .read(localeProvider.notifier)
          .setLocale(const Locale('en'));
      expect(container.read(localeProvider), equals(const Locale('en')));
      expect(prefs.getString(kLocaleStorageKey), equals('en'));
    });

    test('BanglaDigitsNotifier persists toggle', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();

      final container = ProviderContainer(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
        ],
      );
      addTearDown(container.dispose);

      expect(container.read(useBanglaDigitsProvider), isFalse);

      await container
          .read(useBanglaDigitsProvider.notifier)
          .setUseBanglaDigits(enabled: true);
      expect(container.read(useBanglaDigitsProvider), isTrue);
      expect(prefs.getBool(kUseBanglaDigitsStorageKey), isTrue);
    });
  });

  group('Localization Widget Tests', () {
    testWidgets('renders Dashboard in English when locale is en', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(1200, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      SharedPreferences.setMockInitialValues({
        kLocaleStorageKey: 'en',
      });
      final prefs = await SharedPreferences.getInstance();
      final authRepo = FakeAuthRepository.authenticated();
      addTearDown(authRepo.dispose);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            sharedPreferencesProvider.overrideWithValue(prefs),
            authRepositoryProvider.overrideWithValue(authRepo),
          ],
          child: const JobPrepApp(),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('JobPrep Dashboard'), findsOneWidget);
      expect(
        find.text(
          'Your job circulars, upcoming dates, and study momentum at a glance.',
        ),
        findsOneWidget,
      );
      expect(find.text('Deadlines this week'), findsOneWidget);
      expect(find.text('Inbox items'), findsOneWidget);
      expect(find.text('Exams in 14 days'), findsOneWidget);
      expect(find.text('Applications submitted'), findsOneWidget);
      expect(find.text('Overall prep'), findsOneWidget);
    });

    testWidgets('renders Dashboard in Bangla when locale is bn', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(1200, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      SharedPreferences.setMockInitialValues({
        kLocaleStorageKey: 'bn',
      });
      final prefs = await SharedPreferences.getInstance();
      final authRepo = FakeAuthRepository.authenticated();
      addTearDown(authRepo.dispose);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            sharedPreferencesProvider.overrideWithValue(prefs),
            authRepositoryProvider.overrideWithValue(authRepo),
          ],
          child: const JobPrepApp(),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('জবপ্রেপ ড্যাশবোর্ড'), findsOneWidget);
      expect(
        find.text(
          'আপনার সার্কুলার, আসন্ন তারিখ ও পড়াশোনার অগ্রগতির একনজর চিত্র।',
        ),
        findsOneWidget,
      );
      expect(find.text('এই সপ্তাহের শেষ তারিখ'), findsOneWidget);
      expect(find.text('ইনবক্স আইটেম'), findsOneWidget);
      expect(find.text('১৪ দিনের মধ্যে পরীক্ষা'), findsOneWidget);
      expect(find.text('জমা দেওয়া আবেদন'), findsOneWidget);
      expect(find.text('সামগ্রিক প্রস্তুতি'), findsOneWidget);
    });

    testWidgets('switching language updates UI and persists to storage', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(1200, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      SharedPreferences.setMockInitialValues({
        kLocaleStorageKey: 'en',
      });
      final prefs = await SharedPreferences.getInstance();
      final authRepo = FakeAuthRepository.authenticated();
      addTearDown(authRepo.dispose);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            sharedPreferencesProvider.overrideWithValue(prefs),
            authRepositoryProvider.overrideWithValue(authRepo),
            initialRouteLocationProvider.overrideWithValue('/settings'),
          ],
          child: const JobPrepApp(),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Language Switcher'), findsOneWidget);
      expect(find.text('Theme Mode Switcher'), findsOneWidget);

      // Tap Bangla radio option
      await tester.tap(
        find.descendant(
          of: find.byType(LanguageSwitcherCard),
          matching: find.text('বাংলা (Bangla)'),
        ),
      );
      await tester.pumpAndSettle();

      // Verify UI updated to Bangla
      expect(find.text('ভাষা পরিবর্তন'), findsOneWidget);
      expect(find.text('থিম মোড পরিবর্তন'), findsOneWidget);
      expect(prefs.getString(kLocaleStorageKey), equals('bn'));

      // Tap English radio option
      await tester.tap(
        find.descendant(
          of: find.byType(LanguageSwitcherCard),
          matching: find.text('English'),
        ),
      );
      await tester.pumpAndSettle();

      // Verify UI reverted to English
      expect(find.text('Language Switcher'), findsOneWidget);
      expect(prefs.getString(kLocaleStorageKey), equals('en'));
    });
  });

  group('Hardcoded Strings CI Scanner Validation', () {
    test('passes on current presentation codebase', () {
      final violations = findHardcodedStrings([
        Directory('lib/features'),
        Directory('lib/shared'),
      ]);
      expect(
        violations,
        isEmpty,
        reason: 'Violations found: ${violations.join(', ')}',
      );
    });

    test('detects and rejects hardcoded text in presentation widgets', () {
      final tempDir = Directory.systemTemp.createTempSync('jobprep_l10n_test_');
      addTearDown(() => tempDir.deleteSync(recursive: true));

      final presentationSubdir = Directory(
        '${tempDir.path}/features/temp/presentation',
      )..createSync(recursive: true);

      final dummyWidgetFile = File('${presentationSubdir.path}/bad_widget.dart')
        ..writeAsStringSync('''
import 'package:flutter/material.dart';

class BadWidget extends StatelessWidget {
  const BadWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return const Text('Hardcoded String Violation');
  }
}
''');

      expect(dummyWidgetFile.existsSync(), isTrue);

      final violations = findHardcodedStrings([tempDir]);
      expect(violations, hasLength(1));
      expect(
        violations.first,
        contains('Hardcoded Text("Hardcoded String Violation")'),
      );
    });
  });
}
