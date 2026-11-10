import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:job_prep/core/localization/locale_controller.dart';
import 'package:job_prep/core/theme/app_theme.dart';
import 'package:job_prep/core/theme/reduce_effects_controller.dart';
import 'package:job_prep/core/theme/theme_controller.dart';
import 'package:job_prep/core/widgets/glass_button.dart';
import 'package:job_prep/features/auth/domain/errors/auth_failure.dart';
import 'package:job_prep/features/auth/presentation/providers/auth_providers.dart';
import 'package:job_prep/features/auth/presentation/screens/login_screen.dart';
import 'package:job_prep/features/auth/presentation/widgets/auth_status_banner.dart';
import 'package:job_prep/l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'fake_auth_repository.dart';

void main() {
  late SharedPreferences prefs;
  late FakeAuthRepository fakeRepo;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    prefs = await SharedPreferences.getInstance();
    fakeRepo = FakeAuthRepository();
  });

  tearDown(() async {
    await fakeRepo.dispose();
  });

  Future<void> pumpLoginScreen(
    WidgetTester tester, {
    ThemeMode themeMode = ThemeMode.dark,
    Locale locale = const Locale('en'),
    Size size = const Size(800, 900),
    bool reduceEffects = true,
  }) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await prefs.setBool(kReduceEffectsStorageKey, reduceEffects);
    await prefs.setString(kLocaleStorageKey, locale.languageCode);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
          authRepositoryProvider.overrideWithValue(fakeRepo),
        ],
        child: MaterialApp(
          theme: AppTheme.light(),
          darkTheme: AppTheme.dark(),
          themeMode: themeMode,
          locale: locale,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const LoginScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  group('LoginScreen - Idle State & Controls', () {
    testWidgets(
      'renders email, obscured password, visibility toggle, Google button, '
      'forgot link, and mode toggle',
      (tester) async {
        await pumpLoginScreen(tester, reduceEffects: false);

        expect(find.text('Welcome back'), findsOneWidget);
        expect(find.text('Email address'), findsOneWidget);
        expect(find.text('Password'), findsOneWidget);
        expect(find.text('Sign in'), findsOneWidget);
        expect(find.text('Continue with Google'), findsOneWidget);
        expect(find.text('Forgot password?'), findsOneWidget);
        expect(find.text('Create account'), findsOneWidget);

        // Password starts obscured and toggles on suffix icon tap.
        final passwordInputFinder = find.descendant(
          of: find.byKey(const ValueKey('auth_password_field')),
          matching: find.byType(EditableText),
        );
        expect(
          tester.widget<EditableText>(passwordInputFinder).obscureText,
          isTrue,
        );

        await tester.tap(
          find.byKey(const ValueKey('auth_toggle_password_visibility')),
        );
        await tester.pump();
        expect(
          tester.widget<EditableText>(passwordInputFinder).obscureText,
          isFalse,
        );

        await tester.tap(
          find.byKey(const ValueKey('auth_toggle_password_visibility')),
        );
        await tester.pump();
        expect(
          tester.widget<EditableText>(passwordInputFinder).obscureText,
          isTrue,
        );
      },
    );

    testWidgets(
      'renders in light and dark themes and Bangla on compact mobile width',
      (tester) async {
        await pumpLoginScreen(
          tester,
          themeMode: ThemeMode.light,
          locale: const Locale('bn'),
          size: const Size(360, 800),
        );

        expect(find.text('স্বাগতম'), findsOneWidget);
        expect(find.text('ইমেইল ঠিকানা'), findsOneWidget);
        expect(find.text('পাসওয়ার্ড'), findsOneWidget);
        expect(find.text('Google দিয়ে চালিয়ে যান'), findsOneWidget);
        expect(find.text('পাসওয়ার্ড ভুলে গেছেন?'), findsOneWidget);
        expect(find.text('অ্যাকাউন্ট তৈরি করুন'), findsOneWidget);
      },
    );
  });

  group('LoginScreen - Loading States', () {
    testWidgets('shows loading spinner and disables buttons during sign-in',
        (tester) async {
      await pumpLoginScreen(tester);
      fakeRepo.pendingGate = Completer<void>();

      await tester.enterText(
        find.byKey(const ValueKey('auth_email_field')),
        'user@example.com',
      );
      await tester.enterText(
        find.byKey(const ValueKey('auth_password_field')),
        'Password123',
      );

      await tester
          .tap(find.byKey(const ValueKey('auth_primary_submit_button')));
      await tester.pump();

      expect(
        find.descendant(
          of: find.byKey(const ValueKey('auth_primary_submit_button')),
          matching: find.byType(CircularProgressIndicator),
        ),
        findsOneWidget,
      );

      // Google button is disabled while email sign-in is loading.
      final googleBtn = tester.widget<GlassButton>(
        find.descendant(
          of: find.byKey(const ValueKey('auth_google_button')),
          matching: find.byType(GlassButton),
        ),
      );
      expect(googleBtn.onPressed, isNull);

      fakeRepo.pendingGate!.complete();
      await tester.pumpAndSettle();

      expect(find.byType(CircularProgressIndicator), findsNothing);
    });

    testWidgets('shows loading spinner on Continue with Google button',
        (tester) async {
      await pumpLoginScreen(tester);
      fakeRepo.pendingGate = Completer<void>();

      await tester.tap(find.byKey(const ValueKey('auth_google_button')));
      await tester.pump();

      expect(
        find.descendant(
          of: find.byKey(const ValueKey('auth_google_button')),
          matching: find.byType(CircularProgressIndicator),
        ),
        findsOneWidget,
      );

      fakeRepo.pendingGate!.complete();
      await tester.pumpAndSettle();

      expect(find.byType(CircularProgressIndicator), findsNothing);
      expect(fakeRepo.currentSession.isSignedIn, isTrue);
    });
  });

  group('LoginScreen - Error States & Validation', () {
    testWidgets('enforces minimum 8 character password on Create account',
        (tester) async {
      await pumpLoginScreen(tester);

      await tester.tap(find.byKey(const ValueKey('auth_mode_toggle_button')));
      await tester.pumpAndSettle();

      expect(find.text('Create your account'), findsOneWidget);
      expect(find.text('Must be at least 8 characters'), findsOneWidget);

      await tester.enterText(
        find.byKey(const ValueKey('auth_email_field')),
        'newuser@example.com',
      );
      await tester.enterText(
        find.byKey(const ValueKey('auth_password_field')),
        'short7',
      );

      await tester
          .tap(find.byKey(const ValueKey('auth_primary_submit_button')));
      await tester.pumpAndSettle();

      expect(
        find.byWidgetPredicate(
          (w) =>
              w is Text &&
              w.data == 'Password must be at least 8 characters.' &&
              (w.style?.fontSize ?? 0) > 0,
        ),
        findsOneWidget,
      );
      expect(fakeRepo.lastEmail, isNull);
    });

    testWidgets('displays localized errors for every AuthFailure type',
        (tester) async {
      await pumpLoginScreen(tester);

      final failureExpectations = <(AuthFailure, String)>[
        (
          const InvalidCredentialsFailure(),
          'Invalid email or password. Please check your details and try again.',
        ),
        (
          const EmailNotConfirmedFailure(),
          'Please confirm your email address before signing in. Check your '
              'inbox for the verification link.',
        ),
        (
          const AccountAlreadyExistsFailure(),
          'An account with this email already exists. Try signing in instead.',
        ),
        (
          const TooManyRequestsFailure(),
          'Too many attempts. Please wait a moment and try again.',
        ),
        (
          const NetworkFailure(),
          'Network error. Please check your internet connection and try again.',
        ),
        (
          const WeakPasswordFailure(),
          'Your password is too weak. Use at least 8 characters with letters '
              'and numbers.',
        ),
        (
          const UnknownAuthFailure(),
          'Something went wrong during authentication. Please try again.',
        ),
      ];

      await tester.enterText(
        find.byKey(const ValueKey('auth_email_field')),
        'user@example.com',
      );
      await tester.enterText(
        find.byKey(const ValueKey('auth_password_field')),
        'Password123',
      );

      for (final (failure, expectedText) in failureExpectations) {
        fakeRepo.nextFailure = failure;

        await tester.tap(
          find.byKey(const ValueKey('auth_primary_submit_button')),
        );
        await tester.pumpAndSettle();

        expect(find.byType(AuthStatusBanner), findsOneWidget);
        expect(find.text(expectedText), findsOneWidget);
      }
    });

    testWidgets('displays localized Bangla error banner for AuthFailure',
        (tester) async {
      await pumpLoginScreen(tester, locale: const Locale('bn'));
      fakeRepo.nextFailure = const InvalidCredentialsFailure();

      await tester.enterText(
        find.byKey(const ValueKey('auth_email_field')),
        'user@example.com',
      );
      await tester.enterText(
        find.byKey(const ValueKey('auth_password_field')),
        'Password123',
      );
      await tester
          .tap(find.byKey(const ValueKey('auth_primary_submit_button')));
      await tester.pumpAndSettle();

      expect(
        find.text(
          'ইমেইল বা পাসওয়ার্ড সঠিক নয়। তথ্য যাচাই করে আবার চেষ্টা করুন।',
        ),
        findsOneWidget,
      );
    });
  });

  group('LoginScreen - Success States', () {
    testWidgets('signup succeeds and shows check-your-email confirmation',
        (tester) async {
      await pumpLoginScreen(tester);

      await tester.tap(find.byKey(const ValueKey('auth_mode_toggle_button')));
      await tester.pumpAndSettle();

      await tester.enterText(
        find.byKey(const ValueKey('auth_email_field')),
        'aspirant@example.com',
      );
      await tester.enterText(
        find.byKey(const ValueKey('auth_password_field')),
        'StrongPass123',
      );

      await tester
          .tap(find.byKey(const ValueKey('auth_primary_submit_button')));
      await tester.pumpAndSettle();

      expect(find.text('Check your email'), findsOneWidget);
      expect(
        find.textContaining('aspirant@example.com'),
        findsOneWidget,
      );

      await tester.tap(
        find.byKey(const ValueKey('auth_confirmation_back_button')),
      );
      await tester.pumpAndSettle();

      expect(find.text('Welcome back'), findsOneWidget);
    });

    testWidgets('forgot password sends reset email and confirms dispatch',
        (tester) async {
      await pumpLoginScreen(tester);

      await tester.tap(
        find.byKey(const ValueKey('auth_forgot_password_button')),
      );
      await tester.pumpAndSettle();

      expect(find.text('Reset your password'), findsOneWidget);
      expect(find.byKey(const ValueKey('auth_password_field')), findsNothing);
      expect(find.byKey(const ValueKey('auth_google_button')), findsNothing);

      await tester.enterText(
        find.byKey(const ValueKey('auth_email_field')),
        'recover@example.com',
      );
      await tester
          .tap(find.byKey(const ValueKey('auth_primary_submit_button')));
      await tester.pumpAndSettle();

      expect(fakeRepo.lastEmail, equals('recover@example.com'));
      expect(find.text('Reset link sent'), findsOneWidget);
      expect(find.textContaining('recover@example.com'), findsOneWidget);

      await tester.tap(
        find.byKey(const ValueKey('auth_confirmation_back_button')),
      );
      await tester.pumpAndSettle();

      expect(find.text('Welcome back'), findsOneWidget);
    });
  });
}
