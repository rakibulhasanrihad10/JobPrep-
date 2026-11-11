import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:job_prep/core/localization/locale_controller.dart';
import 'package:job_prep/core/theme/app_theme.dart';
import 'package:job_prep/core/theme/theme_controller.dart';
import 'package:job_prep/features/auth/presentation/providers/auth_providers.dart';
import 'package:job_prep/features/settings/data/mappers/reminder_error_mapper.dart';
import 'package:job_prep/features/settings/data/mappers/reminder_settings_mapper.dart';
import 'package:job_prep/features/settings/domain/entities/reminder_settings.dart';
import 'package:job_prep/features/settings/domain/errors/reminder_failure.dart';
import 'package:job_prep/features/settings/presentation/providers/reminder_settings_providers.dart';
import 'package:job_prep/features/settings/presentation/screens/settings_screen.dart';
import 'package:job_prep/l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supabase;

import '../auth/fake_auth_repository.dart';
import 'fake_reminder_settings_repository.dart';

void main() {
  group('ReminderSettings Domain & Mappers', () {
    test('ReminderEmailLanguage parses known values and falls back cleanly',
        () {
      expect(
        ReminderEmailLanguage.tryParse('en'),
        ReminderEmailLanguage.english,
      );
      expect(
        ReminderEmailLanguage.tryParse('bn'),
        ReminderEmailLanguage.bangla,
      );
      expect(ReminderEmailLanguage.tryParse('es'), isNull);
      expect(
        ReminderEmailLanguage.fromValue('unknown'),
        ReminderEmailLanguage.english,
      );
    });

    test('ReminderSettingsMapper deserializes JSON and builds upsert payload',
        () {
      final parsed = ReminderSettingsMapper.fromJson({
        'id': 'pref-1',
        'user_id': 'u-1',
        'reminders_enabled': false,
        'email_language': 'bn',
        'deadline_soon_enabled': true,
        'exam_soon_enabled': false,
        'revision_due_enabled': true,
        'behind_schedule_enabled': false,
        'weekly_review_enabled': true,
        'weekly_review_day': 5,
        'created_at': '2026-11-11T02:00:00Z',
        'updated_at': '2026-11-11T03:00:00Z',
      });

      expect(parsed.id, 'pref-1');
      expect(parsed.userId, 'u-1');
      expect(parsed.enabled, isFalse);
      expect(parsed.emailLanguage, ReminderEmailLanguage.bangla);
      expect(parsed.deadlineSoonEnabled, isTrue);
      expect(parsed.examSoonEnabled, isFalse);
      expect(parsed.revisionDueEnabled, isTrue);
      expect(parsed.behindScheduleEnabled, isFalse);
      expect(parsed.weeklyReviewEnabled, isTrue);
      expect(parsed.weeklyReviewDay, 5);
      expect(parsed.updatedAt, DateTime.utc(2026, 11, 11, 3));

      expect(
        ReminderSettingsMapper.toUpsertJson(
          userId: 'u-1',
          enabled: true,
          emailLanguage: ReminderEmailLanguage.english,
          examSoonEnabled: false,
          weeklyReviewDay: 5,
        ),
        equals({
          'user_id': 'u-1',
          'reminders_enabled': true,
          'email_language': 'en',
          'exam_soon_enabled': false,
          'weekly_review_day': 5,
        }),
      );
    });

    test('ReminderErrorMapper maps timeout, PostgREST RLS, and check errors',
        () {
      expect(
        ReminderErrorMapper.map(TimeoutException('slow')),
        isA<ReminderNetworkFailure>(),
      );
      expect(
        ReminderErrorMapper.map(
          const supabase.PostgrestException(message: 'denied', code: '42501'),
        ),
        isA<ReminderPermissionFailure>(),
      );
      expect(
        ReminderErrorMapper.map(
          const supabase.PostgrestException(message: 'invalid', code: '23514'),
        ),
        isA<ReminderValidationFailure>(),
      );
    });
  });

  group('ReminderSettingsNotifier Provider Tests', () {
    test('loads, toggles, switches language, and rolls back on failure',
        () async {
      final fakeRepo = FakeReminderSettingsRepository();
      final authRepo = FakeAuthRepository.authenticated();
      addTearDown(authRepo.dispose);

      final container = ProviderContainer(
        overrides: [
          authRepositoryProvider.overrideWithValue(authRepo),
          reminderSettingsRepositoryProvider.overrideWithValue(fakeRepo),
        ],
      );
      addTearDown(container.dispose);

      final initial = await container.read(reminderSettingsProvider.future);
      expect(initial.enabled, isTrue);
      expect(initial.emailLanguage, ReminderEmailLanguage.english);

      final toggledOk = await container
          .read(reminderSettingsProvider.notifier)
          .setEnabled(enabled: false);
      expect(toggledOk, isTrue);
      expect(
        container.read(reminderSettingsProvider).requireValue.enabled,
        isFalse,
      );
      expect(fakeRepo.currentSettings.enabled, isFalse);

      final langOk = await container
          .read(reminderSettingsProvider.notifier)
          .setEmailLanguage(ReminderEmailLanguage.bangla);
      expect(langOk, isTrue);
      expect(
        container.read(reminderSettingsProvider).requireValue.emailLanguage,
        ReminderEmailLanguage.bangla,
      );

      // Failed persistence rolls state back to prior saved settings.
      fakeRepo.nextError = const ReminderNetworkFailure(message: 'offline');
      final failedOk = await container
          .read(reminderSettingsProvider.notifier)
          .setEnabled(enabled: true);
      expect(failedOk, isFalse);
      final reverted = container.read(reminderSettingsProvider).requireValue;
      expect(reverted.enabled, isFalse);
      expect(reverted.emailLanguage, ReminderEmailLanguage.bangla);
    });
  });

  group('SettingsScreen & EmailRemindersCard Widget Tests', () {
    Future<FakeReminderSettingsRepository> pumpSettingsScreen(
      WidgetTester tester, {
      required Size size,
      ThemeMode themeMode = ThemeMode.dark,
      String locale = 'en',
      FakeReminderSettingsRepository? repo,
    }) async {
      tester.view.physicalSize = size;
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      SharedPreferences.setMockInitialValues({
        kLocaleStorageKey: locale,
        kThemeModeStorageKey: themeMode.name,
      });
      final prefs = await SharedPreferences.getInstance();
      final authRepo = FakeAuthRepository.authenticated();
      addTearDown(authRepo.dispose);

      final settingsRepo = repo ?? FakeReminderSettingsRepository();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            sharedPreferencesProvider.overrideWithValue(prefs),
            authRepositoryProvider.overrideWithValue(authRepo),
            reminderSettingsRepositoryProvider.overrideWithValue(settingsRepo),
          ],
          child: Consumer(
            builder: (context, ref, _) {
              return MaterialApp(
                theme: AppTheme.light(),
                darkTheme: AppTheme.dark(),
                themeMode: ref.watch(themeModeProvider),
                locale: ref.watch(localeProvider),
                localizationsDelegates: AppLocalizations.localizationsDelegates,
                supportedLocales: AppLocalizations.supportedLocales,
                home: const Scaffold(body: SettingsScreen()),
              );
            },
          ),
        ),
      );
      await tester.pumpAndSettle();
      return settingsRepo;
    }

    testWidgets(
      'toggles email reminders off/on and selects English or Bangla email language',
      (tester) async {
        final repo = await pumpSettingsScreen(
          tester,
          size: const Size(1200, 1200),
        );

        expect(
          find.byKey(const ValueKey('settings-email-reminders-card')),
          findsOneWidget,
        );
        expect(find.text('Email Reminders'), findsOneWidget);

        // Toggle switch off
        final switchFinder =
            find.byKey(const ValueKey('settings-reminders-switch'));
        await tester.ensureVisible(switchFinder);
        await tester.tap(switchFinder);
        await tester.pumpAndSettle();

        expect(repo.currentSettings.enabled, isFalse);
        expect(
          find.textContaining('Email reminders are paused.'),
          findsOneWidget,
        );

        // Select Bangla as email language
        final bnOption =
            find.byKey(const ValueKey('settings-reminders-lang-bn'));
        await tester.ensureVisible(bnOption);
        await tester.tap(bnOption);
        await tester.pumpAndSettle();

        expect(
          repo.currentSettings.emailLanguage,
          ReminderEmailLanguage.bangla,
        );

        // Re-enable reminders and switch back to English
        await tester.ensureVisible(switchFinder);
        await tester.tap(switchFinder);
        await tester.pumpAndSettle();
        expect(repo.currentSettings.enabled, isTrue);

        final enOption =
            find.byKey(const ValueKey('settings-reminders-lang-en'));
        await tester.ensureVisible(enOption);
        await tester.tap(enOption);
        await tester.pumpAndSettle();
        expect(
          repo.currentSettings.emailLanguage,
          ReminderEmailLanguage.english,
        );
      },
    );

    testWidgets(
      'shows inline error and keeps previous value when save fails',
      (tester) async {
        final repo = FakeReminderSettingsRepository()..nextError = null;
        await pumpSettingsScreen(
          tester,
          size: const Size(1200, 1200),
          repo: repo,
        );

        repo.nextError = const ReminderNetworkFailure();
        final switchFinder =
            find.byKey(const ValueKey('settings-reminders-switch'));
        await tester.ensureVisible(switchFinder);
        await tester.tap(switchFinder);
        await tester.pumpAndSettle();

        expect(
          find.byKey(const ValueKey('settings-reminders-save-error')),
          findsOneWidget,
        );
        expect(
          tester.widget<Switch>(switchFinder).value,
          isTrue,
        );
      },
    );

    testWidgets(
      'toggles per-type in-app notifications and weekly review day selector',
      (tester) async {
        final repo = await pumpSettingsScreen(
          tester,
          size: const Size(1200, 1200),
        );

        expect(
          find.byKey(const ValueKey('settings-in-app-notifications-card')),
          findsOneWidget,
        );

        final examSwitch =
            find.byKey(const ValueKey('settings-notif-switch-exam'));
        await tester.ensureVisible(examSwitch);
        await tester.tap(examSwitch);
        await tester.pumpAndSettle();
        expect(repo.currentSettings.examSoonEnabled, isFalse);

        final fridayChip =
            find.byKey(const ValueKey('settings-notif-review-day-5'));
        await tester.ensureVisible(fridayChip);
        await tester.tap(fridayChip);
        await tester.pumpAndSettle();
        expect(repo.currentSettings.weeklyReviewDay, 5);
      },
    );

    testWidgets(
      'renders cleanly in Bangla light mode on 360x800 mobile without overflow',
      (tester) async {
        await pumpSettingsScreen(
          tester,
          size: const Size(360, 800),
          themeMode: ThemeMode.light,
          locale: 'bn',
        );

        expect(find.text('ইমেইল অনুস্মারক'), findsOneWidget);
        expect(find.text('দৈনিক ইমেইল অনুস্মারক চালু করুন'), findsOneWidget);
        expect(find.text('অনুস্মারক ইমেইলের ভাষা'), findsOneWidget);
        expect(
          find.text('বিজ্ঞপ্তির ধরন ও সাপ্তাহিক পর্যালোচনা'),
          findsOneWidget,
        );
        expect(tester.takeException(), isNull);
      },
    );
  });
}
