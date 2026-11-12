import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:job_prep/core/localization/locale_controller.dart';
import 'package:job_prep/core/storage/preferences_provider.dart';
import 'package:job_prep/core/theme/app_theme.dart';
import 'package:job_prep/core/theme/app_theme_tokens.dart';
import 'package:job_prep/features/circulars/domain/entities/circular.dart';
import 'package:job_prep/features/circulars/domain/entities/circular_enums.dart';
import 'package:job_prep/features/circulars/domain/entities/circular_exam_date.dart';
import 'package:job_prep/features/circulars/presentation/providers/circulars_providers.dart';
import 'package:job_prep/features/prep/domain/entities/prep_enums.dart';
import 'package:job_prep/features/prep/domain/entities/prep_material.dart';
import 'package:job_prep/features/prep/domain/entities/progress_log.dart';
import 'package:job_prep/features/prep/domain/entities/study_plan.dart';
import 'package:job_prep/features/prep/domain/entities/subject.dart';
import 'package:job_prep/features/prep/presentation/providers/prep_providers.dart';
import 'package:job_prep/features/prep/presentation/providers/study_plan_providers.dart';
import 'package:job_prep/features/prep/presentation/widgets/prep_study_plans_section.dart';
import 'package:job_prep/l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../features/circulars/fake_circular_repository.dart';
import '../features/prep/fake_material_and_log_repositories.dart';
import '../features/prep/fake_study_plan_repository.dart';
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
  final fixedNow = DateTime.utc(2026, 11, 6, 9);

  setUpAll(() async {
    await initializeDateFormatting('en');
    final currentUrl = Uri.base.resolve('test/goldens/test.dart');
    goldenFileComparator = _TolerantGoldenComparator(currentUrl);
  });

  Future<void> pumpStudyPlansGolden(
    WidgetTester tester, {
    required ThemeMode themeMode,
  }) async {
    tester.view.physicalSize = const Size(920, 880);
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

    final circularRepo = FakeCircularRepository(
      clock: () => fixedNow,
      initialItems: [
        Circular(
          id: 'g-circ',
          userId: 'u-1',
          title: '48th BCS Special Cadre',
          sector: CircularSector.bcs,
          examDates: [
            CircularExamDate(
              id: 'g-exam',
              circularId: 'g-circ',
              stage: 'preliminary',
              examDate: DateTime.utc(2026, 12, 8),
            ),
          ],
        ),
      ],
    );
    final subjectRepo = FakeSubjectRepository(
      initialSubjects: const [
        Subject(id: 'g-sub-bn', userId: 'u-1', name: 'Bengali'),
        Subject(
          id: 'g-sub-math',
          userId: 'u-1',
          name: 'Mathematics',
          sortOrder: 1,
        ),
      ],
    );
    final materialRepo = FakeMaterialRepository(
      initialMaterials: const [
        PrepMaterial(
          id: 'g-mat-1',
          userId: 'u-1',
          subjectId: 'g-sub-bn',
          title: 'Bangla Grammar Digest',
          totalUnits: 300,
          completedUnits: 120,
        ),
        PrepMaterial(
          id: 'g-mat-2',
          userId: 'u-1',
          subjectId: 'g-sub-math',
          title: 'Algebra Workbook',
          totalUnits: 300,
          completedUnits: 40,
        ),
        PrepMaterial(
          id: 'g-mat-3',
          userId: 'u-1',
          subjectId: 'g-sub-math',
          title: 'Quick Practice Notes',
          kind: MaterialKind.notes,
          totalUnits: 100,
        ),
      ],
    );
    final logRepo = FakeProgressLogRepository(
      materialRepository: materialRepo,
      initialLogs: [
        ProgressLog(
          id: 'g-log-1',
          userId: 'u-1',
          materialId: 'g-mat-1',
          unitsDone: 10,
          loggedOn: fixedNow,
        ),
      ],
    );
    final planRepo = FakeStudyPlanRepository(
      initialPlans: [
        StudyPlan(
          id: 'gp-all',
          userId: 'u-1',
          circularId: 'g-circ',
          examDateId: 'g-exam',
          startDate: DateTime.utc(2026, 11),
          targetDate: DateTime.utc(2026, 12, 8),
        ),
        StudyPlan(
          id: 'gp-math',
          userId: 'u-1',
          subjectId: 'g-sub-math',
          startDate: DateTime.utc(2026, 11),
          targetDate: DateTime.utc(2026, 11, 25),
          restDaysPerWeek: 1,
          maxDailyPace: 20,
        ),
      ],
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
          circularNowProvider.overrideWithValue(() => fixedNow),
          circularRepositoryProvider.overrideWithValue(circularRepo),
          subjectRepositoryProvider.overrideWithValue(subjectRepo),
          materialRepositoryProvider.overrideWithValue(materialRepo),
          progressLogRepositoryProvider.overrideWithValue(logRepo),
          studyPlanRepositoryProvider.overrideWithValue(planRepo),
        ],
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: AppTheme.light(),
          darkTheme: AppTheme.dark(),
          themeMode: themeMode,
          locale: const Locale('en'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            body: Consumer(
              builder: (context, ref, _) {
                final tokens = context.tokens;
                final snapshots =
                    ref.watch(studyPlanSnapshotsProvider).asData?.value ??
                        const [];
                return ColoredBox(
                  key: const ValueKey('study-plan-golden-canvas'),
                  color: tokens.colors.background,
                  child: SingleChildScrollView(
                    padding: tokens.spacing.insetsAllXl,
                    child: PrepStudyPlansSection(
                      snapshots: snapshots,
                      visitId: 1,
                    ),
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

  group('Study Plans Golden Tests', () {
    testWidgets('Study plans golden - dark mode', (tester) async {
      await pumpStudyPlansGolden(tester, themeMode: ThemeMode.dark);
      await expectLater(
        find.byKey(const ValueKey('study-plan-golden-canvas')),
        matchesGoldenFile('goldens/study_plan_dark.png'),
      );
    });

    testWidgets('Study plans golden - light mode', (tester) async {
      await pumpStudyPlansGolden(tester, themeMode: ThemeMode.light);
      await expectLater(
        find.byKey(const ValueKey('study-plan-golden-canvas')),
        matchesGoldenFile('goldens/study_plan_light.png'),
      );
    });
  });
}
