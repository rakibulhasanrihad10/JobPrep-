import 'package:flutter_test/flutter_test.dart';
import 'package:job_prep/features/circulars/domain/entities/circular.dart';
import 'package:job_prep/features/circulars/domain/utils/deadline_countdown.dart';

void main() {
  group('computeDeadlineCountdown', () {
    final referenceNow = DateTime(2026, 11, 10, 14, 30);

    test('returns empty countdown with none color band when deadline is null',
        () {
      final result = computeDeadlineCountdown(null, now: referenceNow);

      expect(result.daysRemaining, isNull);
      expect(result.band, equals(DeadlineColorBand.none));
      expect(result.isOverdue, isFalse);
      expect(result.hasDeadline, isFalse);
      expect(result, equals(DeadlineCountdown.empty));
    });

    test('returns green band when strictly more than 7 days remain', () {
      final eightDays = computeDeadlineCountdown(
        DateTime(2026, 11, 18, 23, 59),
        now: referenceNow,
      );
      final thirtyDays = computeDeadlineCountdown(
        DateTime(2026, 12, 10, 9),
        now: referenceNow,
      );

      expect(eightDays.daysRemaining, equals(8));
      expect(eightDays.band, equals(DeadlineColorBand.green));
      expect(eightDays.isOverdue, isFalse);
      expect(eightDays.hasDeadline, isTrue);

      expect(thirtyDays.daysRemaining, equals(30));
      expect(thirtyDays.band, equals(DeadlineColorBand.green));
      expect(thirtyDays.isOverdue, isFalse);
    });

    test('returns amber band for 3 to 7 days remaining inclusive', () {
      for (final days in [7, 5, 3]) {
        final deadline = DateTime(2026, 11, 10 + days, 17);
        final result = computeDeadlineCountdown(deadline, now: referenceNow);

        expect(
          result.daysRemaining,
          equals(days),
          reason: 'Expected $days calendar days remaining',
        );
        expect(
          result.band,
          equals(DeadlineColorBand.amber),
          reason: 'Expected amber band for $days days remaining',
        );
        expect(result.isOverdue, isFalse);
      }
    });

    test('returns red band when under 3 days remain and not overdue', () {
      final twoDays = computeDeadlineCountdown(
        DateTime(2026, 11, 12, 8),
        now: referenceNow,
      );
      final oneDay = computeDeadlineCountdown(
        DateTime(2026, 11, 11, 23, 59),
        now: referenceNow,
      );
      final laterToday = computeDeadlineCountdown(
        DateTime(2026, 11, 10, 23, 59),
        now: referenceNow,
      );
      final dateOnlyToday = computeDeadlineCountdown(
        DateTime(2026, 11, 10),
        now: referenceNow,
      );

      expect(twoDays.daysRemaining, equals(2));
      expect(twoDays.band, equals(DeadlineColorBand.red));
      expect(twoDays.isOverdue, isFalse);

      expect(oneDay.daysRemaining, equals(1));
      expect(oneDay.band, equals(DeadlineColorBand.red));
      expect(oneDay.isOverdue, isFalse);

      expect(laterToday.daysRemaining, equals(0));
      expect(laterToday.band, equals(DeadlineColorBand.red));
      expect(laterToday.isOverdue, isFalse);

      expect(dateOnlyToday.daysRemaining, equals(0));
      expect(dateOnlyToday.band, equals(DeadlineColorBand.red));
      expect(dateOnlyToday.isOverdue, isFalse);
    });

    test('returns red band and marks overdue for past deadlines', () {
      final earlierToday = computeDeadlineCountdown(
        DateTime(2026, 11, 10, 12),
        now: referenceNow,
      );
      final yesterday = computeDeadlineCountdown(
        DateTime(2026, 11, 9, 23, 59),
        now: referenceNow,
      );
      final tenDaysAgo = computeDeadlineCountdown(
        DateTime(2026, 10, 31, 17),
        now: referenceNow,
      );

      expect(earlierToday.daysRemaining, equals(0));
      expect(earlierToday.band, equals(DeadlineColorBand.red));
      expect(earlierToday.isOverdue, isTrue);

      expect(yesterday.daysRemaining, equals(-1));
      expect(yesterday.band, equals(DeadlineColorBand.red));
      expect(yesterday.isOverdue, isTrue);

      expect(tenDaysAgo.daysRemaining, equals(-10));
      expect(tenDaysAgo.band, equals(DeadlineColorBand.red));
      expect(tenDaysAgo.isOverdue, isTrue);
    });

    test('computes consistent calendar days with UTC reference timestamps', () {
      final utcNow = DateTime.utc(2026, 11, 10, 23, 30);
      final utcDeadline = DateTime.utc(2026, 11, 13, 1);

      final result = computeDeadlineCountdown(utcDeadline, now: utcNow);

      expect(result.daysRemaining, equals(3));
      expect(result.band, equals(DeadlineColorBand.amber));
      expect(result.isOverdue, isFalse);
    });

    test('Circular.deadlineCountdown delegates to computeDeadlineCountdown',
        () {
      final circular = Circular(
        title: 'Bangladesh Bank AD',
        deadline: DateTime(2026, 11, 15, 17),
      );

      final result = circular.deadlineCountdown(now: referenceNow);

      expect(result.daysRemaining, equals(5));
      expect(result.band, equals(DeadlineColorBand.amber));
      expect(result.isOverdue, isFalse);
    });
  });
}
