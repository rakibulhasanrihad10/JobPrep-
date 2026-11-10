import 'package:flutter/foundation.dart' show immutable;

/// Urgency color band derived from remaining days until a circular deadline.
enum DeadlineColorBand {
  /// No deadline is assigned.
  none,

  /// More than 7 days remain until the deadline.
  green,

  /// Between 3 and 7 days (inclusive) remain until the deadline.
  amber,

  /// Fewer than 3 days remain, or the deadline is overdue.
  red,
}

/// Immutable result describing days remaining until a deadline and its urgency
/// [DeadlineColorBand].
@immutable
class DeadlineCountdown {
  /// Creates a [DeadlineCountdown].
  const DeadlineCountdown({
    required this.daysRemaining,
    required this.band,
    required this.isOverdue,
  });

  /// Convenience constant when no deadline is set.
  static const empty = DeadlineCountdown(
    daysRemaining: null,
    band: DeadlineColorBand.none,
    isOverdue: false,
  );

  /// Calendar days remaining relative to the reference date.
  ///
  /// Negative values indicate how many calendar days have passed since the
  /// deadline. `null` when no deadline is present.
  final int? daysRemaining;

  /// Semantic urgency band for UI status rendering.
  final DeadlineColorBand band;

  /// Whether the deadline has already passed relative to the reference time.
  final bool isOverdue;

  /// Whether a deadline exists for this countdown.
  bool get hasDeadline => daysRemaining != null;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is DeadlineCountdown &&
        other.daysRemaining == daysRemaining &&
        other.band == band &&
        other.isOverdue == isOverdue;
  }

  @override
  int get hashCode => Object.hash(daysRemaining, band, isOverdue);

  @override
  String toString() => 'DeadlineCountdown('
      'daysRemaining: $daysRemaining, '
      'band: ${band.name}, '
      'isOverdue: $isOverdue)';
}

/// Computes the calendar days remaining until [deadline] and maps it to a
/// [DeadlineColorBand]:
/// - `none`: [deadline] is `null`
/// - `green`: strictly more than 7 days remaining
/// - `amber`: 3 to 7 days (inclusive) remaining
/// - `red`: under 3 days remaining (0, 1, 2) or overdue
///
/// Aligns [deadline] to the same timezone (`UTC` vs local) as [now] before
/// comparing calendar dates so DST transitions and host time zones do not
/// skew whole-day counts.
DeadlineCountdown computeDeadlineCountdown(
  DateTime? deadline, {
  DateTime? now,
}) {
  if (deadline == null) {
    return DeadlineCountdown.empty;
  }

  final referenceNow = now ?? DateTime.now();
  final alignedNow = referenceNow;
  final alignedDeadline =
      referenceNow.isUtc ? deadline.toUtc() : deadline.toLocal();

  final todayCalendar = DateTime.utc(
    alignedNow.year,
    alignedNow.month,
    alignedNow.day,
  );
  final deadlineCalendar = DateTime.utc(
    alignedDeadline.year,
    alignedDeadline.month,
    alignedDeadline.day,
  );

  final daysRemaining = deadlineCalendar.difference(todayCalendar).inDays;
  final isOverdue = daysRemaining < 0 ||
      (daysRemaining == 0 &&
          _hasExplicitTimeOfDay(alignedDeadline) &&
          alignedDeadline.isBefore(alignedNow));

  final band = _bandForCountdown(
    daysRemaining: daysRemaining,
    isOverdue: isOverdue,
  );

  return DeadlineCountdown(
    daysRemaining: daysRemaining,
    band: band,
    isOverdue: isOverdue,
  );
}

DeadlineColorBand _bandForCountdown({
  required int daysRemaining,
  required bool isOverdue,
}) {
  if (isOverdue || daysRemaining < 3) {
    return DeadlineColorBand.red;
  }
  if (daysRemaining <= 7) {
    return DeadlineColorBand.amber;
  }
  return DeadlineColorBand.green;
}

bool _hasExplicitTimeOfDay(DateTime dateTime) {
  return dateTime.hour != 0 ||
      dateTime.minute != 0 ||
      dateTime.second != 0 ||
      dateTime.millisecond != 0 ||
      dateTime.microsecond != 0;
}
