import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:job_prep/core/localization/locale_controller.dart';
import 'package:job_prep/core/theme/app_theme.dart';
import 'package:job_prep/core/theme/reduce_effects_controller.dart';
import 'package:job_prep/core/theme/theme_controller.dart';
import 'package:job_prep/features/settings/domain/entities/reminder_settings.dart';
import 'package:job_prep/features/settings/presentation/providers/reminder_settings_providers.dart';
import 'package:job_prep/features/settings/presentation/screens/settings_screen.dart';
import 'package:job_prep/l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../features/settings/fake_reminder_settings_repository.dart';

class _TolerantGoldenComparator extends LocalFileComparator {
  _TolerantGoldenComparator(super.testFile);

  static const double _tolerance = 0.04;

  @override
  Future<bool> compare(Uint8List imageBytes, Uri golden) async {
    final result = await GoldenFileComparator.compareLists(
      imageBytes,
      await getGoldenBytes(golden),
    );

    if (!result.passed && result.diffPercent <= _tolerance) {
      return true;
    }

    if (!result.passed) {
      final error = await generateFailureOutput(result, golden, basedir);
      throw FlutterError(error);
    }
    return result.passed;
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    final currentUrl = Uri.base.resolve('test/goldens/test.dart');
    goldenFileComparator = _TolerantGoldenComparator(currentUrl);
  });

  Future<void> pumpSettingsGolden(
    WidgetTester tester, {
    required ThemeMode themeMode,
    required Locale locale,
  }) async {
    tester.view.physicalSize = const Size(960, 1340);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    SharedPreferences.setMockInitialValues({
      kReduceEffectsStorageKey: false,
      kLocaleStorageKey: locale.languageCode,
      kThemeModeStorageKey: themeMode.name,
    });
    final prefs = await SharedPreferences.getInstance();
    final repo = FakeReminderSettingsRepository(
      initialSettings: ReminderSettings(
        id: 'rem-g1',
        userId: 'u-1',
        emailLanguage: locale.languageCode == 'bn'
            ? ReminderEmailLanguage.bangla
            : ReminderEmailLanguage.english,
      ),
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
          reminderSettingsRepositoryProvider.overrideWithValue(repo),
        ],
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: AppTheme.light(),
          darkTheme: AppTheme.dark(),
          themeMode: themeMode,
          locale: locale,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const Scaffold(body: SettingsScreen()),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  group('SettingsScreen Golden Tests', () {
    testWidgets('Settings desktop golden - dark mode', (tester) async {
      await pumpSettingsGolden(
        tester,
        themeMode: ThemeMode.dark,
        locale: const Locale('en'),
      );
      await expectLater(
        find.byType(SettingsScreen),
        matchesGoldenFile('goldens/settings_screen_dark.png'),
      );
    });

    testWidgets('Settings desktop golden - light mode', (tester) async {
      await pumpSettingsGolden(
        tester,
        themeMode: ThemeMode.light,
        locale: const Locale('en'),
      );
      await expectLater(
        find.byType(SettingsScreen),
        matchesGoldenFile('goldens/settings_screen_light.png'),
      );
    });
  });
}
