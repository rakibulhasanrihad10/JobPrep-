import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:job_prep/core/localization/locale_controller.dart';
import 'package:job_prep/core/theme/app_theme.dart';
import 'package:job_prep/core/theme/reduce_effects_controller.dart';
import 'package:job_prep/core/theme/theme_controller.dart';
import 'package:job_prep/core/widgets/glass_button.dart';
import 'package:job_prep/features/auth/domain/entities/auth_session_state.dart';
import 'package:job_prep/features/auth/domain/errors/auth_failure.dart';
import 'package:job_prep/features/auth/presentation/providers/auth_providers.dart';
import 'package:job_prep/features/auth/presentation/screens/reset_password_screen.dart';
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
    fakeRepo = FakeAuthRepository(
      initialSession: const AuthSessionState.passwordRecovery(
        user: FakeAuthRepository.defaultTestUser,
      ),
    );
  });

  tearDown(() async {
    await fakeRepo.dispose();
  });

  Future<void> pumpResetScreen(
    WidgetTester tester, {
    ThemeMode themeMode = ThemeMode.dark,
    Locale locale = const Locale('en'),
    Size size = const Size(800, 900),
    VoidCallback? onContinue,
  }) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await prefs.setBool(kReduceEffectsStorageKey, true);
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
          home: ResetPasswordScreen(onContinueToDashboard: onContinue),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  group('ResetPasswordScreen - States', () {
    testWidgets(
      'idle state renders fields with visibility toggles in light/Bangla',
      (tester) async {
        await pumpResetScreen(
          tester,
          themeMode: ThemeMode.light,
          locale: const Locale('bn'),
          size: const Size(360, 800),
        );

        expect(find.text('নতুন পাসওয়ার্ড সেট করুন'), findsOneWidget);
        expect(find.text('নতুন পাসওয়ার্ড'), findsOneWidget);
        expect(find.text('নতুন পাসওয়ার্ড নিশ্চিত করুন'), findsOneWidget);
        expect(find.text('পাসওয়ার্ড আপডেট করুন'), findsOneWidget);

        final newPassEditable = find.descendant(
          of: find.byKey(const ValueKey('reset_new_password_field')),
          matching: find.byType(EditableText),
        );
        expect(
          tester.widget<EditableText>(newPassEditable).obscureText,
          isTrue,
        );

        await tester.tap(
          find.byKey(const ValueKey('reset_toggle_password_visibility')),
        );
        await tester.pump();
        expect(
          tester.widget<EditableText>(newPassEditable).obscureText,
          isFalse,
        );
      },
    );

    testWidgets('loading state shows spinner and disables submit button',
        (tester) async {
      await pumpResetScreen(tester);
      fakeRepo.pendingGate = Completer<void>();

      await tester.enterText(
        find.byKey(const ValueKey('reset_new_password_field')),
        'StrongPassword123',
      );
      await tester.enterText(
        find.byKey(const ValueKey('reset_confirm_password_field')),
        'StrongPassword123',
      );

      await tester.tap(find.byKey(const ValueKey('reset_submit_button')));
      await tester.pump();

      expect(
        find.descendant(
          of: find.byKey(const ValueKey('reset_submit_button')),
          matching: find.byType(CircularProgressIndicator),
        ),
        findsOneWidget,
      );

      final button = tester.widget<GlassButton>(
        find.descendant(
          of: find.byKey(const ValueKey('reset_submit_button')),
          matching: find.byType(GlassButton),
        ),
      );
      expect(button.onPressed, isNull);

      fakeRepo.pendingGate!.complete();
      await tester.pumpAndSettle();

      expect(find.text('Password updated'), findsOneWidget);
    });

    testWidgets('error state validates length, mismatch, and AuthFailure',
        (tester) async {
      await pumpResetScreen(tester);

      // Too short (< 8 chars)
      await tester.enterText(
        find.byKey(const ValueKey('reset_new_password_field')),
        'short',
      );
      await tester.enterText(
        find.byKey(const ValueKey('reset_confirm_password_field')),
        'short',
      );
      await tester.tap(find.byKey(const ValueKey('reset_submit_button')));
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

      // Mismatch
      await tester.enterText(
        find.byKey(const ValueKey('reset_new_password_field')),
        'ValidPassword123',
      );
      await tester.enterText(
        find.byKey(const ValueKey('reset_confirm_password_field')),
        'DifferentPass123',
      );
      await tester.tap(find.byKey(const ValueKey('reset_submit_button')));
      await tester.pumpAndSettle();

      expect(
        find.byWidgetPredicate(
          (w) =>
              w is Text &&
              w.data == 'Passwords do not match.' &&
              (w.style?.fontSize ?? 0) > 0,
        ),
        findsOneWidget,
      );

      // Backend AuthFailure
      await tester.enterText(
        find.byKey(const ValueKey('reset_confirm_password_field')),
        'ValidPassword123',
      );
      fakeRepo.nextFailure = const WeakPasswordFailure();
      await tester.tap(find.byKey(const ValueKey('reset_submit_button')));
      await tester.pumpAndSettle();

      expect(find.byType(AuthStatusBanner), findsOneWidget);
      expect(
        find.text(
          'Your password is too weak. Use at least 8 characters with letters '
          'and numbers.',
        ),
        findsOneWidget,
      );
    });

    testWidgets(
        'success state displays confirmation and invokes dashboard action',
        (tester) async {
      var continued = false;
      await pumpResetScreen(tester, onContinue: () => continued = true);

      await tester.enterText(
        find.byKey(const ValueKey('reset_new_password_field')),
        'UpdatedPass2026!',
      );
      await tester.enterText(
        find.byKey(const ValueKey('reset_confirm_password_field')),
        'UpdatedPass2026!',
      );

      await tester.tap(find.byKey(const ValueKey('reset_submit_button')));
      await tester.pumpAndSettle();

      expect(fakeRepo.lastUpdatedPassword, equals('UpdatedPass2026!'));
      expect(find.text('Password updated'), findsOneWidget);

      await tester.tap(
        find.byKey(const ValueKey('reset_continue_dashboard_button')),
      );
      expect(continued, isTrue);
    });
  });
}
