import 'package:drift/drift.dart';
import 'package:job_prep/core/local/database/app_database.dart';
import 'package:job_prep/features/prep/domain/entities/prep_enums.dart';
import 'package:job_prep/features/prep/domain/entities/progress_log.dart';
import 'package:job_prep/features/prep/domain/errors/prep_failure.dart';
import 'package:job_prep/features/prep/domain/repositories/progress_log_repository.dart';
import 'package:uuid/uuid.dart';

/// Local Drift SQLite implementation of [ProgressLogRepository].
///
/// Recalculates the affected material's `completedUnits` within a single
/// transaction on every insert, update, or delete, clamping units between
/// `0` and `totalUnits`.
class LocalProgressLogRepository implements ProgressLogRepository {
  /// Creates a [LocalProgressLogRepository].
  const LocalProgressLogRepository(this._db);

  final AppDatabase _db;

  @override
  Future<List<ProgressLog>> getLogsForMaterial(String materialId) async {
    final trimmedId = materialId.trim();
    if (trimmedId.isEmpty) return const [];

    final query = _db.select(_db.localProgressLogs)
      ..where((t) => t.materialId.equals(trimmedId))
      ..orderBy([
        (t) => OrderingTerm.desc(t.loggedOn),
        (t) => OrderingTerm.desc(t.createdAt),
      ]);
    final rows = await query.get();
    return List.unmodifiable(rows.map(_mapRow));
  }

  @override
  Future<List<ProgressLog>> getRecentLogs({int limit = 50}) async {
    final safeLimit = limit <= 0 ? 50 : limit;
    final query = _db.select(_db.localProgressLogs)
      ..orderBy([
        (t) => OrderingTerm.desc(t.loggedOn),
        (t) => OrderingTerm.desc(t.createdAt),
      ])
      ..limit(safeLimit);
    final rows = await query.get();
    return List.unmodifiable(rows.map(_mapRow));
  }

  @override
  Future<ProgressLog> createLog(ProgressLog log) async {
    _validateForWrite(log);

    final id = log.id.trim().isEmpty ? const Uuid().v4() : log.id.trim();
    final now = DateTime.now().toUtc();
    final entry = LocalProgressLogsCompanion(
      id: Value(id),
      materialId: Value(log.materialId.trim()),
      unitsDone: Value(log.unitsDone),
      entryType: Value(log.entryType.value),
      loggedOn: Value(log.loggedOn.toUtc()),
      note: Value(log.note),
      createdAt: Value(log.createdAt ?? now),
      updatedAt: Value(now),
    );

    return await _db.transaction(() async {
      await _db.into(_db.localProgressLogs).insertOnConflictUpdate(entry);
      await _recalculateMaterialUnits(log.materialId.trim());
      return log.copyWith(
        id: id,
        createdAt: log.createdAt ?? now,
        updatedAt: now,
      );
    });
  }

  @override
  Future<ProgressLog> updateLog(ProgressLog log) async {
    final trimmedId = log.id.trim();
    if (trimmedId.isEmpty) {
      throw const PrepValidationFailure(
        code: 'missing_log_id',
        message: 'Cannot update a progress log without an id.',
      );
    }
    _validateForWrite(log);

    return await _db.transaction(() async {
      final existing = await (_db.select(_db.localProgressLogs)
            ..where((t) => t.id.equals(trimmedId)))
          .getSingleOrNull();
      if (existing == null) {
        throw const PrepNotFoundFailure(
          code: 'log_not_found',
          message: 'Progress log not found.',
        );
      }

      final now = DateTime.now().toUtc();
      final entry = LocalProgressLogsCompanion(
        id: Value(trimmedId),
        materialId: Value(log.materialId.trim()),
        unitsDone: Value(log.unitsDone),
        entryType: Value(log.entryType.value),
        loggedOn: Value(log.loggedOn.toUtc()),
        note: Value(log.note),
        createdAt: Value(existing.createdAt),
        updatedAt: Value(now),
      );

      await _db.update(_db.localProgressLogs).replace(entry);
      await _recalculateMaterialUnits(log.materialId.trim());
      if (existing.materialId != log.materialId.trim()) {
        await _recalculateMaterialUnits(existing.materialId);
      }

      return log.copyWith(
        id: trimmedId,
        createdAt: existing.createdAt,
        updatedAt: now,
      );
    });
  }

  @override
  Future<void> deleteLog(String id) async {
    final trimmedId = id.trim();
    if (trimmedId.isEmpty) {
      throw const PrepValidationFailure(
        code: 'missing_log_id',
        message: 'Cannot delete a progress log without an id.',
      );
    }

    await _db.transaction(() async {
      final existing = await (_db.select(_db.localProgressLogs)
            ..where((t) => t.id.equals(trimmedId)))
          .getSingleOrNull();
      if (existing == null) return;

      await (_db.delete(_db.localProgressLogs)
            ..where((t) => t.id.equals(trimmedId)))
          .go();
      await _recalculateMaterialUnits(existing.materialId);
    });
  }

  Future<void> _recalculateMaterialUnits(String materialId) async {
    if (materialId.trim().isEmpty) return;

    final logs = await (_db.select(_db.localProgressLogs)
          ..where((t) => t.materialId.equals(materialId)))
        .get();

    var sum = 0;
    for (final l in logs) {
      sum += l.unitsDone;
    }

    final material = await (_db.select(_db.localMaterials)
          ..where((t) => t.id.equals(materialId)))
        .getSingleOrNull();
    if (material == null) return;

    final newCompleted = sum.clamp(0, material.totalUnits);
    final entry = material.toCompanion(true).copyWith(
          completedUnits: Value(newCompleted),
          updatedAt: Value(DateTime.now().toUtc()),
        );
    await _db.update(_db.localMaterials).replace(entry);
  }

  void _validateForWrite(ProgressLog log) {
    if (log.materialId.trim().isEmpty) {
      throw const PrepValidationFailure(
        code: 'missing_material_id',
        message: 'A progress log must be linked to a material.',
      );
    }
  }

  ProgressLog _mapRow(LocalProgressLog row) {
    return ProgressLog(
      id: row.id,
      materialId: row.materialId,
      unitsDone: row.unitsDone,
      entryType: ProgressLogEntryType.fromValue(row.entryType),
      loggedOn: row.loggedOn,
      note: row.note,
      createdAt: row.createdAt,
      updatedAt: row.updatedAt,
    );
  }
}
