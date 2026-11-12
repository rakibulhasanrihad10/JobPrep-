import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:job_prep/core/localization/locale_controller.dart';
import 'package:job_prep/core/storage/preferences_provider.dart';
import 'package:job_prep/core/theme/app_theme.dart';
import 'package:job_prep/core/theme/app_theme_tokens.dart';
import 'package:job_prep/features/circulars/presentation/providers/circulars_providers.dart';
import 'package:job_prep/features/prep/domain/entities/mock_test.dart';
import 'package:job_prep/features/prep/domain/entities/prep_material.dart';
import 'package:job_prep/features/prep/domain/entities/progress_log.dart';
import 'package:job_prep/features/prep/domain/entities/study_plan.dart';
import 'package:job_prep/features/prep/domain/entities/study_session.dart';
import 'package:job_prep/features/prep/domain/entities/subject.dart';
import 'package:job_prep/features/prep/presentation/providers/mock_test_providers.dart';
import 'package:job_prep/features/prep/presentation/providers/prep_progress_log_controller.dart';
import 'package:job_prep/features/prep/presentation/providers/prep_providers.dart';
import 'package:job_prep/features/prep/presentation/providers/study_plan_providers.dart';
import 'package:job_prep/features/prep/presentation/providers/study_session_providers.dart';
import 'package:job_prep/features/prep/presentation/widgets/study_analytics_tab_view.dart';
import 'package:job_prep/l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../features/circulars/fake_circular_repository.dart';
import '../features/prep/fake_material_and_log_repositories.dart';
import '../features/prep/fake_mock_test_repository.dart';
import '../features/prep/fake_study_plan_repository.dart';
import '../features/prep/fake_study_session_repository.dart';
import '../features/prep/fake_subject_and_topic_repositories.dart';

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
  final fixedNow = DateTime(2026, 11, 10, 14);

  setUpAll(() async {
    await initializeDateFormatting('en');
    final currentUrl = Uri.base.resolve('test/goldens/test.dart');
    goldenFileComparator = _TolerantGoldenComparator(currentUrl);
  });

  Future<void> pumpAnalyticsGolden(
    WidgetTester tester, {
    required ThemeMode themeMode,
  }) async {
    tester.view.physicalSize = const Size(980, 1980);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    SharedPreferences.setMockInitialValues({
      kLocaleStorageKey: 'en',
      kUseBanglaDigitsStorageKey: false,
    });
    final prefs = await SharedPreferences.getInstance();

    const subMath = Subject(
      id: 'g-math',
      userId: 'u-1',
      name: 'Quantitative Math',
      icon: 'calculate',
    );
    const subBangla = Subject(
      id: 'g-bn',
      userId: 'u-1',
      name: 'Bangla Literature',
      color: 'info',
      icon: 'language',
      sortOrder: 1,
    );
    const subEng = Subject(
      id: 'g-eng',
      userId: 'u-1',
      name: 'English Grammar',
      color: 'accent_secondary',
      sortOrder: 2,
    );

    const materials = [
      PrepMaterial(
        id: 'gm-1',
        userId: 'u-1',
        subjectId: 'g-math',
        title: 'Basic Math',
        totalUnits: 400,
        completedUnits: 160,
      ),
      PrepMaterial(
        id: 'gm-2',
        userId: 'u-1',
        subjectId: 'g-bn',
        title: 'Ogrodooth Bangla',
        totalUnits: 300,
        completedUnits: 110,
      ),
      PrepMaterial(
        id: 'gm-3',
        userId: 'u-1',
        subjectId: 'g-eng',
        title: 'Competitive English',
        totalUnits: 300,
        completedUnits: 90,
      ),
    ];

    final logs = [
      ProgressLog(
        id: 'gl-1',
        materialId: 'gm-1',
        unitsDone: 28,
        loggedOn: DateTime(2026, 11, 4),
      ),
      ProgressLog(
        id: 'gl-2',
        materialId: 'gm-2',
        unitsDone: 36,
        loggedOn: DateTime(2026, 11, 5),
      ),
      ProgressLog(
        id: 'gl-3',
        materialId: 'gm-1',
        unitsDone: 42,
        loggedOn: DateTime(2026, 11, 6),
      ),
      ProgressLog(
        id: 'gl-4',
        materialId: 'gm-3',
        unitsDone: 22,
        loggedOn: DateTime(2026, 11, 7),
      ),
      ProgressLog(
        id: 'gl-5',
        materialId: 'gm-2',
        unitsDone: 38,
        loggedOn: DateTime(2026, 11, 8),
      ),
      ProgressLog(
        id: 'gl-6',
        materialId: 'gm-1',
        unitsDone: 14,
        loggedOn: DateTime(2026, 11, 9),
      ),
      ProgressLog(
        id: 'gl-7',
        materialId: 'gm-3',
        unitsDone: 40,
        loggedOn: DateTime(2026, 11, 10),
      ),
      ProgressLog(
        id: 'gl-old',
        materialId: 'gm-2',
        unitsDone: 30,
        loggedOn: DateTime(2026, 10, 18),
      ),
    ];

    final plans = [
      StudyPlan(
        id: 'gp-1',
        userId: 'u-1',
        startDate: DateTime.utc(2026, 11),
        targetDate: DateTime.utc(2026, 12, 10),
      ),
    ];

    final mocks = [
      MockTest(
        id: 'gmt-1',
        subjectId: 'g-math',
        title: 'BCS Math Model 01',
        takenOn: DateTime(2026, 11, 6),
        marksObtained: 82,
        totalMarks: 100,
      ),
      MockTest(
        id: 'gmt-2',
        subjectId: 'g-bn',
        title: 'Bangla Set 04',
        takenOn: DateTime(2026, 11, 8),
        marksObtained: 76,
        totalMarks: 100,
      ),
    ];

    final sessions = [
      StudySession(
        id: 'gs-1',
        userId: 'u-1',
        subjectId: 'g-math',
        materialId: 'gm-2',
        startedAt: DateTime(2026, 11, 10, 8),
        endedAt: DateTime(2026, 11, 10, 10),
        durationSeconds: 7200,
      ),
      StudySession(
        id: 'gs-2',
        userId: 'u-1',
        subjectId: 'g-bn',
        materialId: 'gm-1',
        startedAt: DateTime(2026, 11, 9, 15),
        endedAt: DateTime(2026, 11, 9, 16, 30),
        durationSeconds: 5400,
      ),
    ];

    final materialRepo = FakeMaterialRepository(initialMaterials: materials);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
          prepNowProvider.overrideWithValue(() => fixedNow),
          subjectRepositoryProvider.overrideWithValue(
            FakeSubjectRepository(
              initialSubjects: const [subMath, subBangla, subEng],
            ),
          ),
          materialRepositoryProvider.overrideWithValue(materialRepo),
          progressLogRepositoryProvider.overrideWithValue(
            FakeProgressLogRepository(
              initialLogs: logs,
              materialRepository: materialRepo,
              clock: () => fixedNow,
            ),
          ),
          studyPlanRepositoryProvider.overrideWithValue(
            FakeStudyPlanRepository(
              initialPlans: plans,
              clock: () => fixedNow,
            ),
          ),
          circularRepositoryProvider.overrideWithValue(
            FakeCircularRepository(clock: () => fixedNow),
          ),
          mockTestRepositoryProvider.overrideWithValue(
            FakeMockTestRepository(
              initialTests: mocks,
              clock: () => fixedNow,
            ),
          ),
          studySessionRepositoryProvider.overrideWithValue(
            FakeStudySessionRepository(
              initialSessions: sessions,
              clock: () => fixedNow,
            ),
          ),
        ],
        child: MaterialApp(
          theme: AppTheme.light(),
          darkTheme: AppTheme.dark(),
          themeMode: themeMode,
          locale: const Locale('en'),
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          home: Scaffold(
            body: Builder(
              builder: (context) {
                final tokens = context.tokens;
                return Container(
                  color: tokens.colors.background,
                  padding: tokens.spacing.insetsAllLg,
                  child: SingleChildScrollView(
                    child: StudyAnalyticsTabView(visitId: themeMode.index + 1),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();
  }

  testWidgets('Study Analytics dashboard golden - dark mode', (tester) async {
    await pumpAnalyticsGolden(tester, themeMode: ThemeMode.dark);
    await expectLater(
      find.byType(MaterialApp),
      matchesGoldenFile('goldens/study_analytics_dark.png'),
    );
  });

  testWidgets('Study Analytics dashboard golden - light mode', (tester) async {
    await pumpAnalyticsGolden(tester, themeMode: ThemeMode.light);
    await expectLater(
      find.byType(MaterialApp),
      matchesGoldenFile('goldens/study_analytics_light.png'),
    );
  });
}
