import 'package:flutter_test/flutter_test.dart';
import 'package:job_prep/features/circulars/domain/entities/circular.dart';
import 'package:job_prep/features/circulars/domain/entities/circular_exam_date.dart';
import 'package:job_prep/features/notifications/domain/entities/notification_type.dart';
import 'package:job_prep/features/notifications/domain/services/guest_notifications_generator.dart';
import 'package:job_prep/features/prep/domain/entities/prep_material.dart';
import 'package:job_prep/features/prep/domain/entities/revision_item.dart';
import 'package:job_prep/features/prep/domain/entities/study_plan.dart';
import 'package:job_prep/features/settings/domain/entities/reminder_settings.dart';

void main() {
  group('GuestNotificationsGenerator', () {
    final now = DateTime.utc(2026, 11, 15, 10);

    test('returns empty list when reminders are disabled', () {
      final notifs = GuestNotificationsGenerator.generateDueNotifications(
        circulars: [
          Circular(
            id: 'c-1',
            title: '46th BCS',
            deadline: now.add(const Duration(days: 3)),
          ),
        ],
        examDates: [],
        revisionItems: [],
        studyPlans: [],
        materials: [],
        reminderSettings: const ReminderSettings(enabled: false),
        now: now,
      );
      expect(notifs, isEmpty);
    });

    test('generates deadlineSoon, examSoon, revisionDue candidates', () {
      final circular = Circular(
        id: 'c-1',
        title: '38th BCS Officer',
        deadline: now.add(const Duration(days: 3)),
      );

      final examDate = CircularExamDate(
        id: 'ed-1',
        circularId: 'c-1',
        stage: 'Preliminary',
        examDate: now.add(const Duration(days: 1)),
      );

      final revisionItem = RevisionItem(
        id: 'r-1',
        subjectId: 's-1',
        materialId: 'm-1',
        referenceLabel: 'Ch 2',
        dueOn: now.subtract(const Duration(days: 1)),
      );

      final studyPlan = StudyPlan(
        id: 'sp-1',
        startDate: now.subtract(const Duration(days: 5)),
        targetDate: now.add(const Duration(days: 30)),
      );

      const material = PrepMaterial(
        id: 'm-1',
        subjectId: 's-1',
        title: 'Physics',
        totalUnits: 100,
        completedUnits: 20,
      );

      final notifs = GuestNotificationsGenerator.generateDueNotifications(
        circulars: [circular],
        examDates: [examDate],
        revisionItems: [revisionItem],
        studyPlans: [studyPlan],
        materials: [material],
        reminderSettings: const ReminderSettings(),
        now: now,
      );

      expect(notifs, isNotEmpty);
      expect(
        notifs.any((n) => n.type == AppNotificationType.deadlineSoon),
        isTrue,
      );
      expect(
        notifs.any((n) => n.type == AppNotificationType.examSoon),
        isTrue,
      );
      expect(
        notifs.any((n) => n.type == AppNotificationType.revisionDue),
        isTrue,
      );
    });
  });
}
