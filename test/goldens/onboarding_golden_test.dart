import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:job_prep/core/localization/locale_controller.dart';
import 'package:job_prep/core/theme/app_theme.dart';
import 'package:job_prep/core/theme/reduce_effects_controller.dart';
import 'package:job_prep/core/theme/theme_controller.dart';
import 'package:job_prep/features/auth/presentation/providers/auth_providers.dart';
import 'package:job_prep/features/onboarding/domain/entities/onboarding_status.dart';
import 'package:job_prep/features/onboarding/presentation/providers/onboarding_status_provider.dart';
import 'package:job_prep/features/onboarding/presentation/screens/onboarding_wizard_screen.dart';
import 'package:job_prep/l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../features/auth/fake_auth_repository.dart';
import '../features/onboarding/fake_onboarding_repository.dart';

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

  setUpAll(() async {
    await initializeDateFormatting('en');
    final currentUrl = Uri.base.resolve('test/goldens/test.dart');
    goldenFileComparator = _TolerantGoldenComparator(currentUrl);
  });

  Future<void> pumpStep1Golden(
    WidgetTester tester, {
    required ThemeMode themeMode,
  }) async {
    tester.view.physicalSize = const Size(1100, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    SharedPreferences.setMockInitialValues({
      kReduceEffectsStorageKey: false,
      kLocaleStorageKey: 'en',
      kThemeModeStorageKey: themeMode.name,
    });
    final prefs = await SharedPreferences.getInstance();
    final authRepo = FakeAuthRepository.authenticated();
    addTearDown(authRepo.dispose);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
          authRepositoryProvider.overrideWithValue(authRepo),
          onboardingRepositoryProvider.overrideWithValue(
            FakeOnboardingRepository(
              initialStatus: const OnboardingStatus(userId: 'user-1'),
            ),
          ),
        ],
        child: Consumer(
          builder: (context, ref, _) {
            return MaterialApp(
              debugShowCheckedModeBanner: false,
              theme: AppTheme.light(),
              darkTheme: AppTheme.dark(),
              themeMode: ref.watch(themeModeProvider),
              locale: ref.watch(localeProvider),
              localizationsDelegates: AppLocalizations.localizationsDelegates,
              supportedLocales: AppLocalizations.supportedLocales,
              home: const OnboardingWizardScreen(),
            );
          },
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  group('Phase 6K Onboarding Step 1 Golden Tests', () {
    testWidgets('Onboarding Step 1 desktop golden - dark mode', (tester) async {
      await pumpStep1Golden(tester, themeMode: ThemeMode.dark);
      await expectLater(
        find.byType(OnboardingWizardScreen),
        matchesGoldenFile('goldens/onboarding_step1_dark.png'),
      );
    });

    testWidgets('Onboarding Step 1 desktop golden - light mode',
        (tester) async {
      await pumpStep1Golden(tester, themeMode: ThemeMode.light);
      await expectLater(
        find.byType(OnboardingWizardScreen),
        matchesGoldenFile('goldens/onboarding_step1_light.png'),
      );
    });
  });
}
