import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:job_prep/core/local/database/app_database.dart';
import 'package:job_prep/core/local/local_database_provider.dart';
import 'package:job_prep/core/storage/preferences_provider.dart';
import 'package:job_prep/core/theme/app_theme.dart';
import 'package:job_prep/core/widgets/glass_button.dart';
import 'package:job_prep/features/backup/domain/entities/backup_manifest.dart';
import 'package:job_prep/features/backup/presentation/providers/backup_providers.dart';
import 'package:job_prep/features/backup/presentation/widgets/backup_passphrase_dialog.dart';
import 'package:job_prep/features/backup/presentation/widgets/backup_reminder_banner.dart';
import 'package:job_prep/features/backup/presentation/widgets/restore_preview_dialog.dart';
import 'package:job_prep/l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  late SharedPreferences prefs;
  late AppDatabase db;

  setUp(() async {
    SharedPreferences.setMockInitialValues({'jobprep_app_mode': 'guest'});
    prefs = await SharedPreferences.getInstance();
    db = AppDatabase(NativeDatabase.memory());
  });

  tearDown(() async {
    await db.close();
  });

  Widget buildHarness({
    required Widget child,
    ThemeMode themeMode = ThemeMode.dark,
    Locale locale = const Locale('en'),
    List<dynamic> overrides = const [],
  }) {
    return ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
        appDatabaseProvider.overrideWithValue(db),
        ...overrides.cast(),
      ],
      child: MaterialApp(
        theme: AppTheme.light(),
        darkTheme: AppTheme.dark(),
        themeMode: themeMode,
        locale: locale,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(body: Center(child: child)),
      ),
    );
  }

  group('BackupPassphraseDialog', () {
    testWidgets('renders recommended encrypted state and validates passphrase',
        (tester) async {
      await tester.pumpWidget(
        buildHarness(child: const BackupPassphraseDialog()),
      );
      await tester.pumpAndSettle();

      expect(
        find.byKey(const ValueKey('backup-passphrase-dialog')),
        findsOneWidget,
      );
      expect(
        find.byKey(const ValueKey('backup-encryption-switch')),
        findsOneWidget,
      );
      expect(
        find.byKey(const ValueKey('backup-passphrase-input')),
        findsOneWidget,
      );
      expect(
        find.byKey(const ValueKey('backup-passphrase-confirm-input')),
        findsOneWidget,
      );

      // Attempt to export with empty passphrase
      await tester.tap(find.byKey(const ValueKey('backup-dialog-export-btn')));
      await tester.pumpAndSettle();

      expect(
        find.text('Passphrase must be at least 8 characters'),
        findsOneWidget,
      );

      // Type short passphrase
      await tester.enterText(
        find.byKey(const ValueKey('backup-passphrase-input')),
        'short',
      );
      await tester.tap(find.byKey(const ValueKey('backup-dialog-export-btn')));
      await tester.pumpAndSettle();

      expect(
        find.text('Passphrase must be at least 8 characters'),
        findsOneWidget,
      );

      // Type mismatching confirmation
      await tester.enterText(
        find.byKey(const ValueKey('backup-passphrase-input')),
        'ValidPass123!',
      );
      await tester.enterText(
        find.byKey(const ValueKey('backup-passphrase-confirm-input')),
        'DifferentPass123!',
      );
      await tester.tap(find.byKey(const ValueKey('backup-dialog-export-btn')));
      await tester.pumpAndSettle();

      expect(find.text('Passphrases do not match'), findsOneWidget);
    });

    testWidgets('toggles to plaintext export with warning banner',
        (tester) async {
      await tester.pumpWidget(
        buildHarness(child: const BackupPassphraseDialog()),
      );
      await tester.pumpAndSettle();

      // Toggle off encryption
      await tester.tap(find.byKey(const ValueKey('backup-encryption-switch')));
      await tester.pumpAndSettle();

      expect(
        find.byKey(const ValueKey('backup-plaintext-warning-banner')),
        findsOneWidget,
      );
      expect(
        find.byKey(const ValueKey('backup-passphrase-input')),
        findsNothing,
      );
      expect(find.text('Export without passphrase'), findsOneWidget);
    });
  });

  group('RestorePreviewDialog', () {
    final manifest = BackupManifest(
      schemaVersion: 1,
      appVersion: '0.1.0',
      exportedAt: DateTime.utc(2026, 11, 14),
      checksum: 'fake-checksum',
      data: const BackupDataTables(
        subjects: [
          {'id': 's1', 'name': 'Bangla'},
        ],
        materials: [
          {'id': 'm1', 'title': 'Book 1'},
        ],
      ),
    );

    testWidgets('renders counts and requires REPLACE for replace mode',
        (tester) async {
      await tester.pumpWidget(
        buildHarness(
          child: RestorePreviewDialog(manifest: manifest),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Total records: 2'), findsOneWidget);
      expect(
        find.byKey(const ValueKey('restore-strategy-merge-radio')),
        findsOneWidget,
      );
      expect(
        find.byKey(const ValueKey('restore-strategy-replace-radio')),
        findsOneWidget,
      );

      // Select Replace strategy
      await tester
          .tap(find.byKey(const ValueKey('restore-strategy-replace-radio')));
      await tester.pumpAndSettle();

      expect(
        find.byKey(const ValueKey('restore-replace-confirm-input')),
        findsOneWidget,
      );

      // Submit button is disabled until typing REPLACE
      final submitBtnFinder =
          find.byKey(const ValueKey('restore-dialog-submit-btn'));
      final buttonBefore = tester.widget<GlassButton>(submitBtnFinder);
      expect(buttonBefore.onPressed, isNull);

      // Enter confirmation word
      await tester.enterText(
        find.byKey(const ValueKey('restore-replace-confirm-input')),
        'REPLACE',
      );
      await tester.pumpAndSettle();

      final buttonAfter = tester.widget<GlassButton>(submitBtnFinder);
      expect(buttonAfter.onPressed, isNotNull);
    });
  });

  group('BackupReminderBanner', () {
    testWidgets('renders when reminder threshold is met and dismisses',
        (tester) async {
      await tester.pumpWidget(
        buildHarness(
          overrides: [
            lastBackupTimeProvider.overrideWith(
              () => _StaticBackupTimeNotifier(
                DateTime.now().subtract(const Duration(days: 8)),
              ),
            ),
          ],
          child: const BackupReminderBanner(),
        ),
      );
      await tester.pumpAndSettle();

      expect(
        find.byKey(const ValueKey('backup-reminder-banner')),
        findsOneWidget,
      );
      expect(
        find.byKey(const ValueKey('backup-reminder-dismiss-btn')),
        findsOneWidget,
      );
      expect(
        find.byKey(const ValueKey('backup-reminder-action-btn')),
        findsOneWidget,
      );

      // Tap dismiss
      await tester
          .tap(find.byKey(const ValueKey('backup-reminder-dismiss-btn')));
      await tester.pumpAndSettle();

      // State is dismissed
      expect(
        find.byKey(const ValueKey('backup-reminder-banner')),
        findsNothing,
      );
    });
  });
}

class _StaticBackupTimeNotifier extends LastBackupTimeNotifier {
  _StaticBackupTimeNotifier(this._initial);
  final DateTime _initial;
  @override
  DateTime? build() => _initial;
}
