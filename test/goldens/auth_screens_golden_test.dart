import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:job_prep/core/localization/locale_controller.dart';
import 'package:job_prep/core/theme/app_theme.dart';
import 'package:job_prep/core/theme/reduce_effects_controller.dart';
import 'package:job_prep/core/theme/theme_controller.dart';
import 'package:job_prep/features/auth/presentation/providers/auth_providers.dart';
import 'package:job_prep/features/auth/presentation/screens/login_screen.dart';
import 'package:job_prep/l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../features/auth/fake_auth_repository.dart';

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

  Future<void> pumpLoginGolden(
    WidgetTester tester, {
    required ThemeMode themeMode,
  }) async {
    tester.view.physicalSize = const Size(900, 820);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    SharedPreferences.setMockInitialValues({
      kReduceEffectsStorageKey: false,
      kLocaleStorageKey: 'en',
    });
    final prefs = await SharedPreferences.getInstance();
    final fakeRepo = FakeAuthRepository();
    addTearDown(fakeRepo.dispose);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
          authRepositoryProvider.overrideWithValue(fakeRepo),
        ],
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: AppTheme.light(),
          darkTheme: AppTheme.dark(),
          themeMode: themeMode,
          locale: const Locale('en'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const LoginScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  group('Auth Screens Golden Tests', () {
    testWidgets('LoginScreen golden - dark mode', (tester) async {
      await pumpLoginGolden(tester, themeMode: ThemeMode.dark);

      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile('goldens/login_screen_dark.png'),
      );
    });

    testWidgets('LoginScreen golden - light mode', (tester) async {
      await pumpLoginGolden(tester, themeMode: ThemeMode.light);

      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile('goldens/login_screen_light.png'),
      );
    });
  });
}
