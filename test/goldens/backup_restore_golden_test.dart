import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:job_prep/core/data/app_mode.dart';
import 'package:job_prep/core/storage/preferences_provider.dart';
import 'package:job_prep/core/theme/app_theme.dart';
import 'package:job_prep/core/theme/reduce_effects_controller.dart';
import 'package:job_prep/features/backup/domain/entities/backup_manifest.dart';
import 'package:job_prep/features/backup/presentation/widgets/restore_preview_dialog.dart';
import 'package:job_prep/l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _TolerantGoldenComparator extends LocalFileComparator {
  _TolerantGoldenComparator(super.testFile);

  static const double _tolerance = 0.04;

  @override
  Future<bool> compare(Uint8List imageBytes, Uri golden) async {
    final result = await GoldenFileComparator.compareLists(
      imageBytes,
      await getGoldenBytes(golden),
    );

    if (!result.passed && result.diffPercent <= _tolerance) {
      return true;
    }

    if (!result.passed) {
      final error = await generateFailureOutput(result, golden, basedir);
      throw FlutterError(error);
    }
    return result.passed;
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    final currentUrl = Uri.base.resolve('test/goldens/test.dart');
    goldenFileComparator = _TolerantGoldenComparator(currentUrl);
  });

  final manifest = BackupManifest(
    schemaVersion: 1,
    appVersion: '0.1.0',
    exportedAt: DateTime.utc(2026, 11, 14, 12),
    checksum: 'test-checksum-hash',
    data: const BackupDataTables(
      circulars: [
        {'id': 'c1', 'title': 'Bangladesh Bank AD'},
      ],
      circularExamDates: [
        {'id': 'd1', 'circular_id': 'c1', 'stage': 'preliminary'},
      ],
      subjects: [
        {'id': 's1', 'name': 'Bangla Literature'},
      ],
      materials: [
        {'id': 'm1', 'title': 'Lalshalu', 'total_units': 300},
      ],
      progressLogs: [
        {'id': 'p1', 'units_done': 150},
      ],
      topics: [
        {'id': 't1', 'name': 'Modern Novel'},
      ],
      studyPlans: [
        {'id': 'sp1', 'title': '30-Day Plan'},
      ],
      mockTests: [
        {'id': 'mt1', 'title': 'Pre-test 1'},
      ],
      revisionItems: [
        {'id': 'r1', 'material_id': 'm1'},
      ],
      studySessions: [
        {'id': 'ss1', 'duration_minutes': 45},
      ],
      notifications: [
        {'id': 'n1', 'title': 'Exam upcoming'},
      ],
      portalAccounts: [
        {'id': 'pa1', 'portal_name': 'BPSC'},
      ],
    ),
  );

  Future<void> pumpRestoreGolden(
    WidgetTester tester, {
    required ThemeMode themeMode,
    Locale locale = const Locale('en'),
  }) async {
    tester.view.physicalSize = const Size(800, 750);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    SharedPreferences.setMockInitialValues({
      kReduceEffectsStorageKey: false,
    });
    final prefs = await SharedPreferences.getInstance();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
          appModeProvider.overrideWith(
            () => _StaticAppModeNotifier(AppMode.guest),
          ),
        ],
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: AppTheme.light(),
          darkTheme: AppTheme.dark(),
          themeMode: themeMode,
          locale: locale,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            backgroundColor: themeMode == ThemeMode.dark
                ? const Color(0xFF0A0E17)
                : const Color(0xFFF8FAFC),
            body: Center(
              child: RestorePreviewDialog(manifest: manifest),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  group('RestorePreviewDialog Golden Tests', () {
    testWidgets('RestorePreviewDialog - dark mode', (tester) async {
      await pumpRestoreGolden(tester, themeMode: ThemeMode.dark);
      await expectLater(
        find.byType(RestorePreviewDialog),
        matchesGoldenFile('goldens/restore_preview_dialog_dark.png'),
      );
    });

    testWidgets('RestorePreviewDialog - light mode', (tester) async {
      await pumpRestoreGolden(tester, themeMode: ThemeMode.light);
      await expectLater(
        find.byType(RestorePreviewDialog),
        matchesGoldenFile('goldens/restore_preview_dialog_light.png'),
      );
    });
  });
}

class _StaticAppModeNotifier extends AppModeNotifier {
  _StaticAppModeNotifier(this._initial);
  final AppMode _initial;

  @override
  AppMode? build() => _initial;
}
