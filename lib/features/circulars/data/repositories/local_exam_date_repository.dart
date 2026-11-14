import 'package:drift/drift.dart';
import 'package:job_prep/core/local/database/app_database.dart';
import 'package:job_prep/features/circulars/domain/entities/circular_exam_date.dart';
import 'package:job_prep/features/circulars/domain/errors/circular_failure.dart';
import 'package:job_prep/features/circulars/domain/repositories/exam_date_repository.dart';
import 'package:uuid/uuid.dart';

/// Local Drift SQLite implementation of [ExamDateRepository].
class LocalExamDateRepository implements ExamDateRepository {
  /// Creates a [LocalExamDateRepository].
  const LocalExamDateRepository(this._db);

  final AppDatabase _db;

  @override
  Future<List<CircularExamDate>> getExamDatesForCircular(
    String circularId,
  ) async {
    final trimmedId = circularId.trim();
    if (trimmedId.isEmpty) return const [];

    final query = _db.select(_db.localCircularExamDates)
      ..where((t) => t.circularId.equals(trimmedId))
      ..orderBy([(t) => OrderingTerm.asc(t.examDate)]);

    final rows = await query.get();
    return List.unmodifiable(rows.map(_mapRow));
  }

  @override
  Future<CircularExamDate> createExamDate(CircularExamDate examDate) async {
    _validateForWrite(examDate);

    final id =
        examDate.id.trim().isEmpty ? const Uuid().v4() : examDate.id.trim();
    final now = DateTime.now().toUtc();
    final entry = LocalCircularExamDatesCompanion(
      id: Value(id),
      circularId: Value(examDate.circularId.trim()),
      stage: Value(examDate.stage.trim()),
      examDate: Value(examDate.examDate.toUtc()),
      venue: Value(examDate.venue),
      notes: Value(examDate.notes),
      createdAt: Value(examDate.createdAt ?? now),
      updatedAt: Value(now),
    );

    await _db.into(_db.localCircularExamDates).insertOnConflictUpdate(entry);
    return examDate.copyWith(
      id: id,
      createdAt: examDate.createdAt ?? now,
      updatedAt: now,
    );
  }

  @override
  Future<CircularExamDate> updateExamDate(CircularExamDate examDate) async {
    final trimmedId = examDate.id.trim();
    if (trimmedId.isEmpty) {
      throw const CircularValidationFailure(
        code: 'missing_exam_date_id',
        message: 'Cannot update an exam date without an id.',
      );
    }
    _validateForWrite(examDate);

    final existing = await (_db.select(_db.localCircularExamDates)
          ..where((t) => t.id.equals(trimmedId)))
        .getSingleOrNull();
    if (existing == null) {
      throw const CircularNotFoundFailure();
    }

    final now = DateTime.now().toUtc();
    final entry = LocalCircularExamDatesCompanion(
      id: Value(trimmedId),
      circularId: Value(examDate.circularId.trim()),
      stage: Value(examDate.stage.trim()),
      examDate: Value(examDate.examDate.toUtc()),
      venue: Value(examDate.venue),
      notes: Value(examDate.notes),
      createdAt: Value(existing.createdAt),
      updatedAt: Value(now),
    );

    await _db.update(_db.localCircularExamDates).replace(entry);
    return examDate.copyWith(
      id: trimmedId,
      createdAt: existing.createdAt,
      updatedAt: now,
    );
  }

  @override
  Future<void> deleteExamDate(String id) async {
    final trimmedId = id.trim();
    if (trimmedId.isEmpty) {
      throw const CircularValidationFailure(
        code: 'missing_exam_date_id',
        message: 'Cannot delete an exam date without an id.',
      );
    }

    await (_db.delete(_db.localCircularExamDates)
          ..where((t) => t.id.equals(trimmedId)))
        .go();
  }

  void _validateForWrite(CircularExamDate examDate) {
    if (examDate.circularId.trim().isEmpty) {
      throw const CircularValidationFailure(
        code: 'missing_circular_id',
        message: 'An exam date must be associated with a circular.',
      );
    }
    if (examDate.stage.trim().isEmpty) {
      throw const CircularValidationFailure(
        code: 'missing_stage',
        message: 'An exam date must specify an exam stage.',
      );
    }
  }

  CircularExamDate _mapRow(LocalCircularExamDate row) {
    return CircularExamDate(
      id: row.id,
      circularId: row.circularId,
      stage: row.stage,
      examDate: row.examDate,
      venue: row.venue,
      notes: row.notes,
      createdAt: row.createdAt,
      updatedAt: row.updatedAt,
    );
  }
}
