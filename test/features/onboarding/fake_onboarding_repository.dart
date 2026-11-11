import 'package:job_prep/features/onboarding/domain/entities/onboarding_draft.dart';
import 'package:job_prep/features/onboarding/domain/entities/onboarding_status.dart';
import 'package:job_prep/features/onboarding/domain/errors/onboarding_failure.dart';
import 'package:job_prep/features/onboarding/domain/repositories/onboarding_repository.dart';

/// In-memory fake [OnboardingRepository] for unit, widget, and golden tests.
class FakeOnboardingRepository implements OnboardingRepository {
  /// Creates a [FakeOnboardingRepository].
  FakeOnboardingRepository({
    OnboardingStatus? initialStatus,
    this.userId = 'user-1',
    DateTime Function()? clock,
  })  : _status = initialStatus ?? OnboardingStatus(userId: userId),
        _clock = clock ?? (() => DateTime.utc(2026, 11, 12, 3));

  OnboardingStatus _status;

  /// Active user ID stamped on saved records.
  final String userId;
  final DateTime Function() _clock;

  /// Optional error thrown once on the next repository operation when non-null.
  OnboardingFailure? nextError;

  /// Current stored status snapshot.
  OnboardingStatus get currentStatus => _status;

  /// Counter for `saveProgress` calls.
  int saveProgressCalls = 0;

  /// Counter for `completeOnboarding` calls.
  int completeCalls = 0;

  /// Counter for `resetOnboarding` calls.
  int resetCalls = 0;

  /// Counter for `dismissTodayTips` calls.
  int dismissTipsCalls = 0;

  @override
  Future<OnboardingStatus> getStatus() async {
    _consumeError();
    return _status;
  }

  @override
  Future<OnboardingStatus> saveProgress({
    required int step,
    required OnboardingDraft draft,
  }) async {
    _consumeError();
    saveProgressCalls += 1;
    final now = _clock().toUtc();
    return _status = _status.copyWith(
      id: _status.id.isEmpty ? 'user-settings-1' : _status.id,
      userId: _status.userId.isEmpty ? userId : _status.userId,
      onboardingStep: step.clamp(1, 6),
      draft: draft,
      createdAt: _status.createdAt ?? now,
      updatedAt: now,
    );
  }

  @override
  Future<OnboardingStatus> completeOnboarding({
    required DateTime completedAt,
    required OnboardingDraft draft,
  }) async {
    _consumeError();
    completeCalls += 1;
    final now = _clock().toUtc();
    return _status = _status.copyWith(
      id: _status.id.isEmpty ? 'user-settings-1' : _status.id,
      userId: _status.userId.isEmpty ? userId : _status.userId,
      onboardingCompletedAt: completedAt.toUtc(),
      onboardingStep: 6,
      draft: draft,
      todayTipsDismissed: false,
      createdAt: _status.createdAt ?? now,
      updatedAt: now,
    );
  }

  @override
  Future<OnboardingStatus> resetOnboarding() async {
    _consumeError();
    resetCalls += 1;
    final now = _clock().toUtc();
    return _status = _status.copyWith(
      id: _status.id.isEmpty ? 'user-settings-1' : _status.id,
      userId: _status.userId.isEmpty ? userId : _status.userId,
      onboardingCompletedAt: null,
      onboardingStep: 1,
      updatedAt: now,
    );
  }

  @override
  Future<OnboardingStatus> dismissTodayTips() async {
    _consumeError();
    dismissTipsCalls += 1;
    return _status = _status.copyWith(
      todayTipsDismissed: true,
      updatedAt: _clock().toUtc(),
    );
  }

  void _consumeError() {
    final err = nextError;
    if (err != null) {
      nextError = null;
      throw err;
    }
  }
}
