import 'package:job_prep/features/prep/domain/entities/study_plan.dart';
import 'package:job_prep/features/prep/domain/errors/prep_failure.dart';
import 'package:job_prep/features/prep/domain/repositories/study_plan_repository.dart';

/// In-memory fake [StudyPlanRepository] for unit, widget, and golden tests.
class FakeStudyPlanRepository implements StudyPlanRepository {
  /// Creates a [FakeStudyPlanRepository].
  FakeStudyPlanRepository({
    List<StudyPlan> initialPlans = const <StudyPlan>[],
    this.defaultUserId = 'user-1',
    DateTime Function()? clock,
  })  : _plans = List<StudyPlan>.of(initialPlans),
        _clock = clock ?? (() => DateTime.utc(2026, 11, 10, 9));

  final List<StudyPlan> _plans;
  final String defaultUserId;
  final DateTime Function() _clock;
  int _nextId = 1;

  /// Optional failure thrown once on the next repository call.
  PrepFailure? nextError;

  /// Current stored study plans snapshot.
  List<StudyPlan> get plans => List<StudyPlan>.unmodifiable(_plans);

  void _consumeError() {
    final err = nextError;
    if (err != null) {
      nextError = null;
      throw err;
    }
  }

  @override
  Future<List<StudyPlan>> getPlans() async {
    _consumeError();
    final copy = List<StudyPlan>.of(_plans)
      ..sort((a, b) => a.targetDate.compareTo(b.targetDate));
    return List<StudyPlan>.unmodifiable(copy);
  }

  @override
  Future<StudyPlan> savePlan(StudyPlan plan) async {
    _consumeError();
    final now = _clock().toUtc();
    final trimmedId = plan.id.trim();

    var idx = -1;
    if (trimmedId.isNotEmpty) {
      idx = _plans.indexWhere((p) => p.id == trimmedId);
    }
    if (idx < 0) {
      idx = _plans.indexWhere(
        (p) => (p.subjectId ?? '') == (plan.subjectId ?? ''),
      );
    }

    if (idx >= 0) {
      final existing = _plans[idx];
      final updated = plan.copyWith(
        id: existing.id,
        userId: existing.userId.isNotEmpty ? existing.userId : defaultUserId,
        createdAt: existing.createdAt ?? now,
        updatedAt: now,
      );
      _plans[idx] = updated;
      return updated;
    }

    final created = plan.copyWith(
      id: 'plan-${_nextId++}',
      userId: plan.userId.isNotEmpty ? plan.userId : defaultUserId,
      createdAt: now,
      updatedAt: now,
    );
    _plans.add(created);
    return created;
  }

  @override
  Future<void> deletePlan(String id) async {
    _consumeError();
    _plans.removeWhere((p) => p.id == id);
  }
}
