import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:job_prep/core/localization/locale_controller.dart';
import 'package:job_prep/core/storage/preferences_provider.dart';
import 'package:job_prep/core/theme/app_theme.dart';
import 'package:job_prep/core/theme/reduce_effects_controller.dart';
import 'package:job_prep/features/auth/presentation/providers/auth_providers.dart';
import 'package:job_prep/features/circulars/domain/entities/circular.dart';
import 'package:job_prep/features/circulars/domain/entities/circular_enums.dart';
import 'package:job_prep/features/circulars/domain/entities/circular_exam_date.dart';
import 'package:job_prep/features/circulars/presentation/providers/circulars_providers.dart';
import 'package:job_prep/features/prep/domain/entities/prep_enums.dart';
import 'package:job_prep/features/prep/domain/entities/prep_material.dart';
import 'package:job_prep/features/prep/domain/entities/progress_log.dart';
import 'package:job_prep/features/prep/domain/entities/revision_item.dart';
import 'package:job_prep/features/prep/domain/entities/study_plan.dart';
import 'package:job_prep/features/prep/domain/entities/study_session.dart';
import 'package:job_prep/features/prep/domain/entities/subject.dart';
import 'package:job_prep/features/prep/presentation/providers/mock_test_providers.dart';
import 'package:job_prep/features/prep/presentation/providers/prep_providers.dart';
import 'package:job_prep/features/prep/presentation/providers/revision_providers.dart';
import 'package:job_prep/features/prep/presentation/providers/study_plan_providers.dart';
import 'package:job_prep/features/prep/presentation/providers/study_session_providers.dart';
import 'package:job_prep/features/today/presentation/providers/today_providers.dart';
import 'package:job_prep/features/today/presentation/screens/today_screen.dart';
import 'package:job_prep/l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../features/auth/fake_auth_repository.dart';
import '../features/circulars/fake_circular_repository.dart';
import '../features/prep/fake_material_and_log_repositories.dart';
import '../features/prep/fake_mock_test_repository.dart';
import '../features/prep/fake_revision_item_repository.dart';
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
  final fixedNow = DateTime(2026, 11, 12, 9, 30);

  setUpAll(() async {
    await initializeDateFormatting('en');
    await initializeDateFormatting('bn');
    final currentUrl = Uri.base.resolve('test/goldens/test.dart');
    goldenFileComparator = _TolerantGoldenComparator(currentUrl);
  });

  Future<void> pumpTodayGolden(
    WidgetTester tester, {
    required ThemeMode themeMode,
    required Locale locale,
  }) async {
    tester.view.physicalSize = const Size(980, 2240);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    SharedPreferences.setMockInitialValues({
      kReduceEffectsStorageKey: true,
      kLocaleStorageKey: locale.languageCode,
      kUseBanglaDigitsStorageKey: locale.languageCode == 'bn',
    });
    final prefs = await SharedPreferences.getInstance();
    final authRepo = FakeAuthRepository.authenticated();
    addTearDown(authRepo.dispose);

    const subMath = Subject(
      id: 'gt-math',
      userId: 'u-1',
      name: 'Quantitative Math',
    );
    const subBangla = Subject(
      id: 'gt-bn',
      userId: 'u-1',
      name: 'Bangla Literature',
    );
    const matMath = PrepMaterial(
      id: 'gt-m1',
      userId: 'u-1',
      subjectId: 'gt-math',
      title: 'Khairuls Basic Math',
      totalUnits: 400,
      completedUnits: 120,
    );
    const matBangla = PrepMaterial(
      id: 'gt-m2',
      userId: 'u-1',
      subjectId: 'gt-bn',
      title: 'Ogrodooth Bangla',
      totalUnits: 200,
      completedUnits: 146,
    );

    final materialRepo = FakeMaterialRepository(
      initialMaterials: const [matMath, matBangla],
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
          authRepositoryProvider.overrideWithValue(authRepo),
          circularNowProvider.overrideWithValue(() => fixedNow),
          todayOffsetProvider.overrideWithValue(const Duration(hours: 6)),
          circularRepositoryProvider.overrideWithValue(
            FakeCircularRepository(
              clock: () => fixedNow,
              initialItems: [
                Circular(
                  id: 'gc-1',
                  userId: 'u-1',
                  title: '48th BCS Special Cadre',
                  organizationName: 'BPSC',
                  sector: CircularSector.bcs,
                  deadline: DateTime(2026, 11, 13, 18),
                  examDates: [
                    CircularExamDate(
                      id: 'ge-1',
                      circularId: 'gc-1',
                      stage: 'preliminary',
                      examDate: DateTime(2026, 11, 18, 10),
                      venue: 'Dhaka College',
                    ),
                  ],
                ),
                Circular(
                  id: 'gc-2',
                  userId: 'u-1',
                  title: 'Combined Bank Senior Officer',
                  organizationName: 'Bankers Selection Committee',
                  sector: CircularSector.bank,
                  deadline: DateTime(2026, 11, 17, 17),
                ),
                const Circular(
                  id: 'gc-in',
                  userId: 'u-1',
                  title: 'ntrca.gov.bd',
                  circularUrl: 'https://ntrca.gov.bd/notice',
                  workflowStatus: CircularWorkflowStatus.inbox,
                  isQuickCapture: true,
                ),
              ],
            ),
          ),
          subjectRepositoryProvider.overrideWithValue(
            FakeSubjectRepository(
              initialSubjects: const [subMath, subBangla],
            ),
          ),
          materialRepositoryProvider.overrideWithValue(materialRepo),
          progressLogRepositoryProvider.overrideWithValue(
            FakeProgressLogRepository(
              materialRepository: materialRepo,
              clock: () => fixedNow,
              initialLogs: [
                ProgressLog(
                  id: 'gl-seed',
                  materialId: 'gt-m1',
                  unitsDone: 100,
                  loggedOn: DateTime.utc(2026, 11, 9),
                ),
                ProgressLog(
                  id: 'gl-today-1',
                  materialId: 'gt-m1',
                  unitsDone: 20,
                  loggedOn: DateTime.utc(2026, 11, 12),
                ),
                ProgressLog(
                  id: 'gl-today-2',
                  materialId: 'gt-m2',
                  unitsDone: 6,
                  loggedOn: DateTime.utc(2026, 11, 12),
                ),
              ],
            ),
          ),
          studyPlanRepositoryProvider.overrideWithValue(
            FakeStudyPlanRepository(
              clock: () => fixedNow,
              initialPlans: [
                StudyPlan(
                  id: 'gp-math',
                  userId: 'u-1',
                  subjectId: 'gt-math',
                  startDate: DateTime.utc(2026, 11, 10),
                  targetDate: DateTime.utc(2026, 11, 29),
                  initialCompletedUnits: 100,
                ),
                StudyPlan(
                  id: 'gp-bn',
                  userId: 'u-1',
                  subjectId: 'gt-bn',
                  startDate: DateTime.utc(2026, 11, 10),
                  targetDate: DateTime.utc(2026, 11, 29),
                  initialCompletedUnits: 140,
                ),
              ],
            ),
          ),
          revisionItemRepositoryProvider.overrideWithValue(
            FakeRevisionItemRepository(
              clock: () => fixedNow,
              initialItems: [
                RevisionItem(
                  id: 'gr-1',
                  subjectId: 'gt-math',
                  materialId: 'gt-m1',
                  referenceLabel: 'p. 128 — Percentage Ratio',
                  dueOn: DateTime.utc(2026, 11, 11),
                ),
                RevisionItem(
                  id: 'gr-2',
                  subjectId: 'gt-bn',
                  materialId: 'gt-m2',
                  referenceLabel: 'Ch. 4 — Samas',
                  reason: RevisionReason.forgot,
                  dueOn: DateTime.utc(2026, 11, 12),
                ),
              ],
            ),
          ),
          studySessionRepositoryProvider.overrideWithValue(
            FakeStudySessionRepository(
              clock: () => fixedNow,
              initialSessions: [
                StudySession(
                  id: 'gs-1',
                  userId: 'u-1',
                  subjectId: 'gt-math',
                  startedAt: DateTime(2026, 11, 12, 7, 30),
                  endedAt: DateTime(2026, 11, 12, 9),
                  durationSeconds: 5400,
                ),
              ],
            ),
          ),
          mockTestRepositoryProvider.overrideWithValue(
            FakeMockTestRepository(clock: () => fixedNow),
          ),
        ],
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: AppTheme.light(),
          darkTheme: AppTheme.dark(),
          themeMode: themeMode,
          locale: locale,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const Scaffold(body: TodayScreen()),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  group('Phase 6I TodayScreen Golden Tests', () {
    testWidgets('TodayScreen golden - English dark mode', (tester) async {
      await pumpTodayGolden(
        tester,
        themeMode: ThemeMode.dark,
        locale: const Locale('en'),
      );
      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile('goldens/today_screen_en_dark.png'),
      );
    });

    testWidgets('TodayScreen golden - English light mode', (tester) async {
      await pumpTodayGolden(
        tester,
        themeMode: ThemeMode.light,
        locale: const Locale('en'),
      );
      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile('goldens/today_screen_en_light.png'),
      );
    });

    testWidgets('TodayScreen golden - Bangla dark mode', (tester) async {
      await pumpTodayGolden(
        tester,
        themeMode: ThemeMode.dark,
        locale: const Locale('bn'),
      );
      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile('goldens/today_screen_bn_dark.png'),
      );
    });

    testWidgets('TodayScreen golden - Bangla light mode', (tester) async {
      await pumpTodayGolden(
        tester,
        themeMode: ThemeMode.light,
        locale: const Locale('bn'),
      );
      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile('goldens/today_screen_bn_light.png'),
      );
    });
  });
}
