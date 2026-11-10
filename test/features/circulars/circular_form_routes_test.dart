import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
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

  testWidgets('navigates between circulars list, add form, and edit form',
      (tester) async {
    tester.view.physicalSize = const Size(1400, 1000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    SharedPreferences.setMockInitialValues({
      kReduceEffectsStorageKey: true,
    });
    final prefs = await SharedPreferences.getInstance();

    final authRepo = FakeAuthRepository(
      initialSession: const AuthSessionState.signedIn(
        FakeAuthRepository.defaultTestUser,
      ),
    );
    addTearDown(authRepo.dispose);

    final circularRepo = FakeCircularRepository(
      initialItems: const [
        Circular(
          id: 'c-1',
          userId: 'user-1',
          title: 'Initial BCS Circular',
          sector: CircularSector.bcs,
        ),
      ],
      clock: () => fixedNow,
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
          authRepositoryProvider.overrideWithValue(authRepo),
          circularRepositoryProvider.overrideWithValue(circularRepo),
          circularNowProvider.overrideWithValue(() => fixedNow),
        ],
        child: const JobPrepApp(),
      ),
    );
    await tester.pumpAndSettle();

    // Navigate to Circulars via desktop sidebar
    await tester.tap(find.text('Circulars').first);
    await tester.pumpAndSettle();
    expect(find.text('Initial BCS Circular'), findsOneWidget);

    // Tap Add circular -> /circulars/new
    await tester.tap(find.byKey(const ValueKey('circulars-add-btn')));
    await tester.pumpAndSettle();
    expect(find.text('Add Job Circular'), findsOneWidget);

    await tester.enterText(
      find.byKey(const ValueKey('circular-form-title')),
      'Newly Routed Circular',
    );
    final submitBtn = find.byKey(const ValueKey('circular-form-submit-btn'));
    await tester.ensureVisible(submitBtn);
    await tester.tap(submitBtn);
    await tester.pumpAndSettle();

    // Returns to circulars list showing created item
    expect(find.text('Newly Routed Circular'), findsOneWidget);

    // Tap existing row -> opens master-detail view /circulars/c-1,
    // then tapping Edit navigates to /circulars/c-1/edit
    await tester.tap(find.byKey(const ValueKey('circular-row-c-1')));
    await tester.pumpAndSettle();
    expect(
      find.byKey(const ValueKey('circular-detail-pane-c-1')),
      findsOneWidget,
    );

    await tester.tap(find.byKey(const ValueKey('circular-detail-edit-btn')));
    await tester.pumpAndSettle();
    expect(find.text('Edit Job Circular'), findsOneWidget);
    expect(find.text('Initial BCS Circular'), findsOneWidget);
  });
}
