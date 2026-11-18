import 'package:drift/drift.dart';
import 'package:job_prep/core/local/database/app_database.dart';
import 'package:job_prep/features/settings/domain/entities/reminder_settings.dart';
import 'package:job_prep/features/settings/domain/repositories/reminder_settings_repository.dart';

/// Local Drift SQLite implementation of [ReminderSettingsRepository].
class LocalReminderSettingsRepository implements ReminderSettingsRepository {
  /// Creates a [LocalReminderSettingsRepository].
  const LocalReminderSettingsRepository(this._db);

  final AppDatabase _db;

  static const String _localSettingsId = 'local_reminder_settings';

  @override
  Future<ReminderSettings> getSettings() async {
    final row = await (_db.select(_db.localUserReminderSettings)
          ..where((t) => t.id.equals(_localSettingsId)))
        .getSingleOrNull();

    if (row == null) {
      return const ReminderSettings();
    }
    return _mapRow(row);
  }

  @override
  Future<ReminderSettings> saveSettings({
    required bool enabled,
    required ReminderEmailLanguage emailLanguage,
    bool? deadlineSoonEnabled,
    bool? examSoonEnabled,
    bool? revisionDueEnabled,
    bool? behindScheduleEnabled,
    bool? weeklyReviewEnabled,
    int? weeklyReviewDay,
  }) async {
    final now = DateTime.now().toUtc();
    final existing = await (_db.select(_db.localUserReminderSettings)
          ..where((t) => t.id.equals(_localSettingsId)))
        .getSingleOrNull();

    final safeDay = weeklyReviewDay == null
        ? (existing?.weeklyReviewDay ?? 0)
        : weeklyReviewDay.clamp(0, 6);

    final companion = LocalUserReminderSettingsCompanion(
      id: const Value(_localSettingsId),
      remindersEnabled: Value(enabled),
      reminderLanguage: Value(emailLanguage.value),
      deadlineSoon:
          Value(deadlineSoonEnabled ?? existing?.deadlineSoon ?? true),
      examSoon: Value(examSoonEnabled ?? existing?.examSoon ?? true),
      revisionDue: Value(revisionDueEnabled ?? existing?.revisionDue ?? true),
      behindSchedule:
          Value(behindScheduleEnabled ?? existing?.behindSchedule ?? true),
      weeklyReview:
          Value(weeklyReviewEnabled ?? existing?.weeklyReview ?? true),
      weeklyReviewDay: Value(safeDay),
      createdAt: Value(existing?.createdAt ?? now),
      updatedAt: Value(now),
    );

    await _db
        .into(_db.localUserReminderSettings)
        .insertOnConflictUpdate(companion);

    return ReminderSettings(
      id: _localSettingsId,
      enabled: enabled,
      emailLanguage: emailLanguage,
      deadlineSoonEnabled:
          deadlineSoonEnabled ?? existing?.deadlineSoon ?? true,
      examSoonEnabled: examSoonEnabled ?? existing?.examSoon ?? true,
      revisionDueEnabled: revisionDueEnabled ?? existing?.revisionDue ?? true,
      behindScheduleEnabled:
          behindScheduleEnabled ?? existing?.behindSchedule ?? true,
      weeklyReviewEnabled:
          weeklyReviewEnabled ?? existing?.weeklyReview ?? true,
      weeklyReviewDay: safeDay,
      createdAt: existing?.createdAt ?? now,
      updatedAt: now,
    );
  }

  ReminderSettings _mapRow(LocalUserReminderSetting row) {
    return ReminderSettings(
      id: row.id,
      enabled: row.remindersEnabled,
      emailLanguage: ReminderEmailLanguage.fromValue(row.reminderLanguage),
      deadlineSoonEnabled: row.deadlineSoon,
      examSoonEnabled: row.examSoon,
      revisionDueEnabled: row.revisionDue,
      behindScheduleEnabled: row.behindSchedule,
      weeklyReviewEnabled: row.weeklyReview,
      weeklyReviewDay: row.weeklyReviewDay,
      createdAt: row.createdAt,
      updatedAt: row.updatedAt,
    );
  }
}
