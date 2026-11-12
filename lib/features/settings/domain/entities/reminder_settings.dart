import 'package:flutter/foundation.dart' show immutable;

/// Preferred email body & subject language for daily reminder digests
/// (`public.user_reminder_settings.email_language`).
enum ReminderEmailLanguage {
  english('en'),
  bangla('bn');

  const ReminderEmailLanguage(this.value);

  /// Database column value persisted in PostgreSQL (`'en'` or `'bn'`).
  final String value;

  /// Parses [raw] into a [ReminderEmailLanguage], or returns `null`.
  static ReminderEmailLanguage? tryParse(String? raw) {
    if (raw == null) return null;
    for (final item in ReminderEmailLanguage.values) {
      if (item.value == raw) return item;
    }
    return null;
  }

  /// Parses [raw] into a [ReminderEmailLanguage], defaulting to [fallback].
  static ReminderEmailLanguage fromValue(
    String? raw, {
    ReminderEmailLanguage fallback = ReminderEmailLanguage.english,
  }) {
    return tryParse(raw) ?? fallback;
  }
}

/// Immutable domain entity holding a user's daily reminder email preferences
/// (`public.user_reminder_settings`).
@immutable
class ReminderSettings {
  /// Creates a [ReminderSettings].
  const ReminderSettings({
    this.id = '',
    this.userId = '',
    this.enabled = true,
    this.emailLanguage = ReminderEmailLanguage.english,
    this.deadlineSoonEnabled = true,
    this.examSoonEnabled = true,
    this.revisionDueEnabled = true,
    this.behindScheduleEnabled = true,
    this.weeklyReviewEnabled = true,
    this.weeklyReviewDay = 0,
    this.createdAt,
    this.updatedAt,
  });

  static const Object _unset = Object();

  /// Unique record identifier (`user_reminder_settings.id`).
  final String id;

  /// Owning user identifier (`user_reminder_settings.user_id`).
  final String userId;

  /// Whether daily reminder emails (7, 3, and 1 days ahead) are enabled.
  final bool enabled;

  /// Selected email digest language (`en` or `bn`).
  final ReminderEmailLanguage emailLanguage;

  /// Whether in-app circular deadline notifications (7, 3, 1 days) are enabled.
  final bool deadlineSoonEnabled;

  /// Whether in-app exam date notifications (7, 3, 1 days) are enabled.
  final bool examSoonEnabled;

  /// Whether daily revision-due notifications are enabled.
  final bool revisionDueEnabled;

  /// Whether behind-schedule study plan notifications are enabled.
  final bool behindScheduleEnabled;

  /// Whether weekly review notifications are generated on [weeklyReviewDay].
  final bool weeklyReviewEnabled;

  /// Preferred weekday (`0` = Sunday .. `6` = Saturday) for weekly reviews.
  final int weeklyReviewDay;

  /// Creation timestamp managed by PostgreSQL.
  final DateTime? createdAt;

  /// Last update timestamp managed by PostgreSQL.
  final DateTime? updatedAt;

  /// Returns a copy with specified fields overridden.
  ReminderSettings copyWith({
    String? id,
    String? userId,
    bool? enabled,
    ReminderEmailLanguage? emailLanguage,
    bool? deadlineSoonEnabled,
    bool? examSoonEnabled,
    bool? revisionDueEnabled,
    bool? behindScheduleEnabled,
    bool? weeklyReviewEnabled,
    int? weeklyReviewDay,
    Object? createdAt = _unset,
    Object? updatedAt = _unset,
  }) {
    return ReminderSettings(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      enabled: enabled ?? this.enabled,
      emailLanguage: emailLanguage ?? this.emailLanguage,
      deadlineSoonEnabled: deadlineSoonEnabled ?? this.deadlineSoonEnabled,
      examSoonEnabled: examSoonEnabled ?? this.examSoonEnabled,
      revisionDueEnabled: revisionDueEnabled ?? this.revisionDueEnabled,
      behindScheduleEnabled:
          behindScheduleEnabled ?? this.behindScheduleEnabled,
      weeklyReviewEnabled: weeklyReviewEnabled ?? this.weeklyReviewEnabled,
      weeklyReviewDay: (weeklyReviewDay ?? this.weeklyReviewDay).clamp(0, 6),
      createdAt: identical(createdAt, _unset)
          ? this.createdAt
          : createdAt as DateTime?,
      updatedAt: identical(updatedAt, _unset)
          ? this.updatedAt
          : updatedAt as DateTime?,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ReminderSettings &&
        other.id == id &&
        other.userId == userId &&
        other.enabled == enabled &&
        other.emailLanguage == emailLanguage &&
        other.deadlineSoonEnabled == deadlineSoonEnabled &&
        other.examSoonEnabled == examSoonEnabled &&
        other.revisionDueEnabled == revisionDueEnabled &&
        other.behindScheduleEnabled == behindScheduleEnabled &&
        other.weeklyReviewEnabled == weeklyReviewEnabled &&
        other.weeklyReviewDay == weeklyReviewDay &&
        other.createdAt == createdAt &&
        other.updatedAt == updatedAt;
  }

  @override
  int get hashCode => Object.hash(
        id,
        userId,
        enabled,
        emailLanguage,
        deadlineSoonEnabled,
        examSoonEnabled,
        revisionDueEnabled,
        behindScheduleEnabled,
        weeklyReviewEnabled,
        weeklyReviewDay,
        createdAt,
        updatedAt,
      );
}
