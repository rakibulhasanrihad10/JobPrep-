import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:job_prep/core/localization/locale_controller.dart';
import 'package:job_prep/core/router/app_router.dart';
import 'package:job_prep/core/storage/preferences_provider.dart';
import 'package:job_prep/core/theme/app_theme_tokens.dart';
import 'package:job_prep/core/theme/reduce_effects_controller.dart';
import 'package:job_prep/core/widgets/animated_counter.dart';
import 'package:job_prep/core/widgets/animated_progress_ring.dart';
import 'package:job_prep/features/auth/presentation/providers/auth_providers.dart';
import 'package:job_prep/features/circulars/domain/entities/application_checklist.dart';
import 'package:job_prep/features/circulars/domain/entities/circular.dart';
import 'package:job_prep/features/circulars/domain/entities/circular_enums.dart';
import 'package:job_prep/features/circulars/domain/entities/circular_exam_date.dart';
import 'package:job_prep/features/circulars/presentation/providers/circulars_providers.dart';
import 'package:job_prep/features/circulars/presentation/screens/circular_detail_screen.dart';
import 'package:job_prep/features/circulars/presentation/widgets/circular_badges.dart';
import 'package:job_prep/features/dashboard/presentation/screens/dashboard_screen.dart';
import 'package:job_prep/features/prep/domain/entities/prep_material.dart';
import 'package:job_prep/features/prep/domain/entities/progress_log.dart';
import 'package:job_prep/features/prep/domain/entities/subject.dart';
import 'package:job_prep/features/prep/presentation/providers/prep_cover_providers.dart';
import 'package:job_prep/features/prep/presentation/providers/prep_providers.dart';
import 'package:job_prep/features/prep/presentation/providers/prep_template_providers.dart';
import 'package:job_prep/features/prep/presentation/screens/prep_screen.dart';
import 'package:job_prep/features/prep/presentation/screens/prep_subject_detail_screen.dart';
import 'package:job_prep/features/prep/presentation/widgets/material_logs_dialog.dart';
import 'package:job_prep/main.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../auth/fake_auth_repository.dart';
import '../circulars/fake_circular_repository.dart';
import '../prep/fake_material_and_log_repositories.dart';
import '../prep/fake_material_cover_repository.dart';
import '../prep/fake_prep_template_repository.dart';
import '../prep/fake_subject_and_topic_repositories.dart';

void main() {
  final fixedNow = DateTime.utc(2026, 11, 10, 9);

  setUpAll(() async {
    await initializeDateFormatting('en');
    await initializeDateFormatting('bn');
  });

  List<Circular> sampleCirculars() {
    return [
      Circular(
        id: 'c-urgent',
        userId: 'user-1',
        title: '48th BCS Special Cadre',
        organizationName: 'Bangladesh Public Service Commission',
        sector: CircularSector.bcs,
        deadline: DateTime.utc(2026, 11, 11, 18),
        applicationStatus: ApplicationStatus.applied,
        priority: CircularPriority.high,
        examDates: [
          CircularExamDate(
            id: 'e-today',
            circularId: 'c-urgent',
            stage: 'preliminary',
            examDate: DateTime.utc(2026, 11, 10, 14),
            venue: 'Dhaka College',
          ),
        ],
      ),
      Circular(
        id: 'c-amber',
        userId: 'user-1',
        title: 'Combined Bank Senior Officer',
        organizationName: 'Bankers Selection Committee',
        sector: CircularSector.bank,
        deadline: DateTime.utc(2026, 11, 15, 18),
        workflowStatus: CircularWorkflowStatus.inbox,
        checklist: const ApplicationChecklist(submitted: true),
        examDates: [
          CircularExamDate(
            id: 'e-4d',
            circularId: 'c-amber',
            stage: 'written',
            examDate: DateTime.utc(2026, 11, 14, 10),
          ),
        ],
      ),
      Circular(
        id: 'c-green',
        userId: 'user-1',
        title: 'Assistant Software Engineer',
        organizationName: 'ICT Division',
        sector: CircularSector.private,
        deadline: DateTime.utc(2026, 11, 22, 18),
        workflowStatus: CircularWorkflowStatus.examUpcoming,
        examDates: [
          CircularExamDate(
            id: 'e-20d',
            circularId: 'c-green',
            stage: 'viva',
            examDate: DateTime.utc(2026, 11, 30, 10),
          ),
        ],
      ),
      Circular(
        id: 'c-arch',
        userId: 'user-1',
        title: 'Archived Old Circular',
        deadline: DateTime.utc(2026, 11, 12, 18),
        workflowStatus: CircularWorkflowStatus.archived,
      ),
    ];
  }

  List<Subject> sampleSubjects() {
    return const [
      Subject(
        id: 'sub-bn',
        userId: 'user-1',
        name: 'Bengali',
        examType: 'BCS',
      ),
      Subject(
        id: 'sub-en',
        userId: 'user-1',
        name: 'English',
        color: 'info',
        icon: 'language',
        examType: 'BCS',
        sortOrder: 1,
      ),
    ];
  }

  List<PrepMaterial> sampleMaterials() {
    return const [
      PrepMaterial(
        id: 'mat-1',
        userId: 'user-1',
        subjectId: 'sub-bn',
        title: 'অগ্রদূত বাংলা সাহিত্য',
        totalUnits: 400,
        completedUnits: 120,
      ),
      PrepMaterial(
        id: 'mat-2',
        userId: 'user-1',
        subjectId: 'sub-en',
        title: 'Cliffs TOEFL Grammar',
        totalUnits: 200,
        completedUnits: 120,
      ),
    ];
  }

  List<ProgressLog> sampleLogs() {
    return [
      ProgressLog(
        id: 'log-1',
        userId: 'user-1',
        materialId: 'mat-2',
        unitsDone: 25,
        loggedOn: DateTime.utc(2026, 11, 6),
      ),
      ProgressLog(
        id: 'log-2',
        userId: 'user-1',
        materialId: 'mat-1',
        unitsDone: 40,
        loggedOn: DateTime.utc(2026, 11, 9),
        note: 'Completed medieval literature chapter',
      ),
    ];
  }

  Future<FakeAuthRepository> pumpDashboardApp(
    WidgetTester tester, {
    required Size viewportSize,
    String locale = 'en',
    bool reduceEffects = false,
    bool populated = true,
  }) async {
    tester.view.physicalSize = viewportSize;
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    SharedPreferences.setMockInitialValues({
      kLocaleStorageKey: locale,
      kUseBanglaDigitsStorageKey: locale == 'bn',
      kReduceEffectsStorageKey: reduceEffects,
    });
    final prefs = await SharedPreferences.getInstance();
    final authRepo = FakeAuthRepository.authenticated();
    addTearDown(authRepo.dispose);

    final circularRepo = FakeCircularRepository(
      clock: () => fixedNow,
      initialItems: populated ? sampleCirculars() : const [],
    );
    final subjectRepo = FakeSubjectRepository(
      initialSubjects: populated ? sampleSubjects() : const [],
    );
    final materialRepo = FakeMaterialRepository(
      initialMaterials: populated ? sampleMaterials() : const [],
    );
    final logRepo = FakeProgressLogRepository(
      materialRepository: materialRepo,
      initialLogs: populated ? sampleLogs() : const [],
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
          initialRouteLocationProvider.overrideWithValue('/dashboard'),
          authRepositoryProvider.overrideWithValue(authRepo),
          circularNowProvider.overrideWithValue(() => fixedNow),
          circularRepositoryProvider.overrideWithValue(circularRepo),
          subjectRepositoryProvider.overrideWithValue(subjectRepo),
          materialRepositoryProvider.overrideWithValue(materialRepo),
          progressLogRepositoryProvider.overrideWithValue(logRepo),
          topicRepositoryProvider.overrideWithValue(FakeTopicRepository()),
          materialCoverRepositoryProvider.overrideWithValue(
            FakeMaterialCoverRepository(),
          ),
          prepTemplateRepositoryProvider.overrideWithValue(
            FakePrepTemplateRepository(),
          ),
          materialCoverPreviewImageBuilderProvider.overrideWithValue(
            (context, uri) {
              final colors = context.tokens.colors;
              return DecoratedBox(
                decoration: BoxDecoration(color: colors.goldAccentSubtle),
                child: Icon(Icons.menu_book, color: colors.goldAccent),
              );
            },
          ),
        ],
        child: const JobPrepApp(),
      ),
    );
    await tester.pumpAndSettle();
    return authRepo;
  }

  group('DashboardScreen Widget Tests', () {
    testWidgets(
      'displays computed metrics, upcoming deadlines with color bands, '
      'upcoming exams, and continue studying card on desktop',
      (tester) async {
        await pumpDashboardApp(tester, viewportSize: const Size(1280, 960));

        expect(find.byType(DashboardScreen), findsOneWidget);
        expect(
          find.byKey(const ValueKey('dashboard-new-user-welcome-card')),
          findsNothing,
        );

        // Precomputed KPI metrics from DashboardSummary:
        // deadlinesThisWeek = 2, inbox = 1, exams14d = 2,
        // submitted = 3, overallPrep = (120 + 150) / (400 + 200) = 45%
        expect(
          find.descendant(
            of: find.byKey(const ValueKey('dashboard-metric-deadlines-week')),
            matching: find.text('2'),
          ),
          findsOneWidget,
        );
        expect(
          find.descendant(
            of: find.byKey(const ValueKey('dashboard-metric-inbox')),
            matching: find.text('1'),
          ),
          findsOneWidget,
        );
        expect(
          find.descendant(
            of: find.byKey(const ValueKey('dashboard-metric-exams-14d')),
            matching: find.text('2'),
          ),
          findsOneWidget,
        );
        expect(
          find.descendant(
            of: find.byKey(const ValueKey('dashboard-metric-submitted')),
            matching: find.text('3'),
          ),
          findsOneWidget,
        );
        expect(
          find.descendant(
            of: find.byKey(const ValueKey('dashboard-metric-overall-prep')),
            matching: find.text('45%'),
          ),
          findsOneWidget,
        );

        // Upcoming deadlines list: archived excluded, chronological order
        expect(find.text('48th BCS Special Cadre'), findsWidgets);
        expect(find.text('Combined Bank Senior Officer'), findsWidgets);
        expect(find.text('Assistant Software Engineer'), findsWidgets);
        expect(find.text('Archived Old Circular'), findsNothing);
        expect(find.byType(CircularDeadlineCountdownBadge), findsNWidgets(3));

        final urgentTop = tester
            .getTopLeft(
              find.byKey(const ValueKey('dashboard-deadline-row-c-urgent')),
            )
            .dy;
        final amberTop = tester
            .getTopLeft(
              find.byKey(const ValueKey('dashboard-deadline-row-c-amber')),
            )
            .dy;
        final greenTop = tester
            .getTopLeft(
              find.byKey(const ValueKey('dashboard-deadline-row-c-green')),
            )
            .dy;
        expect(urgentTop, lessThan(amberTop));
        expect(amberTop, lessThan(greenTop));

        // Upcoming exams list: Today + In 4 days + In 20 days
        expect(find.text('Preliminary'), findsOneWidget);
        expect(find.text('Written'), findsOneWidget);
        expect(find.text('Viva'), findsOneWidget);
        expect(
          find.descendant(
            of: find.byKey(const ValueKey('dashboard-upcoming-exams-card')),
            matching: find.text('Today'),
          ),
          findsOneWidget,
        );
        expect(find.text('In 4 days'), findsOneWidget);
        expect(find.text('In 20 days'), findsOneWidget);

        // Continue studying shortcut shows mat-1 (latest log on Nov 9)
        expect(find.text('অগ্রদূত বাংলা সাহিত্য'), findsOneWidget);
        expect(find.text('Bengali'), findsOneWidget);
        expect(find.text('+40 pages on 9 Nov 2026'), findsOneWidget);
        expect(find.text('120 / 400 pages (30%)'), findsOneWidget);
      },
    );

    testWidgets(
      'tapping Continue studying navigates to subject and opens logs dialog '
      'for the most recently logged material',
      (tester) async {
        await pumpDashboardApp(tester, viewportSize: const Size(1280, 960));

        await tester.ensureVisible(
          find.byKey(const ValueKey('dashboard-continue-studying-button')),
        );
        await tester.tap(
          find.byKey(const ValueKey('dashboard-continue-studying-button')),
        );
        await tester.pumpAndSettle();

        expect(find.byType(PrepSubjectDetailScreen), findsOneWidget);
        expect(find.byType(MaterialLogsDialog), findsOneWidget);
        expect(find.text('অগ্রদূত বাংলা সাহিত্য'), findsWidgets);
      },
    );

    testWidgets(
      'tapping an upcoming deadline row opens the CircularDetailScreen',
      (tester) async {
        await pumpDashboardApp(tester, viewportSize: const Size(1280, 960));

        await tester.ensureVisible(
          find.byKey(const ValueKey('dashboard-deadline-row-c-urgent')),
        );
        await tester.tap(
          find.byKey(const ValueKey('dashboard-deadline-row-c-urgent')),
        );
        await tester.pumpAndSettle();

        expect(find.byType(CircularDetailScreen), findsOneWidget);
        expect(find.text('48th BCS Special Cadre'), findsWidgets);
      },
    );

    testWidgets(
      'counters and progress ring replay from zero on Dashboard tab return',
      (tester) async {
        await pumpDashboardApp(
          tester,
          viewportSize: const Size(1280, 960),
        );

        final firstRing = tester.widget<AnimatedProgressRing>(
          find.byType(AnimatedProgressRing),
        );
        final firstReplayKey = firstRing.replayKey;
        expect(
          find.descendant(
            of: find.byKey(const ValueKey('dashboard-metric-overall-prep')),
            matching: find.text('45%'),
          ),
          findsOneWidget,
        );

        // Switch away to Prep tab
        await tester.tap(find.text('Prep').first);
        await tester.pumpAndSettle();
        expect(find.byType(PrepScreen), findsOneWidget);
        expect(find.byType(DashboardScreen), findsNothing);

        // Return to Dashboard tab and check frame-0 state before settling
        await tester.tap(find.text('Dashboard').first);
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 16));

        expect(find.byType(DashboardScreen), findsOneWidget);
        final secondRing = tester.widget<AnimatedProgressRing>(
          find.byType(AnimatedProgressRing),
        );
        expect(secondRing.replayKey, isNot(equals(firstReplayKey)));

        // Counters/ring begin near zero rather than jumping straight to target
        expect(
          find.descendant(
            of: find.byKey(const ValueKey('dashboard-metric-overall-prep')),
            matching: find.text('45%'),
          ),
          findsNothing,
        );
        expect(
          find.descendant(
            of: find.byKey(const ValueKey('dashboard-metric-submitted')),
            matching: find.text('3'),
          ),
          findsNothing,
        );
        expect(
          tester
              .widgetList<AnimatedCounter>(find.byType(AnimatedCounter))
              .length,
          5,
        );

        // After settling, full values reach their targets again
        await tester.pumpAndSettle();
        expect(
          find.descendant(
            of: find.byKey(const ValueKey('dashboard-metric-overall-prep')),
            matching: find.text('45%'),
          ),
          findsOneWidget,
        );
        expect(
          find.descendant(
            of: find.byKey(const ValueKey('dashboard-metric-submitted')),
            matching: find.text('3'),
          ),
          findsOneWidget,
        );
      },
    );

    testWidgets(
      'renders new-user onboarding and empty states cleanly in English',
      (tester) async {
        await pumpDashboardApp(
          tester,
          viewportSize: const Size(1280, 960),
          populated: false,
        );

        expect(
          find.byKey(const ValueKey('dashboard-new-user-welcome-card')),
          findsOneWidget,
        );
        expect(find.text('Welcome to JobPrep'), findsOneWidget);
        expect(
          find.byKey(const ValueKey('dashboard-continue-empty')),
          findsOneWidget,
        );
        expect(
          find.byKey(const ValueKey('dashboard-deadlines-empty')),
          findsOneWidget,
        );
        expect(
          find.byKey(const ValueKey('dashboard-exams-empty')),
          findsOneWidget,
        );
        expect(tester.takeException(), isNull);
      },
    );

    testWidgets(
      'renders populated and empty Dashboard on 360x800 mobile in Bangla '
      'without overflow errors',
      (tester) async {
        await pumpDashboardApp(
          tester,
          viewportSize: const Size(360, 800),
          locale: 'bn',
        );
        expect(find.text('জবপ্রেপ ড্যাশবোর্ড'), findsOneWidget);
        expect(find.text('পড়াশোনা চালিয়ে যান'), findsOneWidget);
        expect(find.text('আসন্ন আবেদনের শেষ তারিখ'), findsOneWidget);
        expect(find.text('আসন্ন পরীক্ষাসমূহ'), findsOneWidget);
        expect(tester.takeException(), isNull);

        await pumpDashboardApp(
          tester,
          viewportSize: const Size(360, 800),
          locale: 'bn',
          populated: false,
        );
        expect(find.text('JobPrep-এ স্বাগতম'), findsOneWidget);
        expect(
          find.byKey(const ValueKey('dashboard-continue-empty')),
          findsOneWidget,
        );
        expect(tester.takeException(), isNull);

        // Verify navigation shortcut inside welcome card still works
        await tester.ensureVisible(
          find.byKey(const ValueKey('dashboard-welcome-setup-prep')),
        );
        await tester.tap(
          find.byKey(const ValueKey('dashboard-welcome-setup-prep')),
        );
        await tester.pumpAndSettle();
        expect(find.byType(PrepScreen), findsOneWidget);
      },
    );
  });
}
