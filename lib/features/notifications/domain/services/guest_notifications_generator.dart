import 'package:job_prep/features/circulars/domain/entities/circular.dart';
import 'package:job_prep/features/circulars/domain/entities/circular_enums.dart';
import 'package:job_prep/features/circulars/domain/entities/circular_exam_date.dart';
import 'package:job_prep/features/notifications/domain/entities/app_notification.dart';
import 'package:job_prep/features/notifications/domain/entities/notification_type.dart';
import 'package:job_prep/features/prep/domain/entities/prep_enums.dart';
import 'package:job_prep/features/prep/domain/entities/prep_material.dart';
import 'package:job_prep/features/prep/domain/entities/revision_item.dart';
import 'package:job_prep/features/prep/domain/entities/study_plan.dart';
import 'package:job_prep/features/settings/domain/entities/reminder_settings.dart';
import 'package:uuid/uuid.dart';

/// Pure generator creating in-app notifications for guest mode on device boot,
/// mirroring Phase 6J selection functions with zero cloud Edge Functions.
abstract final class GuestNotificationsGenerator {
  /// Lead days triggering upcoming deadline/exam reminders.
  static const List<int> reminderLeadDays = [7, 3, 1];

  /// Generates due [AppNotification] candidates for the provided data.
  static List<AppNotification> generateDueNotifications({
    required List<Circular> circulars,
    required List<CircularExamDate> examDates,
    required List<RevisionItem> revisionItems,
    required List<StudyPlan> studyPlans,
    required List<PrepMaterial> materials,
    required ReminderSettings reminderSettings,
    required DateTime now,
    String userId = 'local_guest',
  }) {
    if (!reminderSettings.enabled) {
      return const [];
    }

    final todayDate = _isoDate(now);
    final weekday = now.weekday % 7; // 0 Sunday .. 6 Saturday
    final candidates = <AppNotification>[];

    // 1. Deadline soon
    if (reminderSettings.deadlineSoonEnabled) {
      for (final circular in circulars) {
        if (circular.workflowStatus == CircularWorkflowStatus.archived) {
          continue;
        }
        final deadline = circular.deadline;
        if (deadline == null) continue;

        final diff = _diffDays(deadline, now);
        if (reminderLeadDays.contains(diff)) {
          final targetDate = _isoDate(deadline);
          candidates.add(
            AppNotification(
              id: const Uuid().v4(),
              userId: userId,
              type: AppNotificationType.deadlineSoon,
              messageKey: 'notificationMsgDeadlineSoon',
              params: {
                'title': circular.title,
                'days': diff,
                'targetDate': targetDate,
              },
              route: '/circulars/${circular.id}',
              dedupeKey: 'deadline_soon|${circular.id}|${diff}d|$targetDate',
              createdAt: now.toUtc(),
            ),
          );
        }
      }
    }

    // 2. Exam soon
    if (reminderSettings.examSoonEnabled) {
      for (final exam in examDates) {
        final diff = _diffDays(exam.examDate, now);
        if (reminderLeadDays.contains(diff)) {
          final targetDate = _isoDate(exam.examDate);
          candidates.add(
            AppNotification(
              id: const Uuid().v4(),
              userId: userId,
              type: AppNotificationType.examSoon,
              messageKey: 'notificationMsgExamSoon',
              params: {
                'title': exam.stage,
                'stage': exam.stage,
                'days': diff,
                'targetDate': targetDate,
              },
              route: '/circulars/${exam.circularId}',
              dedupeKey: 'exam_soon|${exam.circularId}|${exam.id}|'
                  '${diff}d|$targetDate',
              createdAt: now.toUtc(),
            ),
          );
        }
      }
    }

    // 3. Revision due
    if (reminderSettings.revisionDueEnabled) {
      var dueCount = 0;
      for (final item in revisionItems) {
        if (item.status != RevisionStatus.pending &&
            item.status != RevisionStatus.revised) {
          continue;
        }
        final dueOn = item.dueOn;
        if (!_dateOnly(dueOn).isAfter(_dateOnly(now))) {
          dueCount += 1;
        }
      }
      if (dueCount > 0) {
        candidates.add(
          AppNotification(
            id: const Uuid().v4(),
            userId: userId,
            type: AppNotificationType.revisionDue,
            messageKey: 'notificationMsgRevisionDue',
            params: {'count': dueCount},
            route: '/prep',
            dedupeKey: 'revision_due|$todayDate',
            createdAt: now.toUtc(),
          ),
        );
      }
    }

    // 4. Behind schedule
    if (reminderSettings.behindScheduleEnabled) {
      for (final plan in studyPlans) {
        if (_isBehindSchedule(plan, materials, now)) {
          final subjectId = plan.subjectId;
          final hasSubject = subjectId != null && subjectId.isNotEmpty;
          candidates.add(
            AppNotification(
              id: const Uuid().v4(),
              userId: userId,
              type: AppNotificationType.behindSchedule,
              messageKey: hasSubject
                  ? 'notificationMsgBehindScheduleSubject'
                  : 'notificationMsgBehindScheduleAll',
              params: hasSubject ? {'subject': subjectId} : {},
              route: hasSubject ? '/prep/$subjectId' : '/today',
              dedupeKey: 'behind_schedule|${plan.id}|$todayDate',
              createdAt: now.toUtc(),
            ),
          );
        }
      }
    }

    // 5. Weekly review
    if (reminderSettings.weeklyReviewEnabled &&
        reminderSettings.weeklyReviewDay == weekday) {
      final weekStart = _isoDate(now.subtract(const Duration(days: 6)));
      candidates.add(
        AppNotification(
          id: const Uuid().v4(),
          userId: userId,
          type: AppNotificationType.weeklyReview,
          messageKey: 'notificationMsgWeeklyReview',
          params: {'weekStart': weekStart, 'weekEnd': todayDate},
          route: '/weekly-review',
          dedupeKey: 'weekly_review|$todayDate',
          createdAt: now.toUtc(),
        ),
      );
    }

    return candidates;
  }

  static int _diffDays(DateTime target, DateTime now) {
    final t = DateTime.utc(target.year, target.month, target.day);
    final n = DateTime.utc(now.year, now.month, now.day);
    return t.difference(n).inDays;
  }

  static DateTime _dateOnly(DateTime dt) =>
      DateTime.utc(dt.year, dt.month, dt.day);

  static String _isoDate(DateTime dt) =>
      '${dt.year.toString().padLeft(4, '0')}-'
      '${dt.month.toString().padLeft(2, '0')}-'
      '${dt.day.toString().padLeft(2, '0')}';

  static bool _isBehindSchedule(
    StudyPlan plan,
    List<PrepMaterial> materials,
    DateTime now,
  ) {
    var completedUnits = 0;
    var totalUnits = 0;

    for (final mat in materials) {
      if (plan.subjectId != null && mat.subjectId != plan.subjectId) {
        continue;
      }
      if (plan.postponedMaterialIds.contains(mat.id)) continue;
      completedUnits += mat.completedUnits;
      totalUnits += mat.totalUnits;
    }

    if (totalUnits <= 0 || completedUnits >= totalUnits) return false;

    final effectiveTarget =
        plan.targetDate.subtract(Duration(days: plan.finishBufferDays));
    final totalSpanDays = effectiveTarget.difference(plan.startDate).inDays;
    if (totalSpanDays <= 0) return true;

    final elapsedDays = now.difference(plan.startDate).inDays;
    if (elapsedDays <= 0) return false;

    final expectedUnits = (totalUnits * (elapsedDays / totalSpanDays)).floor();
    return completedUnits < expectedUnits;
  }
}
