import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:job_prep/core/router/app_router.dart';
import 'package:job_prep/core/theme/theme_controller.dart';
import 'package:job_prep/features/auth/presentation/providers/auth_providers.dart';
import 'package:job_prep/features/auth/presentation/screens/login_screen.dart';
import 'package:job_prep/features/legal/presentation/screens/legal_screen.dart';
import 'package:job_prep/main.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../auth/fake_auth_repository.dart';

void main() {
  group('Phase 7D Legal & Privacy Notice Widget Tests', () {
    testWidgets('renders Privacy Policy document with all sections in English',
        (tester) async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final authRepo = FakeAuthRepository();
      addTearDown(authRepo.dispose);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            sharedPreferencesProvider.overrideWithValue(prefs),
            authRepositoryProvider.overrideWithValue(authRepo),
            initialRouteLocationProvider.overrideWithValue('/privacy'),
          ],
          child: const JobPrepApp(),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(LegalScreen), findsOneWidget);
      expect(find.text('Privacy Policy'), findsOneWidget);
      expect(
        find.text(
          'Client-side encryption, zero tracking, and user data ownership.',
        ),
        findsOneWidget,
      );
      expect(find.text('Zero Third-Party Tracking'), findsOneWidget);
      expect(find.text('Client-Side Vault Encryption'), findsOneWidget);
      expect(find.text('Row-Level Security & Isolation'), findsOneWidget);
      expect(find.text('Export & Account Deletion'), findsOneWidget);
      expect(find.byKey(const ValueKey('legal-back-button')), findsOneWidget);
    });

    testWidgets(
        'renders Terms of Service document with all sections in English',
        (tester) async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final authRepo = FakeAuthRepository();
      addTearDown(authRepo.dispose);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            sharedPreferencesProvider.overrideWithValue(prefs),
            authRepositoryProvider.overrideWithValue(authRepo),
            initialRouteLocationProvider.overrideWithValue('/terms'),
          ],
          child: const JobPrepApp(),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(LegalScreen), findsOneWidget);
      expect(find.text('Terms of Service'), findsOneWidget);
      expect(
        find.text('Open, transparent, and built for your exam preparation.'),
        findsOneWidget,
      );
      expect(find.text('Open Educational Use'), findsOneWidget);
      expect(find.text('Circulars Accuracy Disclaimer'), findsOneWidget);
      expect(find.text('User Responsibility'), findsOneWidget);
    });

    testWidgets('renders Privacy Policy in Bangla without overflow',
        (tester) async {
      tester.view.physicalSize = const Size(360, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      SharedPreferences.setMockInitialValues({'jobprep_locale': 'bn'});
      final prefs = await SharedPreferences.getInstance();
      final authRepo = FakeAuthRepository();
      addTearDown(authRepo.dispose);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            sharedPreferencesProvider.overrideWithValue(prefs),
            authRepositoryProvider.overrideWithValue(authRepo),
            initialRouteLocationProvider.overrideWithValue('/privacy'),
          ],
          child: const JobPrepApp(),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('গোপনীয়তা নীতি'), findsOneWidget);
      expect(find.text('কোনো ট্র্যাকিং বা বিজ্ঞাপন নেই'), findsOneWidget);
      expect(find.text('ক্লায়েন্ট-সাইড ভল্ট এনক্রিপশন'), findsOneWidget);
    });

    testWidgets(
        'back button on Privacy Policy navigates back to login when signed out',
        (tester) async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final authRepo = FakeAuthRepository();
      addTearDown(authRepo.dispose);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            sharedPreferencesProvider.overrideWithValue(prefs),
            authRepositoryProvider.overrideWithValue(authRepo),
            initialRouteLocationProvider.overrideWithValue('/privacy'),
          ],
          child: const JobPrepApp(),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const ValueKey('legal-back-button')));
      await tester.pumpAndSettle();

      expect(find.byType(LoginScreen), findsOneWidget);
      expect(find.byKey(const ValueKey('auth_email_field')), findsOneWidget);
    });
  });
}
