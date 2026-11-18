import 'package:job_prep/features/settings/domain/entities/user_app_settings.dart';
import 'package:job_prep/features/settings/domain/errors/settings_failure.dart';
import 'package:job_prep/features/settings/domain/repositories/user_settings_repository.dart';

/// In-memory fake [UserSettingsRepository] for Phase 7A unit & widget tests.
class FakeUserSettingsRepository implements UserSettingsRepository {
  /// Creates a [FakeUserSettingsRepository].
  FakeUserSettingsRepository({
    UserAppSettings? initialSettings,
    this.defaultUserId = 'user-1',
    DateTime Function()? clock,
  })  : _settings = initialSettings,
        _clock = clock ?? (() => DateTime.utc(2026, 11, 12, 12));

  /// Fallback owner user ID attached on upserts.
  final String defaultUserId;
  final DateTime Function() _clock;
  UserAppSettings? _settings;

  /// Optional error thrown on next read or upsert call.
  SettingsFailure? nextError;

  /// Count of successful [upsertSettings] invocations.
  int upsertCount = 0;

  /// Latest synced settings stored in memory.
  UserAppSettings? get currentSettings => _settings;

  @override
  Future<UserAppSettings?> getSettings() async {
    _consumeError();
    return _settings;
  }

  @override
  Future<UserAppSettings> upsertSettings(UserAppSettings settings) async {
    _consumeError();
    upsertCount += 1;
    final saved = settings
        .copyWith(
          userId:
              settings.userId.trim().isEmpty ? defaultUserId : settings.userId,
          updatedAt: _clock().toUtc(),
        )
        .normalized();
    _settings = saved;
    return saved;
  }

  void _consumeError() {
    final failure = nextError;
    if (failure != null) {
      nextError = null;
      throw failure;
    }
  }
}
