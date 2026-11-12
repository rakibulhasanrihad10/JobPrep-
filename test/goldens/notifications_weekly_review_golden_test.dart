import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:job_prep/core/localization/locale_controller.dart';
import 'package:job_prep/core/theme/app_theme.dart';
import 'package:job_prep/core/theme/reduce_effects_controller.dart';
import 'package:job_prep/core/theme/theme_controller.dart';
import 'package:job_prep/features/auth/presentation/providers/auth_providers.dart';
import 'package:job_prep/features/circulars/domain/entities/circular.dart';
import 'package:job_prep/features/circulars/domain/entities/circular_exam_date.dart';
import 'package:job_prep/features/circulars/presentation/providers/circulars_providers.dart';
import 'package:job_prep/features/notifications/domain/entities/app_notification.dart';
import 'package:job_prep/features/notifications/domain/entities/notification_type.dart';
import 'package:job_prep/features/notifications/domain/entities/weekly_review_summary.dart';
import 'package:job_prep/features/notifications/presentation/providers/notifications_providers.dart';
import 'package:job_prep/features/notifications/presentation/screens/notifications_screen.dart';
import 'package:job_prep/features/notifications/presentation/screens/weekly_review_screen.dart';
import 'package:job_prep/features/today/domain/utils/today_window_selectors.dart';
import 'package:job_prep/l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../features/auth/fake_auth_repository.dart';
import '../features/notifications/fake_notifications_repository.dart';

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

  setUpAll(() async {
    await initializeDateFormatting('en');
    final currentUrl = Uri.base.resolve('test/goldens/test.dart');
    goldenFileComparator = _TolerantGoldenComparator(currentUrl);
  });

  Future<void> pumpGoldenWidget(
    WidgetTester tester, {
    required ThemeMode themeMode,
    required Size size,
    required Widget child,
  }) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    SharedPreferences.setMockInitialValues({
      kReduceEffectsStorageKey: false,
      kLocaleStorageKey: 'en',
      kThemeModeStorageKey: themeMode.name,
    });
    final prefs = await SharedPreferences.getInstance();
    final authRepo = FakeAuthRepository.authenticated();
    addTearDown(authRepo.dispose);

    final now = DateTime.utc(2026, 11, 15, 2);
    final notifRepo = FakeNotificationsRepository(
      clock: () => now,
      initialItems: [
        AppNotification(
          id: 'ng-1',
          userId: 'user-1',
          type: AppNotificationType.deadlineSoon,
          messageKey: 'notificationMsgDeadlineSoon',
          params: const {
            'title': '47th BCS Special Circular',
            'days': 3,
            'targetDate': '2026-11-18',
          },
          route: '/circulars/c-1',
          dedupeKey: 'k1',
          createdAt: now.subtract(const Duration(hours: 1)),
        ),
        AppNotification(
          id: 'ng-2',
          userId: 'user-1',
          type: AppNotificationType.revisionDue,
          messageKey: 'notificationMsgRevisionDue',
          params: const {'count': 4},
          route: '/prep/revision',
          dedupeKey: 'k2',
          createdAt: now.subtract(const Duration(hours: 2)),
        ),
        AppNotification(
          id: 'ng-3',
          userId: 'user-1',
          type: AppNotificationType.weeklyReview,
          messageKey: 'notificationMsgWeeklyReview',
          params: const {'weekStart': '2026-11-09'},
          route: '/weekly-review',
          dedupeKey: 'k3',
          createdAt: now.subtract(const Duration(hours: 3)),
          readAt: now.subtract(const Duration(minutes: 45)),
        ),
      ],
    );
    addTearDown(notifRepo.dispose);

    final circular = Circular(
      id: 'c-1',
      userId: 'user-1',
      title: '47th BCS Special Circular',
      organizationName: 'Bangladesh Public Service Commission',
      deadline: DateTime.utc(2026, 11, 18, 11),
      examDates: [
        CircularExamDate(
          id: 'e-1',
          circularId: 'c-1',
          stage: 'preliminary',
          examDate: DateTime.utc(2026, 11, 20, 4),
        ),
      ],
    );

    final weeklySummary = WeeklyReviewSummary(
      weekStart: DateTime(2026, 11, 9),
      weekEnd: DateTime(2026, 11, 15),
      unitsThisWeek: 185,
      unitsPreviousWeek: 140,
      secondsThisWeek: 50400, // 14.0h
      secondsPreviousWeek: 43200, // 12.0h
      daysStudied: 6,
      missedDaysCount: 1,
      missedDates: [DateTime(2026, 11, 12)],
      mockTestsThisWeekCount: 3,
      mockTestAverageThisWeek: 84.5,
      mockTestAveragePreviousWeek: 78,
      mockAverageDelta: 6.5,
      revisionsClearedThisWeek: 11,
      upcomingDeadlines: TodayWindowSelectors.selectDeadlinesWithinDays(
        circulars: [circular],
        now: now,
      ),
      upcomingExams: TodayWindowSelectors.selectExamsWithinDays(
        circulars: [circular],
        now: now,
      ),
      suggestionKind: WeeklyReviewSuggestionKind.prioritizeNearestDeadline,
      suggestionParam: circular.title,
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
          authRepositoryProvider.overrideWithValue(authRepo),
          circularNowProvider.overrideWithValue(() => now),
          notificationsRepositoryProvider.overrideWithValue(notifRepo),
          notificationPollingIntervalProvider.overrideWithValue(null),
          notificationsNowProvider.overrideWithValue(() => now),
          weeklyReviewSummaryProvider.overrideWithValue(
            AsyncData<WeeklyReviewSummary>(weeklySummary),
          ),
        ],
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: AppTheme.light(),
          darkTheme: AppTheme.dark(),
          themeMode: themeMode,
          locale: const Locale('en'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(body: child),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  group('Phase 6J Notifications & Weekly Review Golden Tests', () {
    testWidgets('NotificationsScreen desktop golden - dark mode',
        (tester) async {
      await pumpGoldenWidget(
        tester,
        themeMode: ThemeMode.dark,
        size: const Size(1100, 900),
        child: const NotificationsScreen(),
      );
      await expectLater(
        find.byType(NotificationsScreen),
        matchesGoldenFile('goldens/notifications_screen_dark.png'),
      );
    });

    testWidgets('NotificationsScreen desktop golden - light mode',
        (tester) async {
      await pumpGoldenWidget(
        tester,
        themeMode: ThemeMode.light,
        size: const Size(1100, 900),
        child: const NotificationsScreen(),
      );
      await expectLater(
        find.byType(NotificationsScreen),
        matchesGoldenFile('goldens/notifications_screen_light.png'),
      );
    });

    testWidgets('WeeklyReviewScreen desktop golden - dark mode',
        (tester) async {
      await pumpGoldenWidget(
        tester,
        themeMode: ThemeMode.dark,
        size: const Size(1280, 1080),
        child: const WeeklyReviewScreen(),
      );
      await expectLater(
        find.byType(WeeklyReviewScreen),
        matchesGoldenFile('goldens/weekly_review_dark.png'),
      );
    });

    testWidgets('WeeklyReviewScreen desktop golden - light mode',
        (tester) async {
      await pumpGoldenWidget(
        tester,
        themeMode: ThemeMode.light,
        size: const Size(1280, 1080),
        child: const WeeklyReviewScreen(),
      );
      await expectLater(
        find.byType(WeeklyReviewScreen),
        matchesGoldenFile('goldens/weekly_review_light.png'),
      );
    });
  });
}
