import 'dart:async';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:job_prep/core/localization/locale_controller.dart';
import 'package:job_prep/core/storage/preferences_provider.dart';
import 'package:job_prep/core/theme/app_theme.dart';
import 'package:job_prep/core/theme/reduce_effects_controller.dart';
import 'package:job_prep/features/circulars/domain/entities/circular.dart';
import 'package:job_prep/features/circulars/domain/entities/circular_enums.dart';
import 'package:job_prep/features/circulars/presentation/providers/circulars_providers.dart';
import 'package:job_prep/features/prep/domain/entities/mock_test.dart';
import 'package:job_prep/features/prep/domain/entities/prep_material.dart';
import 'package:job_prep/features/prep/domain/entities/subject.dart';
import 'package:job_prep/features/prep/domain/entities/topic.dart';
import 'package:job_prep/features/prep/domain/errors/prep_failure.dart';
import 'package:job_prep/features/prep/presentation/providers/mock_test_providers.dart';
import 'package:job_prep/features/prep/presentation/providers/prep_cover_providers.dart';
import 'package:job_prep/features/prep/presentation/providers/prep_progress_log_controller.dart';
import 'package:job_prep/features/prep/presentation/providers/prep_providers.dart';
import 'package:job_prep/features/prep/presentation/providers/prep_template_providers.dart';
import 'package:job_prep/features/prep/presentation/providers/study_plan_providers.dart';
import 'package:job_prep/features/prep/presentation/screens/prep_screen.dart';
import 'package:job_prep/features/prep/presentation/widgets/mock_tests_tab_view.dart';
import 'package:job_prep/features/prep/presentation/widgets/prep_subject_detail_view.dart';
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
  final fixedNow = DateTime.utc(2026, 11, 10, 9);

  setUpAll(() async {
    await initializeDateFormatting('en');
    await initializeDateFormatting('bn');
  });

  const subBangla = Subject(
    id: 'sub-bn',
    userId: 'u-1',
    name: 'Bangla Literature',
    color: 'info',
    icon: 'language',
  );
  const subMath = Subject(
    id: 'sub-math',
    userId: 'u-1',
    name: 'Mathematics',
    icon: 'calculate',
    sortOrder: 1,
  );
  const matBangla = PrepMaterial(
    id: 'mat-1',
    userId: 'u-1',
    subjectId: 'sub-bn',
    title: 'Ogrodooth Bangla',
    totalUnits: 300,
    completedUnits: 120,
  );
  const topicGrammar = Topic(
    id: 'top-1',
    userId: 'u-1',
    subjectId: 'sub-bn',
    name: 'Somash & Sandhi',
  );
  const sampleCircular = Circular(
    id: 'circ-1',
    userId: 'u-1',
    title: '48th BCS Circular',
    sector: CircularSector.bcs,
  );

  Future<Widget> buildHarness({
    required Widget child,
    required FakeMockTestRepository mockRepo,
    List<Subject> subjects = const [subBangla, subMath],
    List<PrepMaterial> materials = const [matBangla],
    List<Topic> topics = const [topicGrammar],
    List<Circular> circulars = const [],
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

    return ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
        prepNowProvider.overrideWithValue(() => fixedNow),
        subjectRepositoryProvider.overrideWithValue(
          FakeSubjectRepository(initialSubjects: subjects),
        ),
        materialRepositoryProvider.overrideWithValue(
          FakeMaterialRepository(initialMaterials: materials),
        ),
        progressLogRepositoryProvider.overrideWithValue(
          FakeProgressLogRepository(),
        ),
        topicRepositoryProvider.overrideWithValue(
          FakeTopicRepository(initialTopics: topics),
        ),
        materialCoverRepositoryProvider.overrideWithValue(
          FakeMaterialCoverRepository(),
        ),
        prepTemplateRepositoryProvider.overrideWithValue(
          FakePrepTemplateRepository(),
        ),
        studyPlanRepositoryProvider.overrideWithValue(
          FakeStudyPlanRepository(clock: () => fixedNow),
        ),
        circularRepositoryProvider.overrideWithValue(
          FakeCircularRepository(initialItems: circulars),
        ),
        mockTestRepositoryProvider.overrideWithValue(mockRepo),
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

  group('Phase 6D Mock Test Widgets', () {
    testWidgets('shows loading, error retry recovery, and empty states',
        (tester) async {
      tester.view.physicalSize = const Size(1200, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final gate = Completer<void>();
      final repo = FakeMockTestRepository(clock: () => fixedNow)
        ..getTestsGate = gate
        ..nextError = const UnknownPrepFailure(message: 'Network down');

      await tester.pumpWidget(
        await buildHarness(
          child: const PrepScreen(),
          mockRepo: repo,
          subjects: const [],
          circulars: [sampleCircular],
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const ValueKey('prep-tab-mock-tests')));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));

      expect(find.byKey(const ValueKey('mock-tab-loading')), findsOneWidget);

      gate.complete();
      await tester.pumpAndSettle();
      expect(find.byKey(const ValueKey('mock-tab-error')), findsOneWidget);

      await tester.tap(find.byKey(const ValueKey('mock-tab-retry-button')));
      await tester.pumpAndSettle();

      expect(find.byKey(const ValueKey('mock-tab-empty')), findsOneWidget);
    });

    testWidgets(
        'filters by subject and date preset and handles form validation, '
        'attachments, edit, and delete', (tester) async {
      tester.view.physicalSize = const Size(1280, 960);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final repo = FakeMockTestRepository(
        clock: () => fixedNow,
        initialTests: [
          MockTest(
            id: 'mt-1',
            userId: 'u-1',
            subjectId: subBangla.id,
            title: 'Live MCQ 01',
            source: 'Live MCQ',
            takenOn: DateTime.utc(2026, 11, 8),
            marksObtained: 84,
            totalMarks: 100,
            negativeMarks: 4,
          ),
          MockTest(
            id: 'mt-2',
            userId: 'u-1',
            subjectId: subMath.id,
            title: 'Bank Math Oct',
            takenOn: DateTime.utc(2026, 10),
            marksObtained: 40,
            totalMarks: 50,
          ),
        ],
      );

      await tester.pumpWidget(
        await buildHarness(
          child: const PrepScreen(),
          mockRepo: repo,
          circulars: [sampleCircular],
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const ValueKey('prep-tab-mock-tests')));
      await tester.pumpAndSettle();

      expect(find.text('Live MCQ 01'), findsOneWidget);
      expect(find.text('Bank Math Oct'), findsOneWidget);
      expect(find.byType(LineChart), findsOneWidget);

      // Filter to Mathematics -> hides Bangla test.
      await tester.tap(
        find.byKey(const ValueKey('mock-filter-subject-dropdown')),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('Mathematics').last);
      await tester.pumpAndSettle();

      expect(find.text('Bank Math Oct'), findsOneWidget);
      expect(find.text('Live MCQ 01'), findsNothing);

      // Filter last 7 days (Oct 1 is outside) -> shows filtered empty card.
      await tester
          .tap(find.byKey(const ValueKey('mock-filter-date-last7Days')));
      await tester.pumpAndSettle();
      expect(
        find.byKey(const ValueKey('mock-tab-filtered-empty')),
        findsOneWidget,
      );

      // Clear filters -> restores both tests.
      await tester
          .tap(find.byKey(const ValueKey('mock-tab-empty-clear-button')));
      await tester.pumpAndSettle();
      expect(find.text('Live MCQ 01'), findsOneWidget);
      expect(find.text('Bank Math Oct'), findsOneWidget);

      // Open Add dialog and verify validation rules.
      await tester.tap(find.byKey(const ValueKey('mock-tab-add-button')));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const ValueKey('mock-form-submit-button')));
      await tester.pumpAndSettle();
      expect(find.text('Enter a title for the mock test.'), findsOneWidget);

      await tester.enterText(
        find.byKey(const ValueKey('mock-form-title-field')),
        'BCS Model 02',
      );
      await tester.enterText(
        find.byKey(const ValueKey('mock-form-total-marks-field')),
        '0',
      );
      await tester.tap(find.byKey(const ValueKey('mock-form-submit-button')));
      await tester.pumpAndSettle();
      expect(
        find.text('Total marks must be greater than zero.'),
        findsOneWidget,
      );

      await tester.enterText(
        find.byKey(const ValueKey('mock-form-total-marks-field')),
        '100',
      );
      await tester.enterText(
        find.byKey(const ValueKey('mock-form-marks-obtained-field')),
        '120',
      );
      await tester.tap(find.byKey(const ValueKey('mock-form-submit-button')));
      await tester.pumpAndSettle();
      expect(
        find.text('Marks obtained must be between 0 and total marks.'),
        findsOneWidget,
      );

      await tester.enterText(
        find.byKey(const ValueKey('mock-form-marks-obtained-field')),
        '92',
      );
      await tester.enterText(
        find.byKey(const ValueKey('mock-form-negative-marks-field')),
        '150',
      );
      await tester.tap(find.byKey(const ValueKey('mock-form-submit-button')));
      await tester.pumpAndSettle();
      expect(
        find.text('Negative marks must be between 0 and total marks.'),
        findsOneWidget,
      );

      await tester.enterText(
        find.byKey(const ValueKey('mock-form-negative-marks-field')),
        '2',
      );
      await tester.enterText(
        find.byKey(const ValueKey('mock-form-time-taken-field')),
        '-10',
      );
      await tester.tap(find.byKey(const ValueKey('mock-form-submit-button')));
      await tester.pumpAndSettle();
      expect(
        find.text(
          'Time taken must be 0 or more, and time limit must be greater than '
          'zero.',
        ),
        findsOneWidget,
      );

      await tester.enterText(
        find.byKey(const ValueKey('mock-form-time-taken-field')),
        '55',
      );
      await tester.enterText(
        find.byKey(const ValueKey('mock-form-time-limit-field')),
        '60',
      );
      await tester.enterText(
        find.byKey(const ValueKey('mock-form-weak-topics-field')),
        'Suffixes',
      );

      // Attach Circular, Material, and Topic for Bangla subject.
      final circularDrop =
          find.byKey(const ValueKey('mock-form-circular-dropdown'));
      await tester.ensureVisible(circularDrop);
      await tester.tap(circularDrop);
      await tester.pumpAndSettle();
      await tester.tap(find.text('48th BCS Circular').last);
      await tester.pumpAndSettle();

      final materialDrop =
          find.byKey(const ValueKey('mock-form-material-dropdown'));
      await tester.ensureVisible(materialDrop);
      await tester.tap(materialDrop);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Ogrodooth Bangla').last);
      await tester.pumpAndSettle();

      final topicDrop = find.byKey(const ValueKey('mock-form-topic-dropdown'));
      await tester.ensureVisible(topicDrop);
      await tester.tap(topicDrop);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Somash & Sandhi').last);
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const ValueKey('mock-form-submit-button')));
      await tester.pumpAndSettle();

      final created = repo.tests.last;
      expect(created.title, 'BCS Model 02');
      expect(created.circularId, 'circ-1');
      expect(created.materialId, 'mat-1');
      expect(created.topicId, 'top-1');
      expect(find.text('Circular: 48th BCS Circular'), findsOneWidget);
      expect(find.text('Material: Ogrodooth Bangla'), findsOneWidget);
      expect(find.text('Topic: Somash & Sandhi'), findsOneWidget);

      // Edit test title cleanly.
      final editBtn = find.byKey(ValueKey('mock-test-edit-${created.id}'));
      await tester.ensureVisible(editBtn);
      await tester.tap(editBtn);
      await tester.pumpAndSettle();

      await tester.enterText(
        find.byKey(const ValueKey('mock-form-title-field')),
        'BCS Model 02 Revised',
      );
      await tester.tap(find.byKey(const ValueKey('mock-form-submit-button')));
      await tester.pumpAndSettle();
      expect(find.text('BCS Model 02 Revised'), findsOneWidget);

      // Delete test cleanly via confirmation dialog.
      final deleteBtn = find.byKey(ValueKey('mock-test-delete-${created.id}'));
      await tester.ensureVisible(deleteBtn);
      await tester.tap(deleteBtn);
      await tester.pumpAndSettle();
      await tester
          .tap(find.byKey(const ValueKey('mock-delete-confirm-button')));
      await tester.pumpAndSettle();
      expect(find.text('BCS Model 02 Revised'), findsNothing);
    });

    testWidgets(
        'Subject detail shows 4 cards and LineChart, respects reduceEffects '
        'and renders cleanly in Bangla narrow layout', (tester) async {
      tester.view.physicalSize = const Size(360, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final repo = FakeMockTestRepository(
        clock: () => fixedNow,
        initialTests: [
          MockTest(
            id: 's-1',
            userId: 'u-1',
            subjectId: subBangla.id,
            title: 'Bangla Set 1',
            takenOn: DateTime.utc(2026, 11, 2),
            marksObtained: 65,
            totalMarks: 100,
            negativeMarks: 5,
          ),
          MockTest(
            id: 's-2',
            userId: 'u-1',
            subjectId: subBangla.id,
            title: 'Bangla Set 2',
            takenOn: DateTime.utc(2026, 11, 9),
            marksObtained: 85,
            totalMarks: 100,
            negativeMarks: 5,
          ),
        ],
      );

      // With reduceEffects = true, LineChart uses Duration.zero.
      await tester.pumpWidget(
        await buildHarness(
          child: const SingleChildScrollView(
            child: PrepSubjectDetailView(subject: subBangla),
          ),
          mockRepo: repo,
          locale: const Locale('bn'),
          themeMode: ThemeMode.light,
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byKey(const ValueKey('mock-stat-latest')), findsOneWidget);
      expect(find.byKey(const ValueKey('mock-stat-best')), findsOneWidget);
      expect(find.byKey(const ValueKey('mock-stat-average')), findsOneWidget);
      expect(
        find.byKey(const ValueKey('mock-stat-improvement')),
        findsOneWidget,
      );
      final chartZero = tester.widget<LineChart>(find.byType(LineChart));
      expect(chartZero.duration, Duration.zero);
      expect(tester.takeException(), isNull);

      // With reduceEffects = false, LineChart animates with non-zero duration.
      await tester.pumpWidget(
        await buildHarness(
          child: const SingleChildScrollView(
            child: PrepSubjectDetailView(subject: subBangla),
          ),
          mockRepo: repo,
          reduceEffects: false,
        ),
      );
      await tester.pumpAndSettle();

      final chartAnimated = tester.widget<LineChart>(find.byType(LineChart));
      expect(chartAnimated.duration, greaterThan(Duration.zero));

      // Verify MockTestsTabView renders at 360x800 Bangla with zero overflow.
      await tester.pumpWidget(
        await buildHarness(
          child: const SingleChildScrollView(
            padding: EdgeInsets.all(16),
            child: MockTestsTabView(visitId: 1),
          ),
          mockRepo: repo,
          locale: const Locale('bn'),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.byKey(const ValueKey('mock-tests-tab-view')), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('replays chart animation key when switching tabs',
        (tester) async {
      tester.view.physicalSize = const Size(1200, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final repo = FakeMockTestRepository(
        clock: () => fixedNow,
        initialTests: [
          MockTest(
            id: 'r-1',
            userId: 'u-1',
            subjectId: subBangla.id,
            title: 'Bangla Set 1',
            takenOn: DateTime.utc(2026, 11, 2),
            marksObtained: 80,
            totalMarks: 100,
          ),
        ],
      );

      await tester.pumpWidget(
        await buildHarness(
          child: const PrepScreen(),
          mockRepo: repo,
          reduceEffects: false,
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const ValueKey('prep-tab-mock-tests')));
      await tester.pumpAndSettle();
      final firstKey = tester
          .widget<TweenAnimationBuilder<double>>(
            find.byType(TweenAnimationBuilder<double>).last,
          )
          .key;

      await tester.tap(find.byKey(const ValueKey('prep-tab-subjects')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('prep-tab-mock-tests')));
      await tester.pumpAndSettle();
      final secondKey = tester
          .widget<TweenAnimationBuilder<double>>(
            find.byType(TweenAnimationBuilder<double>).last,
          )
          .key;

      expect(firstKey, isNot(equals(secondKey)));
    });
  });
}
