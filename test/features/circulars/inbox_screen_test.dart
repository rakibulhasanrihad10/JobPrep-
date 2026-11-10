import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:job_prep/core/localization/locale_controller.dart';
import 'package:job_prep/core/theme/app_theme.dart';
import 'package:job_prep/core/theme/reduce_effects_controller.dart';
import 'package:job_prep/core/theme/theme_controller.dart';
import 'package:job_prep/features/circulars/domain/entities/circular.dart';
import 'package:job_prep/features/circulars/domain/entities/circular_enums.dart';
import 'package:job_prep/features/circulars/domain/entities/circular_filter.dart';
import 'package:job_prep/features/circulars/domain/errors/circular_failure.dart';
import 'package:job_prep/features/circulars/domain/repositories/circular_repository.dart';
import 'package:job_prep/features/circulars/presentation/providers/circulars_providers.dart';
import 'package:job_prep/features/circulars/presentation/screens/inbox_screen.dart';
import 'package:job_prep/l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'fake_circular_repository.dart';

class _LoadingCircularRepository implements CircularRepository {
  _LoadingCircularRepository(this.completer);

  final Completer<List<Circular>> completer;

  @override
  Future<List<Circular>> getCirculars({CircularFilter? filter}) =>
      completer.future;

  @override
  Future<Circular?> getCircularById(String id) async => null;

  @override
  Future<Circular> createCircular(Circular circular) =>
      throw UnimplementedError();

  @override
  Future<Circular> updateCircular(Circular circular) =>
      throw UnimplementedError();

  @override
  Future<void> deleteCircular(String id) => throw UnimplementedError();
}

void main() {
  final fixedNow = DateTime.utc(2026, 11, 10, 12);
  late SharedPreferences prefs;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    prefs = await SharedPreferences.getInstance();
  });

  Future<void> pumpInboxScreen(
    WidgetTester tester,
    CircularRepository repo, {
    String languageCode = 'en',
    ThemeMode themeMode = ThemeMode.dark,
    ValueChanged<Circular>? onCompleteDetails,
  }) async {
    tester.view.physicalSize = const Size(1100, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await prefs.setBool(kReduceEffectsStorageKey, true);
    await prefs.setString(kLocaleStorageKey, languageCode);

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
            body: InboxScreen(
              onCompleteDetails: onCompleteDetails,
            ),
          ),
        ),
      ),
    );
  }

  group('InboxScreen States & Actions', () {
    testWidgets('shows loading, error retry, and empty state cleanly',
        (tester) async {
      final completer = Completer<List<Circular>>();
      await pumpInboxScreen(tester, _LoadingCircularRepository(completer));
      await tester.pump();

      expect(
        find.byKey(const ValueKey('circulars-loading-state')),
        findsOneWidget,
      );

      final repo = FakeCircularRepository(clock: () => fixedNow)
        ..nextError = const CircularNetworkFailure();
      await pumpInboxScreen(tester, repo);
      await tester.pumpAndSettle();

      expect(
        find.byKey(const ValueKey('circulars-error-state')),
        findsOneWidget,
      );

      await tester.tap(find.byKey(const ValueKey('circulars-retry-btn')));
      await tester.pumpAndSettle();

      expect(find.byKey(const ValueKey('inbox-empty-state')), findsOneWidget);
      expect(find.text('Your Inbox is clear'), findsOneWidget);
    });

    testWidgets(
        'renders quick-captured items and handles Complete, Skip, and Delete',
        (tester) async {
      final repo = FakeCircularRepository(
        initialItems: [
          Circular(
            id: 'in-1',
            userId: 'u-1',
            title: 'bpsc.gov.bd',
            circularUrl: 'https://bpsc.gov.bd/notices/47',
            deadline: DateTime.utc(2026, 11, 20, 17),
            workflowStatus: CircularWorkflowStatus.inbox,
            isQuickCapture: true,
            createdAt: DateTime.utc(2026, 11, 10, 9),
          ),
          Circular(
            id: 'in-2',
            userId: 'u-1',
            title: 'Bangladesh Bank AD',
            circularUrl: 'https://bb.org.bd/jobs/ad',
            workflowStatus: CircularWorkflowStatus.inbox,
            isQuickCapture: true,
            createdAt: DateTime.utc(2026, 11, 10, 11),
          ),
          const Circular(
            id: 'saved-1',
            userId: 'u-1',
            title: 'Completed Circular Not Shown In Inbox',
          ),
        ],
        clock: () => fixedNow,
      );

      Circular? completedTarget;
      await pumpInboxScreen(
        tester,
        repo,
        onCompleteDetails: (c) => completedTarget = c,
      );
      await tester.pumpAndSettle();

      expect(find.byKey(const ValueKey('inbox-item-in-1')), findsOneWidget);
      expect(find.byKey(const ValueKey('inbox-item-in-2')), findsOneWidget);
      expect(find.text('Completed Circular Not Shown In Inbox'), findsNothing);
      expect(find.text('2 quick-captured items waiting'), findsOneWidget);

      // Complete details invokes callback cleanly
      await tester.tap(find.byKey(const ValueKey('inbox-complete-btn-in-1')));
      await tester.pumpAndSettle();
      expect(completedTarget?.id, equals('in-1'));

      // Skip moves in-2 to archived and removes it from Inbox
      await tester.tap(find.byKey(const ValueKey('inbox-skip-btn-in-2')));
      await tester.pumpAndSettle();
      expect(find.byKey(const ValueKey('inbox-item-in-2')), findsNothing);
      expect(
        repo.items.firstWhere((c) => c.id == 'in-2').workflowStatus,
        equals(CircularWorkflowStatus.archived),
      );
      expect(find.text('1 quick-captured item waiting'), findsOneWidget);

      // Delete removes in-1 permanently
      await tester.tap(find.byKey(const ValueKey('inbox-delete-btn-in-1')));
      await tester.pumpAndSettle();
      expect(repo.deletedIds, equals(['in-1']));
      expect(find.byKey(const ValueKey('inbox-empty-state')), findsOneWidget);
    });

    testWidgets('renders Bangla Inbox labels and numerals', (tester) async {
      final repo = FakeCircularRepository(
        initialItems: [
          Circular(
            id: 'in-bn',
            userId: 'u-1',
            title: 'bb.org.bd',
            circularUrl: 'https://bb.org.bd/career',
            workflowStatus: CircularWorkflowStatus.inbox,
            isQuickCapture: true,
            createdAt: DateTime.utc(2026, 11, 10, 10),
          ),
        ],
        clock: () => fixedNow,
      );

      await pumpInboxScreen(tester, repo, languageCode: 'bn');
      await tester.pumpAndSettle();

      expect(find.text('ইনবক্স'), findsOneWidget);
      expect(find.text('১টি দ্রুত-সংরক্ষিত আইটেম অপেক্ষমাণ'), findsOneWidget);
      expect(find.text('বিস্তারিত পূরণ করুন'), findsOneWidget);
      expect(find.text('এড়িয়ে যান'), findsOneWidget);
      expect(find.text('মুছে ফেলুন'), findsOneWidget);
    });
  });
}
