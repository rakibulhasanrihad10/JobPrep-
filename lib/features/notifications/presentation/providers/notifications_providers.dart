import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:job_prep/core/supabase/supabase_provider.dart';
import 'package:job_prep/features/auth/domain/entities/auth_session_state.dart';
import 'package:job_prep/features/auth/presentation/providers/auth_providers.dart';
import 'package:job_prep/features/circulars/domain/entities/circular.dart';
import 'package:job_prep/features/circulars/presentation/providers/circulars_providers.dart';
import 'package:job_prep/features/notifications/data/repositories/supabase_notifications_repository.dart';
import 'package:job_prep/features/notifications/data/repositories/unconfigured_notifications_repository.dart';
import 'package:job_prep/features/notifications/domain/entities/app_notification.dart';
import 'package:job_prep/features/notifications/domain/entities/weekly_review_summary.dart';
import 'package:job_prep/features/notifications/domain/repositories/notifications_repository.dart';
import 'package:job_prep/features/notifications/domain/services/push_notification_extension_point.dart';
import 'package:job_prep/features/notifications/domain/utils/weekly_review_calculator.dart';
import 'package:job_prep/features/prep/domain/entities/mock_test.dart';
import 'package:job_prep/features/prep/domain/entities/progress_log.dart';
import 'package:job_prep/features/prep/domain/entities/revision_item.dart';
import 'package:job_prep/features/prep/domain/entities/study_plan_snapshot.dart';
import 'package:job_prep/features/prep/domain/entities/study_session.dart';
import 'package:job_prep/features/prep/presentation/providers/mock_test_providers.dart';
import 'package:job_prep/features/prep/presentation/providers/prep_providers.dart';
import 'package:job_prep/features/prep/presentation/providers/revision_providers.dart';
import 'package:job_prep/features/prep/presentation/providers/study_plan_providers.dart';
import 'package:job_prep/features/prep/presentation/providers/study_session_providers.dart';
import 'package:job_prep/features/today/presentation/providers/today_providers.dart';

Duration? _noRetry(int retryCount, Object error) => null;

/// Dependency-injected [NotificationsRepository] provider.
final Provider<NotificationsRepository> notificationsRepositoryProvider =
    Provider<NotificationsRepository>((ref) {
  final client = ref.watch(optionalSupabaseClientProvider);
  if (client == null) {
    return const UnconfiguredNotificationsRepository();
  }
  return SupabaseNotificationsRepository(client);
});

/// Extension point reserved for future Web Push / Android push integration.
final Provider<PushNotificationExtensionPoint>
    pushNotificationExtensionPointProvider =
    Provider<PushNotificationExtensionPoint>(
  (ref) => const NoopPushNotificationExtensionPoint(),
);

/// Optional polling interval acting as a resilient fallback beside Supabase
/// Realtime updates while the app is open (`null` disables background polling).
final Provider<Duration?> notificationPollingIntervalProvider =
    Provider<Duration?>((ref) {
  final repo = ref.watch(notificationsRepositoryProvider);
  if (repo is UnconfiguredNotificationsRepository) {
    return null;
  }
  return const Duration(seconds: 45);
});

/// Clock callback for notification formatting and read timestamps.
final Provider<DateTime Function()> notificationsNowProvider =
    Provider<DateTime Function()>((ref) => ref.watch(todayNowProvider));

/// Live notification feed synced via Supabase Realtime + polling fallback.
class NotificationsNotifier extends AsyncNotifier<List<AppNotification>> {
  StreamSubscription<List<AppNotification>>? _realtimeSub;
  Timer? _pollingTimer;

  @override
  FutureOr<List<AppNotification>> build() async {
    ref.onDispose(_cancelSubscriptions);
    _cancelSubscriptions();

    final authState = ref.watch(authSessionProvider);
    if (authState.status != AuthStatus.signedIn) {
      return const <AppNotification>[];
    }

    final repo = ref.watch(notificationsRepositoryProvider);
    final pollingInterval = ref.watch(notificationPollingIntervalProvider);

    final initial = await repo.getNotifications();

    _realtimeSub = repo.watchNotifications().listen(
      (items) {
        if (ref.mounted) {
          state = AsyncData<List<AppNotification>>(items);
        }
      },
      onError: (_) {
        // Polling fallback continues smoothly if Realtime channel drops.
      },
    );

    if (pollingInterval != null && pollingInterval > Duration.zero) {
      _pollingTimer = Timer.periodic(
        pollingInterval,
        (_) => unawaited(_pollSilently()),
      );
    }

    return initial;
  }

  /// Refreshes notifications manually from the repository.
  Future<void> refresh() async {
    final repo = ref.read(notificationsRepositoryProvider);
    try {
      final latest = await repo.getNotifications();
      if (ref.mounted) {
        state = AsyncData<List<AppNotification>>(latest);
      }
    } on Object {
      // Preserve last known state cleanly when offline.
    }
  }

  /// Marks a single notification as read optimistically and persists it.
  Future<bool> markAsRead(String notificationId) async {
    final previous = state.asData?.value ?? const <AppNotification>[];
    final targetIndex =
        previous.indexWhere((item) => item.id == notificationId);
    if (targetIndex < 0) return false;
    final target = previous[targetIndex];
    if (target.isRead) return true;

    final now = ref.read(notificationsNowProvider)().toUtc();
    final optimistic = List<AppNotification>.of(previous);
    optimistic[targetIndex] = target.copyWith(readAt: now);
    state = AsyncData<List<AppNotification>>(
      List<AppNotification>.unmodifiable(optimistic),
    );

    try {
      final saved = await ref.read(notificationsRepositoryProvider).markAsRead(
            notificationId,
          );
      if (ref.mounted) {
        final current = state.asData?.value ?? const <AppNotification>[];
        final updated = current
            .map((item) => item.id == saved.id ? saved : item)
            .toList(growable: false);
        state = AsyncData<List<AppNotification>>(
          List<AppNotification>.unmodifiable(updated),
        );
      }
      return true;
    } on Object {
      if (ref.mounted) {
        state = AsyncData<List<AppNotification>>(previous);
      }
      return false;
    }
  }

  /// Marks every currently unread notification as read.
  Future<bool> markAllAsRead() async {
    final previous = state.asData?.value ?? const <AppNotification>[];
    if (previous.every((item) => item.isRead)) return true;

    final now = ref.read(notificationsNowProvider)().toUtc();
    final optimistic = previous
        .map((item) => item.isRead ? item : item.copyWith(readAt: now))
        .toList(growable: false);
    state = AsyncData<List<AppNotification>>(
      List<AppNotification>.unmodifiable(optimistic),
    );

    try {
      await ref.read(notificationsRepositoryProvider).markAllAsRead();
      return true;
    } on Object {
      if (ref.mounted) {
        state = AsyncData<List<AppNotification>>(previous);
      }
      return false;
    }
  }

  /// Removes a notification permanently.
  Future<bool> deleteNotification(String notificationId) async {
    final previous = state.asData?.value ?? const <AppNotification>[];
    final filtered = previous
        .where((item) => item.id != notificationId)
        .toList(growable: false);
    state = AsyncData<List<AppNotification>>(
      List<AppNotification>.unmodifiable(filtered),
    );

    try {
      await ref
          .read(notificationsRepositoryProvider)
          .deleteNotification(notificationId);
      return true;
    } on Object {
      if (ref.mounted) {
        state = AsyncData<List<AppNotification>>(previous);
      }
      return false;
    }
  }

  Future<void> _pollSilently() async {
    if (!ref.mounted) return;
    await refresh();
  }

  void _cancelSubscriptions() {
    unawaited(_realtimeSub?.cancel() ?? Future<void>.value());
    _realtimeSub = null;
    _pollingTimer?.cancel();
    _pollingTimer = null;
  }
}

/// Provides the signed-in user's live notification list.
final AsyncNotifierProvider<NotificationsNotifier, List<AppNotification>>
    notificationsProvider =
    AsyncNotifierProvider<NotificationsNotifier, List<AppNotification>>(
  NotificationsNotifier.new,
  retry: _noRetry,
);

/// Count of unread in-app notifications driving the shell bell badge.
final Provider<int> unreadNotificationsCountProvider = Provider<int>((ref) {
  final notifications = ref.watch(notificationsProvider).asData?.value;
  if (notifications == null || notifications.isEmpty) return 0;
  return notifications.where((item) => item.isUnread).length;
});

/// Live Weekly Review summary computed across the trailing 7 local days
/// compared with the previous 7 days.
final Provider<AsyncValue<WeeklyReviewSummary>> weeklyReviewSummaryProvider =
    Provider<AsyncValue<WeeklyReviewSummary>>((ref) {
  final now = ref.watch(todayNowProvider)();
  final localOffset = ref.watch(todayOffsetProvider);

  final logsAsync = ref.watch(analyticsProgressLogsProvider);
  final sessionsAsync = ref.watch(studySessionsProvider);
  final mockTestsAsync = ref.watch(mockTestsProvider);
  final revisionAsync = ref.watch(revisionItemsProvider);
  final circularsAsync = ref.watch(circularsListProvider);
  final planSnapshotsAsync = ref.watch(studyPlanSnapshotsProvider);

  final sources = <AsyncValue<Object?>>[
    logsAsync,
    sessionsAsync,
    mockTestsAsync,
    revisionAsync,
    circularsAsync,
    planSnapshotsAsync,
  ];
  for (final src in sources) {
    if (src is AsyncError<Object?> && !src.hasValue) {
      return AsyncError<WeeklyReviewSummary>(src.error, src.stackTrace);
    }
  }
  if (sources.any((s) => s.isLoading && !s.hasValue)) {
    return const AsyncLoading<WeeklyReviewSummary>();
  }

  return AsyncData<WeeklyReviewSummary>(
    WeeklyReviewCalculator.buildSummary(
      logs: logsAsync.asData?.value ?? const <ProgressLog>[],
      sessions: sessionsAsync.asData?.value ?? const <StudySession>[],
      mockTests: mockTestsAsync.asData?.value ?? const <MockTest>[],
      revisionItems: revisionAsync.asData?.value ?? const <RevisionItem>[],
      circulars: circularsAsync.asData?.value ?? const <Circular>[],
      planSnapshots:
          planSnapshotsAsync.asData?.value ?? const <StudyPlanSnapshot>[],
      now: now,
      localOffset: localOffset,
    ),
  );
});
