import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:job_prep/core/localization/locale_controller.dart';
import 'package:job_prep/core/router/app_router.dart';
import 'package:job_prep/core/storage/preferences_provider.dart';
import 'package:job_prep/core/theme/app_theme.dart';
import 'package:job_prep/core/theme/reduce_effects_controller.dart';
import 'package:job_prep/core/widgets/animated_progress_bar.dart';
import 'package:job_prep/core/widgets/animated_progress_ring.dart';
import 'package:job_prep/features/auth/presentation/providers/auth_providers.dart';
import 'package:job_prep/features/circulars/domain/entities/circular.dart';
import 'package:job_prep/features/circulars/domain/entities/circular_enums.dart';
import 'package:job_prep/features/circulars/domain/entities/circular_exam_date.dart';
import 'package:job_prep/features/circulars/presentation/providers/circulars_providers.dart';
import 'package:job_prep/features/circulars/presentation/screens/inbox_screen.dart';
import 'package:job_prep/features/dashboard/presentation/screens/dashboard_screen.dart';
import 'package:job_prep/features/prep/domain/entities/prep_enums.dart';
import 'package:job_prep/features/prep/domain/entities/prep_material.dart';
import 'package:job_prep/features/prep/domain/entities/progress_log.dart';
import 'package:job_prep/features/prep/domain/entities/revision_item.dart';
import 'package:job_prep/features/prep/domain/entities/study_plan.dart';
import 'package:job_prep/features/prep/domain/entities/study_session.dart';
import 'package:job_prep/features/prep/domain/entities/subject.dart';
import 'package:job_prep/features/prep/domain/utils/revision_scheduler.dart';
import 'package:job_prep/features/prep/presentation/providers/mock_test_providers.dart';
import 'package:job_prep/features/prep/presentation/providers/prep_cover_providers.dart';
import 'package:job_prep/features/prep/presentation/providers/prep_providers.dart';
import 'package:job_prep/features/prep/presentation/providers/prep_template_providers.dart';
import 'package:job_prep/features/prep/presentation/providers/revision_providers.dart';
import 'package:job_prep/features/prep/presentation/providers/study_plan_providers.dart';
import 'package:job_prep/features/prep/presentation/providers/study_session_providers.dart';
import 'package:job_prep/features/prep/presentation/providers/study_timer_controller.dart';
import 'package:job_prep/features/prep/presentation/screens/prep_screen.dart';
import 'package:job_prep/features/prep/presentation/utils/timer_platform_adapter.dart';
import 'package:job_prep/features/today/presentation/providers/today_providers.dart';
import 'package:job_prep/features/today/presentation/screens/today_screen.dart';
import 'package:job_prep/l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../auth/fake_auth_repository.dart';
import '../circulars/fake_circular_repository.dart';
import '../prep/fake_material_and_log_repositories.dart';
import '../prep/fake_material_cover_repository.dart';
import '../prep/fake_mock_test_repository.dart';
import '../prep/fake_prep_template_repository.dart';
import '../prep/fake_revision_item_repository.dart';
import '../prep/fake_study_plan_repository.dart';
import '../prep/fake_study_session_repository.dart';
import '../prep/fake_subject_and_topic_repositories.dart';

class _NoopTimerPlatformAdapter implements StudyTimerPlatformAdapter {
  @override
  Future<void> playGentleChime() async {}

  @override
  void restoreTabTitle() {}

  @override
  void setTabTitle(String title) {}
}

void main() {
  setUpAll(() async {
    await initializeDateFormatting('en');
    await initializeDateFormatting('bn');
  });

  group('Phase 6I TodayScreen - Ordering, Live Updates & Empty States', () {
    testWidgets(
      'displays sections in exact order and updates live on quick log, '
      'revision completion, and timer finish',
      (tester) async {
        var now = DateTime(2026, 11, 12, 10);
        tester.view.physicalSize = const Size(1280, 1600);
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
        final authRepo = FakeAuthRepository.authenticated();
        addTearDown(authRepo.dispose);

        const subMath = Subject(
          id: 'sub-math',
          userId: 'user-1',
          name: 'Mathematics',
        );
        const subBangla = Subject(
          id: 'sub-bn',
          userId: 'user-1',
          name: 'Bangla Literature',
        );
        const matMath = PrepMaterial(
          id: 'mat-math',
          userId: 'user-1',
          subjectId: 'sub-math',
          title: 'Geometry Bank',
          totalUnits: 300,
          completedUnits: 100,
        );
        const matBangla = PrepMaterial(
          id: 'mat-bn',
          userId: 'user-1',
          subjectId: 'sub-bn',
          title: 'Sahitya Path',
          totalUnits: 200,
          completedUnits: 140,
        );

        final planMath = StudyPlan(
          id: 'plan-math',
          userId: 'user-1',
          subjectId: 'sub-math',
          startDate: DateTime.utc(2026, 11, 10),
          targetDate: DateTime.utc(2026, 11, 29),
          initialCompletedUnits: 100,
        ); // 200 rem / 10 days = 20/day + missed catch-up!
        final planBangla = StudyPlan(
          id: 'plan-bn',
          userId: 'user-1',
          subjectId: 'sub-bn',
          startDate: DateTime.utc(2026, 11, 12),
          targetDate: DateTime.utc(2026, 11, 29),
          initialCompletedUnits: 140,
        ); // 60 rem / 10 days = 6/day

        final materialRepo = FakeMaterialRepository(
          initialMaterials: const [matMath, matBangla],
        );
        final logRepo = FakeProgressLogRepository(
          materialRepository: materialRepo,
          initialLogs: [
            ProgressLog(
              id: 'l-seed-1',
              materialId: 'mat-math',
              unitsDone: 100,
              loggedOn: DateTime.utc(2026, 11, 9),
            ),
            ProgressLog(
              id: 'l-seed-2',
              materialId: 'mat-bn',
              unitsDone: 140,
              loggedOn: DateTime.utc(2026, 11, 11),
            ),
          ],
          clock: () => now,
        );

        final overdueRev = RevisionItem(
          id: 'rev-overdue',
          userId: 'user-1',
          subjectId: 'sub-math',
          materialId: 'mat-math',
          referenceLabel: 'Theorem 12',
          dueOn: DateTime.utc(2026, 11, 10),
        );
        final todayRev = RevisionItem(
          id: 'rev-today',
          userId: 'user-1',
          subjectId: 'sub-bn',
          materialId: 'mat-bn',
          referenceLabel: 'Kobi Kazi Notes',
          dueOn: DateTime.utc(2026, 11, 12),
        );

        final revRepo = FakeRevisionItemRepository(
          initialItems: [overdueRev, todayRev],
          clock: () => now,
        );
        final sessionRepo = FakeStudySessionRepository(
          initialSessions: [
            StudySession(
              id: 'sess-morning',
              userId: 'user-1',
              subjectId: 'sub-math',
              startedAt: DateTime(2026, 11, 12, 8),
              endedAt: DateTime(2026, 11, 12, 8, 30),
              durationSeconds: 1800,
            ),
          ],
          clock: () => now,
        );
        final circularRepo = FakeCircularRepository(
          initialItems: [
            Circular(
              id: 'c-urgent',
              userId: 'user-1',
              title: '48th BCS Special Circular',
              organizationName: 'BPSC',
              sector: CircularSector.bcs,
              deadline: DateTime(2026, 11, 13, 18),
              examDates: [
                CircularExamDate(
                  id: 'ex-1',
                  circularId: 'c-urgent',
                  stage: 'preliminary',
                  examDate: DateTime(2026, 11, 18, 10),
                  venue: 'Dhaka College',
                ),
              ],
            ),
            const Circular(
              id: 'c-inbox',
              userId: 'user-1',
              title: 'bb.org.bd',
              circularUrl: 'https://bb.org.bd/jobs',
              workflowStatus: CircularWorkflowStatus.inbox,
              isQuickCapture: true,
            ),
          ],
          clock: () => now,
        );

        final container = ProviderContainer(
          overrides: [
            sharedPreferencesProvider.overrideWithValue(prefs),
            authRepositoryProvider.overrideWithValue(authRepo),
            circularNowProvider.overrideWithValue(() => now),
            todayOffsetProvider.overrideWithValue(const Duration(hours: 6)),
            circularRepositoryProvider.overrideWithValue(circularRepo),
            subjectRepositoryProvider.overrideWithValue(
              FakeSubjectRepository(
                initialSubjects: const [subMath, subBangla],
              ),
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
            mockTestRepositoryProvider.overrideWithValue(
              FakeMockTestRepository(clock: () => now),
            ),
            studyPlanRepositoryProvider.overrideWithValue(
              FakeStudyPlanRepository(
                initialPlans: [planMath, planBangla],
                clock: () => now,
              ),
            ),
            revisionItemRepositoryProvider.overrideWithValue(revRepo),
            studySessionRepositoryProvider.overrideWithValue(sessionRepo),
            studyTimerPlatformProvider
                .overrideWithValue(_NoopTimerPlatformAdapter()),
          ],
        );

        Future<void> disposeContainer() async {
          await tester.pumpWidget(const SizedBox.shrink());
          container.dispose();
          await tester.pump();
        }

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

        expect(find.byType(TodayScreen), findsOneWidget);

        // Assert exact top-to-bottom section order (9 sections).
        final orderedKeys = [
          'today-header-card',
          'today-do-next-card',
          'today-targets-card',
          'today-catch-up-card',
          'today-revision-card',
          'today-deadlines-card',
          'today-exams-card',
          'today-inbox-card',
          'today-time-card',
        ];
        var previousDy = -double.infinity;
        for (final key in orderedKeys) {
          final finder = find.byKey(ValueKey(key));
          expect(
            finder,
            findsOneWidget,
            reason: 'Expected $key on TodayScreen',
          );
          final top = tester.getTopLeft(finder).dy;
          expect(
            top,
            greaterThan(previousDy),
            reason: 'Expected $key below previous section',
          );
          previousDy = top;
        }

        // Verify Do this next chose circular deadline <= 2d (Priority 1).
        expect(
          find.byKey(const ValueKey('today-do-next-priority-circularDeadline')),
          findsOneWidget,
        );
        expect(
          find.descendant(
            of: find.byKey(const ValueKey('today-do-next-card')),
            matching: find.text('48th BCS Special Circular'),
          ),
          findsOneWidget,
        );

        // Quick log +10 units updates Mathematics count & progress live.
        await tester.ensureVisible(
          find.byKey(const ValueKey('today-target-quick-log-sub-math')),
        );
        await tester.tap(
          find.byKey(const ValueKey('today-target-quick-log-sub-math')),
        );
        await tester.pumpAndSettle();

        await tester.tap(
          find.byKey(const ValueKey('today-quick-log-preset-10')),
        );
        await tester.pumpAndSettle();
        await tester.tap(
          find.byKey(const ValueKey('today-quick-log-submit-btn')),
        );
        await tester.pumpAndSettle();

        expect(
          find.descendant(
            of: find.byKey(const ValueKey('today-target-row-sub-math')),
            matching: find.text('10 / 20 units'),
          ),
          findsOneWidget,
        );

        // Completing overdue revision updates Revision due count live (2 -> 1).
        await tester.ensureVisible(
          find.byKey(const ValueKey('today-revision-count-badge')),
        );
        expect(find.text('2 due'), findsOneWidget);
        await container.read(revisionControllerProvider.notifier).applyAction(
              item: overdueRev,
              action: RevisionReviewAction.easy,
            );
        await tester.pumpAndSettle();
        expect(find.text('1 due'), findsOneWidget);

        // Initial Time studied today = 30m; finish 25m timer -> 55m live!
        expect(
          find.descendant(
            of: find.byKey(const ValueKey('today-time-card')),
            matching: find.text('30m'),
          ),
          findsOneWidget,
        );
        await container
            .read(studyTimerControllerProvider.notifier)
            .startSession(
              subjectId: 'sub-math',
              materialId: 'mat-math',
              mode: StudySessionMode.focus,
            );
        now = now.add(const Duration(minutes: 25));
        await container
            .read(studyTimerControllerProvider.notifier)
            .finishActiveSession();
        await tester.pumpAndSettle();
        expect(
          find.descendant(
            of: find.byKey(const ValueKey('today-time-card')),
            matching: find.text('55m'),
          ),
          findsOneWidget,
        );

        // Review inbox button navigates to /inbox cleanly.
        await tester.ensureVisible(
          find.byKey(const ValueKey('today-review-inbox-btn')),
        );
        await tester.tap(find.byKey(const ValueKey('today-review-inbox-btn')));
        await tester.pumpAndSettle();
        expect(find.byType(InboxScreen), findsOneWidget);

        // Go back to Today, tap Start revision -> /prep/revision.
        router.go('/today');
        await tester.pumpAndSettle();
        await tester.ensureVisible(
          find.byKey(const ValueKey('today-start-revision-btn')),
        );
        await tester
            .tap(find.byKey(const ValueKey('today-start-revision-btn')));
        await tester.pumpAndSettle();
        expect(find.byType(PrepScreen), findsOneWidget);

        // Return to Today and tap Start timer on target row -> Focus timer.
        router.go('/today');
        await tester.pumpAndSettle();
        await tester.ensureVisible(
          find.byKey(const ValueKey('today-target-start-timer-sub-bn')),
        );
        await tester.tap(
          find.byKey(const ValueKey('today-target-start-timer-sub-bn')),
        );
        await tester.pumpAndSettle();
        expect(find.byKey(const ValueKey('study-timer-card')), findsOneWidget);

        await disposeContainer();
      },
    );

    testWidgets(
      'renders friendly empty states and opens Create study plan flow',
      (tester) async {
        final now = DateTime(2026, 11, 12, 19);
        tester.view.physicalSize = const Size(1000, 1400);
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
        final authRepo = FakeAuthRepository.authenticated();
        addTearDown(authRepo.dispose);

        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              sharedPreferencesProvider.overrideWithValue(prefs),
              authRepositoryProvider.overrideWithValue(authRepo),
              circularNowProvider.overrideWithValue(() => now),
              circularRepositoryProvider.overrideWithValue(
                FakeCircularRepository(clock: () => now),
              ),
              subjectRepositoryProvider.overrideWithValue(
                FakeSubjectRepository(),
              ),
              materialRepositoryProvider.overrideWithValue(
                FakeMaterialRepository(),
              ),
              progressLogRepositoryProvider.overrideWithValue(
                FakeProgressLogRepository(
                  materialRepository: FakeMaterialRepository(),
                  clock: () => now,
                ),
              ),
              studyPlanRepositoryProvider.overrideWithValue(
                FakeStudyPlanRepository(clock: () => now),
              ),
              revisionItemRepositoryProvider.overrideWithValue(
                FakeRevisionItemRepository(clock: () => now),
              ),
              studySessionRepositoryProvider.overrideWithValue(
                FakeStudySessionRepository(clock: () => now),
              ),
            ],
            child: MaterialApp(
              theme: AppTheme.light(),
              darkTheme: AppTheme.dark(),
              themeMode: ThemeMode.light,
              locale: const Locale('en'),
              localizationsDelegates: AppLocalizations.localizationsDelegates,
              supportedLocales: AppLocalizations.supportedLocales,
              home: const Scaffold(body: TodayScreen()),
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(
          find.byKey(const ValueKey('today-do-next-caught-up')),
          findsOneWidget,
        );
        expect(
          find.byKey(const ValueKey('today-targets-empty')),
          findsOneWidget,
        );
        expect(find.byKey(const ValueKey('today-catch-up-card')), findsNothing);
        expect(
          find.byKey(const ValueKey('today-revision-empty')),
          findsOneWidget,
        );
        expect(
          find.byKey(const ValueKey('today-deadlines-empty')),
          findsOneWidget,
        );
        expect(find.byKey(const ValueKey('today-exams-empty')), findsOneWidget);
        expect(find.text('Nothing waiting in Inbox'), findsOneWidget);
        expect(find.text('0m'), findsOneWidget);

        await tester.tap(find.byKey(const ValueKey('today-create-plan-btn')));
        await tester.pumpAndSettle();
        expect(
          find.byKey(const ValueKey('study-plan-form-dialog')),
          findsOneWidget,
        );
      },
    );

    testWidgets(
      'replays ring & progress bars when reopening Today and fits '
      'phone (360x800 Bangla), tablet (800x900), and desktop (1280x900)',
      (tester) async {
        final now = DateTime(2026, 11, 12, 9);
        const subMath = Subject(id: 's1', userId: 'u-1', name: 'Math');
        const matMath = PrepMaterial(
          id: 'm1',
          userId: 'u-1',
          subjectId: 's1',
          title: 'Book One',
          totalUnits: 300,
          completedUnits: 110,
        );
        final planMath = StudyPlan(
          id: 'p1',
          userId: 'u-1',
          subjectId: 's1',
          startDate: DateTime.utc(2026, 11, 10),
          targetDate: DateTime.utc(2026, 11, 29),
          initialCompletedUnits: 100,
        );

        Future<void> checkViewport({
          required Size size,
          required String localeCode,
          required bool testReplay,
        }) async {
          tester.view.physicalSize = size;
          tester.view.devicePixelRatio = 1.0;
          addTearDown(() {
            tester.view.resetPhysicalSize();
            tester.view.resetDevicePixelRatio();
          });

          SharedPreferences.setMockInitialValues({
            kReduceEffectsStorageKey: !testReplay,
            kLocaleStorageKey: localeCode,
          });
          final prefs = await SharedPreferences.getInstance();
          final authRepo = FakeAuthRepository.authenticated();
          addTearDown(authRepo.dispose);

          final matRepo =
              FakeMaterialRepository(initialMaterials: const [matMath]);
          final container = ProviderContainer(
            overrides: [
              sharedPreferencesProvider.overrideWithValue(prefs),
              authRepositoryProvider.overrideWithValue(authRepo),
              circularNowProvider.overrideWithValue(() => now),
              circularRepositoryProvider.overrideWithValue(
                FakeCircularRepository(clock: () => now),
              ),
              subjectRepositoryProvider.overrideWithValue(
                FakeSubjectRepository(initialSubjects: const [subMath]),
              ),
              materialRepositoryProvider.overrideWithValue(matRepo),
              progressLogRepositoryProvider.overrideWithValue(
                FakeProgressLogRepository(
                  materialRepository: matRepo,
                  initialLogs: [
                    ProgressLog(
                      id: 'l-init',
                      materialId: 'm1',
                      unitsDone: 100,
                      loggedOn: DateTime.utc(2026, 11, 9),
                    ),
                    ProgressLog(
                      id: 'l-today',
                      materialId: 'm1',
                      unitsDone: 10,
                      loggedOn: DateTime.utc(2026, 11, 12),
                    ),
                  ],
                  clock: () => now,
                ),
              ),
              studyPlanRepositoryProvider.overrideWithValue(
                FakeStudyPlanRepository(
                  initialPlans: [planMath],
                  clock: () => now,
                ),
              ),
              revisionItemRepositoryProvider.overrideWithValue(
                FakeRevisionItemRepository(clock: () => now),
              ),
              studySessionRepositoryProvider.overrideWithValue(
                FakeStudySessionRepository(clock: () => now),
              ),
            ],
          );

          final router = container.read(routerProvider);
          await tester.pumpWidget(
            UncontrolledProviderScope(
              container: container,
              child: MaterialApp.router(
                routerConfig: router,
                theme: AppTheme.light(),
                darkTheme: AppTheme.dark(),
                themeMode: ThemeMode.dark,
                locale: Locale(localeCode),
                localizationsDelegates: AppLocalizations.localizationsDelegates,
                supportedLocales: AppLocalizations.supportedLocales,
              ),
            ),
          );
          await tester.pumpAndSettle();

          expect(find.byType(TodayScreen), findsOneWidget);
          expect(tester.takeException(), isNull);

          if (testReplay) {
            final firstRing = tester.widget<AnimatedProgressRing>(
              find.byKey(const ValueKey('today-daily-progress-ring')),
            );
            final firstBar = tester.widget<AnimatedProgressBar>(
              find.byKey(const ValueKey('today-target-bar-s1')),
            );

            router.go('/dashboard');
            await tester.pumpAndSettle();
            expect(find.byType(DashboardScreen), findsOneWidget);

            router.go('/today');
            await tester.pump();
            await tester.pump(const Duration(milliseconds: 16));

            final secondRing = tester.widget<AnimatedProgressRing>(
              find.byKey(const ValueKey('today-daily-progress-ring')),
            );
            final secondBar = tester.widget<AnimatedProgressBar>(
              find.byKey(const ValueKey('today-target-bar-s1')),
            );
            expect(secondRing.replayKey, isNot(equals(firstRing.replayKey)));
            expect(secondBar.replayKey, isNot(equals(firstBar.replayKey)));
            await tester.pumpAndSettle();
          }

          await tester.pumpWidget(const SizedBox.shrink());
          container.dispose();
          await tester.pump();
        }

        await checkViewport(
          size: const Size(360, 800),
          localeCode: 'bn',
          testReplay: false,
        );
        await checkViewport(
          size: const Size(800, 900),
          localeCode: 'en',
          testReplay: false,
        );
        await checkViewport(
          size: const Size(1280, 900),
          localeCode: 'en',
          testReplay: true,
        );
      },
    );
  });
}
