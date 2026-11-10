import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:job_prep/core/localization/locale_controller.dart';
import 'package:job_prep/core/router/app_router.dart';
import 'package:job_prep/core/theme/reduce_effects_controller.dart';
import 'package:job_prep/core/theme/theme_controller.dart';
import 'package:job_prep/features/auth/domain/entities/auth_session_state.dart';
import 'package:job_prep/features/auth/presentation/providers/auth_providers.dart';
import 'package:job_prep/features/circulars/domain/entities/circular.dart';
import 'package:job_prep/features/circulars/domain/entities/circular_enums.dart';
import 'package:job_prep/features/circulars/presentation/providers/circulars_providers.dart';
import 'package:job_prep/main.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../auth/fake_auth_repository.dart';
import 'fake_circular_repository.dart';

void main() {
  final fixedNow = DateTime.utc(2026, 11, 10, 12);

  Future<FakeAuthRepository> pumpFullApp(
    WidgetTester tester, {
    required FakeCircularRepository circularRepo,
    AuthSessionState initialSession = const AuthSessionState.signedIn(
      FakeAuthRepository.defaultTestUser,
    ),
    String? initialRoute,
    Size viewport = const Size(1400, 950),
  }) async {
    tester.view.physicalSize = viewport;
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

    final authRepo = FakeAuthRepository(initialSession: initialSession);
    addTearDown(authRepo.dispose);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
          authRepositoryProvider.overrideWithValue(authRepo),
          circularRepositoryProvider.overrideWithValue(circularRepo),
          circularNowProvider.overrideWithValue(() => fixedNow),
          if (initialRoute != null)
            initialRouteLocationProvider.overrideWithValue(initialRoute),
        ],
        child: const JobPrepApp(),
      ),
    );
    await tester.pumpAndSettle();
    return authRepo;
  }

  group('Phase 3E - End-to-End Quick Capture & Inbox Shell Flows', () {
    testWidgets(
        'shows inbox count badge in navigation, opens Quick capture via button '
        'and Alt+Q shortcut across screens, and completes details into saved',
        (tester) async {
      final circularRepo = FakeCircularRepository(
        initialItems: [
          Circular(
            id: 'in-init',
            userId: 'user-1',
            title: 'bpsc.gov.bd',
            circularUrl: 'https://bpsc.gov.bd/47',
            workflowStatus: CircularWorkflowStatus.inbox,
            isQuickCapture: true,
            createdAt: DateTime.utc(2026, 11, 10, 10),
          ),
        ],
        clock: () => fixedNow,
      );

      await pumpFullApp(tester, circularRepo: circularRepo);

      // Navigation shows live inbox badge count "1"
      expect(
        find.descendant(
          of: find.byKey(const ValueKey('nav-inbox-count-badge')),
          matching: find.text('1'),
        ),
        findsOneWidget,
      );

      // Navigate to Settings -> Quick capture button is still reachable
      await tester.tap(find.text('Settings'));
      await tester.pumpAndSettle();
      expect(
        find.byKey(const ValueKey('shell-quick-capture-btn')),
        findsOneWidget,
      );

      // Trigger Quick capture via web keyboard shortcut (Alt+Q)
      await tester.sendKeyDownEvent(LogicalKeyboardKey.altLeft);
      await tester.sendKeyEvent(LogicalKeyboardKey.keyQ);
      await tester.sendKeyUpEvent(LogicalKeyboardKey.altLeft);
      await tester.pumpAndSettle();

      expect(
        find.byKey(const ValueKey('quick-capture-dialog')),
        findsOneWidget,
      );

      // Save with only a link
      await tester.enterText(
        find.byKey(const ValueKey('quick-capture-link-field')),
        'https://bb.org.bd/career/ad',
      );
      await tester.tap(find.byKey(const ValueKey('quick-capture-save-btn')));
      await tester.pumpAndSettle();

      // Badge updates to "2"
      expect(
        find.descendant(
          of: find.byKey(const ValueKey('nav-inbox-count-badge')),
          matching: find.text('2'),
        ),
        findsOneWidget,
      );

      // Open Inbox tab -> shows both quick-captured items
      await tester.tap(find.text('Inbox'));
      await tester.pumpAndSettle();
      expect(find.byKey(const ValueKey('inbox-item-in-init')), findsOneWidget);
      expect(find.text('bb.org.bd'), findsOneWidget);

      // Complete details on in-init opens Phase 3D form & promotes inbox->saved
      await tester
          .tap(find.byKey(const ValueKey('inbox-complete-btn-in-init')));
      await tester.pumpAndSettle();
      expect(find.text('Edit Job Circular'), findsOneWidget);

      await tester.enterText(
        find.byKey(const ValueKey('circular-form-title')),
        '47th BCS General Cadre',
      );
      final submitBtn = find.byKey(const ValueKey('circular-form-submit-btn'));
      await tester.ensureVisible(submitBtn);
      await tester.tap(submitBtn);
      await tester.pumpAndSettle();

      // Returns back to Inbox, in-init left Inbox, count badge drops back to 1
      expect(find.byKey(const ValueKey('inbox-item-in-init')), findsNothing);
      expect(
        find.descendant(
          of: find.byKey(const ValueKey('nav-inbox-count-badge')),
          matching: find.text('1'),
        ),
        findsOneWidget,
      );
      expect(
        circularRepo.items.firstWhere((c) => c.id == 'in-init').workflowStatus,
        equals(CircularWorkflowStatus.saved),
      );
    });

    testWidgets(
        'reads ?capture= query param when signed in and checks duplicates',
        (tester) async {
      final circularRepo = FakeCircularRepository(
        initialItems: const [
          Circular(
            id: 'dup-1',
            userId: 'user-1',
            title: 'Existing Notice',
            circularUrl: 'https://erecruitment.bb.org.bd/job/99',
          ),
        ],
        clock: () => fixedNow,
      );

      await pumpFullApp(
        tester,
        circularRepo: circularRepo,
        initialRoute:
            '/?capture=https%3A%2F%2Ferecruitment.bb.org.bd%2Fjob%2F99',
      );

      // Quick capture opens automatically with prefilled link & duplicate warn
      expect(
        find.byKey(const ValueKey('quick-capture-dialog')),
        findsOneWidget,
      );
      final field = tester.widget<TextFormField>(
        find.descendant(
          of: find.byKey(const ValueKey('quick-capture-link-field')),
          matching: find.byType(TextFormField),
        ),
      );
      expect(
        field.controller?.text,
        equals('https://erecruitment.bb.org.bd/job/99'),
      );
      expect(
        find.byKey(const ValueKey('circular-form-duplicate-warning')),
        findsOneWidget,
      );

      // Save in 1 tap -> closes dialog & creates inbox item
      await tester.tap(find.byKey(const ValueKey('quick-capture-save-btn')));
      await tester.pumpAndSettle();

      expect(find.byKey(const ValueKey('quick-capture-dialog')), findsNothing);
      expect(
        circularRepo.createdItems.single.workflowStatus,
        equals(CircularWorkflowStatus.inbox),
      );
      expect(circularRepo.createdItems.single.isQuickCapture, isTrue);
    });

    testWidgets(
        'preserves ?capture= across sign-in redirect and opens Quick capture',
        (tester) async {
      final circularRepo = FakeCircularRepository(clock: () => fixedNow);

      final authRepo = await pumpFullApp(
        tester,
        circularRepo: circularRepo,
        initialSession: const AuthSessionState.signedOut(),
        initialRoute: '/?capture=https%3A%2F%2Fntrca.gov.bd%2Fcircular-18',
      );

      // Redirected to Login screen while preserving ?capture=
      expect(find.byKey(const ValueKey('quick-capture-dialog')), findsNothing);

      // User completes authentication
      authRepo.emitSession(
        const AuthSessionState.signedIn(FakeAuthRepository.defaultTestUser),
      );
      await tester.pumpAndSettle();

      // Quick capture automatically pops up prefilled with captured link
      expect(
        find.byKey(const ValueKey('quick-capture-dialog')),
        findsOneWidget,
      );
      final field = tester.widget<TextFormField>(
        find.descendant(
          of: find.byKey(const ValueKey('quick-capture-link-field')),
          matching: find.byType(TextFormField),
        ),
      );
      expect(
        field.controller?.text,
        equals('https://ntrca.gov.bd/circular-18'),
      );
    });

    testWidgets('shows Quick capture button and Inbox badge on mobile viewport',
        (tester) async {
      final circularRepo = FakeCircularRepository(
        initialItems: const [
          Circular(
            id: 'in-mob',
            userId: 'user-1',
            title: 'bb.org.bd',
            circularUrl: 'https://bb.org.bd/career',
            workflowStatus: CircularWorkflowStatus.inbox,
            isQuickCapture: true,
          ),
        ],
        clock: () => fixedNow,
      );

      await pumpFullApp(
        tester,
        circularRepo: circularRepo,
        viewport: const Size(400, 820),
      );

      expect(
        find.byKey(const ValueKey('shell-quick-capture-btn')),
        findsOneWidget,
      );
      expect(
        find.descendant(
          of: find.byKey(const ValueKey('nav-inbox-count-badge')),
          matching: find.text('1'),
        ),
        findsOneWidget,
      );

      await tester.tap(find.byKey(const ValueKey('shell-quick-capture-btn')));
      await tester.pumpAndSettle();
      expect(
        find.byKey(const ValueKey('quick-capture-dialog')),
        findsOneWidget,
      );
    });
  });
}
