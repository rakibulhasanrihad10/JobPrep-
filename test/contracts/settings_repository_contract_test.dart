import 'package:drift/native.dart';
import 'package:flutter/material.dart' show ThemeMode;
import 'package:flutter_test/flutter_test.dart';
import 'package:job_prep/core/local/database/app_database.dart';
import 'package:job_prep/features/settings/data/repositories/local_reminder_settings_repository.dart';
import 'package:job_prep/features/settings/data/repositories/local_user_settings_repository.dart';
import 'package:job_prep/features/settings/data/repositories/supabase_reminder_settings_repository.dart';
import 'package:job_prep/features/settings/data/repositories/supabase_user_settings_repository.dart';
import 'package:job_prep/features/settings/domain/entities/reminder_settings.dart';
import 'package:job_prep/features/settings/domain/entities/user_app_settings.dart';
import 'package:job_prep/features/settings/domain/repositories/reminder_settings_repository.dart';
import 'package:job_prep/features/settings/domain/repositories/user_settings_repository.dart';

import 'mock_supabase_http_client.dart';

void testSettingsRepositoriesContract({
  required Future<
              ({
                UserSettingsRepository userSettings,
                ReminderSettingsRepository reminderSettings,
              })>
          Function()
      createRepositories,
  Future<void> Function()? tearDownRepositories,
}) {
  group('Settings Repositories Contract Tests', () {
    late UserSettingsRepository userSettingsRepo;
    late ReminderSettingsRepository reminderSettingsRepo;

    setUp(() async {
      final repos = await createRepositories();
      userSettingsRepo = repos.userSettings;
      reminderSettingsRepo = repos.reminderSettings;
    });

    tearDown(() async {
      if (tearDownRepositories != null) {
        await tearDownRepositories();
      }
    });

    test('UserSettings upsert and retrieval', () async {
      final initial = await userSettingsRepo.getSettings();
      expect(initial, isNull);

      const settings = UserAppSettings(
        displayName: 'Rakib Hasan',
        themeMode: ThemeMode.dark,
        reduceEffects: true,
        localeCode: 'bn',
        banglaDigits: true,
        focusMinutes: 45,
      );

      final saved = await userSettingsRepo.upsertSettings(settings);
      expect(saved.displayName, equals('Rakib Hasan'));
      expect(saved.themeMode, equals(ThemeMode.dark));
      expect(saved.reduceEffects, isTrue);
      expect(saved.localeCode, equals('bn'));
      expect(saved.banglaDigits, isTrue);
      expect(saved.focusMinutes, equals(45));

      final retrieved = await userSettingsRepo.getSettings();
      expect(retrieved, isNotNull);
      expect(retrieved!.displayName, equals('Rakib Hasan'));
      expect(retrieved.themeMode, equals(ThemeMode.dark));
      expect(retrieved.reduceEffects, isTrue);
    });

    test('ReminderSettings save and retrieval', () async {
      final initial = await reminderSettingsRepo.getSettings();
      expect(initial.enabled, isTrue);

      final saved = await reminderSettingsRepo.saveSettings(
        enabled: false,
        emailLanguage: ReminderEmailLanguage.bangla,
        deadlineSoonEnabled: true,
        examSoonEnabled: false,
        weeklyReviewDay: 5,
      );

      expect(saved.enabled, isFalse);
      expect(saved.emailLanguage, equals(ReminderEmailLanguage.bangla));
      expect(saved.examSoonEnabled, isFalse);
      expect(saved.weeklyReviewDay, equals(5));

      final retrieved = await reminderSettingsRepo.getSettings();
      expect(retrieved.enabled, isFalse);
      expect(retrieved.emailLanguage, equals(ReminderEmailLanguage.bangla));
      expect(retrieved.examSoonEnabled, isFalse);
      expect(retrieved.weeklyReviewDay, equals(5));
    });
  });
}

void main() {
  group('Local Implementation Contract', () {
    late AppDatabase db;

    testSettingsRepositoriesContract(
      createRepositories: () async {
        db = AppDatabase(NativeDatabase.memory());
        return (
          userSettings: LocalUserSettingsRepository(db),
          reminderSettings: LocalReminderSettingsRepository(db),
        );
      },
      tearDownRepositories: () async {
        await db.close();
      },
    );
  });

  group('Supabase Implementation Contract', () {
    late MockSupabaseHttpClient mockHttp;
    late MockSupabaseClient client;

    testSettingsRepositoriesContract(
      createRepositories: () async {
        mockHttp = MockSupabaseHttpClient();
        client = MockSupabaseClient(mockHttpClient: mockHttp);
        return (
          userSettings: SupabaseUserSettingsRepository(client),
          reminderSettings: SupabaseReminderSettingsRepository(client),
        );
      },
      tearDownRepositories: () async {
        mockHttp.clear();
      },
    );
  });
}
