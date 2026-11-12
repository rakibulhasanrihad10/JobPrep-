/// Categories of persisted in-app notifications dispatched daily or weekly.
enum AppNotificationType {
  /// A tracked circular application deadline is 7, 3, or 1 day away.
  deadlineSoon('deadline_soon'),

  /// A scheduled circular exam stage is 7, 3, or 1 day away.
  examSoon('exam_soon'),

  /// One or more spaced-revision items are due today.
  revisionDue('revision_due'),

  /// An active study plan has fallen behind its ideal completion pace.
  behindSchedule('behind_schedule'),

  /// Scheduled weekly progress digest inviting the user to review their week.
  weeklyReview('weekly_review');

  const AppNotificationType(this.value);

  /// Database column value stored in `public.notifications.type`.
  final String value;

  /// Parses [raw] into an [AppNotificationType], returning `null` if unknown.
  static AppNotificationType? tryParse(String? raw) {
    if (raw == null) return null;
    for (final value in AppNotificationType.values) {
      if (value.value == raw.trim()) {
        return value;
      }
    }
    return null;
  }

  /// Parses [raw] into an [AppNotificationType], falling back to
  /// [AppNotificationType.deadlineSoon] when unrecognized.
  static AppNotificationType fromValue(String? raw) {
    return tryParse(raw) ?? AppNotificationType.deadlineSoon;
  }
}
