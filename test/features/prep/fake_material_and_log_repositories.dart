import 'package:job_prep/features/prep/domain/entities/prep_material.dart';
import 'package:job_prep/features/prep/domain/entities/progress_log.dart';
import 'package:job_prep/features/prep/domain/errors/prep_failure.dart';
import 'package:job_prep/features/prep/domain/repositories/material_repository.dart';
import 'package:job_prep/features/prep/domain/repositories/progress_log_repository.dart';

/// In-memory fake [MaterialRepository].
class FakeMaterialRepository implements MaterialRepository {
  /// Creates a [FakeMaterialRepository].
  FakeMaterialRepository({
    List<PrepMaterial> initialMaterials = const [],
    this.defaultUserId = 'user-1',
    DateTime Function()? clock,
  })  : _materials = List<PrepMaterial>.of(initialMaterials),
        _clock = clock ?? (() => DateTime.utc(2026, 11, 10, 12));

  final List<PrepMaterial> _materials;
  final String defaultUserId;
  final DateTime Function() _clock;
  int _nextId = 1;

  /// Optional error thrown on the next operation when set.
  PrepFailure? nextError;

  /// Snapshot of stored materials.
  List<PrepMaterial> get materials => List.unmodifiable(_materials);

  /// Updates `completedUnits` clamped to `[0, totalUnits]` to mirror the DB
  /// recalculation trigger in tests.
  void applyCompletedUnits({
    required String materialId,
    required int rawSum,
  }) {
    final index = _materials.indexWhere((m) => m.id == materialId);
    if (index < 0) return;
    final current = _materials[index];
    final clamped = rawSum.clamp(0, current.totalUnits);
    _materials[index] = current.copyWith(
      completedUnits: clamped,
      updatedAt: _clock().toUtc(),
    );
  }

  @override
  Future<List<PrepMaterial>> getAllMaterials() async {
    _consumeError();
    return List.unmodifiable(_materials);
  }

  @override
  Future<List<PrepMaterial>> getMaterialsForSubject(String subjectId) async {
    _consumeError();
    return List.unmodifiable(
      _materials.where((m) => m.subjectId == subjectId),
    );
  }

  @override
  Future<PrepMaterial?> getMaterialById(String id) async {
    _consumeError();
    for (final m in _materials) {
      if (m.id == id) return m;
    }
    return null;
  }

  @override
  Future<PrepMaterial> createMaterial(PrepMaterial material) async {
    _consumeError();
    final now = _clock().toUtc();
    final clamped = material.completedUnits.clamp(0, material.totalUnits);
    final created = material.copyWith(
      id: material.id.trim().isEmpty ? 'mat-${_nextId++}' : material.id.trim(),
      userId: material.userId.trim().isEmpty ? defaultUserId : material.userId,
      completedUnits: clamped,
      createdAt: material.createdAt ?? now,
      updatedAt: now,
    );
    _materials.add(created);
    return created;
  }

  @override
  Future<PrepMaterial> updateMaterial(PrepMaterial material) async {
    _consumeError();
    final index = _materials.indexWhere((m) => m.id == material.id);
    if (index < 0) throw const PrepNotFoundFailure();
    final clamped = material.completedUnits.clamp(0, material.totalUnits);
    final updated = material.copyWith(
      completedUnits: clamped,
      updatedAt: _clock().toUtc(),
    );
    _materials[index] = updated;
    return updated;
  }

  @override
  Future<void> deleteMaterial(String id) async {
    _consumeError();
    _materials.removeWhere((m) => m.id == id);
  }

  void _consumeError() {
    final failure = nextError;
    if (failure != null) {
      nextError = null;
      throw failure;
    }
  }
}

/// In-memory fake [ProgressLogRepository] optionally syncing completed units on
/// a backing [FakeMaterialRepository] like PostgreSQL's trigger.
class FakeProgressLogRepository implements ProgressLogRepository {
  /// Creates a [FakeProgressLogRepository].
  FakeProgressLogRepository({
    List<ProgressLog> initialLogs = const [],
    this.materialRepository,
    this.defaultUserId = 'user-1',
    DateTime Function()? clock,
  })  : _logs = List<ProgressLog>.of(initialLogs),
        _clock = clock ?? (() => DateTime.utc(2026, 11, 10, 12));

  final List<ProgressLog> _logs;

  /// Optional linked material store whose `completedUnits` stays recalculated.
  final FakeMaterialRepository? materialRepository;
  final String defaultUserId;
  final DateTime Function() _clock;
  int _nextId = 1;

  /// Optional error thrown on the next operation when set.
  PrepFailure? nextError;

  @override
  Future<List<ProgressLog>> getLogsForMaterial(String materialId) async {
    _consumeError();
    final matching = _logs.where((l) => l.materialId == materialId).toList()
      ..sort((a, b) => b.loggedOn.compareTo(a.loggedOn));
    return List.unmodifiable(matching);
  }

  @override
  Future<List<ProgressLog>> getRecentLogs({int limit = 50}) async {
    _consumeError();
    final sorted = List<ProgressLog>.of(_logs)
      ..sort((a, b) => b.loggedOn.compareTo(a.loggedOn));
    return List.unmodifiable(sorted.take(limit));
  }

  @override
  Future<ProgressLog> createLog(ProgressLog log) async {
    _consumeError();
    final now = _clock().toUtc();
    final created = log.copyWith(
      id: log.id.trim().isEmpty ? 'log-${_nextId++}' : log.id.trim(),
      userId: log.userId.trim().isEmpty ? defaultUserId : log.userId,
      createdAt: log.createdAt ?? now,
      updatedAt: now,
    );
    _logs.add(created);
    _recalculate(created.materialId);
    return created;
  }

  @override
  Future<ProgressLog> updateLog(ProgressLog log) async {
    _consumeError();
    final index = _logs.indexWhere((l) => l.id == log.id);
    if (index < 0) throw const PrepNotFoundFailure();
    final oldMaterialId = _logs[index].materialId;
    final updated = log.copyWith(updatedAt: _clock().toUtc());
    _logs[index] = updated;
    if (oldMaterialId != updated.materialId) {
      _recalculate(oldMaterialId);
    }
    _recalculate(updated.materialId);
    return updated;
  }

  @override
  Future<void> deleteLog(String id) async {
    _consumeError();
    final index = _logs.indexWhere((l) => l.id == id);
    if (index < 0) return;
    final materialId = _logs[index].materialId;
    _logs.removeAt(index);
    _recalculate(materialId);
  }

  void _recalculate(String materialId) {
    final repo = materialRepository;
    if (repo == null) return;
    var sum = 0;
    for (final log in _logs) {
      if (log.materialId == materialId) {
        sum += log.unitsDone;
      }
    }
    repo.applyCompletedUnits(materialId: materialId, rawSum: sum);
  }

  void _consumeError() {
    final failure = nextError;
    if (failure != null) {
      nextError = null;
      throw failure;
    }
  }
}
