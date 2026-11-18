import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:job_prep/core/data/app_mode.dart';
import 'package:job_prep/core/storage/preferences_provider.dart';
import 'package:job_prep/core/theme/app_theme.dart';
import 'package:job_prep/core/theme/reduce_effects_controller.dart';
import 'package:job_prep/features/backup/domain/entities/backup_manifest.dart';
import 'package:job_prep/features/backup/presentation/providers/backup_providers.dart';
import 'package:job_prep/features/migration/domain/entities/guest_migration_state.dart';
import 'package:job_prep/features/migration/presentation/providers/guest_migration_providers.dart';
import 'package:job_prep/features/migration/presentation/widgets/guest_migration_choice_dialog.dart';
import 'package:job_prep/features/migration/presentation/widgets/guest_migration_complete_dialog.dart';
import 'package:job_prep/features/migration/presentation/widgets/guest_migration_progress_dialog.dart';
import 'package:job_prep/features/migration/presentation/widgets/guest_upgrade_banner.dart';
import 'package:job_prep/features/settings/presentation/providers/data_export_providers.dart';
import 'package:job_prep/l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _StaticAppModeNotifier extends AppModeNotifier {
  _StaticAppModeNotifier(this._initialMode);

  final AppMode? _initialMode;

  @override
  AppMode? build() => _initialMode;
}

class _StaticMigrationNotifier extends GuestMigrationNotifier {
  _StaticMigrationNotifier(this._state);

  final GuestMigrationState _state;

  @override
  GuestMigrationState build() => _state;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late SharedPreferences prefs;

  setUp(() async {
    SharedPreferences.setMockInitialValues({
      kReduceEffectsStorageKey: false,
    });
    prefs = await SharedPreferences.getInstance();
  });

  Widget createTestWidget({
    required Widget child,
    AppMode? appMode = AppMode.guest,
    GuestMigrationState? migrationState,
    DataExportFileSaverFn? fileSaver,
  }) {
    return ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
        appModeProvider.overrideWith(() => _StaticAppModeNotifier(appMode)),
        if (migrationState != null)
          guestMigrationControllerProvider.overrideWith(
            () => _StaticMigrationNotifier(migrationState),
          ),
        if (fileSaver != null)
          backupFileSaverProvider.overrideWithValue(fileSaver),
      ],
      child: MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        theme: AppTheme.light(),
        home: Scaffold(body: Center(child: child)),
      ),
    );
  }

  group('GuestUpgradeBanner Widget Tests', () {
    testWidgets('renders upgrade banner in guest mode', (tester) async {
      await tester.pumpWidget(
        createTestWidget(
          child: const GuestUpgradeBanner(),
        ),
      );
      await tester.pumpAndSettle();

      expect(
        find.byKey(const ValueKey('today-guest-upgrade-banner')),
        findsOneWidget,
      );
      expect(
        find.byKey(const ValueKey('today-guest-upgrade-btn')),
        findsOneWidget,
      );
    });

    testWidgets('hides upgrade banner in signedIn mode', (tester) async {
      await tester.pumpWidget(
        createTestWidget(
          child: const GuestUpgradeBanner(),
          appMode: AppMode.signedIn,
        ),
      );
      await tester.pumpAndSettle();

      expect(
        find.byKey(const ValueKey('today-guest-upgrade-banner')),
        findsNothing,
      );
    });
  });

  group('GuestMigrationChoiceDialog Widget Tests', () {
    testWidgets('renders table counts and triggers callbacks', (tester) async {
      var moved = false;
      var fresh = false;

      const tables = BackupDataTables(
        subjects: [
          {'id': 'sub-1', 'name': 'Bangla'},
        ],
        materials: [
          {'id': 'mat-1', 'title': 'Grammar'},
        ],
      );

      await tester.pumpWidget(
        createTestWidget(
          child: GuestMigrationChoiceDialog(
            tables: tables,
            onMoveData: () => moved = true,
            onStartFresh: () => fresh = true,
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(
        find.byKey(const ValueKey('guest-migration-choice-dialog')),
        findsOneWidget,
      );
      expect(find.text('Subjects: '), findsOneWidget);
      expect(find.text('Materials: '), findsOneWidget);

      await tester.tap(find.byKey(const ValueKey('migration-choice-move-btn')));
      expect(moved, isTrue);

      await tester
          .tap(find.byKey(const ValueKey('migration-choice-fresh-btn')));
      expect(fresh, isTrue);
    });
  });

  group('GuestMigrationProgressDialog Widget Tests', () {
    testWidgets('renders progress step and bar during upload', (tester) async {
      const state = GuestMigrationState(
        status: MigrationStatus.uploading,
        currentTable: 'materials',
        processedRecords: 5,
        totalRecords: 10,
      );

      await tester.pumpWidget(
        createTestWidget(
          child: GuestMigrationProgressDialog(
            onRetry: () {},
            onCancel: () {},
          ),
          migrationState: state,
        ),
      );
      await tester.pumpAndSettle();

      expect(
        find.byKey(const ValueKey('guest-migration-progress-dialog')),
        findsOneWidget,
      );
      expect(
        find.byKey(const ValueKey('migration-progress-bar')),
        findsOneWidget,
      );
      expect(find.text('50%'), findsOneWidget);
    });

    testWidgets('renders error and retry button on failure', (tester) async {
      var retried = false;
      var cancelled = false;

      const state = GuestMigrationState(
        status: MigrationStatus.failed,
        errorMessage: 'Connection lost to cloud',
      );

      await tester.pumpWidget(
        createTestWidget(
          child: GuestMigrationProgressDialog(
            onRetry: () => retried = true,
            onCancel: () => cancelled = true,
          ),
          migrationState: state,
        ),
      );
      await tester.pumpAndSettle();

      expect(find.textContaining('Connection lost to cloud'), findsOneWidget);
      expect(find.byKey(const ValueKey('migration-retry-btn')), findsOneWidget);

      await tester.tap(find.byKey(const ValueKey('migration-retry-btn')));
      expect(retried, isTrue);

      await tester.tap(find.byKey(const ValueKey('migration-cancel-btn')));
      expect(cancelled, isTrue);
    });
  });

  group('GuestMigrationCompleteDialog Widget Tests', () {
    testWidgets('toggles erase switch and triggers download and finish',
        (tester) async {
      bool? eraseResult;
      var downloadCalled = false;

      final manifest = BackupManifest(
        schemaVersion: 1,
        appVersion: '0.1.0',
        exportedAt: DateTime.utc(2026, 11, 14),
        checksum: 'hash',
        data: const BackupDataTables(),
      );

      final state = GuestMigrationState(
        status: MigrationStatus.completed,
        finalBackupManifest: manifest,
      );

      await tester.pumpWidget(
        createTestWidget(
          child: GuestMigrationCompleteDialog(
            onFinish: ({required eraseLocalCopy}) =>
                eraseResult = eraseLocalCopy,
          ),
          migrationState: state,
          fileSaver: ({
            required bytes,
            required mimeType,
            required fileName,
          }) async {
            downloadCalled = true;
            return Uri.parse('file://test');
          },
        ),
      );
      await tester.pumpAndSettle();

      expect(
        find.byKey(const ValueKey('guest-migration-complete-dialog')),
        findsOneWidget,
      );

      // Download backup
      await tester.tap(
        find.byKey(const ValueKey('migration-download-final-backup-btn')),
      );
      await tester.pumpAndSettle();
      expect(downloadCalled, isTrue);

      // Toggle erase switch
      final switchFinder =
          find.byKey(const ValueKey('migration-erase-local-switch'));
      expect(switchFinder, findsOneWidget);
      await tester.tap(switchFinder);
      await tester.pumpAndSettle();

      // Finish
      await tester
          .tap(find.byKey(const ValueKey('migration-complete-finish-btn')));
      expect(eraseResult, isFalse);
    });
  });
}
