import 'package:drift/drift.dart';

/// Local SQLite schema for in-app notifications.
class LocalNotifications extends Table {
  @override
  String get tableName => 'notifications';

  TextColumn get id => text()();
  TextColumn get type => text()();
  TextColumn get messageKey => text()();
  TextColumn get params => text().withDefault(const Constant('{}'))();
  TextColumn get route => text()();
  TextColumn get dedupeKey => text()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get readAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

/// Local SQLite schema for application portal accounts (ciphertext only).
class LocalPortalAccounts extends Table {
  @override
  String get tableName => 'portal_accounts';

  TextColumn get id => text()();
  TextColumn get circularId => text()();
  TextColumn get portalUrl => text().nullable()();
  TextColumn get username => text()();
  TextColumn get encryptedPassword => text()();
  TextColumn get salt => text()();
  TextColumn get nonce => text()();
  IntColumn get iterations => integer().withDefault(const Constant(210000))();
  TextColumn get notes => text().nullable()();
  DateTimeColumn get createdAt => dateTime().nullable()();
  DateTimeColumn get updatedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

/// Local SQLite schema for user settings, onboarding state, and preferences.
class LocalUserSettings extends Table {
  @override
  String get tableName => 'user_settings';

  TextColumn get id => text()();
  DateTimeColumn get onboardingCompletedAt => dateTime().nullable()();
  IntColumn get onboardingStep => integer().withDefault(const Constant(1))();
  TextColumn get onboardingDraft => text().withDefault(const Constant('{}'))();
  BoolColumn get todayTipsDismissed =>
      boolean().withDefault(const Constant(false))();
  TextColumn get displayName => text().nullable()();
  TextColumn get themeMode => text().withDefault(const Constant('system'))();
  BoolColumn get reduceEffects =>
      boolean().withDefault(const Constant(false))();
  TextColumn get localeCode => text().withDefault(const Constant('en'))();
  BoolColumn get banglaDigits => boolean().withDefault(const Constant(false))();
  IntColumn get focusMinutes => integer().withDefault(const Constant(25))();
  IntColumn get shortBreakMinutes => integer().withDefault(const Constant(5))();
  IntColumn get longBreakMinutes => integer().withDefault(const Constant(15))();
  DateTimeColumn get createdAt => dateTime().nullable()();
  DateTimeColumn get updatedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

/// Local SQLite schema for reminder and notification settings.
class LocalUserReminderSettings extends Table {
  @override
  String get tableName => 'user_reminder_settings';

  TextColumn get id => text()();
  BoolColumn get remindersEnabled =>
      boolean().withDefault(const Constant(true))();
  TextColumn get leadDays => text().withDefault(const Constant('[7, 3, 1]'))();
  TextColumn get reminderLanguage => text().withDefault(const Constant('en'))();
  BoolColumn get deadlineSoon => boolean().withDefault(const Constant(true))();
  BoolColumn get examSoon => boolean().withDefault(const Constant(true))();
  BoolColumn get revisionDue => boolean().withDefault(const Constant(true))();
  BoolColumn get behindSchedule =>
      boolean().withDefault(const Constant(true))();
  BoolColumn get weeklyReview => boolean().withDefault(const Constant(true))();
  IntColumn get weeklyReviewDay => integer().withDefault(const Constant(0))();
  DateTimeColumn get createdAt => dateTime().nullable()();
  DateTimeColumn get updatedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}
