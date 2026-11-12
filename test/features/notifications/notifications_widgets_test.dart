import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:job_prep/core/localization/locale_controller.dart';
import 'package:job_prep/core/router/app_router.dart';
import 'package:job_prep/core/theme/app_theme.dart';
import 'package:job_prep/core/theme/reduce_effects_controller.dart';
import 'package:job_prep/core/theme/theme_controller.dart';
import 'package:job_prep/features/auth/presentation/navigation/auth_redirect.dart';
import 'package:job_prep/features/auth/presentation/providers/auth_providers.dart';
import 'package:job_prep/features/circulars/domain/entities/circular.dart';
import 'package:job_prep/features/circulars/domain/entities/circular_exam_date.dart';
import 'package:job_prep/features/circulars/presentation/providers/circulars_providers.dart';
import 'package:job_prep/features/notifications/domain/entities/app_notification.dart';
import 'package:job_prep/features/notifications/domain/entities/notification_type.dart';
import 'package:job_prep/features/notifications/domain/entities/weekly_review_summary.dart';
import 'package:job_prep/features/notifications/domain/errors/notification_failure.dart';
import 'package:job_prep/features/notifications/presentation/providers/notifications_providers.dart';
import 'package:job_prep/features/notifications/presentation/screens/weekly_review_screen.dart';
import 'package:job_prep/features/notifications/presentation/widgets/notifications_bell_button.dart';
import 'package:job_prep/features/notifications/presentation/widgets/notifications_panel_dialog.dart';
import 'package:job_prep/features/prep/domain/entities/mock_test.dart';
import 'package:job_prep/features/prep/domain/entities/prep_enums.dart';
import 'package:job_prep/features/prep/domain/entities/prep_material.dart';
import 'package:job_prep/features/prep/domain/entities/progress_log.dart';
import 'package:job_prep/features/prep/domain/entities/revision_item.dart';
import 'package:job_prep/features/prep/domain/entities/study_session.dart';
import 'package:job_prep/features/prep/domain/entities/subject.dart';
import 'package:job_prep/features/prep/presentation/providers/mock_test_providers.dart';
import 'package:job_prep/features/prep/presentation/providers/prep_cover_providers.dart';
import 'package:job_prep/features/prep/presentation/providers/prep_providers.dart';
import 'package:job_prep/features/prep/presentation/providers/prep_template_providers.dart';
import 'package:job_prep/features/prep/presentation/providers/revision_providers.dart';
import 'package:job_prep/features/prep/presentation/providers/study_plan_providers.dart';
import 'package:job_prep/features/prep/presentation/providers/study_session_providers.dart';
import 'package:job_prep/features/prep/presentation/utils/timer_platform_adapter.dart';
import 'package:job_prep/features/today/presentation/providers/today_providers.dart';
import 'package:job_prep/l10n/app_localizations.dart';
import 'package:job_prep/main.dart';
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
import 'fake_notifications_repository.dart';

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

  group('Phase 6J Notifications Live Delivery & Provider Tests', () {
    test(
      'updates unread badge live on Realtime stream push and polling fallback, '
      'and rolls back on failure',
      () async {
        final now = DateTime.utc(2026, 11, 15, 8);
        final notifRepo = FakeNotificationsRepository(
          clock: () => now,
          initialItems: [
            AppNotification(
              id: 'n-1',
              userId: 'user-1',
              type: AppNotificationType.deadlineSoon,
              messageKey: 'notificationMsgDeadlineSoon',
              params: const {
                'title': '47th BCS',
                'days': 3,
                'targetDate': '2026-11-18',
              },
              route: '/circulars/c-1',
              dedupeKey: 'k-1',
              createdAt: now.subtract(const Duration(hours: 2)),
            ),
          ],
        );
        addTearDown(notifRepo.dispose);
        final authRepo = FakeAuthRepository.authenticated();
        addTearDown(authRepo.dispose);

        final container = ProviderContainer(
          overrides: [
            authRepositoryProvider.overrideWithValue(authRepo),
            notificationsRepositoryProvider.overrideWithValue(notifRepo),
            notificationsNowProvider.overrideWithValue(() => now),
            notificationPollingIntervalProvider.overrideWithValue(
              const Duration(milliseconds: 40),
            ),
          ],
        );
        addTearDown(container.dispose);

        final initial = await container.read(notificationsProvider.future);
        expect(initial.length, 1);
        expect(container.read(unreadNotificationsCountProvider), 1);

        // Simulated Supabase Realtime insert updates live badge immediately
        notifRepo.emitRemoteInsert(
          AppNotification(
            id: 'n-2',
            userId: 'user-1',
            type: AppNotificationType.weeklyReview,
            messageKey: 'notificationMsgWeeklyReview',
            params: const {'weekStart': '2026-11-09'},
            route: '/weekly-review',
            dedupeKey: 'k-2',
            createdAt: now.subtract(const Duration(hours: 1)),
          ),
        );
        await Future<void>.delayed(const Duration(milliseconds: 10));
        expect(container.read(unreadNotificationsCountProvider), 2);

        // Polling fallback picks up staged notifications cleanly
        notifRepo.stageRemoteWithoutRealtime(
          AppNotification(
            id: 'n-3',
            userId: 'user-1',
            type: AppNotificationType.revisionDue,
            messageKey: 'notificationMsgRevisionDue',
            params: const {'count': 3},
            route: '/prep/revision',
            dedupeKey: 'k-3',
            createdAt: now,
          ),
        );
        await Future<void>.delayed(const Duration(milliseconds: 90));
        expect(container.read(unreadNotificationsCountProvider), 3);

        // Failure on markAsRead rolls back unread state cleanly
        notifRepo.nextError = const NotificationNetworkFailure();
        final failed = await container
            .read(notificationsProvider.notifier)
            .markAsRead('n-1');
        expect(failed, isFalse);
        expect(container.read(unreadNotificationsCountProvider), 3);

        final okAll = await container
            .read(notificationsProvider.notifier)
            .markAllAsRead();
        expect(okAll, isTrue);
        expect(container.read(unreadNotificationsCountProvider), 0);
      },
    );
  });

  group('Phase 6J App Shell Bell, Dialog & Weekly Review Widget Tests', () {
    Future<FakeNotificationsRepository> pumpFullApp(
      WidgetTester tester, {
      required Size size,
      String locale = 'en',
      ThemeMode themeMode = ThemeMode.dark,
      List<AppNotification> notifications = const <AppNotification>[],
      String initialRoute = AppRoutePaths.today,
    }) async {
      final now = DateTime.utc(2026, 11, 15, 2);
      tester.view.physicalSize = size;
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      SharedPreferences.setMockInitialValues({
        kReduceEffectsStorageKey: true,
        kLocaleStorageKey: locale,
        kThemeModeStorageKey: themeMode.name,
      });
      final prefs = await SharedPreferences.getInstance();
      final authRepo = FakeAuthRepository.authenticated();
      addTearDown(authRepo.dispose);

      final notifRepo = FakeNotificationsRepository(
        initialItems: notifications,
        clock: () => now,
      );
      addTearDown(notifRepo.dispose);

      const subject = Subject(id: 'sub-1', name: 'Bangladesh Affairs');
      const material = PrepMaterial(
        id: 'mat-1',
        subjectId: 'sub-1',
        title: 'BCS Digest',
        totalUnits: 200,
        completedUnits: 80,
      );
      final materialRepo =
          FakeMaterialRepository(initialMaterials: const [material]);
      final logRepo = FakeProgressLogRepository(
        materialRepository: materialRepo,
        initialLogs: [
          ProgressLog(
            id: 'l-1',
            materialId: 'mat-1',
            unitsDone: 35,
            loggedOn: DateTime.utc(2026, 11, 14),
          ),
        ],
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            sharedPreferencesProvider.overrideWithValue(prefs),
            authRepositoryProvider.overrideWithValue(authRepo),
            initialRouteLocationProvider.overrideWithValue(initialRoute),
            circularNowProvider.overrideWithValue(() => now),
            todayOffsetProvider.overrideWithValue(const Duration(hours: 6)),
            circularRepositoryProvider.overrideWithValue(
              FakeCircularRepository(
                initialItems: [
                  Circular(
                    id: 'c-1',
                    userId: 'user-1',
                    title: '47th BCS Special',
                    organizationName: 'BPSC',
                    deadline: DateTime.utc(2026, 11, 18, 11),
                    examDates: [
                      CircularExamDate(
                        id: 'ex-1',
                        circularId: 'c-1',
                        stage: 'preliminary',
                        examDate: DateTime.utc(2026, 11, 20, 4),
                      ),
                    ],
                  ),
                ],
                clock: () => now,
              ),
            ),
            subjectRepositoryProvider.overrideWithValue(
              FakeSubjectRepository(initialSubjects: const [subject]),
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
              FakeMockTestRepository(
                initialTests: [
                  MockTest(
                    id: 'mt-1',
                    subjectId: 'sub-1',
                    title: 'Model 1',
                    source: 'Oracle',
                    takenOn: DateTime.utc(2026, 11, 13),
                    marksObtained: 84,
                    totalMarks: 100,
                  ),
                  MockTest(
                    id: 'mt-prev',
                    subjectId: 'sub-1',
                    title: 'Prev Model',
                    source: 'Oracle',
                    takenOn: DateTime.utc(2026, 11, 5),
                    marksObtained: 72,
                    totalMarks: 100,
                  ),
                ],
                clock: () => now,
              ),
            ),
            studyPlanRepositoryProvider.overrideWithValue(
              FakeStudyPlanRepository(),
            ),
            revisionItemRepositoryProvider.overrideWithValue(
              FakeRevisionItemRepository(
                initialItems: [
                  RevisionItem(
                    id: 'rev-1',
                    subjectId: 'sub-1',
                    referenceLabel: 'p. 44',
                    dueOn: DateTime.utc(2026, 11, 22),
                    status: RevisionStatus.revised,
                    lastReviewedOn: DateTime.utc(2026, 11, 14),
                  ),
                ],
              ),
            ),
            studySessionRepositoryProvider.overrideWithValue(
              FakeStudySessionRepository(
                initialSessions: [
                  StudySession(
                    id: 'ss-1',
                    userId: 'user-1',
                    subjectId: 'sub-1',
                    startedAt: DateTime.utc(2026, 11, 14, 5),
                    endedAt: DateTime.utc(2026, 11, 14, 7),
                    durationSeconds: 7200,
                  ),
                ],
                clock: () => now,
              ),
            ),
            studyTimerPlatformProvider.overrideWithValue(
              _NoopTimerPlatformAdapter(),
            ),
            notificationsRepositoryProvider.overrideWithValue(notifRepo),
            notificationPollingIntervalProvider.overrideWithValue(null),
          ],
          child: const JobPrepApp(),
        ),
      );
      await tester.pumpAndSettle();
      return notifRepo;
    }

    testWidgets(
      'bell shows live unread badge, panel handles read/delete & navigation',
      (tester) async {
        final now = DateTime.utc(2026, 11, 15, 2);
        final notifRepo = await pumpFullApp(
          tester,
          size: const Size(1280, 900),
          notifications: [
            AppNotification(
              id: 'n-deadline',
              userId: 'user-1',
              type: AppNotificationType.deadlineSoon,
              messageKey: 'notificationMsgDeadlineSoon',
              params: const {
                'title': '47th BCS Special',
                'days': 3,
                'targetDate': '2026-11-18',
              },
              route: '/circulars/c-1',
              dedupeKey: 'k-d',
              createdAt: now.subtract(const Duration(minutes: 30)),
            ),
            AppNotification(
              id: 'n-weekly',
              userId: 'user-1',
              type: AppNotificationType.weeklyReview,
              messageKey: 'notificationMsgWeeklyReview',
              params: const {'weekStart': '2026-11-09'},
              route: '/weekly-review',
              dedupeKey: 'k-w',
              createdAt: now.subtract(const Duration(minutes: 10)),
            ),
          ],
        );

        expect(
          find.byType(NotificationsBellButton),
          findsOneWidget,
        );
        expect(
          find.byKey(const ValueKey('shell-notifications-unread-badge')),
          findsOneWidget,
        );
        expect(find.text('2'), findsOneWidget);

        // Live push raises unread badge to 3 immediately
        notifRepo.emitRemoteInsert(
          AppNotification(
            id: 'n-rev',
            userId: 'user-1',
            type: AppNotificationType.revisionDue,
            messageKey: 'notificationMsgRevisionDue',
            params: const {'count': 2},
            route: '/prep/revision',
            dedupeKey: 'k-r',
            createdAt: now,
          ),
        );
        await tester.pumpAndSettle();
        expect(find.text('3'), findsOneWidget);

        // Tap bell to open panel
        await tester.tap(
          find.byKey(const ValueKey('shell-notifications-bell-btn')),
        );
        await tester.pumpAndSettle();

        expect(
          find.byType(NotificationsPanelDialog),
          findsOneWidget,
        );
        expect(
          find.byKey(const ValueKey('notifications-in-app-notice')),
          findsOneWidget,
        );
        expect(
          find.textContaining('while the app is open'),
          findsOneWidget,
        );
        expect(
          find.textContaining('47th BCS Special closes in 3 days'),
          findsOneWidget,
        );

        // Delete revision notification
        await tester.tap(
          find.byKey(const ValueKey('notification-delete-n-rev')),
        );
        await tester.pumpAndSettle();
        expect(
          find.byKey(const ValueKey('notification-item-n-rev')),
          findsNothing,
        );

        // Mark deadline notification as read individually
        await tester.tap(
          find.byKey(const ValueKey('notification-mark-read-n-deadline')),
        );
        await tester.pumpAndSettle();
        expect(
          find.byKey(const ValueKey('notification-mark-read-n-deadline')),
          findsNothing,
        );

        // Tap Weekly Review item -> marks read, closes, and navigates
        await tester.tap(
          find.byKey(const ValueKey('notification-item-n-weekly')),
        );
        await tester.pumpAndSettle();

        expect(
          find.byKey(const ValueKey('notifications-panel-dialog')),
          findsNothing,
        );
        expect(
          find.byKey(const ValueKey('weekly-review-screen')),
          findsOneWidget,
        );
        expect(find.text('Weekly Review'), findsOneWidget);
        expect(find.text('35'), findsOneWidget);
        expect(find.text('2.0h'), findsOneWidget);
        expect(find.text('84.0%'), findsOneWidget);
        expect(
          find.byKey(const ValueKey('shell-notifications-unread-badge')),
          findsNothing,
        );
      },
    );

    testWidgets(
      'tablet shell renders NotificationsBellButton inside rail',
      (tester) async {
        await pumpFullApp(
          tester,
          size: const Size(800, 900),
        );
        expect(find.byType(NotificationsBellButton), findsOneWidget);
        expect(tester.takeException(), isNull);
      },
    );

    testWidgets(
      'mobile 360x800 Bangla light mode shows bell and Weekly Review cleanly',
      (tester) async {
        await pumpFullApp(
          tester,
          size: const Size(360, 800),
          locale: 'bn',
          themeMode: ThemeMode.light,
          initialRoute: '/weekly-review',
        );

        expect(
          find.byKey(const ValueKey('shell-notifications-bell-btn')),
          findsOneWidget,
        );
        expect(
          find.byKey(const ValueKey('weekly-review-screen')),
          findsOneWidget,
        );
        expect(find.text('সাপ্তাহিক পর্যালোচনা'), findsOneWidget);
        expect(find.text('৩৫'), findsOneWidget);
        expect(tester.takeException(), isNull);
      },
    );

    testWidgets(
      'WeeklyReviewScreen handles empty data without errors or NaN',
      (tester) async {
        tester.view.physicalSize = const Size(960, 1000);
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

        final emptySummary = WeeklyReviewSummary(
          weekStart: DateTime(2026, 11, 9),
          weekEnd: DateTime(2026, 11, 15),
          unitsThisWeek: 0,
          unitsPreviousWeek: 0,
          secondsThisWeek: 0,
          secondsPreviousWeek: 0,
          daysStudied: 0,
          missedDaysCount: 7,
          missedDates: [
            for (var d = 9; d <= 15; d++) DateTime(2026, 11, d),
          ],
          mockTestsThisWeekCount: 0,
          mockTestAverageThisWeek: null,
          mockTestAveragePreviousWeek: null,
          mockAverageDelta: null,
          revisionsClearedThisWeek: 0,
          upcomingDeadlines: const [],
          upcomingExams: const [],
          suggestionKind: WeeklyReviewSuggestionKind.startLoggingRoutine,
        );

        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              sharedPreferencesProvider.overrideWithValue(prefs),
              weeklyReviewSummaryProvider.overrideWithValue(
                AsyncData<WeeklyReviewSummary>(emptySummary),
              ),
            ],
            child: MaterialApp(
              theme: AppTheme.light(),
              darkTheme: AppTheme.dark(),
              themeMode: ThemeMode.dark,
              locale: const Locale('en'),
              localizationsDelegates: AppLocalizations.localizationsDelegates,
              supportedLocales: AppLocalizations.supportedLocales,
              home: const Scaffold(body: WeeklyReviewScreen()),
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text('Weekly Review'), findsOneWidget);
        expect(find.text('No score yet'), findsOneWidget);
        expect(find.text('0 / 7 days'), findsOneWidget);
        expect(
          find.byKey(const ValueKey('weekly-review-upcoming-empty')),
          findsOneWidget,
        );
        expect(find.textContaining('Start light next week'), findsOneWidget);
        expect(tester.takeException(), isNull);
      },
    );
  });
}
