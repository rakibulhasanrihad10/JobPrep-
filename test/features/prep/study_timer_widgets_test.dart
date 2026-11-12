import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:job_prep/core/localization/locale_controller.dart';
import 'package:job_prep/core/router/app_router.dart';
import 'package:job_prep/core/storage/preferences_provider.dart';
import 'package:job_prep/core/theme/app_theme.dart';
import 'package:job_prep/core/theme/reduce_effects_controller.dart';
import 'package:job_prep/features/auth/domain/entities/auth_user.dart';
import 'package:job_prep/features/auth/presentation/providers/auth_providers.dart';
import 'package:job_prep/features/circulars/domain/entities/circular.dart';
import 'package:job_prep/features/circulars/domain/entities/circular_filter.dart';
import 'package:job_prep/features/circulars/domain/repositories/circular_repository.dart';
import 'package:job_prep/features/circulars/presentation/providers/circulars_providers.dart';
import 'package:job_prep/features/prep/domain/entities/prep_enums.dart';
import 'package:job_prep/features/prep/domain/entities/prep_material.dart';
import 'package:job_prep/features/prep/domain/entities/progress_log.dart';
import 'package:job_prep/features/prep/domain/entities/study_session.dart';
import 'package:job_prep/features/prep/domain/entities/subject.dart';
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
import 'package:job_prep/features/prep/presentation/widgets/prep_tab_switcher.dart';
import 'package:job_prep/l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../auth/fake_auth_repository.dart';
import 'fake_material_and_log_repositories.dart';
import 'fake_material_cover_repository.dart';
import 'fake_mock_test_repository.dart';
import 'fake_prep_template_repository.dart';
import 'fake_revision_item_repository.dart';
import 'fake_study_plan_repository.dart';
import 'fake_study_session_repository.dart';
import 'fake_subject_and_topic_repositories.dart';

class _EmptyCircularRepository implements CircularRepository {
  @override
  Future<Circular> createCircular(Circular circular) =>
      throw UnimplementedError();

  @override
  Future<void> deleteCircular(String id) async {}

  @override
  Future<Circular?> getCircularById(String id) async => null;

  @override
  Future<List<Circular>> getCirculars({CircularFilter? filter}) async =>
      const <Circular>[];

  @override
  Future<Circular> updateCircular(Circular circular) =>
      throw UnimplementedError();
}

class _FakeTimerPlatformAdapter implements StudyTimerPlatformAdapter {
  final List<String> titles = <String>[];
  int restoreCount = 0;
  int chimeCount = 0;

  @override
  void setTabTitle(String title) => titles.add(title);

  @override
  void restoreTabTitle() => restoreCount += 1;

  @override
  Future<void> playGentleChime() async => chimeCount += 1;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

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
    name: 'English',
    color: 'info',
    icon: 'language',
    sortOrder: 1,
  );
  const matMath = PrepMaterial(
    id: 'mat-math',
    userId: 'u-1',
    subjectId: 'sub-math',
    title: 'Algebra Guide',
    totalUnits: 300,
    completedUnits: 100,
  );

  Future<ProviderContainer> pumpTimerTab(
    WidgetTester tester, {
    required DateTime Function() clock,
    required FakeSubjectRepository subjectRepo,
    required FakeMaterialRepository materialRepo,
    required FakeProgressLogRepository logRepo,
    required FakeRevisionItemRepository revisionRepo,
    required FakeStudySessionRepository sessionRepo,
    required _FakeTimerPlatformAdapter platform,
    Size viewport = const Size(1280, 900),
    ThemeMode themeMode = ThemeMode.dark,
    String localeCode = 'en',
    bool reduceEffects = true,
  }) async {
    tester.view.physicalSize = viewport;
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    SharedPreferences.setMockInitialValues({
      kReduceEffectsStorageKey: reduceEffects,
      kLocaleStorageKey: localeCode,
      kUseBanglaDigitsStorageKey: false,
      kTimerSoundEnabledKey: true,
    });
    final prefs = await SharedPreferences.getInstance();

    final container = ProviderContainer(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
        circularNowProvider.overrideWithValue(clock),
        circularRepositoryProvider
            .overrideWithValue(_EmptyCircularRepository()),
        subjectRepositoryProvider.overrideWithValue(subjectRepo),
        materialRepositoryProvider.overrideWithValue(materialRepo),
        progressLogRepositoryProvider.overrideWithValue(logRepo),
        materialCoverRepositoryProvider.overrideWithValue(
          FakeMaterialCoverRepository(),
        ),
        prepTemplateRepositoryProvider.overrideWithValue(
          FakePrepTemplateRepository(),
        ),
        mockTestRepositoryProvider.overrideWithValue(
          FakeMockTestRepository(clock: clock),
        ),
        studyPlanRepositoryProvider.overrideWithValue(
          FakeStudyPlanRepository(clock: clock),
        ),
        revisionItemRepositoryProvider.overrideWithValue(revisionRepo),
        studySessionRepositoryProvider.overrideWithValue(sessionRepo),
        studyTimerPlatformProvider.overrideWithValue(platform),
      ],
    );
    addTearDown(container.dispose);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          theme: AppTheme.light(),
          darkTheme: AppTheme.dark(),
          themeMode: themeMode,
          locale: Locale(localeCode),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const Scaffold(
            body: PrepScreen(initialTab: PrepSectionTab.timer),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    return container;
  }

  group('Phase 6H StudyTimer & Session Flows', () {
    testWidgets(
        'starts, pauses, resumes, finishes stopwatch session and saves '
        'progress log units plus revision item cleanly', (tester) async {
      var now = DateTime.utc(2026, 11, 11, 10);
      final subjectRepo = FakeSubjectRepository(initialSubjects: [subMath]);
      final materialRepo = FakeMaterialRepository(initialMaterials: [matMath]);
      final logRepo = FakeProgressLogRepository(
        initialLogs: [
          ProgressLog(
            id: 'seed-log-100',
            materialId: matMath.id,
            unitsDone: 100,
            loggedOn: DateTime.utc(2026, 11, 10),
          ),
        ],
        materialRepository: materialRepo,
        clock: () => now,
      );
      final revisionRepo = FakeRevisionItemRepository(clock: () => now);
      final sessionRepo = FakeStudySessionRepository(clock: () => now);
      final platform = _FakeTimerPlatformAdapter();

      final container = await pumpTimerTab(
        tester,
        clock: () => now,
        subjectRepo: subjectRepo,
        materialRepo: materialRepo,
        logRepo: logRepo,
        revisionRepo: revisionRepo,
        sessionRepo: sessionRepo,
        platform: platform,
      );

      // Select Stopwatch mode & pick material.
      await tester.tap(find.byKey(const ValueKey('timer-mode-stopwatch')));
      await tester.pumpAndSettle();
      await tester.tap(
        find.byKey(const ValueKey('timer-material-sub-math-null')),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('Algebra Guide').last);
      await tester.pumpAndSettle();

      // Start session.
      await tester.tap(find.byKey(const ValueKey('timer-start-button')));
      await tester.pumpAndSettle();
      expect(sessionRepo.sessions.single.endedAt, isNull);
      expect(sessionRepo.sessions.single.materialId, matMath.id);

      // Advance 12m, then pause.
      now = DateTime.utc(2026, 11, 11, 10, 12);
      container.read(studyTimerControllerProvider.notifier).refreshTick();
      await tester.pump();
      expect(
        tester
            .widget<Text>(find.byKey(const ValueKey('timer-clock-display')))
            .data,
        '12:00',
      );

      await tester.tap(find.byKey(const ValueKey('timer-pause-button')));
      await tester.pumpAndSettle();
      expect(sessionRepo.sessions.single.pauseIntervals.length, 1);
      expect(sessionRepo.sessions.single.pauseIntervals.single.isOpen, isTrue);

      // Wait 5m paused -> clock stays at 12:00; resume + study 3m -> 15:00.
      now = DateTime.utc(2026, 11, 11, 10, 17);
      await tester.tap(find.byKey(const ValueKey('timer-resume-button')));
      await tester.pumpAndSettle();
      expect(
        sessionRepo.sessions.single.pauseIntervals.single.resumedAt,
        DateTime.utc(2026, 11, 11, 10, 17),
      );

      now = DateTime.utc(2026, 11, 11, 10, 20);
      container.read(studyTimerControllerProvider.notifier).refreshTick();
      await tester.pump();
      expect(find.text('15:00'), findsOneWidget);

      // Finish -> opens Finish sheet displaying 15:00, log 20 units & flag.
      await tester.tap(find.byKey(const ValueKey('timer-finish-button')));
      await tester.pumpAndSettle();
      expect(find.byKey(const ValueKey('timer-finish-dialog')), findsOneWidget);
      expect(
        tester
            .widget<Text>(
              find.byKey(const ValueKey('timer-finish-duration-text')),
            )
            .data,
        '15:00',
      );

      await tester.enterText(
        find.byKey(const ValueKey('timer-finish-note-field')),
        'Quadratic inequalities',
      );
      await tester.enterText(
        find.byKey(const ValueKey('timer-finish-units-field')),
        '20',
      );
      await tester.tap(
        find.byKey(const ValueKey('timer-finish-revision-checkbox')),
      );
      await tester.pump();
      await tester.tap(find.byKey(const ValueKey('timer-finish-save-btn')));
      await tester.pumpAndSettle();

      // Session finalized, units logged to Algebra Guide, composer open.
      final completed = sessionRepo.sessions.single;
      final savedLogs = await logRepo.getLogsForMaterial(matMath.id);
      expect(completed.endedAt, DateTime.utc(2026, 11, 11, 10, 20));
      expect(completed.durationSeconds, 15 * 60);
      expect(completed.note, 'Quadratic inequalities');
      expect(materialRepo.materials.single.completedUnits, 120);
      expect(savedLogs.length, 2);
      expect(savedLogs.first.unitsDone, 20);
      expect(
        find.byKey(const ValueKey('timer-finish-saved-dialog')),
        findsOneWidget,
      );

      // Flag a revision mark via inline Phase 6G composer without adding units.
      await tester.enterText(
        find.byKey(const ValueKey('revision-ref-field')),
        'p. 44 Exercise 7',
      );
      await tester.tap(find.byKey(const ValueKey('revision-add-flag-button')));
      await tester.pumpAndSettle();
      expect(revisionRepo.items.length, 1);
      expect(revisionRepo.items.single.progressLogId, savedLogs.first.id);
      expect(revisionRepo.items.single.source, RevisionSource.log);

      await tester.tap(find.byKey(const ValueKey('timer-finish-done-btn')));
      await tester.pumpAndSettle();
      expect(find.byKey(const ValueKey('session-row-sess-1')), findsOneWidget);
    });

    testWidgets(
        'configures Focus round, updates browser tab title, shows gentle '
        'alert & plays chime when Focus ends, and supports manual edit/delete',
        (tester) async {
      var now = DateTime.utc(2026, 11, 11, 8);
      final subjectRepo =
          FakeSubjectRepository(initialSubjects: [subMath, subEng]);
      final materialRepo = FakeMaterialRepository(initialMaterials: [matMath]);
      final logRepo = FakeProgressLogRepository(
        initialLogs: [
          ProgressLog(
            id: 'seed-log-100',
            materialId: matMath.id,
            unitsDone: 100,
            loggedOn: DateTime.utc(2026, 11, 10),
          ),
        ],
        materialRepository: materialRepo,
        clock: () => now,
      );
      final revisionRepo = FakeRevisionItemRepository(clock: () => now);
      final sessionRepo = FakeStudySessionRepository(clock: () => now);
      final platform = _FakeTimerPlatformAdapter();

      final container = await pumpTimerTab(
        tester,
        clock: () => now,
        subjectRepo: subjectRepo,
        materialRepo: materialRepo,
        logRepo: logRepo,
        revisionRepo: revisionRepo,
        sessionRepo: sessionRepo,
        platform: platform,
      );

      // Configure 10m focus / 2m short break / 12m long break.
      await tester.tap(find.byKey(const ValueKey('timer-config-button')));
      await tester.pumpAndSettle();
      await tester.enterText(
        find.byKey(const ValueKey('timer-config-focus-field')),
        '10',
      );
      await tester.enterText(
        find.byKey(const ValueKey('timer-config-short-field')),
        '2',
      );
      await tester.enterText(
        find.byKey(const ValueKey('timer-config-long-field')),
        '12',
      );
      await tester.tap(find.byKey(const ValueKey('timer-config-save-btn')));
      await tester.pumpAndSettle();
      expect(find.text('10:00'), findsOneWidget);

      await tester.tap(find.byKey(const ValueKey('timer-start-button')));
      await tester.pumpAndSettle();
      expect(platform.titles.last, contains('10:00'));

      // Complete 10m Focus round -> gentle alert banner & sound chime trigger.
      now = DateTime.utc(2026, 11, 11, 8, 10);
      container.read(studyTimerControllerProvider.notifier).refreshTick();
      await tester.pumpAndSettle();
      expect(
        find.byKey(const ValueKey('timer-round-alert-banner')),
        findsOneWidget,
      );
      expect(platform.chimeCount, 1);

      // Start short break (2:00) & discard active open timer cleanly.
      await tester.tap(find.byKey(const ValueKey('timer-alert-advance-btn')));
      await tester.pumpAndSettle();
      expect(find.text('02:00'), findsOneWidget);

      await tester.tap(find.byKey(const ValueKey('timer-discard-button')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('timer-discard-confirm-btn')));
      await tester.pumpAndSettle();
      expect(sessionRepo.sessions, isEmpty);

      // Add a manual session (1h 30m), edit it to 2h 0m, then delete it.
      await tester.tap(find.byKey(const ValueKey('timer-manual-button')));
      await tester.pumpAndSettle();
      await tester.enterText(
        find.byKey(const ValueKey('session-form-hours-field')),
        '1',
      );
      await tester.enterText(
        find.byKey(const ValueKey('session-form-minutes-field')),
        '30',
      );
      await tester.enterText(
        find.byKey(const ValueKey('session-form-note-field')),
        'Library workbook',
      );
      await tester.tap(find.byKey(const ValueKey('session-form-save-btn')));
      await tester.pumpAndSettle();

      expect(sessionRepo.sessions.length, 1);
      expect(sessionRepo.sessions.single.mode, StudySessionMode.manual);
      expect(sessionRepo.sessions.single.durationSeconds, 5400);
      final savedId = sessionRepo.sessions.single.id;
      expect(find.byKey(ValueKey('session-row-$savedId')), findsOneWidget);

      await tester.tap(find.byKey(ValueKey('session-edit-$savedId')));
      await tester.pumpAndSettle();
      await tester.enterText(
        find.byKey(const ValueKey('session-form-hours-field')),
        '2',
      );
      await tester.enterText(
        find.byKey(const ValueKey('session-form-minutes-field')),
        '0',
      );
      await tester.tap(find.byKey(const ValueKey('session-form-save-btn')));
      await tester.pumpAndSettle();
      expect(sessionRepo.sessions.single.durationSeconds, 7200);

      await tester.tap(find.byKey(ValueKey('session-delete-$savedId')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(ValueKey('session-delete-confirm-$savedId')));
      await tester.pumpAndSettle();
      expect(sessionRepo.sessions, isEmpty);
    });

    testWidgets(
        'renders compact floating timer control on every screen and fits '
        '360x800 Bangla layout', (tester) async {
      final now = DateTime.utc(2026, 11, 11, 11);
      final fakeAuth = FakeAuthRepository.authenticated(
        const AuthUser(id: 'u-1', email: 'u@example.test'),
      );
      addTearDown(fakeAuth.dispose);

      final openSession = StudySession(
        id: 'open-1',
        userId: 'u-1',
        subjectId: subMath.id,
        startedAt: DateTime.utc(2026, 11, 11, 10, 50),
        phaseStartedAt: DateTime.utc(2026, 11, 11, 10, 50),
        targetDurationSeconds: 1500,
        pomodoroRound: 1,
        pomodoroPhase: PomodoroPhase.focus,
      );
      final sessionRepo = FakeStudySessionRepository(
        initialSessions: [openSession],
        clock: () => now,
      );
      final platform = _FakeTimerPlatformAdapter();

      Future<Future<void> Function()> pumpShell({
        required Size viewport,
        required String localeCode,
        required String route,
      }) async {
        tester.view.physicalSize = viewport;
        tester.view.devicePixelRatio = 1.0;
        addTearDown(() {
          tester.view.resetPhysicalSize();
          tester.view.resetDevicePixelRatio();
        });

        SharedPreferences.setMockInitialValues({
          kReduceEffectsStorageKey: true,
          kLocaleStorageKey: localeCode,
        });
        final prefs = await SharedPreferences.getInstance();
        final materialRepo =
            FakeMaterialRepository(initialMaterials: [matMath]);

        final container = ProviderContainer(
          overrides: [
            sharedPreferencesProvider.overrideWithValue(prefs),
            initialRouteLocationProvider.overrideWithValue(route),
            circularNowProvider.overrideWithValue(() => now),
            authRepositoryProvider.overrideWithValue(fakeAuth),
            circularRepositoryProvider
                .overrideWithValue(_EmptyCircularRepository()),
            subjectRepositoryProvider.overrideWithValue(
              FakeSubjectRepository(initialSubjects: [subMath]),
            ),
            materialRepositoryProvider.overrideWithValue(materialRepo),
            progressLogRepositoryProvider.overrideWithValue(
              FakeProgressLogRepository(
                materialRepository: materialRepo,
                clock: () => now,
              ),
            ),
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
              FakeStudyPlanRepository(clock: () => now),
            ),
            revisionItemRepositoryProvider.overrideWithValue(
              FakeRevisionItemRepository(clock: () => now),
            ),
            studySessionRepositoryProvider.overrideWithValue(sessionRepo),
            studyTimerPlatformProvider.overrideWithValue(platform),
          ],
        );
        var disposed = false;
        addTearDown(() {
          if (!disposed) {
            container.dispose();
          }
        });

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
        expect(
          find.byKey(const ValueKey('study-timer-floating-bar')),
          findsOneWidget,
        );
        router.go('/settings');
        await tester.pumpAndSettle();
        expect(
          find.byKey(const ValueKey('study-timer-floating-bar')),
          findsOneWidget,
        );

        return () async {
          await tester.pumpWidget(const SizedBox.shrink());
          if (!disposed) {
            disposed = true;
            container.dispose();
          }
          await tester.pump();
        };
      }

      final disposeDesktop = await pumpShell(
        viewport: const Size(1280, 900),
        localeCode: 'en',
        route: '/dashboard',
      );
      expect(find.text('15:00'), findsOneWidget);
      await tester.tap(find.byKey(const ValueKey('floating-timer-pause-btn')));
      await tester.pumpAndSettle();
      expect(
        find.byKey(const ValueKey('floating-timer-resume-btn')),
        findsOneWidget,
      );
      await tester.tap(find.byKey(const ValueKey('floating-timer-resume-btn')));
      await tester.pumpAndSettle();
      expect(
        find.byKey(const ValueKey('floating-timer-pause-btn')),
        findsOneWidget,
      );
      await tester.tap(find.byKey(const ValueKey('floating-timer-open-btn')));
      await tester.pumpAndSettle();
      expect(find.byKey(const ValueKey('timer-clock-display')), findsOneWidget);
      expect(tester.takeException(), isNull);
      await disposeDesktop();

      final disposeMobile = await pumpShell(
        viewport: const Size(360, 800),
        localeCode: 'bn',
        route: '/prep/timer',
      );
      expect(tester.takeException(), isNull);
      await disposeMobile();
    });
  });
}
