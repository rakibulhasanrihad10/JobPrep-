import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:job_prep/features/circulars/domain/entities/circular.dart';
import 'package:job_prep/features/circulars/domain/entities/circular_enums.dart';
import 'package:job_prep/features/circulars/domain/entities/circular_exam_date.dart';
import 'package:job_prep/features/notifications/data/mappers/notification_error_mapper.dart';
import 'package:job_prep/features/notifications/data/mappers/notification_mapper.dart';
import 'package:job_prep/features/notifications/domain/entities/app_notification.dart';
import 'package:job_prep/features/notifications/domain/entities/notification_type.dart';
import 'package:job_prep/features/notifications/domain/entities/weekly_review_summary.dart';
import 'package:job_prep/features/notifications/domain/errors/notification_failure.dart';
import 'package:job_prep/features/notifications/domain/services/push_notification_extension_point.dart';
import 'package:job_prep/features/notifications/domain/utils/weekly_review_calculator.dart';
import 'package:job_prep/features/notifications/presentation/utils/notification_message_formatter.dart';
import 'package:job_prep/features/prep/domain/entities/mock_test.dart';
import 'package:job_prep/features/prep/domain/entities/prep_enums.dart';
import 'package:job_prep/features/prep/domain/entities/prep_material.dart';
import 'package:job_prep/features/prep/domain/entities/progress_log.dart';
import 'package:job_prep/features/prep/domain/entities/revision_item.dart';
import 'package:job_prep/features/prep/domain/entities/study_plan.dart';
import 'package:job_prep/features/prep/domain/entities/study_plan_snapshot.dart';
import 'package:job_prep/features/prep/domain/entities/study_session.dart';
import 'package:job_prep/features/prep/domain/entities/subject.dart';
import 'package:job_prep/features/prep/domain/utils/study_plan_calculator.dart';
import 'package:job_prep/l10n/app_localizations_bn.dart';
import 'package:job_prep/l10n/app_localizations_en.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supabase;

void main() {
  setUpAll(() async {
    await initializeDateFormatting('en');
    await initializeDateFormatting('bn');
  });

  group('Notification Domain, Mappers & Formatter', () {
    test('AppNotificationType and AppNotification equality handle params', () {
      expect(
        AppNotificationType.tryParse('weekly_review'),
        AppNotificationType.weeklyReview,
      );
      expect(AppNotificationType.tryParse('unknown'), isNull);
      expect(
        AppNotificationType.fromValue('bad'),
        AppNotificationType.deadlineSoon,
      );

      final n = AppNotification(
        id: 'n-1',
        userId: 'u-1',
        type: AppNotificationType.deadlineSoon,
        messageKey: 'notificationMsgDeadlineSoon',
        params: const {'title': '47th BCS', 'days': 3},
        route: '/circulars/c1',
        dedupeKey: 'deadline_soon|c1|3d|2026-11-18',
        createdAt: DateTime.utc(2026, 11, 15, 2),
      );
      expect(n.isUnread, isTrue);
      expect(n.isRead, isFalse);

      final read = n.copyWith(readAt: DateTime.utc(2026, 11, 15, 4));
      expect(read.isRead, isTrue);
      expect(read.copyWith(clearReadAt: true), equals(n));
    });

    test('NotificationMapper and NotificationErrorMapper handle rows & errors',
        () {
      final mapped = NotificationMapper.fromJson({
        'id': 'n-10',
        'user_id': 'u-1',
        'type': 'exam_soon',
        'message_key': 'notificationMsgExamSoon',
        'params': {
          'title': '47th BCS',
          'stage': 'preliminary',
          'days': 1,
          'targetDate': '2026-11-16',
        },
        'route': '/circulars/c1',
        'dedupe_key': 'exam_soon|c1|e1|1d|2026-11-16',
        'created_at': '2026-11-15T02:00:00Z',
        'read_at': null,
      });

      expect(mapped.type, AppNotificationType.examSoon);
      expect(mapped.params['days'], 1);
      expect(mapped.isUnread, isTrue);

      expect(
        NotificationErrorMapper.map(TimeoutException('slow')),
        isA<NotificationNetworkFailure>(),
      );
      expect(
        NotificationErrorMapper.map(
          const supabase.PostgrestException(message: 'denied', code: '42501'),
        ),
        isA<NotificationPermissionFailure>(),
      );
      expect(
        NotificationErrorMapper.map(
          const supabase.PostgrestException(message: 'invalid', code: '23514'),
        ),
        isA<NotificationValidationFailure>(),
      );
    });

    test('NotificationMessageFormatter localizes all 5 types in EN and BN', () {
      final en = AppLocalizationsEn();
      final bn = AppLocalizationsBn();

      final deadlineNotif = AppNotification(
        id: 'n-d',
        userId: 'u-1',
        type: AppNotificationType.deadlineSoon,
        messageKey: 'notificationMsgDeadlineSoon',
        params: const {
          'title': '47th BCS',
          'days': 3,
          'targetDate': '2026-11-18',
        },
        route: '/circulars/c1',
        dedupeKey: 'k1',
        createdAt: DateTime.utc(2026, 11, 15, 2),
      );
      final examNotif = AppNotification(
        id: 'n-e',
        userId: 'u-1',
        type: AppNotificationType.examSoon,
        messageKey: 'notificationMsgExamSoon',
        params: const {
          'title': 'Bank PO',
          'stage': 'preliminary',
          'days': 1,
          'targetDate': '2026-11-16',
        },
        route: '/circulars/c2',
        dedupeKey: 'k2',
        createdAt: DateTime.utc(2026, 11, 15, 2),
      );
      final revNotif = AppNotification(
        id: 'n-r',
        userId: 'u-1',
        type: AppNotificationType.revisionDue,
        messageKey: 'notificationMsgRevisionDue',
        params: const {'count': 4},
        route: '/prep/revision',
        dedupeKey: 'k3',
        createdAt: DateTime.utc(2026, 11, 15, 2),
      );
      final behindNotif = AppNotification(
        id: 'n-b',
        userId: 'u-1',
        type: AppNotificationType.behindSchedule,
        messageKey: 'notificationMsgBehindScheduleSubject',
        params: const {'subject': 'English'},
        route: '/prep/s1',
        dedupeKey: 'k4',
        createdAt: DateTime.utc(2026, 11, 15, 2),
      );
      final reviewNotif = AppNotification(
        id: 'n-w',
        userId: 'u-1',
        type: AppNotificationType.weeklyReview,
        messageKey: 'notificationMsgWeeklyReview',
        params: const {'weekStart': '2026-11-09'},
        route: '/weekly-review',
        dedupeKey: 'k5',
        createdAt: DateTime.utc(2026, 11, 15, 2),
      );

      final msgEn = NotificationMessageFormatter.formatMessage(
        notification: deadlineNotif,
        l10n: en,
        locale: const Locale('en'),
      );
      final msgBn = NotificationMessageFormatter.formatMessage(
        notification: deadlineNotif,
        l10n: bn,
        locale: const Locale('bn'),
        useBanglaDigits: true,
      );
      expect(msgEn, contains('47th BCS closes in 3 days'));
      expect(msgBn, contains('৩ দিন বাকি'));

      expect(
        NotificationMessageFormatter.formatMessage(
          notification: examNotif,
          l10n: en,
          locale: const Locale('en'),
        ),
        contains('Bank PO — Preliminary exam is tomorrow'),
      );
      expect(
        NotificationMessageFormatter.formatMessage(
          notification: revNotif,
          l10n: bn,
          locale: const Locale('bn'),
          useBanglaDigits: true,
        ),
        contains('৪টি'),
      );
      expect(
        NotificationMessageFormatter.formatMessage(
          notification: behindNotif,
          l10n: en,
          locale: const Locale('en'),
        ),
        contains('English'),
      );
      expect(
        NotificationMessageFormatter.formatMessage(
          notification: reviewNotif,
          l10n: en,
          locale: const Locale('en'),
        ),
        contains('weekly review is ready'),
      );
    });

    test('NoopPushNotificationExtensionPoint exposes clean push contract',
        () async {
      const push = NoopPushNotificationExtensionPoint();
      expect(push.isSupported, isFalse);
      expect(
        await push.getPermissionStatus(),
        PushPermissionStatus.unsupported,
      );
      expect(
        await push.requestPermission(),
        PushPermissionStatus.unsupported,
      );
      await push.syncDeviceToken(userId: 'u-1');
      await push.clearDeviceToken();
    });
  });

  group('WeeklyReviewCalculator Unit Tests', () {
    test(
      'computes 7d metrics, local midnight split, mock delta, revisions, '
      'and upcoming events',
      () {
        // Sunday 2026-11-15 08:00 AM +06:00 (UTC 02:00)
        // Current 7d: Nov 9..Nov 15; Previous 7d: Nov 2..Nov 8
        final nowUtc = DateTime.utc(2026, 11, 15, 2);
        const dhakaOffset = Duration(hours: 6);

        final logs = [
          // This week study logs (total = 45)
          ProgressLog(
            id: 'l-1',
            materialId: 'm-1',
            unitsDone: 20,
            loggedOn: DateTime.utc(2026, 11, 9),
          ),
          ProgressLog(
            id: 'l-2',
            materialId: 'm-1',
            unitsDone: 25,
            loggedOn: DateTime.utc(2026, 11, 14),
          ),
          // Correction log must NEVER inflate studied units
          ProgressLog(
            id: 'l-corr',
            materialId: 'm-1',
            unitsDone: 30,
            loggedOn: DateTime.utc(2026, 11, 12),
            entryType: ProgressLogEntryType.correction,
          ),
          // Previous week study logs (total = 30)
          ProgressLog(
            id: 'l-prev',
            materialId: 'm-1',
            unitsDone: 30,
            loggedOn: DateTime.utc(2026, 11, 5),
          ),
        ];

        final sessions = [
          // Crosses +06:00 midnight (1h split across Nov 14 & Nov 15)
          StudySession(
            id: 'ss-1',
            userId: 'u-1',
            subjectId: 's-1',
            startedAt: DateTime.utc(2026, 11, 14, 17, 30),
            endedAt: DateTime.utc(2026, 11, 14, 18, 30),
            durationSeconds: 3600,
          ),
          // Qualifying 30m session on Nov 10 -> marks Nov 10 as studied
          StudySession(
            id: 'ss-2',
            userId: 'u-1',
            subjectId: 's-1',
            startedAt: DateTime.utc(2026, 11, 10, 4),
            endedAt: DateTime.utc(2026, 11, 10, 4, 30),
            durationSeconds: 1800,
            mode: StudySessionMode.stopwatch,
          ),
          // Previous week session (30 min = 1800s)
          StudySession(
            id: 'ss-prev',
            userId: 'u-1',
            subjectId: 's-1',
            startedAt: DateTime.utc(2026, 11, 4, 4),
            endedAt: DateTime.utc(2026, 11, 4, 4, 30),
            durationSeconds: 1800,
            mode: StudySessionMode.manual,
          ),
        ];

        final mockTests = [
          MockTest(
            id: 'mt-1',
            subjectId: 's-1',
            title: 'Model 1',
            source: 'Oracle',
            takenOn: DateTime.utc(2026, 11, 11),
            marksObtained: 80,
            totalMarks: 100, // 80%
          ),
          MockTest(
            id: 'mt-2',
            subjectId: 's-1',
            title: 'Model 2',
            source: 'Oracle',
            takenOn: DateTime.utc(2026, 11, 14),
            marksObtained: 90,
            totalMarks: 100, // 90% -> avg 85%
          ),
          MockTest(
            id: 'mt-prev',
            subjectId: 's-1',
            title: 'Prev Model',
            source: 'Oracle',
            takenOn: DateTime.utc(2026, 11, 6),
            marksObtained: 75,
            totalMarks: 100, // 75% -> delta +10.0
          ),
        ];

        final revisionItems = [
          RevisionItem(
            id: 'r-1',
            subjectId: 's-1',
            referenceLabel: 'p. 14',
            dueOn: DateTime.utc(2026, 11, 20),
            status: RevisionStatus.revised,
            lastReviewedOn: DateTime.utc(2026, 11, 13),
          ),
          RevisionItem(
            id: 'r-2',
            subjectId: 's-1',
            referenceLabel: 'p. 28',
            dueOn: DateTime.utc(2026, 12, 10),
            status: RevisionStatus.mastered,
            lastReviewedOn: DateTime.utc(2026, 11, 15),
          ),
          // Outside 7d window -> excluded
          RevisionItem(
            id: 'r-old',
            subjectId: 's-1',
            referenceLabel: 'p. 5',
            dueOn: DateTime.utc(2026, 11, 15),
            status: RevisionStatus.revised,
            lastReviewedOn: DateTime.utc(2026, 11, 8),
          ),
        ];

        final circulars = [
          Circular(
            id: 'c-1',
            title: '47th BCS Circular',
            organizationName: 'BPSC',
            deadline: DateTime.utc(2026, 11, 18, 11),
            workflowStatus: CircularWorkflowStatus.preparing,
            examDates: [
              CircularExamDate(
                id: 'e-1',
                circularId: 'c-1',
                stage: 'preliminary',
                examDate: DateTime.utc(2026, 11, 21, 4), // +6d
              ),
              CircularExamDate(
                id: 'e-far',
                circularId: 'c-1',
                stage: 'written',
                examDate: DateTime.utc(2026, 12, 10, 4), // >7d -> excluded
              ),
            ],
          ),
        ];

        final summary = WeeklyReviewCalculator.buildSummary(
          logs: logs,
          sessions: sessions,
          mockTests: mockTests,
          revisionItems: revisionItems,
          circulars: circulars,
          planSnapshots: const <StudyPlanSnapshot>[],
          now: nowUtc,
          localOffset: dhakaOffset,
        );

        expect(summary.weekStart, DateTime(2026, 11, 9));
        expect(summary.weekEnd, DateTime(2026, 11, 15));
        expect(summary.unitsThisWeek, 45);
        expect(summary.unitsPreviousWeek, 30);
        expect(summary.unitsDelta, 15);
        expect(summary.secondsThisWeek, 5400);
        expect(summary.secondsPreviousWeek, 1800);
        expect(summary.hoursThisWeek, closeTo(1.5, 0.001));
        // Qualified days: Nov 9, Nov 10, Nov 14, Nov 15 (crossing midnight)
        expect(summary.daysStudied, 4);
        expect(summary.missedDaysCount, 3);
        expect(summary.missedDates, [
          DateTime(2026, 11, 11),
          DateTime(2026, 11, 12),
          DateTime(2026, 11, 13),
        ]);
        expect(summary.mockTestsThisWeekCount, 2);
        expect(summary.mockTestAverageThisWeek, closeTo(85.0, 0.001));
        expect(summary.mockTestAveragePreviousWeek, closeTo(75.0, 0.001));
        expect(summary.mockAverageDelta, closeTo(10.0, 0.001));
        expect(summary.revisionsClearedThisWeek, 2);
        expect(summary.upcomingDeadlines.length, 1);
        expect(summary.upcomingExams.length, 1);
        expect(
          summary.suggestionKind,
          WeeklyReviewSuggestionKind.prioritizeNearestDeadline,
        );
        expect(summary.suggestionParam, '47th BCS Circular');
      },
    );

    test('WeeklyReviewCalculator.selectSuggestion chooses top priority signal',
        () {
      final behindPlan = StudyPlanCalculator.buildSnapshot(
        plan: StudyPlan(
          id: 'p-1',
          subjectId: 's-1',
          startDate: DateTime.utc(2026, 11),
          targetDate: DateTime.utc(2026, 11, 20),
          finishBufferDays: 2,
        ),
        today: DateTime.utc(2026, 11, 15),
        materials: const [
          PrepMaterial(
            id: 'm-1',
            subjectId: 's-1',
            title: 'Book',
            totalUnits: 180,
            completedUnits: 10,
          ),
        ],
        recentLogs: const [],
        subject: const Subject(id: 's-1', name: 'English'),
      );

      final behindRes = WeeklyReviewCalculator.selectSuggestion(
        daysStudied: 2,
        missedDaysCount: 5,
        mockTestsThisWeekCount: 0,
        mockAverageDelta: null,
        dueOrOverdueRevisionCount: 3,
        upcomingDeadlines: const [],
        upcomingExams: const [],
        planSnapshots: [behindPlan],
      );
      expect(behindRes.kind, WeeklyReviewSuggestionKind.catchUpBehindPlan);
      expect(behindRes.param, 'English');

      expect(
        WeeklyReviewCalculator.selectSuggestion(
          daysStudied: 0,
          missedDaysCount: 7,
          mockTestsThisWeekCount: 0,
          mockAverageDelta: null,
          dueOrOverdueRevisionCount: 0,
          upcomingDeadlines: const [],
          upcomingExams: const [],
          planSnapshots: const [],
        ).kind,
        WeeklyReviewSuggestionKind.startLoggingRoutine,
      );

      expect(
        WeeklyReviewCalculator.selectSuggestion(
          daysStudied: 6,
          missedDaysCount: 1,
          mockTestsThisWeekCount: 1,
          mockAverageDelta: 4,
          dueOrOverdueRevisionCount: 2,
          upcomingDeadlines: const [],
          upcomingExams: const [],
          planSnapshots: const [],
        ).kind,
        WeeklyReviewSuggestionKind.clearOverdueRevision,
      );

      expect(
        WeeklyReviewCalculator.selectSuggestion(
          daysStudied: 6,
          missedDaysCount: 1,
          mockTestsThisWeekCount: 2,
          mockAverageDelta: 5,
          dueOrOverdueRevisionCount: 0,
          upcomingDeadlines: const [],
          upcomingExams: const [],
          planSnapshots: const [],
        ).kind,
        WeeklyReviewSuggestionKind.maintainStrongStreak,
      );
    });
  });
}
