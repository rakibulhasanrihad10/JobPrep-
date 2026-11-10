import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:job_prep/core/localization/locale_controller.dart';
import 'package:job_prep/core/theme/app_theme.dart';
import 'package:job_prep/core/theme/reduce_effects_controller.dart';
import 'package:job_prep/core/theme/theme_controller.dart';
import 'package:job_prep/features/circulars/domain/entities/circular.dart';
import 'package:job_prep/features/circulars/domain/entities/circular_enums.dart';
import 'package:job_prep/features/circulars/domain/errors/circular_failure.dart';
import 'package:job_prep/features/circulars/presentation/providers/circulars_providers.dart';
import 'package:job_prep/features/circulars/presentation/widgets/quick_capture_dialog.dart';
import 'package:job_prep/l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'fake_circular_repository.dart';

void main() {
  final fixedNow = DateTime.utc(2026, 11, 10, 12);
  late SharedPreferences prefs;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    prefs = await SharedPreferences.getInstance();
  });

  Future<Circular?> openDialog(
    WidgetTester tester,
    FakeCircularRepository repo, {
    String? initialUrl,
    ThemeMode themeMode = ThemeMode.dark,
    String languageCode = 'en',
    ValueChanged<Circular?>? onResult,
  }) async {
    tester.view.physicalSize = const Size(900, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await prefs.setBool(kReduceEffectsStorageKey, true);
    await prefs.setString(kLocaleStorageKey, languageCode);

    Circular? poppedResult;

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
          circularRepositoryProvider.overrideWithValue(repo),
          circularNowProvider.overrideWithValue(() => fixedNow),
        ],
        child: MaterialApp(
          theme: AppTheme.light(),
          darkTheme: AppTheme.dark(),
          themeMode: themeMode,
          locale: Locale(languageCode),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            body: Builder(
              builder: (context) => Center(
                child: ElevatedButton(
                  key: const ValueKey('open-dialog-trigger'),
                  onPressed: () async {
                    poppedResult = await showQuickCaptureDialog(
                      context,
                      initialUrl: initialUrl,
                    );
                    onResult?.call(poppedResult);
                  },
                  child: const Text('Open'),
                ),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const ValueKey('open-dialog-trigger')));
    await tester.pumpAndSettle();
    return poppedResult;
  }

  group('QuickCaptureDialog Widget Tests', () {
    testWidgets('validates required link and saves with only a link',
        (tester) async {
      final repo = FakeCircularRepository(clock: () => fixedNow);
      Circular? result;

      await openDialog(
        tester,
        repo,
        onResult: (saved) => result = saved,
      );

      expect(
        find.byKey(const ValueKey('quick-capture-dialog')),
        findsOneWidget,
      );

      // Submit empty -> validation error, stays open
      await tester.tap(find.byKey(const ValueKey('quick-capture-save-btn')));
      await tester.pumpAndSettle();

      expect(find.text('Please enter the circular link.'), findsOneWidget);
      expect(repo.createdItems, isEmpty);
      expect(
        find.byKey(const ValueKey('quick-capture-dialog')),
        findsOneWidget,
      );

      // Enter ONLY a link and save
      await tester.enterText(
        find.byKey(const ValueKey('quick-capture-link-field')),
        'https://www.bpsc.gov.bd/notices/47',
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const ValueKey('quick-capture-save-btn')));
      await tester.pumpAndSettle();

      expect(find.byKey(const ValueKey('quick-capture-dialog')), findsNothing);
      expect(result, isNotNull);
      expect(result!.title, equals('bpsc.gov.bd'));
      expect(
        result!.circularUrl,
        equals('https://www.bpsc.gov.bd/notices/47'),
      );
      expect(result!.workflowStatus, equals(CircularWorkflowStatus.inbox));
      expect(result!.isQuickCapture, isTrue);
      expect(result!.deadline, isNull);
    });

    testWidgets(
        'shows duplicate warning from Phase 3D and optional fields work',
        (tester) async {
      final repo = FakeCircularRepository(
        initialItems: const [
          Circular(
            id: 'dup-1',
            title: '47th BCS General',
            circularUrl: 'https://bpsc.gov.bd/notices/47',
          ),
        ],
        clock: () => fixedNow,
      );
      Circular? result;

      await openDialog(
        tester,
        repo,
        themeMode: ThemeMode.light,
        initialUrl: 'https://BPSC.GOV.BD/notices/47/',
        onResult: (saved) => result = saved,
      );

      expect(
        find.byKey(const ValueKey('circular-form-duplicate-warning')),
        findsOneWidget,
      );
      expect(
        find.text(
          'Warning: "47th BCS General" already uses this circular link.',
        ),
        findsOneWidget,
      );

      // Edit link, add optional title, submit via keyboard Done action
      await tester.enterText(
        find.byKey(const ValueKey('quick-capture-link-field')),
        'https://bb.org.bd/jobs/ad',
      );
      await tester.enterText(
        find.byKey(const ValueKey('quick-capture-title-field')),
        'Bangladesh Bank AD',
      );
      await tester.pumpAndSettle();

      expect(
        find.byKey(const ValueKey('circular-form-duplicate-warning')),
        findsNothing,
      );

      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pumpAndSettle();

      expect(result, isNotNull);
      expect(result!.title, equals('Bangladesh Bank AD'));
      expect(result!.workflowStatus, equals(CircularWorkflowStatus.inbox));
      expect(result!.isQuickCapture, isTrue);
    });

    testWidgets('shows repository failure banner and loading state cleanly',
        (tester) async {
      final repo = FakeCircularRepository(clock: () => fixedNow);

      await openDialog(tester, repo);

      repo.nextError = const CircularNetworkFailure();
      await tester.enterText(
        find.byKey(const ValueKey('quick-capture-link-field')),
        'https://example.com/circular',
      );
      await tester.tap(find.byKey(const ValueKey('quick-capture-save-btn')));
      await tester.pumpAndSettle();

      expect(
        find.byKey(const ValueKey('quick-capture-error-banner')),
        findsOneWidget,
      );
      expect(
        find.byKey(const ValueKey('quick-capture-dialog')),
        findsOneWidget,
      );

      // Allow closing via Cancel
      await tester.tap(find.byKey(const ValueKey('quick-capture-cancel-btn')));
      await tester.pumpAndSettle();
      expect(find.byKey(const ValueKey('quick-capture-dialog')), findsNothing);
    });

    testWidgets('supports deadline picker and Bangla localization',
        (tester) async {
      final repo = FakeCircularRepository(clock: () => fixedNow);
      Circular? result;

      await openDialog(
        tester,
        repo,
        languageCode: 'bn',
        onResult: (saved) => result = saved,
      );

      expect(find.text('দ্রুত সংরক্ষণ'), findsOneWidget);
      expect(find.text('সার্কুলারের লিংক'), findsOneWidget);

      await tester.enterText(
        find.byKey(const ValueKey('quick-capture-link-field')),
        'https://ntrca.gov.bd/notice',
      );
      await tester
          .tap(find.byKey(const ValueKey('quick-capture-deadline-btn')));
      await tester.pumpAndSettle();

      // Pick default date in Material date picker (OK)
      await tester.tap(find.byType(TextButton).last);
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const ValueKey('quick-capture-save-btn')));
      await tester.pumpAndSettle();

      expect(result, isNotNull);
      expect(result!.deadline, isNotNull);
      expect(result!.workflowStatus, equals(CircularWorkflowStatus.inbox));
    });
  });
}
