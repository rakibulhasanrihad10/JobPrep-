import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:job_prep/core/router/app_router.dart';
import 'package:job_prep/core/theme/app_breakpoints.dart';
import 'package:job_prep/core/theme/app_colors.dart';
import 'package:job_prep/core/theme/app_radii.dart';
import 'package:job_prep/core/theme/app_theme.dart';
import 'package:job_prep/core/theme/app_theme_tokens.dart';
import 'package:job_prep/core/theme/theme_controller.dart';
import 'package:job_prep/features/auth/presentation/providers/auth_providers.dart';
import 'package:job_prep/features/settings/presentation/screens/settings_screen.dart';
import 'package:job_prep/main.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'features/auth/fake_auth_repository.dart';

void main() {
  group('Theme System - Tokens & Extension', () {
    test(
      'AppBreakpointsToken has 600 compact, 1024 medium, 1200 max content',
      () {
        const breakpoints = AppBreakpointsToken();
        expect(breakpoints.compact, equals(600.0));
        expect(breakpoints.medium, equals(1024.0));
        expect(breakpoints.maxContentWidth, equals(1200.0));

        expect(breakpoints.isCompact(599), isTrue);
        expect(breakpoints.isCompact(600), isFalse);

        expect(breakpoints.isMedium(600), isTrue);
        expect(breakpoints.isMedium(1024), isTrue);
        expect(breakpoints.isMedium(1025), isFalse);

        expect(breakpoints.isExpanded(1025), isTrue);
        expect(breakpoints.isExpanded(1024), isFalse);
      },
    );

    test('AppRadiiToken adheres to strict 12px cards and 8px buttons', () {
      const radii = AppRadiiToken();
      expect(radii.card, equals(12.0));
      expect(radii.button, equals(8.0));
      expect(radii.cardRadius, equals(BorderRadius.circular(12)));
      expect(radii.buttonRadius, equals(BorderRadius.circular(8)));
    });

    test('AppColorsToken.dark has deep navy background and gold accent', () {
      final darkColors = AppColorsToken.dark();
      expect(darkColors.background, equals(const Color(0xFF0A0E1A)));
      expect(darkColors.goldAccent, equals(const Color(0xFFE5A93C)));
      expect(darkColors.surface, equals(const Color(0xFF12182B)));
      expect(darkColors.info, equals(const Color(0xFF38BDF8)));
      expect(darkColors.accentSecondary, equals(const Color(0xFFA78BFA)));
    });

    test('AppColorsToken.light has light background and gold accent', () {
      final lightColors = AppColorsToken.light();
      expect(lightColors.background, equals(const Color(0xFFF4F6FB)));
      expect(lightColors.goldAccent, equals(const Color(0xFFC59128)));
      expect(lightColors.surface, equals(const Color(0xFFFFFFFF)));
      expect(lightColors.info, equals(const Color(0xFF0284C7)));
      expect(lightColors.accentSecondary, equals(const Color(0xFF7C3AED)));
    });

    test('AppThemeTokens copyWith and lerp produce valid transitions', () {
      final dark = AppThemeTokens.dark();
      final light = AppThemeTokens.light();

      final copy = dark.copyWith(colors: light.colors);
      expect(copy.colors.background, equals(light.colors.background));

      final lerped = dark.lerp(light, 0.5);
      expect(lerped.colors.goldAccent, isNot(equals(dark.colors.goldAccent)));
    });

    test('AppTheme builds valid light and dark ThemeData with tokens', () {
      final darkTheme = AppTheme.dark();
      final lightTheme = AppTheme.light();

      expect(darkTheme.brightness, equals(Brightness.dark));
      expect(lightTheme.brightness, equals(Brightness.light));

      expect(darkTheme.extension<AppThemeTokens>(), isNotNull);
      expect(lightTheme.extension<AppThemeTokens>(), isNotNull);
    });
  });

  group('Theme Controller & Persistence Widget Tests', () {
    testWidgets('App renders in light mode when saved preference is light',
        (tester) async {
      SharedPreferences.setMockInitialValues({
        kThemeModeStorageKey: 'light',
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

      final materialApp = tester.widget<MaterialApp>(find.byType(MaterialApp));
      expect(materialApp.themeMode, equals(ThemeMode.light));

      expect(find.byType(SettingsScreen), findsOneWidget);
      expect(find.text('Light Theme (Navy & Gold)'), findsOneWidget);
    });

    testWidgets('App renders in dark mode when saved preference is dark',
        (tester) async {
      SharedPreferences.setMockInitialValues({
        kThemeModeStorageKey: 'dark',
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

      final materialApp = tester.widget<MaterialApp>(find.byType(MaterialApp));
      expect(materialApp.themeMode, equals(ThemeMode.dark));

      expect(find.byType(SettingsScreen), findsOneWidget);
      expect(find.text('Dark Theme (Deep Navy & Gold)'), findsOneWidget);
    });

    testWidgets('Switching theme mode updates UI and persists to storage',
        (tester) async {
      SharedPreferences.setMockInitialValues({});
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

      expect(
        tester.widget<MaterialApp>(find.byType(MaterialApp)).themeMode,
        equals(ThemeMode.system),
      );

      // Tap dark theme option
      await tester.tap(find.text('Dark Theme (Deep Navy & Gold)'));
      await tester.pumpAndSettle();

      expect(
        tester.widget<MaterialApp>(find.byType(MaterialApp)).themeMode,
        equals(ThemeMode.dark),
      );
      expect(prefs.getString(kThemeModeStorageKey), equals('dark'));

      // Tap light theme option
      await tester.tap(find.text('Light Theme (Navy & Gold)'));
      await tester.pumpAndSettle();

      expect(
        tester.widget<MaterialApp>(find.byType(MaterialApp)).themeMode,
        equals(ThemeMode.light),
      );
      expect(prefs.getString(kThemeModeStorageKey), equals('light'));

      // Tap system theme option
      await tester.tap(find.text('System Theme'));
      await tester.pumpAndSettle();

      expect(
        tester.widget<MaterialApp>(find.byType(MaterialApp)).themeMode,
        equals(ThemeMode.system),
      );
      expect(prefs.getString(kThemeModeStorageKey), isNull);
    });
  });
}
