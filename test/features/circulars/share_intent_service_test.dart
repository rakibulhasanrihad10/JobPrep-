import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:job_prep/core/localization/locale_controller.dart';
import 'package:job_prep/core/storage/preferences_provider.dart';
import 'package:job_prep/core/theme/app_theme.dart';
import 'package:job_prep/core/theme/reduce_effects_controller.dart';
import 'package:job_prep/features/circulars/data/services/share_intent_service.dart';
import 'package:job_prep/features/circulars/presentation/providers/circulars_providers.dart';
import 'package:job_prep/features/circulars/presentation/widgets/quick_capture_dialog.dart';
import 'package:job_prep/features/circulars/presentation/widgets/quick_capture_shell.dart';
import 'package:job_prep/l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'fake_circular_repository.dart';

/// Test double implementing [ShareIntentService] for deterministic unit and
/// widget tests without invoking native platform channels.
class FakeShareIntentService implements ShareIntentService {
  FakeShareIntentService({
    this.initialLink,
  });

  final String? initialLink;
  final StreamController<String> _controller =
      StreamController<String>.broadcast();
  bool wasReset = false;

  @override
  Stream<String> get sharedLinksStream => _controller.stream;

  @override
  Future<String?> getInitialSharedLink() async => initialLink;

  @override
  Future<void> reset() async {
    wasReset = true;
  }

  void emitSharedLink(String url) {
    _controller.add(url);
  }

  void dispose() {
    unawaited(_controller.close());
  }
}

void main() {
  setUpAll(() async {
    await initializeDateFormatting('en');
    await initializeDateFormatting('bn');
  });

  group('ShareIntentService & PendingShareCaptureNotifier', () {
    test('captures cold launch initial share link and resets on consume',
        () async {
      final fake = FakeShareIntentService(
        initialLink: 'https://bpsc.gov.bd/notices/47',
      );

      final container = ProviderContainer(
        overrides: [
          shareIntentServiceProvider.overrideWithValue(fake),
        ],
      );
      addTearDown(container.dispose);
      addTearDown(fake.dispose);

      // Trigger build and wait for initial check
      container.read(pendingShareCaptureProvider);
      await Future<void>.delayed(const Duration(milliseconds: 20));

      expect(
        container.read(pendingShareCaptureProvider),
        equals('https://bpsc.gov.bd/notices/47'),
      );

      // Consume resets pending state and calls native reset
      final consumed =
          container.read(pendingShareCaptureProvider.notifier).consume();
      expect(consumed, equals('https://bpsc.gov.bd/notices/47'));
      expect(container.read(pendingShareCaptureProvider), isNull);
      expect(fake.wasReset, isTrue);
    });

    test('listens to incoming stream while active and updates pending state',
        () async {
      final fake = FakeShareIntentService();

      final container = ProviderContainer(
        overrides: [
          shareIntentServiceProvider.overrideWithValue(fake),
        ],
      );
      addTearDown(container.dispose);
      addTearDown(fake.dispose);

      container.read(pendingShareCaptureProvider);
      expect(container.read(pendingShareCaptureProvider), isNull);

      // Emit new shared link from social/facebook
      fake.emitSharedLink('https://facebook.com/bpsc/posts/98765');
      await Future<void>.delayed(const Duration(milliseconds: 20));

      expect(
        container.read(pendingShareCaptureProvider),
        equals('https://facebook.com/bpsc/posts/98765'),
      );
    });
  });

  group('QuickCaptureShell Share-to-Capture Integration', () {
    testWidgets('opens QuickCaptureDialog prefilled when share arrives',
        (tester) async {
      tester.view.physicalSize = const Size(1280, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      SharedPreferences.setMockInitialValues({
        kReduceEffectsStorageKey: true,
        kLocaleStorageKey: 'en',
      });
      final prefs = await SharedPreferences.getInstance();

      final fakeShare = FakeShareIntentService();
      addTearDown(fakeShare.dispose);

      final circularRepo = FakeCircularRepository();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            sharedPreferencesProvider.overrideWithValue(prefs),
            circularRepositoryProvider.overrideWithValue(circularRepo),
            shareIntentServiceProvider.overrideWithValue(fakeShare),
            circularNowProvider.overrideWithValue(() => DateTime.utc(2026, 11)),
          ],
          child: MaterialApp(
            theme: AppTheme.dark(),
            locale: const Locale('en'),
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: QuickCaptureShell(
              currentUri: Uri.parse('/today'),
              child: const Scaffold(body: Text('Today Body')),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Today Body'), findsOneWidget);
      expect(find.byType(QuickCaptureDialog), findsNothing);

      // Simulate incoming share intent from Facebook
      fakeShare.emitSharedLink('https://bpsc.gov.bd/circulars/47th-bcs');
      await tester.pump();
      await tester.pumpAndSettle();

      // Quick Capture dialog opens prefilled with the shared link
      expect(find.byType(QuickCaptureDialog), findsOneWidget);
      expect(
        find.text('https://bpsc.gov.bd/circulars/47th-bcs'),
        findsOneWidget,
      );
    });
  });

  group('Android Manifest & Play Store Material Verification', () {
    test('AndroidManifest.xml registers singleTask and SEND intent filter', () {
      final manifest = File('android/app/src/main/AndroidManifest.xml');
      expect(manifest.existsSync(), isTrue);

      final content = manifest.readAsStringSync();
      expect(content, contains('android:launchMode="singleTask"'));
      expect(content, contains('android.intent.action.SEND'));
      expect(content, contains('android:mimeType="text/plain"'));
      expect(content, contains('android:mimeType="text/*"'));
    });

    test('Google Play Store listing material and release checklist exist', () {
      final listing = File('docs/play_store/LISTING.md');
      final checklist = File('docs/play_store/RELEASE_CHECKLIST.md');
      expect(listing.existsSync(), isTrue);
      expect(checklist.existsSync(), isTrue);

      final listingContent = listing.readAsStringSync();
      expect(listingContent, contains('JobPrep - Job & Exam Tracker'));
      expect(listingContent, contains('জবপ্রেপ - চাকরির প্রস্তুতি'));
      expect(listingContent, contains('https://jobprep.app/privacy'));
      expect(listingContent, contains('Google Play Data Safety Form Answers'));
      expect(listingContent, contains('IARC Questionnaire'));

      final checklistContent = checklist.readAsStringSync();
      expect(checklistContent, contains('Stage 1: Internal Testing Track'));
      expect(
        checklistContent,
        contains(
          'Stage 2: Closed Testing (Google Play 20-Tester / 14-Day Gate)',
        ),
      );
      expect(checklistContent, contains('Stage 3: Production Release'));
    });

    test('ci.yml defines play_store_internal upload job', () {
      final ci = File('.github/workflows/ci.yml');
      expect(ci.existsSync(), isTrue);

      final content = ci.readAsStringSync();
      expect(content, contains('play_store_internal:'));
      expect(content, contains('r0adkll/upload-google-play@v1'));
      expect(content, contains('track: internal'));
      expect(content, contains('PLAY_STORE_SERVICE_ACCOUNT_JSON'));
    });
  });
}
