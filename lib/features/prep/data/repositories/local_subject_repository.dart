import 'package:drift/drift.dart';
import 'package:job_prep/core/local/database/app_database.dart';
import 'package:job_prep/features/prep/domain/entities/subject.dart';
import 'package:job_prep/features/prep/domain/errors/prep_failure.dart';
import 'package:job_prep/features/prep/domain/repositories/subject_repository.dart';
import 'package:uuid/uuid.dart';

/// Local Drift SQLite implementation of [SubjectRepository].
class LocalSubjectRepository implements SubjectRepository {
  /// Creates a [LocalSubjectRepository].
  const LocalSubjectRepository(this._db);

  final AppDatabase _db;

  @override
  Future<List<Subject>> getSubjects() async {
    final query = _db.select(_db.localSubjects)
      ..orderBy([
        (t) => OrderingTerm.asc(t.sortOrder),
        (t) => OrderingTerm.asc(t.createdAt),
      ]);
    final rows = await query.get();
    return List.unmodifiable(rows.map(_mapRow));
  }

  @override
  Future<Subject?> getSubjectById(String id) async {
    final trimmedId = id.trim();
    if (trimmedId.isEmpty) return null;

    final query = _db.select(_db.localSubjects)
      ..where((t) => t.id.equals(trimmedId));
    final row = await query.getSingleOrNull();
    if (row == null) return null;
    return _mapRow(row);
  }

  @override
  Future<Subject> createSubject(Subject subject) async {
    _validateForWrite(subject);

    final id =
        subject.id.trim().isEmpty ? const Uuid().v4() : subject.id.trim();
    final now = DateTime.now().toUtc();
    final entry = LocalSubjectsCompanion(
      id: Value(id),
      name: Value(subject.name.trim()),
      color:
          Value(subject.color.trim().isEmpty ? 'gold' : subject.color.trim()),
      icon: Value(
        subject.icon.trim().isEmpty ? 'menu_book' : subject.icon.trim(),
      ),
      examType: Value(
        subject.examType.trim().isEmpty ? 'general' : subject.examType.trim(),
      ),
      sortOrder: Value(subject.sortOrder < 0 ? 0 : subject.sortOrder),
      createdAt: Value(subject.createdAt ?? now),
      updatedAt: Value(now),
    );

    await _db.into(_db.localSubjects).insertOnConflictUpdate(entry);
    return subject.copyWith(
      id: id,
      createdAt: subject.createdAt ?? now,
      updatedAt: now,
    );
  }

  @override
  Future<Subject> updateSubject(Subject subject) async {
    final trimmedId = subject.id.trim();
    if (trimmedId.isEmpty) {
      throw const PrepValidationFailure(
        code: 'missing_subject_id',
        message: 'Cannot update a subject without an id.',
      );
    }
    _validateForWrite(subject);

    final existing = await (_db.select(_db.localSubjects)
          ..where((t) => t.id.equals(trimmedId)))
        .getSingleOrNull();
    if (existing == null) {
      throw const PrepNotFoundFailure(
        code: 'subject_not_found',
        message: 'Subject not found.',
      );
    }

    final now = DateTime.now().toUtc();
    final entry = LocalSubjectsCompanion(
      id: Value(trimmedId),
      name: Value(subject.name.trim()),
      color:
          Value(subject.color.trim().isEmpty ? 'gold' : subject.color.trim()),
      icon: Value(
        subject.icon.trim().isEmpty ? 'menu_book' : subject.icon.trim(),
      ),
      examType: Value(
        subject.examType.trim().isEmpty ? 'general' : subject.examType.trim(),
      ),
      sortOrder: Value(subject.sortOrder < 0 ? 0 : subject.sortOrder),
      createdAt: Value(existing.createdAt),
      updatedAt: Value(now),
    );

    await _db.update(_db.localSubjects).replace(entry);
    return subject.copyWith(
      id: trimmedId,
      createdAt: existing.createdAt,
      updatedAt: now,
    );
  }

  @override
  Future<void> deleteSubject(String id) async {
    final trimmedId = id.trim();
    if (trimmedId.isEmpty) {
      throw const PrepValidationFailure(
        code: 'missing_subject_id',
        message: 'Cannot delete a subject without an id.',
      );
    }

    await _db.transaction(() async {
      await (_db.delete(_db.localCircularSubjects)
            ..where((t) => t.subjectId.equals(trimmedId)))
          .go();
      await (_db.delete(_db.localTopics)
            ..where((t) => t.subjectId.equals(trimmedId)))
          .go();
      await (_db.delete(_db.localMaterials)
            ..where((t) => t.subjectId.equals(trimmedId)))
          .go();
      await (_db.delete(_db.localSubjects)
            ..where((t) => t.id.equals(trimmedId)))
          .go();
    });
  }

  @override
  Future<List<String>> getSubjectIdsForCircular(String circularId) async {
    final trimmedId = circularId.trim();
    if (trimmedId.isEmpty) return const [];

    final query = _db.select(_db.localCircularSubjects)
      ..where((t) => t.circularId.equals(trimmedId));
    final rows = await query.get();
    return List.unmodifiable(rows.map((r) => r.subjectId));
  }

  @override
  Future<void> linkSubjectToCircular({
    required String circularId,
    required String subjectId,
  }) async {
    final trimmedCircularId = circularId.trim();
    final trimmedSubjectId = subjectId.trim();
    if (trimmedCircularId.isEmpty || trimmedSubjectId.isEmpty) return;

    final existing = await (_db.select(_db.localCircularSubjects)
          ..where(
            (t) =>
                t.circularId.equals(trimmedCircularId) &
                t.subjectId.equals(trimmedSubjectId),
          ))
        .getSingleOrNull();
    if (existing != null) return;

    final now = DateTime.now().toUtc();
    await _db.into(_db.localCircularSubjects).insert(
          LocalCircularSubjectsCompanion(
            id: Value(const Uuid().v4()),
            circularId: Value(trimmedCircularId),
            subjectId: Value(trimmedSubjectId),
            createdAt: Value(now),
            updatedAt: Value(now),
          ),
        );
  }

  @override
  Future<void> unlinkSubjectFromCircular({
    required String circularId,
    required String subjectId,
  }) async {
    final trimmedCircularId = circularId.trim();
    final trimmedSubjectId = subjectId.trim();
    if (trimmedCircularId.isEmpty || trimmedSubjectId.isEmpty) return;

    await (_db.delete(_db.localCircularSubjects)
          ..where(
            (t) =>
                t.circularId.equals(trimmedCircularId) &
                t.subjectId.equals(trimmedSubjectId),
          ))
        .go();
  }

  void _validateForWrite(Subject subject) {
    if (subject.name.trim().isEmpty) {
      throw const PrepValidationFailure(
        code: 'missing_subject_name',
        message: 'A subject must have a non-empty name.',
      );
    }
  }

  Subject _mapRow(LocalSubject row) {
    return Subject(
      id: row.id,
      name: row.name,
      color: row.color,
      icon: row.icon,
      examType: row.examType,
      sortOrder: row.sortOrder,
      createdAt: row.createdAt,
      updatedAt: row.updatedAt,
    );
  }
}
