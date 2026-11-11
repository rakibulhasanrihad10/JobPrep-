import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:job_prep/core/localization/locale_controller.dart';
import 'package:job_prep/core/storage/preferences_provider.dart';
import 'package:job_prep/core/theme/app_theme.dart';
import 'package:job_prep/core/widgets/animated_progress_ring.dart';
import 'package:job_prep/features/circulars/domain/entities/circular.dart';
import 'package:job_prep/features/circulars/domain/entities/circular_enums.dart';
import 'package:job_prep/features/circulars/domain/entities/circular_exam_date.dart';
import 'package:job_prep/features/circulars/presentation/providers/circulars_providers.dart';
import 'package:job_prep/features/dashboard/presentation/screens/dashboard_screen.dart';
import 'package:job_prep/features/prep/domain/entities/prep_enums.dart';
import 'package:job_prep/features/prep/domain/entities/prep_material.dart';
import 'package:job_prep/features/prep/domain/entities/progress_log.dart';
import 'package:job_prep/features/prep/domain/entities/study_plan.dart';
import 'package:job_prep/features/prep/domain/entities/subject.dart';
import 'package:job_prep/features/prep/presentation/providers/prep_cover_providers.dart';
import 'package:job_prep/features/prep/presentation/providers/prep_progress_log_controller.dart';
import 'package:job_prep/features/prep/presentation/providers/prep_providers.dart';
import 'package:job_prep/features/prep/presentation/providers/prep_template_providers.dart';
import 'package:job_prep/features/prep/presentation/providers/study_plan_providers.dart';
import 'package:job_prep/features/prep/presentation/screens/prep_screen.dart';
import 'package:job_prep/features/prep/presentation/widgets/study_plan_card.dart';
import 'package:job_prep/l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../circulars/fake_circular_repository.dart';
import 'fake_material_and_log_repositories.dart';
import 'fake_material_cover_repository.dart';
import 'fake_prep_template_repository.dart';
import 'fake_study_plan_repository.dart';
import 'fake_subject_and_topic_repositories.dart';

void main() {
  final fixedNow = DateTime.utc(2026, 11, 6, 9);

  setUpAll(() async {
    await initializeDateFormatting('en');
    await initializeDateFormatting('bn');
  });

  List<Subject> sampleSubjects() {
    return const [
      Subject(id: 'sub-bn', userId: 'user-1', name: 'Bengali', examType: 'BCS'),
      Subject(
        id: 'sub-math',
        userId: 'user-1',
        name: 'Mathematics',
        examType: 'BCS',
        sortOrder: 1,
      ),
    ];
  }

  List<Circular> sampleCirculars() {
    return [
      Circular(
        id: 'circ-bcs',
        userId: 'user-1',
        title: '48th BCS Special Cadre',
        sector: CircularSector.bcs,
        deadline: DateTime.utc(2026, 11, 20),
        examDates: [
          CircularExamDate(
            id: 'exam-preli',
            circularId: 'circ-bcs',
            stage: 'preliminary',
            examDate: DateTime.utc(2026, 12, 8),
          ),
        ],
      ),
    ];
  }

  Future<
      ({
        FakeStudyPlanRepository planRepo,
        FakeMaterialRepository materialRepo,
        FakeProgressLogRepository logRepo,
      })> pumpStudyPlanApp(
    WidgetTester tester, {
    required Widget home,
    List<StudyPlan> initialPlans = const [],
    List<PrepMaterial>? initialMaterials,
    List<ProgressLog> initialLogs = const [],
    List<Circular>? initialCirculars,
    Locale locale = const Locale('en'),
    ThemeMode themeMode = ThemeMode.dark,
    Size viewportSize = const Size(1200, 1200),
  }) async {
    tester.view.physicalSize = viewportSize;
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    SharedPreferences.setMockInitialValues({
      kLocaleStorageKey: locale.languageCode,
      kUseBanglaDigitsStorageKey: locale.languageCode == 'bn',
    });
    final prefs = await SharedPreferences.getInstance();

    final subjectRepo =
        FakeSubjectRepository(initialSubjects: sampleSubjects());
    final materialRepo = FakeMaterialRepository(
      initialMaterials: initialMaterials ??
          const [
            PrepMaterial(
              id: 'mat-1',
              userId: 'user-1',
              subjectId: 'sub-bn',
              title: 'Bangla Textbook',
              totalUnits: 300,
              completedUnits: 40,
            ),
            PrepMaterial(
              id: 'mat-2',
              userId: 'user-1',
              subjectId: 'sub-bn',
              title: 'Optional Grammar Notes',
              kind: MaterialKind.notes,
              totalUnits: 100,
            ),
          ],
    );
    final logRepo = FakeProgressLogRepository(
      materialRepository: materialRepo,
      initialLogs: initialLogs,
    );
    final planRepo = FakeStudyPlanRepository(initialPlans: initialPlans);
    final circularRepo = FakeCircularRepository(
      clock: () => fixedNow,
      initialItems: initialCirculars ?? sampleCirculars(),
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
          materialCoverRepositoryProvider.overrideWithValue(
            FakeMaterialCoverRepository(),
          ),
          prepTemplateRepositoryProvider.overrideWithValue(
            FakePrepTemplateRepository(),
          ),
        ],
        child: MaterialApp(
          theme: AppTheme.light(),
          darkTheme: AppTheme.dark(),
          themeMode: themeMode,
          locale: locale,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(body: home),
        ),
      ),
    );
    await tester.pumpAndSettle();
    return (planRepo: planRepo, materialRepo: materialRepo, logRepo: logRepo);
  }

  Future<void> tapVisible(WidgetTester tester, Finder finder) async {
    await tester.ensureVisible(finder);
    await tester.pumpAndSettle();
    await tester.tap(finder);
    await tester.pumpAndSettle();
  }

  group('Phase 6C - Study Plan UI, Live Recalculation & Pace Options', () {
    testWidgets(
      'creates plan linked to circular exam date, renders combined & subject '
      'cards, and edits/deletes cleanly',
      (tester) async {
        final harness = await pumpStudyPlanApp(
          tester,
          home: const PrepScreen(selectedSubjectId: 'sub-bn'),
        );

        await tapVisible(
          tester,
          find.byKey(const ValueKey('open-study-plan-button')),
        );
        expect(
          find.byKey(const ValueKey('study-plan-form-dialog')),
          findsOneWidget,
        );

        // Link circular & verify exam stage chip updates target date.
        await tester.tap(
          find.byKey(const ValueKey('study-plan-circular-dropdown')),
        );
        await tester.pumpAndSettle();
        await tester.tap(find.text('48th BCS Special Cadre').last);
        await tester.pumpAndSettle();
        expect(
          find.byKey(const ValueKey('study-plan-exam-stage-exam-preli')),
          findsOneWidget,
        );
        expect(find.textContaining('8 Dec 2026'), findsOneWidget);

        // Select 1 rest day per week and max pace 50.
        await tapVisible(
          tester,
          find.byKey(const ValueKey('study-plan-rest-1')),
        );
        await tester.enterText(
          find.byKey(const ValueKey('study-plan-max-pace-field')),
          '50',
        );
        await tapVisible(
          tester,
          find.byKey(const ValueKey('study-plan-save-button')),
        );

        expect(harness.planRepo.plans, hasLength(1));
        expect(harness.planRepo.plans.first.circularId, 'circ-bcs');
        expect(harness.planRepo.plans.first.examDateId, 'exam-preli');
        expect(harness.planRepo.plans.first.restDaysPerWeek, 1);
        expect(harness.planRepo.plans.first.finishBufferDays, 7);

        expect(
          find.byKey(const ValueKey('study-plan-card-all')),
          findsOneWidget,
        );
        expect(
          find.text('48th BCS Special Cadre (preliminary)'),
          findsOneWidget,
        );

        // Delete plan with confirmation.
        await tapVisible(
          tester,
          find.byKey(const ValueKey('delete-study-plan-all')),
        );
        await tester.tap(
          find.byKey(
            ValueKey(
              'confirm-delete-study-plan-${harness.planRepo.plans.first.id}',
            ),
          ),
        );
        await tester.pumpAndSettle();
        expect(harness.planRepo.plans, isEmpty);
      },
    );

    testWidgets(
      'displays catch-up message, recalculates automatically on progress log, '
      'and handles all pace-limit recovery options without hiding high targets',
      (tester) async {
        // Plan started Nov 1, finishes Dec 1 (target Dec 8 - 7 buffer).
        // Today is Nov 6 -> 25 days left, 5 elapsed.
        // Total = 300, completed before today = 40 -> 10 missed -> +0.4/day,
        // today's target = ceil(260/25) = 11!
        final initialPlans = [
          StudyPlan(
            id: 'plan-all',
            userId: 'user-1',
            startDate: DateTime.utc(2026, 11),
            targetDate: DateTime.utc(2026, 12, 8),
            maxDailyPace: 25,
          ),
          StudyPlan(
            id: 'plan-bn',
            userId: 'user-1',
            subjectId: 'sub-bn',
            startDate: DateTime.utc(2026, 11),
            targetDate: DateTime.utc(2026, 11, 20), // Nov 13 finish = 7d
            restDaysPerWeek: 1, // 6 study days left for 360 rem = 60/day!
            maxDailyPace: 25,
          ),
        ];

        await pumpStudyPlanApp(
          tester,
          home: const PrepScreen(selectedSubjectId: 'sub-bn'),
          initialPlans: initialPlans,
          initialLogs: [
            ProgressLog(
              id: 'log-init',
              userId: 'user-1',
              materialId: 'mat-1',
              unitsDone: 40,
              loggedOn: DateTime.utc(2026, 11, 2),
            ),
          ],
          initialMaterials: const [
            PrepMaterial(
              id: 'mat-1',
              userId: 'user-1',
              subjectId: 'sub-bn',
              title: 'Core Bangla Book',
              totalUnits: 300,
              completedUnits: 40,
            ),
            PrepMaterial(
              id: 'mat-2',
              userId: 'user-1',
              subjectId: 'sub-bn',
              title: 'Extra Grammar Notes',
              kind: MaterialKind.notes,
              totalUnits: 100,
            ),
          ],
        );

        // Both combined all-subjects card and subject card appear with rings.
        expect(
          find.byKey(const ValueKey('study-plan-card-all')),
          findsOneWidget,
        );
        expect(
          find.byKey(const ValueKey('study-plan-card-sub-bn')),
          findsWidgets,
        );
        expect(find.byType(AnimatedProgressRing), findsWidgets);
        expect(
          find.byKey(const ValueKey('study-plan-status-badge-sub-bn')),
          findsWidgets,
        );

        // Missed-day redistribution catch-up banner on behind plan.
        expect(
          find.byKey(const ValueKey('study-plan-catch-up-sub-bn')),
          findsWidgets,
        );

        // Pace warning box shows even when daily target exceeds pace cap.
        expect(
          find.byKey(const ValueKey('study-plan-pace-warning-sub-bn')),
          findsWidgets,
        );

        // Option 1: Turn a rest day into a study day.
        await tapVisible(
          tester,
          find.byKey(const ValueKey('pace-action-convert-rest-sub-bn')).first,
        );
        // Converted rest day increases study days left by +1 (6 -> 7 days).
        expect(find.text('7 days'), findsWidgets);

        // Option 3: Postpone lower-priority material and show restore chip.
        await tapVisible(
          tester,
          find.byKey(const ValueKey('pace-action-postpone-sub-bn')).first,
        );
        await tester.tap(
          find.byKey(const ValueKey('postpone-candidate-mat-2')),
        );
        await tester.pumpAndSettle();
        expect(
          find.byKey(const ValueKey('postponed-chip-mat-2')),
          findsWidgets,
        );

        // Option 2: Raise pace limit cleanly via dialog.
        await tapVisible(
          tester,
          find.byKey(const ValueKey('pace-action-raise-limit-sub-bn')).first,
        );
        await tester.enterText(
          find.byKey(const ValueKey('raise-pace-input-field')),
          '120',
        );
        await tester.tap(
          find.byKey(const ValueKey('raise-pace-confirm-button')),
        );
        await tester.pumpAndSettle();
        expect(
          find.byKey(const ValueKey('study-plan-pace-warning-sub-bn')),
          findsNothing,
        );

        // Log progress via controller -> live recalculation across cards.
        final container = ProviderScope.containerOf(
          tester.element(find.byType(StudyPlanCard).first),
        );
        final ok = await container
            .read(prepProgressLogControllerProvider.notifier)
            .logUnits(
              material: const PrepMaterial(
                id: 'mat-1',
                userId: 'user-1',
                subjectId: 'sub-bn',
                title: 'Core Bangla Book',
                totalUnits: 300,
                completedUnits: 40,
              ),
              units: 10,
              loggedOn: fixedNow,
            );
        expect(ok, isTrue);
        await tester.pumpAndSettle();

        // Snapshot immediately reflects today's logged units cleanly.
        final snapshots =
            container.read(studyPlanSnapshotsProvider).asData?.value ?? [];
        final bnSnap =
            snapshots.firstWhere((s) => s.plan.subjectId == 'sub-bn');
        expect(bnSnap.todayCompletedUnits, 10);
        expect(bnSnap.remainingUnits, 250);
      },
    );

    testWidgets(
      'DashboardTodayTargetCard renders empty state cleanly',
      (tester) async {
        await pumpStudyPlanApp(
          tester,
          home: const DashboardScreen(),
        );
        expect(
          find.byKey(const ValueKey('dashboard-today-target-card')),
          findsOneWidget,
        );
        expect(
          find.byKey(const ValueKey('dashboard-today-target-empty')),
          findsOneWidget,
        );
      },
    );

    testWidgets(
      'DashboardTodayTargetCard renders active Bangla state on 360x800 cleanly',
      (tester) async {
        await pumpStudyPlanApp(
          tester,
          home: const DashboardScreen(),
          locale: const Locale('bn'),
          themeMode: ThemeMode.light,
          viewportSize: const Size(360, 800),
          initialPlans: [
            StudyPlan(
              id: 'plan-bn-dash',
              userId: 'user-1',
              startDate: DateTime.utc(2026, 11),
              targetDate: DateTime.utc(2026, 12, 8),
              maxDailyPace: 8,
            ),
          ],
          initialMaterials: const [
            PrepMaterial(
              id: 'mat-1',
              userId: 'user-1',
              subjectId: 'sub-bn',
              title: 'বাংলা ব্যাকরণ',
              totalUnits: 300,
              completedUnits: 40,
            ),
          ],
        );

        expect(
          find.byKey(const ValueKey('dashboard-today-target-card')),
          findsOneWidget,
        );
        expect(
          find.byKey(const ValueKey('dashboard-today-target-ring')),
          findsOneWidget,
        );
        expect(
          find.byKey(const ValueKey('dashboard-today-target-status')),
          findsOneWidget,
        );
        expect(find.text('আজকের অধ্যয়নের লক্ষ্য'), findsOneWidget);
        expect(tester.takeException(), isNull);
      },
    );
  });
}
