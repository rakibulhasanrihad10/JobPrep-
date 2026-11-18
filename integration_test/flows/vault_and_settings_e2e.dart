import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:job_prep/core/localization/locale_controller.dart';
import 'package:job_prep/core/security/vault_service.dart';
import 'package:job_prep/core/theme/theme_controller.dart';
import 'package:job_prep/core/widgets/app_sidebar_nav.dart';
import 'package:job_prep/features/settings/presentation/screens/settings_screen.dart';

import '../harness/e2e_test_harness.dart';

/// End-to-end integration tests for Portal Vault (locking & unlocking) and
/// Settings (Appearance & Language switching).
void runVaultAndSettingsE2ETests() {
  group('E2E Flow - Vault & Settings', () {
    testWidgets('locks and unlocks vault with passphrase verification',
        (tester) async {
      final harness = await E2ETestHarness.create();
      addTearDown(harness.dispose);

      final vault = VaultService(iterations: VaultService.minIterations);
      const passphrase = 'MyStrongPassphrase#2026';

      // 1. Initialize and unlock vault with passphrase
      final unlocked = await vault.unlock(passphrase: passphrase);
      expect(unlocked, isTrue);
      expect(vault.isUnlocked, isTrue);

      // 2. Lock the vault
      vault.lock();
      expect(vault.isUnlocked, isFalse);

      // 3. Unlock again
      final unlockedAgain = await vault.unlock(passphrase: passphrase);
      expect(unlockedAgain, isTrue);
      expect(vault.isUnlocked, isTrue);
    });

    testWidgets('switches theme and language seamlessly from settings',
        (tester) async {
      tester.view.physicalSize = const Size(1280, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final harness = await E2ETestHarness.create();
      addTearDown(harness.dispose);

      await tester.pumpWidget(harness.buildApp());
      await tester.pumpAndSettle();

      // Open Settings
      await tester.tap(
        find.descendant(
          of: find.byType(AppSidebarNav),
          matching: find.text('Settings'),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(SettingsScreen), findsOneWidget);
      expect(
        find.byKey(const ValueKey('settings-scroll-view')),
        findsOneWidget,
      );

      // Switch language to Bangla
      final element = tester.element(find.byType(SettingsScreen));
      final container = ProviderScope.containerOf(element);

      await container
          .read(localeProvider.notifier)
          .setLocale(const Locale('bn'));
      await tester.pumpAndSettle();

      // Settings title updates to Bangla (in sidebar nav and screen header)
      expect(
        find.descendant(
          of: find.byType(SettingsScreen),
          matching: find.text('সেটিংস'),
        ),
        findsOneWidget,
      );

      // Switch theme to light mode
      await container
          .read(themeModeProvider.notifier)
          .setThemeMode(ThemeMode.light);
      await tester.pumpAndSettle();

      expect(container.read(themeModeProvider), equals(ThemeMode.light));

      // Switch theme to dark mode
      await container
          .read(themeModeProvider.notifier)
          .setThemeMode(ThemeMode.dark);
      await tester.pumpAndSettle();

      expect(container.read(themeModeProvider), equals(ThemeMode.dark));

      // Switch language back to English
      await container
          .read(localeProvider.notifier)
          .setLocale(const Locale('en'));
      await tester.pumpAndSettle();

      expect(
        find.byKey(const ValueKey('settings-scroll-view')),
        findsOneWidget,
      );
    });
  });
}
