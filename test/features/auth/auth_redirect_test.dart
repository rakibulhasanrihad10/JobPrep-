import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:job_prep/core/router/app_router.dart';
import 'package:job_prep/core/theme/theme_controller.dart';
import 'package:job_prep/features/auth/domain/entities/auth_session_state.dart';
import 'package:job_prep/features/auth/presentation/navigation/auth_redirect.dart';
import 'package:job_prep/features/auth/presentation/providers/auth_providers.dart';
import 'package:job_prep/features/auth/presentation/screens/login_screen.dart';
import 'package:job_prep/features/auth/presentation/screens/reset_password_screen.dart';
import 'package:job_prep/features/dashboard/presentation/screens/dashboard_screen.dart';
import 'package:job_prep/main.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'fake_auth_repository.dart';

void main() {
  group('resolveAuthRedirect - Pure Redirect Rules', () {
    const signedOut = AuthSessionState.signedOut();
    const signedIn = AuthSessionState.signedIn(
      FakeAuthRepository.defaultTestUser,
    );
    const recovery = AuthSessionState.passwordRecovery(
      user: FakeAuthRepository.defaultTestUser,
    );

    test('sends signed-out users to /login from protected and recovery routes',
        () {
      for (final path in [
        '/',
        '/dashboard',
        '/circulars',
        '/prep',
        '/calendar',
        '/settings',
        '/reset-password',
      ]) {
        expect(
          resolveAuthRedirect(authState: signedOut, location: path),
          equals('/login'),
          reason: 'Expected signed-out access to $path to redirect to /login',
        );
      }

      expect(
        resolveAuthRedirect(authState: signedOut, location: '/login'),
        isNull,
      );
      expect(
        resolveAuthRedirect(authState: signedOut, location: '/login/'),
        isNull,
      );
    });

    test('sends signed-in users away from /login and allows app routes', () {
      expect(
        resolveAuthRedirect(authState: signedIn, location: '/login'),
        equals('/dashboard'),
      );
      expect(
        resolveAuthRedirect(authState: signedIn, location: '/'),
        equals('/dashboard'),
      );

      for (final path in [
        '/dashboard',
        '/circulars',
        '/prep',
        '/calendar',
        '/settings',
        '/reset-password',
      ]) {
        expect(
          resolveAuthRedirect(authState: signedIn, location: path),
          isNull,
          reason: 'Expected signed-in access to $path to be allowed',
        );
      }
    });

    test('sends recovery sessions to /reset-password from all other routes',
        () {
      for (final path in [
        '/',
        '/login',
        '/dashboard',
        '/circulars',
        '/prep',
        '/calendar',
        '/settings',
      ]) {
        expect(
          resolveAuthRedirect(authState: recovery, location: path),
          equals('/reset-password'),
          reason: 'Expected recovery session on $path to go to /reset-password',
        );
      }

      expect(
        resolveAuthRedirect(authState: recovery, location: '/reset-password'),
        isNull,
      );
    });
  });

  group('AuthSessionNotifier - Stream & Error Resilience', () {
    test('seeds from currentSession and reacts to auth stream events',
        () async {
      final fakeRepo = FakeAuthRepository();
      addTearDown(fakeRepo.dispose);

      final container = ProviderContainer(
        overrides: [
          authRepositoryProvider.overrideWithValue(fakeRepo),
        ],
      );
      addTearDown(container.dispose);

      expect(container.read(authSessionProvider).isSignedOut, isTrue);

      fakeRepo.emitSession(
        const AuthSessionState.signedIn(FakeAuthRepository.defaultTestUser),
      );
      await pumpEventQueue();
      expect(container.read(authSessionProvider).isSignedIn, isTrue);
      expect(
        container.read(currentUserProvider),
        equals(FakeAuthRepository.defaultTestUser),
      );

      // Stream error should not crash or drop the active session.
      fakeRepo.emitStreamError(Exception('Temporary network hiccup'));
      await pumpEventQueue();
      expect(container.read(authSessionProvider).isSignedIn, isTrue);

      // Recovery event updates state to passwordRecovery.
      fakeRepo.emitSession(
        const AuthSessionState.passwordRecovery(
          user: FakeAuthRepository.defaultTestUser,
        ),
      );
      await pumpEventQueue();
      expect(container.read(authSessionProvider).isPasswordRecovery, isTrue);

      // Sign-out transitions state back to signedOut.
      await fakeRepo.signOut();
      await pumpEventQueue();
      expect(container.read(authSessionProvider).isSignedOut, isTrue);
    });
  });

  group('GoRouter Integration - Live Redirects with FakeAuthRepository', () {
    testWidgets(
      'redirects across /login, /dashboard, and /reset-password on session '
      'changes',
      (tester) async {
        tester.view.physicalSize = const Size(1280, 900);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(() {
          tester.view.resetPhysicalSize();
          tester.view.resetDevicePixelRatio();
        });

        SharedPreferences.setMockInitialValues({});
        final prefs = await SharedPreferences.getInstance();
        final fakeRepo = FakeAuthRepository();
        addTearDown(fakeRepo.dispose);

        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              sharedPreferencesProvider.overrideWithValue(prefs),
              authRepositoryProvider.overrideWithValue(fakeRepo),
            ],
            child: const JobPrepApp(),
          ),
        );
        await tester.pumpAndSettle();

        // Starts signed out -> redirected to /login.
        expect(find.byType(LoginScreen), findsOneWidget);
        expect(find.byType(DashboardScreen), findsNothing);

        // User signs in -> redirected away from /login to /dashboard.
        fakeRepo.emitSession(
          const AuthSessionState.signedIn(FakeAuthRepository.defaultTestUser),
        );
        await tester.pumpAndSettle();

        expect(find.byType(DashboardScreen), findsOneWidget);
        expect(find.byType(LoginScreen), findsNothing);

        // Password recovery session arrives -> redirected to /reset-password.
        fakeRepo.emitSession(
          const AuthSessionState.passwordRecovery(
            user: FakeAuthRepository.defaultTestUser,
          ),
        );
        await tester.pumpAndSettle();

        expect(find.byType(ResetPasswordScreen), findsOneWidget);
        expect(find.byType(DashboardScreen), findsNothing);

        // Completing password update yields signedIn so dashboard loads.
        await fakeRepo.updatePassword(newPassword: 'UpdatedPassword123!');
        await tester.pumpAndSettle();

        final container = ProviderScope.containerOf(
          tester.element(find.byType(JobPrepApp)),
        );
        container.read(routerProvider).go(AppRoutePaths.dashboard);
        await tester.pumpAndSettle();

        expect(find.byType(DashboardScreen), findsOneWidget);

        // Sign out sends user back to /login.
        await fakeRepo.signOut();
        await tester.pumpAndSettle();

        expect(find.byType(LoginScreen), findsOneWidget);
      },
    );
  });
}
