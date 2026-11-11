import 'dart:async';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:job_prep/core/localization/locale_controller.dart';
import 'package:job_prep/core/storage/preferences_provider.dart';
import 'package:job_prep/core/theme/app_theme.dart';
import 'package:job_prep/core/theme/reduce_effects_controller.dart';
import 'package:job_prep/features/circulars/presentation/providers/circulars_providers.dart';
import 'package:job_prep/features/prep/domain/entities/mock_test.dart';
import 'package:job_prep/features/prep/domain/entities/prep_material.dart';
import 'package:job_prep/features/prep/domain/entities/progress_log.dart';
import 'package:job_prep/features/prep/domain/entities/study_plan.dart';
import 'package:job_prep/features/prep/domain/entities/subject.dart';
import 'package:job_prep/features/prep/domain/errors/prep_failure.dart';
import 'package:job_prep/features/prep/presentation/providers/mock_test_providers.dart';
import 'package:job_prep/features/prep/presentation/providers/prep_cover_providers.dart';
import 'package:job_prep/features/prep/presentation/providers/prep_progress_log_controller.dart';
import 'package:job_prep/features/prep/presentation/providers/prep_providers.dart';
import 'package:job_prep/features/prep/presentation/providers/prep_template_providers.dart';
import 'package:job_prep/features/prep/presentation/providers/study_plan_providers.dart';
import 'package:job_prep/features/prep/presentation/screens/prep_screen.dart';
import 'package:job_prep/features/prep/presentation/screens/study_analytics_screen.dart';
import 'package:job_prep/features/prep/presentation/widgets/study_analytics_tab_view.dart';
import 'package:job_prep/l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../circulars/fake_circular_repository.dart';
import 'fake_material_and_log_repositories.dart';
import 'fake_material_cover_repository.dart';
import 'fake_mock_test_repository.dart';
import 'fake_prep_template_repository.dart';
import 'fake_study_plan_repository.dart';
import 'fake_subject_and_topic_repositories.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final fixedNow = DateTime(2026, 11, 10, 14);

  setUpAll(() async {
    await initializeDateFormatting('en');
    await initializeDateFormatting('bn');
  });

  const subMath = Subject(
    id: 'sub-math',
    userId: 'u-1',
    name: 'Mathematics',
    icon: 'calculate',
  );
  const subEng = Subject(
    id: 'sub-eng',
    userId: 'u-1',
    name: 'English Grammar',
    color: 'info',
    icon: 'language',
    sortOrder: 1,
  );
  const matMath = PrepMaterial(
    id: 'mat-math',
    userId: 'u-1',
    subjectId: 'sub-math',
    title: 'Algebra Guide',
    totalUnits: 400,
    completedUnits: 100,
  );
  const matEng = PrepMaterial(
    id: 'mat-eng',
    userId: 'u-1',
    subjectId: 'sub-eng',
    title: 'Grammar Digest',
    totalUnits: 200,
    completedUnits: 60,
  );

  Future<Widget> buildHarness({
    required Widget child,
    List<ProgressLog> logs = const [],
    List<StudyPlan> plans = const [],
    List<MockTest> mocks = const [],
    FakeProgressLogRepository? customLogRepo,
    List<Override> extraOverrides = const [],
    Locale locale = const Locale('en'),
    ThemeMode themeMode = ThemeMode.dark,
    bool reduceEffects = true,
  }) async {
    SharedPreferences.setMockInitialValues({
      kLocaleStorageKey: locale.languageCode,
      kUseBanglaDigitsStorageKey: locale.languageCode == 'bn',
      kReduceEffectsStorageKey: reduceEffects,
    });
    final prefs = await SharedPreferences.getInstance();
    final materialRepo = FakeMaterialRepository(
      initialMaterials: const [matMath, matEng],
    );
    final logRepo = customLogRepo ??
        FakeProgressLogRepository(
          initialLogs: logs,
          materialRepository: materialRepo,
          clock: () => fixedNow,
        );

    return ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
        prepNowProvider.overrideWithValue(() => fixedNow),
        subjectRepositoryProvider.overrideWithValue(
          FakeSubjectRepository(initialSubjects: const [subMath, subEng]),
        ),
        materialRepositoryProvider.overrideWithValue(materialRepo),
        progressLogRepositoryProvider.overrideWithValue(logRepo),
        topicRepositoryProvider.overrideWithValue(FakeTopicRepository()),
        materialCoverRepositoryProvider.overrideWithValue(
          FakeMaterialCoverRepository(),
        ),
        prepTemplateRepositoryProvider.overrideWithValue(
          FakePrepTemplateRepository(),
        ),
        studyPlanRepositoryProvider.overrideWithValue(
          FakeStudyPlanRepository(initialPlans: plans, clock: () => fixedNow),
        ),
        circularRepositoryProvider.overrideWithValue(
          FakeCircularRepository(clock: () => fixedNow),
        ),
        mockTestRepositoryProvider.overrideWithValue(
          FakeMockTestRepository(initialTests: mocks, clock: () => fixedNow),
        ),
        ...extraOverrides,
      ],
      child: MaterialApp(
        theme: AppTheme.light(),
        darkTheme: AppTheme.dark(),
        themeMode: themeMode,
        locale: locale,
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        home: Scaffold(body: child),
      ),
    );
  }

  group('Phase 6E Study Analytics Widgets', () {
    testWidgets('shows loading, error retry recovery, and empty state CTA',
        (tester) async {
      tester.view.physicalSize = const Size(1200, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final loadingCompleter = Completer<List<ProgressLog>>();

      await tester.pumpWidget(
        await buildHarness(
          child: const PrepScreen(),
          extraOverrides: [
            analyticsProgressLogsProvider.overrideWith((ref) {
              if (!loadingCompleter.isCompleted) {
                return loadingCompleter.future;
              }
              return Future<List<ProgressLog>>.value(const []);
            }),
          ],
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const ValueKey('prep-tab-analytics')));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));

      expect(find.byKey(const ValueKey('analytics-loading')), findsOneWidget);

      loadingCompleter.completeError(
        const UnknownPrepFailure(message: 'Analytics offline'),
      );
      await tester.pumpAndSettle();
      expect(find.byKey(const ValueKey('analytics-error')), findsOneWidget);

      await tester.tap(find.byKey(const ValueKey('analytics-retry-button')));
      await tester.pumpAndSettle();

      expect(find.byKey(const ValueKey('analytics-empty')), findsOneWidget);

      await tester.tap(
        find.byKey(const ValueKey('analytics-empty-open-subjects')),
      );
      await tester.pumpAndSettle();
      expect(find.byKey(const ValueKey('analytics-empty')), findsNothing);
    });

    testWidgets(
        'renders 4 KPI cards, target banner, all fl_chart views, heatmap, '
        'date & subject filters, and replay on tab open', (tester) async {
      tester.view.physicalSize = const Size(1280, 1200);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final logs = [
        ProgressLog(
          id: 'l1',
          materialId: matMath.id,
          unitsDone: 30,
          loggedOn: DateTime(2026, 11, 7),
        ),
        ProgressLog(
          id: 'l2',
          materialId: matMath.id,
          unitsDone: 5,
          loggedOn: DateTime(2026, 11, 9), // yesterday < target
        ),
        ProgressLog(
          id: 'l3',
          materialId: matEng.id,
          unitsDone: 18,
          loggedOn: DateTime(2026, 11, 10), // today < combined target
        ),
      ];
      final plans = [
        StudyPlan(
          id: 'p1',
          userId: 'u-1',
          startDate: DateTime.utc(2026, 11),
          targetDate: DateTime.utc(2026, 11, 25), // 440 units / ~10d => ~44/day
        ),
      ];
      final mocks = [
        MockTest(
          id: 'm1',
          subjectId: subMath.id,
          title: 'Algebra Mock 1',
          takenOn: DateTime(2026, 11, 9),
          marksObtained: 80,
          totalMarks: 100,
        ),
      ];

      await tester.pumpWidget(
        await buildHarness(
          child: const PrepScreen(),
          logs: logs,
          plans: plans,
          mocks: mocks,
          reduceEffects: false,
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const ValueKey('prep-tab-analytics')));
      await tester.pumpAndSettle();

      expect(
        find.byKey(const ValueKey('analytics-below-target-banner')),
        findsOneWidget,
      );
      expect(
        find.byKey(const ValueKey('analytics-kpi-current-streak')),
        findsOneWidget,
      );
      expect(
        find.byKey(const ValueKey('analytics-kpi-longest-streak')),
        findsOneWidget,
      );
      expect(
        find.byKey(const ValueKey('analytics-kpi-units-week')),
        findsOneWidget,
      );
      expect(
        find.byKey(const ValueKey('analytics-kpi-consistency')),
        findsOneWidget,
      );
      expect(find.byType(BarChart), findsNWidgets(2));
      expect(find.byType(PieChart), findsOneWidget);
      expect(
        find.byKey(const ValueKey('analytics-heatmap-card')),
        findsOneWidget,
      );
      expect(
        find.byKey(const ValueKey('analytics-daily-target-badge')),
        findsOneWidget,
      );

      final barAnimated = tester.widget<BarChart>(find.byType(BarChart).first);
      expect(barAnimated.duration, greaterThan(Duration.zero));

      final firstDailyKey = tester
          .widget<TweenAnimationBuilder<double>>(
            find.byType(TweenAnimationBuilder<double>).first,
          )
          .key;

      // Switch date range 7 -> 30 -> 90
      await tester.tap(find.byKey(const ValueKey('analytics-range-days30')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('analytics-range-days90')));
      await tester.pumpAndSettle();

      // Switch Subject dropdown to Mathematics only
      final subjectDropdown =
          find.byKey(const ValueKey('analytics-subject-dropdown'));
      await tester.ensureVisible(subjectDropdown);
      await tester.tap(subjectDropdown);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Mathematics').last);
      await tester.pumpAndSettle();

      expect(find.text('English Grammar'), findsNothing);

      // Clear filter restores both subjects & 7-day range
      await tester.tap(
        find.byKey(const ValueKey('analytics-clear-filter-button')),
      );
      await tester.pumpAndSettle();
      expect(find.text('English Grammar'), findsWidgets);

      // Switching away and back to Analytics bumps replay keys from zero
      final subjectsTab = find.byKey(const ValueKey('prep-tab-subjects'));
      await tester.ensureVisible(subjectsTab);
      await tester.tap(subjectsTab);
      await tester.pumpAndSettle();
      final analyticsTab = find.byKey(const ValueKey('prep-tab-analytics'));
      await tester.ensureVisible(analyticsTab);
      await tester.tap(analyticsTab);
      await tester.pumpAndSettle();
      final secondDailyKey = tester
          .widget<TweenAnimationBuilder<double>>(
            find.byType(TweenAnimationBuilder<double>).first,
          )
          .key;
      expect(firstDailyKey, isNot(equals(secondDailyKey)));
    });

    testWidgets(
        'respects reduceEffects and renders cleanly on 360x800 Bangla mobile',
        (tester) async {
      tester.view.physicalSize = const Size(360, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final logs = [
        ProgressLog(
          id: 'b1',
          materialId: matMath.id,
          unitsDone: 25,
          loggedOn: DateTime(2026, 11, 9),
        ),
        ProgressLog(
          id: 'b2',
          materialId: matEng.id,
          unitsDone: 10,
          loggedOn: DateTime(2026, 11, 10),
        ),
      ];
      final plans = [
        StudyPlan(
          id: 'bp1',
          userId: 'u-1',
          startDate: DateTime.utc(2026, 11),
          targetDate: DateTime.utc(2026, 11, 25),
        ),
      ];

      await tester.pumpWidget(
        await buildHarness(
          child: const SingleChildScrollView(
            padding: EdgeInsets.all(16),
            child: StudyAnalyticsTabView(visitId: 1),
          ),
          logs: logs,
          plans: plans,
          locale: const Locale('bn'),
          themeMode: ThemeMode.light,
        ),
      );
      await tester.pumpAndSettle();

      final barZero = tester.widget<BarChart>(find.byType(BarChart).first);
      final pieZero = tester.widget<PieChart>(find.byType(PieChart));
      expect(barZero.duration, Duration.zero);
      expect(pieZero.duration, Duration.zero);
      expect(tester.takeException(), isNull);
    });

    testWidgets('StudyAnalyticsScreen renders standalone cleanly',
        (tester) async {
      tester.view.physicalSize = const Size(1200, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        await buildHarness(
          child: const StudyAnalyticsScreen(),
          logs: [
            ProgressLog(
              id: 's1',
              materialId: matMath.id,
              unitsDone: 15,
              loggedOn: DateTime(2026, 11, 10),
            ),
          ],
        ),
      );
      await tester.pumpAndSettle();

      expect(
        find.byKey(const ValueKey('study-analytics-tab-view')),
        findsOneWidget,
      );
      expect(find.byType(BarChart), findsNWidgets(2));
      expect(find.byType(PieChart), findsOneWidget);
    });
  });
}
