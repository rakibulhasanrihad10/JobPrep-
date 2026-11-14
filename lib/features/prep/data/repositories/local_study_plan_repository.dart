import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:job_prep/core/local/database/app_database.dart';
import 'package:job_prep/features/prep/domain/entities/study_plan.dart';
import 'package:job_prep/features/prep/domain/errors/prep_failure.dart';
import 'package:job_prep/features/prep/domain/repositories/study_plan_repository.dart';
import 'package:uuid/uuid.dart';

/// Local Drift SQLite implementation of [StudyPlanRepository].
class LocalStudyPlanRepository implements StudyPlanRepository {
  /// Creates a [LocalStudyPlanRepository].
  const LocalStudyPlanRepository(this._db);

  final AppDatabase _db;

  @override
  Future<List<StudyPlan>> getPlans() async {
    final query = _db.select(_db.localStudyPlans)
      ..orderBy([
        (t) => OrderingTerm.asc(t.targetDate),
        (t) => OrderingTerm.asc(t.createdAt),
      ]);
    final rows = await query.get();
    return List.unmodifiable(rows.map(_mapRow));
  }

  @override
  Future<StudyPlan> savePlan(StudyPlan plan) async {
    _validateForWrite(plan);

    final trimmedId = plan.id.trim();
    final now = DateTime.now().toUtc();

    if (trimmedId.isNotEmpty) {
      final existing = await (_db.select(_db.localStudyPlans)
            ..where((t) => t.id.equals(trimmedId)))
          .getSingleOrNull();
      if (existing != null) {
        final entry = _toCompanion(
          plan,
          id: trimmedId,
          now: now,
          createdAt: existing.createdAt,
        );
        await _db.update(_db.localStudyPlans).replace(entry);
        return plan.copyWith(
          id: trimmedId,
          createdAt: existing.createdAt,
          updatedAt: now,
        );
      }
    }

    final existingScope = await _findExistingInScope(plan.subjectId);
    if (existingScope != null) {
      final entry = _toCompanion(
        plan,
        id: existingScope.id,
        now: now,
        createdAt: existingScope.createdAt,
      );
      await _db.update(_db.localStudyPlans).replace(entry);
      return plan.copyWith(
        id: existingScope.id,
        createdAt: existingScope.createdAt,
        updatedAt: now,
      );
    }

    final newId = trimmedId.isEmpty ? const Uuid().v4() : trimmedId;
    final entry = _toCompanion(plan, id: newId, now: now);
    await _db.into(_db.localStudyPlans).insertOnConflictUpdate(entry);
    return plan.copyWith(
      id: newId,
      createdAt: plan.createdAt ?? now,
      updatedAt: now,
    );
  }

  @override
  Future<void> deletePlan(String id) async {
    final trimmedId = id.trim();
    if (trimmedId.isEmpty) {
      throw const PrepValidationFailure(
        code: 'missing_study_plan_id',
        message: 'Cannot delete a study plan without an id.',
      );
    }

    await (_db.delete(_db.localStudyPlans)
          ..where((t) => t.id.equals(trimmedId)))
        .go();
  }

  Future<LocalStudyPlan?> _findExistingInScope(String? subjectId) async {
    final trimmed = subjectId?.trim();
    if (trimmed == null || trimmed.isEmpty) {
      return await (_db.select(_db.localStudyPlans)
            ..where((t) => t.subjectId.isNull()))
          .getSingleOrNull();
    }
    return await (_db.select(_db.localStudyPlans)
          ..where((t) => t.subjectId.equals(trimmed)))
        .getSingleOrNull();
  }

  void _validateForWrite(StudyPlan plan) {
    if (plan.targetDate.isBefore(plan.startDate)) {
      throw const PrepValidationFailure(
        code: 'invalid_target_date',
        message: 'Target date cannot be earlier than start date.',
      );
    }
  }

  LocalStudyPlansCompanion _toCompanion(
    StudyPlan p, {
    required String id,
    required DateTime now,
    DateTime? createdAt,
  }) {
    return LocalStudyPlansCompanion(
      id: Value(id),
      subjectId: Value(p.subjectId?.trim()),
      circularId: Value(p.circularId?.trim()),
      examDateId: Value(p.examDateId?.trim()),
      startDate: Value(p.startDate.toUtc()),
      targetDate: Value(p.targetDate.toUtc()),
      finishBufferDays: Value(p.finishBufferDays),
      restDaysPerWeek: Value(p.restDaysPerWeek),
      extraStudyDays: Value(p.extraStudyDays),
      maxDailyPace: Value(p.maxDailyPace),
      initialCompletedUnits: Value(p.initialCompletedUnits),
      postponedMaterialIds: Value(jsonEncode(p.postponedMaterialIds)),
      createdAt: Value(p.createdAt ?? createdAt ?? now),
      updatedAt: Value(now),
    );
  }

  StudyPlan _mapRow(LocalStudyPlan row) {
    List<String> postponed;
    try {
      final decoded = jsonDecode(row.postponedMaterialIds);
      postponed = (decoded as List)
          .map((e) => e.toString())
          .where((e) => e.isNotEmpty)
          .toList();
    } on Object catch (_) {
      postponed = const [];
    }

    return StudyPlan(
      id: row.id,
      subjectId: row.subjectId,
      circularId: row.circularId,
      examDateId: row.examDateId,
      startDate: row.startDate,
      targetDate: row.targetDate,
      finishBufferDays: row.finishBufferDays,
      restDaysPerWeek: row.restDaysPerWeek,
      extraStudyDays: row.extraStudyDays,
      maxDailyPace: row.maxDailyPace,
      initialCompletedUnits: row.initialCompletedUnits,
      postponedMaterialIds: postponed,
      createdAt: row.createdAt,
      updatedAt: row.updatedAt,
    );
  }
}
