import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:job_prep/core/local/database/app_database.dart';
import 'package:job_prep/features/onboarding/domain/entities/onboarding_draft.dart';
import 'package:job_prep/features/onboarding/domain/entities/onboarding_status.dart';
import 'package:job_prep/features/onboarding/domain/repositories/onboarding_repository.dart';

/// Local Drift SQLite implementation of [OnboardingRepository].
class LocalOnboardingRepository implements OnboardingRepository {
  /// Creates a [LocalOnboardingRepository].
  const LocalOnboardingRepository(this._db);

  final AppDatabase _db;

  static const String _localSettingsId = 'local_user_settings';

  @override
  Future<OnboardingStatus> getStatus() async {
    final row = await (_db.select(_db.localUserSettings)
          ..where((t) => t.id.equals(_localSettingsId)))
        .getSingleOrNull();

    if (row == null) {
      return const OnboardingStatus(userId: _localSettingsId);
    }
    return _mapRow(row);
  }

  @override
  Future<OnboardingStatus> saveProgress({
    required int step,
    required OnboardingDraft draft,
  }) async {
    final now = DateTime.now().toUtc();
    final existing = await (_db.select(_db.localUserSettings)
          ..where((t) => t.id.equals(_localSettingsId)))
        .getSingleOrNull();

    final companion = LocalUserSettingsCompanion(
      id: const Value(_localSettingsId),
      onboardingStep: Value(step.clamp(1, 6)),
      onboardingDraft: Value(jsonEncode(draft.toJson())),
      createdAt: Value(existing?.createdAt ?? now),
      updatedAt: Value(now),
    );

    await _db.into(_db.localUserSettings).insertOnConflictUpdate(companion);
    return await getStatus();
  }

  @override
  Future<OnboardingStatus> completeOnboarding({
    required DateTime completedAt,
    required OnboardingDraft draft,
  }) async {
    final now = DateTime.now().toUtc();
    final existing = await (_db.select(_db.localUserSettings)
          ..where((t) => t.id.equals(_localSettingsId)))
        .getSingleOrNull();

    final companion = LocalUserSettingsCompanion(
      id: const Value(_localSettingsId),
      onboardingCompletedAt: Value(completedAt.toUtc()),
      onboardingDraft: Value(jsonEncode(draft.toJson())),
      todayTipsDismissed: const Value(false),
      createdAt: Value(existing?.createdAt ?? now),
      updatedAt: Value(now),
    );

    await _db.into(_db.localUserSettings).insertOnConflictUpdate(companion);
    return await getStatus();
  }

  @override
  Future<OnboardingStatus> resetOnboarding() async {
    final now = DateTime.now().toUtc();
    final existing = await (_db.select(_db.localUserSettings)
          ..where((t) => t.id.equals(_localSettingsId)))
        .getSingleOrNull();

    final companion = LocalUserSettingsCompanion(
      id: const Value(_localSettingsId),
      onboardingCompletedAt: const Value(null),
      onboardingStep: const Value(1),
      createdAt: Value(existing?.createdAt ?? now),
      updatedAt: Value(now),
    );

    await _db.into(_db.localUserSettings).insertOnConflictUpdate(companion);
    return await getStatus();
  }

  @override
  Future<OnboardingStatus> dismissTodayTips() async {
    final now = DateTime.now().toUtc();
    final existing = await (_db.select(_db.localUserSettings)
          ..where((t) => t.id.equals(_localSettingsId)))
        .getSingleOrNull();

    final companion = LocalUserSettingsCompanion(
      id: const Value(_localSettingsId),
      todayTipsDismissed: const Value(true),
      createdAt: Value(existing?.createdAt ?? now),
      updatedAt: Value(now),
    );

    await _db.into(_db.localUserSettings).insertOnConflictUpdate(companion);
    return await getStatus();
  }

  OnboardingStatus _mapRow(LocalUserSetting row) {
    OnboardingDraft draft;
    try {
      final decoded = jsonDecode(row.onboardingDraft);
      if (decoded is Map) {
        draft = OnboardingDraft.fromJson(Map<String, dynamic>.from(decoded));
      } else {
        draft = const OnboardingDraft();
      }
    } on Object catch (_) {
      draft = const OnboardingDraft();
    }

    return OnboardingStatus(
      id: row.id,
      userId: row.id,
      onboardingCompletedAt: row.onboardingCompletedAt,
      onboardingStep: row.onboardingStep,
      draft: draft,
      todayTipsDismissed: row.todayTipsDismissed,
      createdAt: row.createdAt,
      updatedAt: row.updatedAt,
    );
  }
}
