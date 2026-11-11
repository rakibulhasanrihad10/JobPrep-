import 'dart:math' as math;

import 'package:job_prep/features/prep/domain/entities/study_session.dart';
import 'package:job_prep/features/prep/domain/utils/study_timer_calculator.dart';

/// Pure helpers splitting study timer sessions across user local calendar
/// dates (`DateTime(year, month, day)`), handling offsets and pauses.
abstract final class StudySessionDateSplitter {
  /// Splits [session] active duration across the user's local calendar dates,
  /// excluding pause intervals and guaranteeing the sum equals the session
  /// studied duration.
  static Map<DateTime, int> splitByLocalDate(
    StudySession session, {
    DateTime? now,
    Duration? localOffset,
  }) {
    final startUtc = session.startedAt.toUtc();
    final refEnd = (session.endedAt ?? now ?? session.startedAt).toUtc();
    final startLocal = toLocalDate(startUtc, localOffset: localOffset);

    final targetSeconds = session.endedAt != null
        ? math.max(0, session.durationSeconds)
        : StudyTimerCalculator.evaluateSession(
            session,
            now: refEnd,
          ).studiedSeconds;
    if (targetSeconds <= 0) return const <DateTime, int>{};

    final computedEnd = !refEnd.isAfter(startUtc)
        ? startUtc.add(Duration(seconds: targetSeconds))
        : refEnd;
    final endLocal = toLocalDate(computedEnd, localOffset: localOffset);

    final rawByDay = <DateTime, int>{};
    var totalRaw = 0;
    var dayCursor = startLocal;
    while (!dayCursor.isAfter(endLocal)) {
      final dayStartUtc = localMidnightUtc(dayCursor, localOffset: localOffset);
      final dayEndUtc = localMidnightUtc(
        DateTime(dayCursor.year, dayCursor.month, dayCursor.day + 1),
        localOffset: localOffset,
      );
      final segStart = startUtc.isAfter(dayStartUtc) ? startUtc : dayStartUtc;
      final segEnd = computedEnd.isBefore(dayEndUtc) ? computedEnd : dayEndUtc;
      final active = segEnd.isAfter(segStart)
          ? StudyTimerCalculator.calculateActiveSeconds(
              startedAt: segStart,
              endedAt: segEnd,
              pauseIntervals: session.pauseIntervals,
              now: segEnd,
            )
          : 0;
      if (active > 0) {
        rawByDay[dayCursor] = active;
        totalRaw += active;
      }
      dayCursor = DateTime(dayCursor.year, dayCursor.month, dayCursor.day + 1);
    }

    if (totalRaw == targetSeconds) {
      return Map<DateTime, int>.unmodifiable(rawByDay);
    }
    if (totalRaw <= 0 || rawByDay.isEmpty) {
      return Map<DateTime, int>.unmodifiable({startLocal: targetSeconds});
    }

    final adjusted = <DateTime, int>{};
    var assigned = 0;
    final entries = rawByDay.entries.toList(growable: false);
    for (var i = 0; i < entries.length; i++) {
      final entry = entries[i];
      if (i == entries.length - 1) {
        adjusted[entry.key] = math.max(0, targetSeconds - assigned);
      } else {
        final scaled = (targetSeconds * entry.value) ~/ totalRaw;
        adjusted[entry.key] = scaled;
        assigned += scaled;
      }
    }
    adjusted.removeWhere((_, secs) => secs <= 0);
    return Map<DateTime, int>.unmodifiable(adjusted);
  }

  /// Resolves local calendar date for a UTC timestamp.
  static DateTime toLocalDate(DateTime utcInstant, {Duration? localOffset}) {
    final shifted = localOffset != null
        ? utcInstant.toUtc().add(localOffset)
        : utcInstant.toLocal();
    return DateTime(shifted.year, shifted.month, shifted.day);
  }

  /// Resolves UTC instant corresponding to midnight of [localDate].
  static DateTime localMidnightUtc(
    DateTime localDate, {
    Duration? localOffset,
  }) {
    if (localOffset != null) {
      return DateTime.utc(
        localDate.year,
        localDate.month,
        localDate.day,
      ).subtract(localOffset);
    }
    return DateTime(localDate.year, localDate.month, localDate.day).toUtc();
  }
}
