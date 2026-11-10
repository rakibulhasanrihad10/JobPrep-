import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:job_prep/core/localization/locale_controller.dart';
import 'package:job_prep/core/router/app_router.dart';
import 'package:job_prep/core/theme/app_theme.dart';
import 'package:job_prep/core/theme/reduce_effects_controller.dart';
import 'package:job_prep/core/theme/theme_controller.dart';
import 'package:job_prep/features/auth/domain/entities/auth_user.dart';
import 'package:job_prep/features/auth/presentation/providers/auth_providers.dart';
import 'package:job_prep/features/circulars/presentation/providers/circulars_providers.dart';
import 'package:job_prep/features/prep/domain/entities/prep_material.dart';
import 'package:job_prep/features/prep/domain/entities/subject.dart';
import 'package:job_prep/features/prep/presentation/providers/prep_cover_providers.dart';
import 'package:job_prep/features/prep/presentation/providers/prep_providers.dart';
import 'package:job_prep/l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../auth/fake_auth_repository.dart';
import '../circulars/fake_circular_repository.dart';
import 'fake_material_and_log_repositories.dart';
import 'fake_material_cover_repository.dart';
import 'fake_subject_and_topic_repositories.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('replays progress rings and bars from zero on tab switches',
      (tester) async {
    tester.view.physicalSize = const Size(1280, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    SharedPreferences.setMockInitialValues({
      kReduceEffectsStorageKey: false,
      kLocaleStorageKey: 'en',
    });
    final prefs = await SharedPreferences.getInstance();

    final fakeAuth = FakeAuthRepository.authenticated(
      const AuthUser(id: 'u-1', email: 'u@example.test'),
    );
    addTearDown(fakeAuth.dispose);

    final subjectRepo = FakeSubjectRepository(
      initialSubjects: const [
        Subject(id: 'sub-1', userId: 'u-1', name: 'Bengali'),
      ],
    );
    final materialRepo = FakeMaterialRepository(
      initialMaterials: const [
        PrepMaterial(
          id: 'm1',
          userId: 'u-1',
          subjectId: 'sub-1',
          title: 'Book One',
          totalUnits: 100,
          completedUnits: 60,
        ),
      ],
    );
    final logRepo = FakeProgressLogRepository(
      materialRepository: materialRepo,
    );

    final container = ProviderContainer(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
        initialRouteLocationProvider.overrideWithValue('/prep'),
        authRepositoryProvider.overrideWithValue(fakeAuth),
        circularRepositoryProvider.overrideWithValue(FakeCircularRepository()),
        subjectRepositoryProvider.overrideWithValue(subjectRepo),
        materialRepositoryProvider.overrideWithValue(materialRepo),
        progressLogRepositoryProvider.overrideWithValue(logRepo),
        materialCoverRepositoryProvider.overrideWithValue(
          FakeMaterialCoverRepository(),
        ),
      ],
    );
    addTearDown(container.dispose);

    final router = container.read(routerProvider);
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp.router(
          routerConfig: router,
          theme: AppTheme.light(),
          darkTheme: AppTheme.dark(),
          themeMode: ThemeMode.dark,
          locale: const Locale('en'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Navigate away to Dashboard then back to Prep tab
    router.go('/dashboard');
    await tester.pumpAndSettle();
    router.go('/prep');
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 16));

    final initialBox = tester.widget<FractionallySizedBox>(
      find
          .descendant(
            of: find.byKey(const ValueKey('material-card-m1')),
            matching: find.byType(FractionallySizedBox),
          )
          .first,
    );
    expect(initialBox.widthFactor ?? 0.0, lessThan(0.25));

    await tester.pumpAndSettle();
    final settledBox = tester.widget<FractionallySizedBox>(
      find
          .descendant(
            of: find.byKey(const ValueKey('material-card-m1')),
            matching: find.byType(FractionallySizedBox),
          )
          .first,
    );
    expect(settledBox.widthFactor, closeTo(0.60, 0.01));
  });
}
