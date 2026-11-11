import 'package:job_prep/features/settings/domain/entities/reminder_settings.dart';
import 'package:job_prep/features/settings/domain/errors/reminder_failure.dart';
import 'package:job_prep/features/settings/domain/repositories/reminder_settings_repository.dart';

/// In-memory fake [ReminderSettingsRepository] for unit and widget tests.
class FakeReminderSettingsRepository implements ReminderSettingsRepository {
  /// Creates a [FakeReminderSettingsRepository].
  FakeReminderSettingsRepository({
    ReminderSettings? initialSettings,
    this.defaultUserId = 'user-1',
    DateTime Function()? clock,
  })  : _settings = initialSettings ?? ReminderSettings(userId: defaultUserId),
        _clock = clock ?? (() => DateTime.utc(2026, 11, 11, 8));

  ReminderSettings _settings;
  final String defaultUserId;
  final DateTime Function() _clock;

  /// Optional failure thrown on the next read or write when non-null.
  ReminderFailure? nextError;

  /// Current stored reminder settings.
  ReminderSettings get currentSettings => _settings;

  /// Number of `saveSettings` calls processed without error.
  int saveCalls = 0;

  @override
  Future<ReminderSettings> getSettings() async {
    _consumeError();
    return _settings;
  }

  @override
  Future<ReminderSettings> saveSettings({
    required bool enabled,
    required ReminderEmailLanguage emailLanguage,
  }) async {
    _consumeError();
    saveCalls += 1;
    final now = _clock().toUtc();
    return _settings = _settings.copyWith(
      id: _settings.id.isEmpty ? 'rem-pref-1' : _settings.id,
      userId: _settings.userId.isEmpty ? defaultUserId : _settings.userId,
      enabled: enabled,
      emailLanguage: emailLanguage,
      createdAt: _settings.createdAt ?? now,
      updatedAt: now,
    );
  }

  void _consumeError() {
    final failure = nextError;
    if (failure != null) {
      nextError = null;
      throw failure;
    }
  }
}
