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
    Object? createdAt = _unset,
    Object? updatedAt = _unset,
  }) {
    return ReminderSettings(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      enabled: enabled ?? this.enabled,
      emailLanguage: emailLanguage ?? this.emailLanguage,
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
        other.createdAt == createdAt &&
        other.updatedAt == updatedAt;
  }

  @override
  int get hashCode => Object.hash(
        id,
        userId,
        enabled,
        emailLanguage,
        createdAt,
        updatedAt,
      );
}
