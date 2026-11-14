import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:job_prep/core/data/app_mode.dart';
import 'package:job_prep/core/local/database/app_database.dart';
import 'package:job_prep/core/local/local_database_provider.dart';
import 'package:job_prep/core/storage/preferences_provider.dart';
import 'package:job_prep/core/theme/app_theme.dart';
import 'package:job_prep/features/settings/presentation/widgets/guest_settings_card.dart';
import 'package:job_prep/l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  late AppDatabase db;
  late SharedPreferences prefs;

  setUp(() async {
    SharedPreferences.setMockInitialValues({'jobprep_app_mode': 'guest'});
    prefs = await SharedPreferences.getInstance();
    db = AppDatabase(NativeDatabase.memory());
  });

  tearDown(() async {
    await db.close();
  });

  Widget buildTestSettings({GoRouter? router}) {
    return ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
        appDatabaseProvider.overrideWithValue(db),
      ],
      child: router != null
          ? MaterialApp.router(
              theme: AppTheme.dark(),
              localizationsDelegates: AppLocalizations.localizationsDelegates,
              supportedLocales: AppLocalizations.supportedLocales,
              routerConfig: router,
            )
          : MaterialApp(
              theme: AppTheme.dark(),
              localizationsDelegates: AppLocalizations.localizationsDelegates,
              supportedLocales: AppLocalizations.supportedLocales,
              home: const Scaffold(
                body: SingleChildScrollView(child: GuestSettingsCard()),
              ),
            ),
    );
  }

  group('GuestSettingsCard & Double Confirmation Erase Tests', () {
    testWidgets('renders storage status and all guest action buttons',
        (tester) async {
      await tester.pumpWidget(buildTestSettings());
      await tester.pumpAndSettle();

      expect(
        find.byKey(const ValueKey('settings-guest-section-card')),
        findsOneWidget,
      );
      expect(
        find.byKey(const ValueKey('settings-guest-storage-status')),
        findsOneWidget,
      );
      expect(
        find.byKey(const ValueKey('settings-guest-backup-btn')),
        findsOneWidget,
      );
      expect(
        find.byKey(const ValueKey('settings-guest-create-account-btn')),
        findsOneWidget,
      );
      expect(
        find.byKey(const ValueKey('settings-guest-erase-data-btn')),
        findsOneWidget,
      );
    });

    testWidgets('tapping Back up my data opens real backup export dialog',
        (tester) async {
      await tester.pumpWidget(buildTestSettings());
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const ValueKey('settings-guest-backup-btn')));
      await tester.pumpAndSettle();

      expect(
        find.byKey(const ValueKey('backup-passphrase-dialog')),
        findsOneWidget,
      );
    });

    testWidgets('cancel on step 1 of double confirmation aborts erase',
        (tester) async {
      await tester.pumpWidget(buildTestSettings());
      await tester.pumpAndSettle();

      await tester
          .tap(find.byKey(const ValueKey('settings-guest-erase-data-btn')));
      await tester.pumpAndSettle();

      expect(
        find.byKey(const ValueKey('erase_data_dialog_step_1')),
        findsOneWidget,
      );
      await tester
          .tap(find.byKey(const ValueKey('erase_data_dialog_1_cancel_button')));
      await tester.pumpAndSettle();

      expect(
        find.byKey(const ValueKey('erase_data_dialog_step_1')),
        findsNothing,
      );
      expect(
        find.byKey(const ValueKey('erase_data_dialog_step_2')),
        findsNothing,
      );
      expect(prefs.getString(AppModeNotifier.storageKey), equals('guest'));
    });

    testWidgets(
        'proceeding through step 1 and confirming step 2 erases local data',
        (tester) async {
      final router = GoRouter(
        initialLocation: '/settings',
        routes: [
          GoRoute(
            path: '/settings',
            builder: (ctx, state) => const Scaffold(
              body: SingleChildScrollView(child: GuestSettingsCard()),
            ),
          ),
          GoRoute(
            path: '/login',
            builder: (ctx, state) => const Scaffold(
              body: Text('Login Screen Landmark'),
            ),
          ),
        ],
      );

      await tester.pumpWidget(buildTestSettings(router: router));
      await tester.pumpAndSettle();

      await tester
          .tap(find.byKey(const ValueKey('settings-guest-erase-data-btn')));
      await tester.pumpAndSettle();

      expect(
        find.byKey(const ValueKey('erase_data_dialog_step_1')),
        findsOneWidget,
      );
      await tester.tap(
        find.byKey(const ValueKey('erase_data_dialog_1_confirm_button')),
      );
      await tester.pumpAndSettle();

      expect(
        find.byKey(const ValueKey('erase_data_dialog_step_2')),
        findsOneWidget,
      );
      await tester.tap(
        find.byKey(const ValueKey('erase_data_dialog_2_confirm_button')),
      );
      await tester.pumpAndSettle();

      // Verify preferences cleared and redirected to login
      expect(prefs.getString(AppModeNotifier.storageKey), isNull);
      expect(find.text('Login Screen Landmark'), findsOneWidget);
    });
  });
}
