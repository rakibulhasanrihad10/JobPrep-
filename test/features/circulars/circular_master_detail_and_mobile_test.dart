import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:job_prep/core/localization/locale_controller.dart';
import 'package:job_prep/core/theme/reduce_effects_controller.dart';
import 'package:job_prep/core/theme/theme_controller.dart';
import 'package:job_prep/features/auth/domain/entities/auth_session_state.dart';
import 'package:job_prep/features/auth/presentation/providers/auth_providers.dart';
import 'package:job_prep/features/circulars/domain/entities/circular.dart';
import 'package:job_prep/features/circulars/domain/entities/circular_enums.dart';
import 'package:job_prep/features/circulars/presentation/providers/circulars_providers.dart';
import 'package:job_prep/features/circulars/presentation/providers/exam_date_providers.dart';
import 'package:job_prep/main.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../auth/fake_auth_repository.dart';
import 'fake_circular_repository.dart';
import 'fake_exam_date_repository.dart';

void main() {
  final fixedNow = DateTime.utc(2026, 11, 10, 12);

  Future<void> pumpAppWithSize(
    WidgetTester tester, {
    required Size size,
    required FakeCircularRepository circularRepo,
    required FakeExamDateRepository examRepo,
  }) async {
    tester.view.physicalSize = size;
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

    final authRepo = FakeAuthRepository(
      initialSession: const AuthSessionState.signedIn(
        FakeAuthRepository.defaultTestUser,
      ),
    );
    addTearDown(authRepo.dispose);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
          authRepositoryProvider.overrideWithValue(authRepo),
          circularRepositoryProvider.overrideWithValue(circularRepo),
          examDateRepositoryProvider.overrideWithValue(examRepo),
          circularNowProvider.overrideWithValue(() => fixedNow),
        ],
        child: const JobPrepApp(),
      ),
    );
    await tester.pumpAndSettle();
  }

  List<Circular> sampleItems() => const [
        Circular(
          id: 'c-1',
          userId: 'user-1',
          title: '47th BCS General Cadre',
          sector: CircularSector.bcs,
          organizationName: 'BPSC',
        ),
        Circular(
          id: 'c-2',
          userId: 'user-1',
          title: 'Bangladesh Bank AD',
          sector: CircularSector.bank,
          organizationName: 'Bangladesh Bank',
        ),
      ];

  group('Circular Detail Responsive Master-Detail & Mobile Full-Screen', () {
    testWidgets(
        'desktop shows detail in right master-detail pane next to list and '
        'closes cleanly', (tester) async {
      final circularRepo = FakeCircularRepository(
        initialItems: sampleItems(),
        clock: () => fixedNow,
      );
      final examRepo = FakeExamDateRepository(clock: () => fixedNow);

      await pumpAppWithSize(
        tester,
        size: const Size(1400, 960),
        circularRepo: circularRepo,
        examRepo: examRepo,
      );

      // Go to Circulars
      await tester.tap(find.text('Circulars'));
      await tester.pumpAndSettle();
      expect(
        find.byKey(const ValueKey('circulars-desktop-table')),
        findsOneWidget,
      );

      // Tap first circular -> right master-detail pane opens next to card list
      await tester.tap(find.byKey(const ValueKey('circular-row-c-1')));
      await tester.pumpAndSettle();

      expect(
        find.byKey(const ValueKey('circulars-master-detail-layout')),
        findsOneWidget,
      );
      expect(
        find.byKey(const ValueKey('circular-detail-pane-c-1')),
        findsOneWidget,
      );
      expect(find.byKey(const ValueKey('circular-card-c-2')), findsOneWidget);

      // Switch selection in left list to c-2
      await tester.tap(find.byKey(const ValueKey('circular-card-c-2')));
      await tester.pumpAndSettle();
      expect(
        find.byKey(const ValueKey('circular-detail-pane-c-2')),
        findsOneWidget,
      );

      // Delete confirmation on c-2 removes item and closes pane
      await tester
          .tap(find.byKey(const ValueKey('circular-detail-delete-btn')));
      await tester.pumpAndSettle();
      expect(
        find.byKey(const ValueKey('circular-delete-dialog')),
        findsOneWidget,
      );
      await tester.tap(
        find.byKey(const ValueKey('circular-delete-confirm-btn')),
      );
      await tester.pumpAndSettle();

      expect(circularRepo.deletedIds, equals(['c-2']));
      expect(
        find.byKey(const ValueKey('circulars-desktop-table')),
        findsOneWidget,
      );
    });

    testWidgets(
        'mobile opens full-screen CircularDetailScreen with back navigation',
        (tester) async {
      final circularRepo = FakeCircularRepository(
        initialItems: sampleItems(),
        clock: () => fixedNow,
      );
      final examRepo = FakeExamDateRepository(clock: () => fixedNow);

      await pumpAppWithSize(
        tester,
        size: const Size(400, 844),
        circularRepo: circularRepo,
        examRepo: examRepo,
      );

      await tester.tap(find.text('Circulars'));
      await tester.pumpAndSettle();
      expect(
        find.byKey(const ValueKey('circulars-mobile-list')),
        findsOneWidget,
      );

      // Tap card -> opens full-screen detail (no master-detail split)
      await tester.tap(find.byKey(const ValueKey('circular-card-c-1')));
      await tester.pumpAndSettle();

      expect(
        find.byKey(const ValueKey('circular-detail-fullscreen-scroll')),
        findsOneWidget,
      );
      expect(
        find.byKey(const ValueKey('circulars-master-detail-layout')),
        findsNothing,
      );

      // Back button returns to mobile list
      await tester.tap(find.byKey(const ValueKey('circular-detail-back-btn')));
      await tester.pumpAndSettle();
      expect(
        find.byKey(const ValueKey('circulars-mobile-list')),
        findsOneWidget,
      );
    });
  });
}
