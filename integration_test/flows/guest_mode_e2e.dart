import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:job_prep/core/widgets/app_sidebar_nav.dart';
import 'package:job_prep/features/auth/presentation/screens/login_screen.dart';
import 'package:job_prep/features/circulars/domain/entities/circular.dart';
import 'package:job_prep/features/circulars/presentation/screens/circulars_screen.dart';
import 'package:job_prep/features/today/presentation/screens/today_screen.dart';

import '../harness/e2e_test_harness.dart';

/// End-to-end integration test verifying Guest Mode lifecycle:
/// 1. Start unauthenticated on login screen.
/// 2. Click "Continue without account".
/// 3. Confirm the plain-language bottom sheet.
/// 4. Land on Today screen as guest with local storage active.
/// 5. Add a circular.
/// 6. Reload / restart the application (retaining local SharedPreferences and repository state).
/// 7. Confirm guest session persists and the circular is still present.
void runGuestModeE2ETests() {
  group('E2E Flow - Guest Mode & Persistence', () {
    testWidgets(
        'uses app as guest, adds circular, reloads app and circular persists',
        (tester) async {
      tester.view.physicalSize = const Size(1280, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      // Initialize harness without authentication
      final harness = await E2ETestHarness.create(
        isAuthenticated: false,
      );
      addTearDown(harness.dispose);

      // Launch app
      await tester.pumpWidget(harness.buildApp());
      await tester.pumpAndSettle();

      // 1. Should be on LoginScreen
      expect(find.byType(LoginScreen), findsOneWidget);
      expect(
        find.byKey(const ValueKey('auth_continue_without_account_button')),
        findsOneWidget,
      );

      // 2. Tap "Continue without account"
      await tester.tap(
        find.byKey(const ValueKey('auth_continue_without_account_button')),
      );
      await tester.pumpAndSettle();

      // 3. Guest confirmation sheet opens with caveats
      expect(
        find.byKey(const ValueKey('guest-confirmation-sheet')),
        findsOneWidget,
      );
      expect(
        find.byKey(const ValueKey('guest_confirm_understand_button')),
        findsOneWidget,
      );

      // 4. Tap "I understand"
      await tester.tap(
        find.byKey(const ValueKey('guest_confirm_understand_button')),
      );
      await tester.pumpAndSettle();

      // 5. Land on Today screen
      expect(find.byType(TodayScreen), findsOneWidget);

      // 6. Add a circular in guest mode
      await harness.circularRepo.createCircular(
        Circular(
          title: 'Guest Bangladesh Bank Circular 2026',
          organizationName: 'Bangladesh Bank',
          deadline: DateTime.utc(2026, 12, 31),
        ),
      );

      // 7. Simulate page reload / restarting the web application
      await tester.pumpWidget(
        harness.buildApp(key: const ValueKey('reloaded_guest_app')),
      );
      await tester.pumpAndSettle();

      // Router sees 'jobprep_app_mode' == 'guest' in SharedPreferences,
      // so it does NOT redirect to /login.
      expect(find.byType(LoginScreen), findsNothing);

      // Open Circulars screen from sidebar
      final circularsNav = find.descendant(
        of: find.byType(AppSidebarNav),
        matching: find.text('Circulars'),
      );
      expect(circularsNav, findsOneWidget);
      await tester.tap(circularsNav);
      await tester.pumpAndSettle();

      // Verify the circular created in guest mode is still there after reload
      expect(find.byType(CircularsScreen), findsOneWidget);
      expect(find.text('Guest Bangladesh Bank Circular 2026'), findsOneWidget);
    });
  });
}
