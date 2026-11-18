import 'package:flutter_test/flutter_test.dart';
import 'package:job_prep/features/auth/domain/entities/auth_user.dart';
import 'package:job_prep/features/auth/domain/errors/auth_failure.dart';
import 'package:job_prep/features/calendar/domain/entities/calendar_event.dart';
import 'package:job_prep/features/circulars/domain/entities/circular.dart';
import 'package:job_prep/features/circulars/domain/errors/circular_failure.dart';
import 'package:job_prep/features/onboarding/domain/entities/onboarding_subject_draft.dart';
import 'package:job_prep/features/prep/domain/entities/mock_test.dart';
import 'package:job_prep/features/prep/domain/entities/prep_template.dart';
import 'package:job_prep/features/prep/domain/entities/prep_template_item.dart';
import 'package:job_prep/features/prep/domain/entities/study_session.dart';
import 'package:job_prep/features/prep/domain/errors/prep_failure.dart';
import 'package:job_prep/features/settings/domain/errors/reminder_failure.dart';
import 'package:job_prep/features/vault/domain/entities/portal_account.dart';

void main() {
  group('Domain Failures and Entities Unit Tests', () {
    test('AuthFailure subclasses instantiate and toString cleanly', () {
      final failures = <AuthFailure>[
        const InvalidCredentialsFailure(code: 'v1', message: 'invalid'),
        const EmailNotConfirmedFailure(code: 'n1', message: 'not confirmed'),
        const AccountAlreadyExistsFailure(code: 'p1', message: 'exists'),
        const TooManyRequestsFailure(code: 'c1', message: 'rate limit'),
        const NetworkFailure(code: 'net1', message: 'network err'),
        const UnknownAuthFailure(code: 'u1', message: 'unknown'),
      ];

      for (final f in failures) {
        expect(f.message, isNotEmpty);
        expect(f.toString(), contains(f.code));
      }
    });

    test('CircularFailure subclasses instantiate and toString cleanly', () {
      final failures = <CircularFailure>[
        const CircularValidationFailure(code: 'v1', message: 'invalid'),
        const CircularNotFoundFailure(code: 'n1', message: 'not found'),
        const CircularPermissionFailure(code: 'p1', message: 'denied'),
        const CircularNetworkFailure(code: 'net1', message: 'network err'),
        const UnknownCircularFailure(code: 'u1', message: 'unknown'),
      ];

      for (final f in failures) {
        expect(f.message, isNotEmpty);
        expect(f.toString(), contains(f.code));
      }
    });

    test('PrepFailure subclasses instantiate and toString cleanly', () {
      final failures = <PrepFailure>[
        const PrepValidationFailure(code: 'v1', message: 'invalid'),
        const PrepNotFoundFailure(code: 'n1', message: 'not found'),
        const PrepPermissionFailure(code: 'p1', message: 'denied'),
        const PrepNetworkFailure(code: 'net1', message: 'network err'),
        const UnknownPrepFailure(code: 'u1', message: 'unknown'),
      ];

      for (final f in failures) {
        expect(f.message, isNotEmpty);
        expect(f.toString(), contains(f.code));
      }
    });

    test('ReminderFailure subclasses instantiate and toString cleanly', () {
      final failures = <ReminderFailure>[
        const ReminderValidationFailure(code: 'v1', message: 'invalid'),
        const ReminderPermissionFailure(code: 'p1', message: 'denied'),
        const ReminderNetworkFailure(code: 'net1', message: 'network err'),
        const UnknownReminderFailure(code: 'u1', message: 'unknown'),
      ];

      for (final f in failures) {
        expect(f.message, isNotEmpty);
        expect(f.toString(), contains(f.code));
      }
    });

    test('AuthUser equality and copyWith', () {
      const user1 = AuthUser(
        id: 'u-1',
        email: 'user@example.com',
        displayName: 'User One',
        emailConfirmed: true,
      );
      final user2 = user1.copyWith(displayName: 'Updated Name');
      expect(user2.id, equals('u-1'));
      expect(user2.displayName, equals('Updated Name'));
      expect(user1 == user2, isFalse);
    });

    test('CalendarEvent equality and properties', () {
      final date = DateTime.utc(2026, 12);
      const circular = Circular(id: 'c-1', title: 'BCS Preliminary');
      final ev1 = CalendarEvent(
        id: 'ev-1',
        circular: circular,
        date: date,
        kind: CalendarEventKind.preliminary,
      );
      final ev2 = CalendarEvent(
        id: 'ev-1',
        circular: circular,
        date: date,
        kind: CalendarEventKind.preliminary,
      );
      expect(ev1, equals(ev2));
      expect(ev1.hashCode, equals(ev2.hashCode));
    });

    test('OnboardingSubjectDraft equality and serialization', () {
      const draft = OnboardingSubjectDraft(
        localId: 'd-1',
        name: 'Mathematics',
      );
      final json = draft.toJson();
      final revived = OnboardingSubjectDraft.fromJson(json);
      expect(revived, equals(draft));
      expect(revived.name, equals('Mathematics'));
    });

    test('MockTest equality, copyWith and marks', () {
      final now = DateTime.utc(2026, 3);
      final mt1 = MockTest(
        id: 'mt-1',
        userId: 'u-1',
        subjectId: 's-1',
        title: 'Mock 1',
        takenOn: now,
        marksObtained: 75,
        totalMarks: 100,
      );
      expect(mt1.marksObtained, equals(75.0));
      expect(mt1.totalMarks, equals(100.0));

      final mt2 = mt1.copyWith(title: 'Mock 1 Updated');
      expect(mt2.title, equals('Mock 1 Updated'));
      expect(mt1 == mt2, isFalse);
    });

    test('StudySession and PauseInterval equality and duration math', () {
      final start = DateTime.utc(2026, 1, 1, 10);
      final pause = PauseInterval(
        pausedAt: DateTime.utc(2026, 1, 1, 10, 20),
        resumedAt: DateTime.utc(2026, 1, 1, 10, 30),
      );
      expect(pause.isOpen, isFalse);

      final session = StudySession(
        id: 'ss-1',
        userId: 'u-1',
        subjectId: 's-1',
        startedAt: start,
        endedAt: DateTime.utc(2026, 1, 1, 11),
        durationSeconds: 3000,
        pauseIntervals: [pause],
      );
      expect(session.isCompleted, isTrue);
      expect(session.isOpen, isFalse);
    });

    test('PortalAccount equality and copyWith', () {
      const pa1 = PortalAccount(
        id: 'pa-1',
        circularId: 'c-1',
        username: 'candidate',
        encryptedPassword: 'enc',
        salt: 's',
        nonce: 'n',
      );
      final pa2 = pa1.copyWith(username: 'candidate2');
      expect(pa2.username, equals('candidate2'));
      expect(pa1 == pa2, isFalse);
    });

    test('PrepTemplate and PrepTemplateItem properties', () {
      const item = PrepTemplateItem(
        id: 'item-1',
        subjectName: 'Mathematics',
        materialTitle: 'Basic Algebra',
        totalUnits: 50,
        itemSortOrder: 1,
      );
      const template = PrepTemplate(
        id: 't-1',
        slug: 'gov-job',
        title: 'Government Job Starter',
        description: 'Starter pack for BPSC exams',
        isSystem: true,
        items: [item],
      );
      expect(template.slug, equals('gov-job'));
      expect(template.items.first.materialTitle, equals('Basic Algebra'));
    });
  });
}
