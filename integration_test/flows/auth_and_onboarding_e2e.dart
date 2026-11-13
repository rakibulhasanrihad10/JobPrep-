import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:job_prep/features/auth/presentation/screens/login_screen.dart';
import 'package:job_prep/features/onboarding/presentation/screens/onboarding_wizard_screen.dart';
import 'package:job_prep/features/today/presentation/screens/today_screen.dart';

import '../harness/e2e_test_harness.dart';

/// End-to-end integration tests for authentication and first-run onboarding.
void runAuthAndOnboardingE2ETests() {
  group('E2E Flow - Auth & Onboarding', () {
    testWidgets('sign up and sign in redirects to today screen',
        (tester) async {
      final harness = await E2ETestHarness.create(isAuthenticated: false);
      addTearDown(harness.dispose);

      await tester.pumpWidget(harness.buildApp());
      await tester.pumpAndSettle();

      // Starts on LoginScreen
      expect(find.byType(LoginScreen), findsOneWidget);

      // Perform sign in via repository
      await harness.authRepo.signInWithEmail(
        email: 'candidate@test.com',
        password: 'Password123!',
      );
      await tester.pumpAndSettle();

      // Successfully redirected to TodayScreen
      expect(find.byType(TodayScreen), findsOneWidget);
      expect(find.text('Do this next'), findsOneWidget);
    });

    testWidgets('new user completes full 6-step onboarding wizard',
        (tester) async {
      tester.view.physicalSize = const Size(1280, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final harness = await E2ETestHarness.create(
        needsOnboarding: true,
      );
      addTearDown(harness.dispose);

      await tester.pumpWidget(harness.buildApp());
      await tester.pumpAndSettle();

      // Onboarding wizard opens for new user
      expect(find.byType(OnboardingWizardScreen), findsOneWidget);
      expect(find.byKey(const ValueKey('onboarding-step-1')), findsOneWidget);

      // Step 1 -> Step 2
      await tester.tap(find.byKey(const ValueKey('onboarding-next-btn')));
      await tester.pumpAndSettle();
      expect(find.byKey(const ValueKey('onboarding-step-2')), findsOneWidget);

      // Step 2 -> Step 3
      await tester.tap(find.byKey(const ValueKey('onboarding-next-btn')));
      await tester.pumpAndSettle();
      expect(find.byKey(const ValueKey('onboarding-step-3')), findsOneWidget);

      // Step 3 -> Step 4
      await tester.tap(find.byKey(const ValueKey('onboarding-next-btn')));
      await tester.pumpAndSettle();
      expect(find.byKey(const ValueKey('onboarding-step-4')), findsOneWidget);

      // In Step 4: tap unknown exam date switch and study days so form is valid
      await tester.tap(
        find.byKey(const ValueKey('onboarding-exam-unknown-switch')),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('onboarding-study-days-5')));
      await tester.pumpAndSettle();

      // Step 4 -> Step 5
      await tester.tap(find.byKey(const ValueKey('onboarding-next-btn')));
      await tester.pumpAndSettle();
      expect(find.byKey(const ValueKey('onboarding-step-5')), findsOneWidget);

      // Step 5: Quick capture (optional) -> Step 6
      await tester.tap(find.byKey(const ValueKey('onboarding-next-btn')));
      await tester.pumpAndSettle();
      expect(find.byKey(const ValueKey('onboarding-step-6')), findsOneWidget);

      // Step 6: Finish setup
      await tester.tap(find.byKey(const ValueKey('onboarding-next-btn')));
      await tester.pumpAndSettle();

      // Redirected to Today screen with 3 tips
      expect(find.byType(TodayScreen), findsOneWidget);
      expect(
        find.byKey(const ValueKey('today-onboarding-tips-card')),
        findsOneWidget,
      );
    });
  });
}
