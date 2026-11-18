import 'package:drift/drift.dart';
import 'package:job_prep/core/local/database/app_database.dart';
import 'package:job_prep/features/prep/domain/entities/prep_enums.dart';
import 'package:job_prep/features/prep/domain/entities/prep_material.dart';
import 'package:job_prep/features/prep/domain/errors/prep_failure.dart';
import 'package:job_prep/features/prep/domain/repositories/material_repository.dart';
import 'package:uuid/uuid.dart';

/// Local Drift SQLite implementation of [MaterialRepository].
class LocalMaterialRepository implements MaterialRepository {
  /// Creates a [LocalMaterialRepository].
  const LocalMaterialRepository(this._db);

  final AppDatabase _db;

  @override
  Future<List<PrepMaterial>> getAllMaterials() async {
    final query = _db.select(_db.localMaterials)
      ..orderBy([(t) => OrderingTerm.desc(t.createdAt)]);
    final rows = await query.get();
    return List.unmodifiable(rows.map(_mapRow));
  }

  @override
  Future<List<PrepMaterial>> getMaterialsForSubject(String subjectId) async {
    final trimmedId = subjectId.trim();
    if (trimmedId.isEmpty) return const [];

    final query = _db.select(_db.localMaterials)
      ..where((t) => t.subjectId.equals(trimmedId))
      ..orderBy([(t) => OrderingTerm.asc(t.createdAt)]);
    final rows = await query.get();
    return List.unmodifiable(rows.map(_mapRow));
  }

  @override
  Future<PrepMaterial?> getMaterialById(String id) async {
    final trimmedId = id.trim();
    if (trimmedId.isEmpty) return null;

    final query = _db.select(_db.localMaterials)
      ..where((t) => t.id.equals(trimmedId));
    final row = await query.getSingleOrNull();
    if (row == null) return null;
    return _mapRow(row);
  }

  @override
  Future<PrepMaterial> createMaterial(PrepMaterial material) async {
    _validateForWrite(material);

    final id =
        material.id.trim().isEmpty ? const Uuid().v4() : material.id.trim();
    final now = DateTime.now().toUtc();
    final safeTotal = material.totalUnits < 0 ? 0 : material.totalUnits;
    final safeCompleted = material.completedUnits < 0
        ? 0
        : (material.completedUnits > safeTotal
            ? safeTotal
            : material.completedUnits);

    final entry = LocalMaterialsCompanion(
      id: Value(id),
      subjectId: Value(material.subjectId.trim()),
      title: Value(material.title.trim()),
      kind: Value(material.kind.value),
      unitLabel: Value(
        material.unitLabel.trim().isEmpty ? 'pages' : material.unitLabel.trim(),
      ),
      totalUnits: Value(safeTotal),
      completedUnits: Value(safeCompleted),
      coverImagePath: Value(material.coverImagePath),
      coverImageUrl: Value(material.coverImageUrl),
      createdAt: Value(material.createdAt ?? now),
      updatedAt: Value(now),
    );

    await _db.into(_db.localMaterials).insertOnConflictUpdate(entry);
    return material.copyWith(
      id: id,
      totalUnits: safeTotal,
      completedUnits: safeCompleted,
      createdAt: material.createdAt ?? now,
      updatedAt: now,
    );
  }

  @override
  Future<PrepMaterial> updateMaterial(PrepMaterial material) async {
    final trimmedId = material.id.trim();
    if (trimmedId.isEmpty) {
      throw const PrepValidationFailure(
        code: 'missing_material_id',
        message: 'Cannot update a material without an id.',
      );
    }
    _validateForWrite(material);

    final existing = await (_db.select(_db.localMaterials)
          ..where((t) => t.id.equals(trimmedId)))
        .getSingleOrNull();
    if (existing == null) {
      throw const PrepNotFoundFailure(
        code: 'material_not_found',
        message: 'Material not found.',
      );
    }

    final now = DateTime.now().toUtc();
    final safeTotal = material.totalUnits < 0 ? 0 : material.totalUnits;
    final safeCompleted = material.completedUnits < 0
        ? 0
        : (material.completedUnits > safeTotal
            ? safeTotal
            : material.completedUnits);

    final entry = LocalMaterialsCompanion(
      id: Value(trimmedId),
      subjectId: Value(material.subjectId.trim()),
      title: Value(material.title.trim()),
      kind: Value(material.kind.value),
      unitLabel: Value(
        material.unitLabel.trim().isEmpty ? 'pages' : material.unitLabel.trim(),
      ),
      totalUnits: Value(safeTotal),
      completedUnits: Value(safeCompleted),
      coverImagePath: Value(material.coverImagePath),
      coverImageUrl: Value(material.coverImageUrl),
      createdAt: Value(existing.createdAt),
      updatedAt: Value(now),
    );

    await _db.update(_db.localMaterials).replace(entry);
    return material.copyWith(
      id: trimmedId,
      totalUnits: safeTotal,
      completedUnits: safeCompleted,
      createdAt: existing.createdAt,
      updatedAt: now,
    );
  }

  @override
  Future<void> deleteMaterial(String id) async {
    final trimmedId = id.trim();
    if (trimmedId.isEmpty) {
      throw const PrepValidationFailure(
        code: 'missing_material_id',
        message: 'Cannot delete a material without an id.',
      );
    }

    await _db.transaction(() async {
      await (_db.delete(_db.localProgressLogs)
            ..where((t) => t.materialId.equals(trimmedId)))
          .go();
      await (_db.delete(_db.localMaterials)
            ..where((t) => t.id.equals(trimmedId)))
          .go();
    });
  }

  void _validateForWrite(PrepMaterial material) {
    if (material.subjectId.trim().isEmpty) {
      throw const PrepValidationFailure(
        code: 'missing_subject_id',
        message: 'A material must belong to a subject.',
      );
    }
    if (material.title.trim().isEmpty) {
      throw const PrepValidationFailure(
        code: 'missing_material_title',
        message: 'A material must have a non-empty title.',
      );
    }
    if (material.totalUnits < 0) {
      throw const PrepValidationFailure(
        code: 'invalid_total_units',
        message: 'Total units cannot be negative.',
      );
    }
    if (material.completedUnits < 0) {
      throw const PrepValidationFailure(
        code: 'invalid_completed_units',
        message: 'Completed units cannot be negative.',
      );
    }
  }

  PrepMaterial _mapRow(LocalMaterial row) {
    return PrepMaterial(
      id: row.id,
      subjectId: row.subjectId,
      title: row.title,
      kind: MaterialKind.fromValue(row.kind),
      unitLabel: row.unitLabel,
      totalUnits: row.totalUnits,
      completedUnits: row.completedUnits,
      coverImagePath: row.coverImagePath,
      coverImageUrl: row.coverImageUrl,
      createdAt: row.createdAt,
      updatedAt: row.updatedAt,
    );
  }
}
