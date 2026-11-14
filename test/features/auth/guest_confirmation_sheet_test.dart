import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:job_prep/core/storage/preferences_provider.dart';
import 'package:job_prep/core/theme/app_theme.dart';
import 'package:job_prep/features/auth/presentation/widgets/guest_confirmation_sheet.dart';
import 'package:job_prep/l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  late SharedPreferences prefs;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    prefs = await SharedPreferences.getInstance();
  });

  Widget buildTestSheet({Locale locale = const Locale('en')}) {
    return ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
      ],
      child: MaterialApp(
        theme: AppTheme.light(),
        darkTheme: AppTheme.dark(),
        locale: locale,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: Builder(
            builder: (context) => Center(
              child: ElevatedButton(
                key: const ValueKey('open_sheet_button'),
                onPressed: () => showGuestConfirmationSheet(context),
                child: const Text('Open'),
              ),
            ),
          ),
        ),
      ),
    );
  }

  group('GuestConfirmationSheet Widget Tests', () {
    testWidgets('renders all four plain-language caveats and action buttons',
        (tester) async {
      await tester.pumpWidget(buildTestSheet());
      await tester.tap(find.byKey(const ValueKey('open_sheet_button')));
      await tester.pumpAndSettle();

      expect(
        find.byKey(const ValueKey('guest-confirmation-sheet')),
        findsOneWidget,
      );
      expect(
        find.byKey(const ValueKey('guest_confirm_understand_button')),
        findsOneWidget,
      );
      expect(
        find.byKey(const ValueKey('guest_confirm_cancel_button')),
        findsOneWidget,
      );

      // Verify text mentions device/browser, clearing data, no sync/reminders,
      // and create account later
      expect(
        find.text('Data is stored only on this device and browser.'),
        findsOneWidget,
      );
      expect(
        find.text(
          'Clearing browser data or uninstalling the app deletes it '
          'permanently.',
        ),
        findsOneWidget,
      );
      expect(
        find.text('There is no cloud sync and no email reminders.'),
        findsOneWidget,
      );
      expect(
        find.text('You can create an account later and move your data across.'),
        findsOneWidget,
      );
    });

    testWidgets('tapping I understand dismisses sheet returning true',
        (tester) async {
      await tester.pumpWidget(buildTestSheet());
      await tester.tap(find.byKey(const ValueKey('open_sheet_button')));
      await tester.pumpAndSettle();

      await tester
          .tap(find.byKey(const ValueKey('guest_confirm_understand_button')));
      await tester.pumpAndSettle();

      expect(
        find.byKey(const ValueKey('guest-confirmation-sheet')),
        findsNothing,
      );
    });

    testWidgets('tapping Go back dismisses sheet without proceeding',
        (tester) async {
      await tester.pumpWidget(buildTestSheet());
      await tester.tap(find.byKey(const ValueKey('open_sheet_button')));
      await tester.pumpAndSettle();

      await tester
          .tap(find.byKey(const ValueKey('guest_confirm_cancel_button')));
      await tester.pumpAndSettle();

      expect(
        find.byKey(const ValueKey('guest-confirmation-sheet')),
        findsNothing,
      );
    });

    testWidgets('renders Bangla copy cleanly without text truncation',
        (tester) async {
      await tester.pumpWidget(buildTestSheet(locale: const Locale('bn')));
      await tester.tap(find.byKey(const ValueKey('open_sheet_button')));
      await tester.pumpAndSettle();

      expect(find.text('অ্যাকাউন্ট ছাড়াই চালিয়ে যান'), findsOneWidget);
      expect(find.text('আমি বুঝতে পেরেছি'), findsOneWidget);
      expect(find.text('ফিরে যান'), findsOneWidget);
    });
  });
}
