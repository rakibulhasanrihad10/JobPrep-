import 'package:drift/drift.dart';
import 'package:job_prep/core/local/database/app_database.dart';
import 'package:job_prep/features/circulars/domain/entities/application_checklist.dart';
import 'package:job_prep/features/circulars/domain/entities/circular.dart';
import 'package:job_prep/features/circulars/domain/entities/circular_enums.dart';
import 'package:job_prep/features/circulars/domain/entities/circular_exam_date.dart';
import 'package:job_prep/features/circulars/domain/entities/circular_filter.dart';
import 'package:job_prep/features/circulars/domain/errors/circular_failure.dart';
import 'package:job_prep/features/circulars/domain/repositories/circular_repository.dart';
import 'package:uuid/uuid.dart';

/// Local Drift SQLite implementation of [CircularRepository].
class LocalCircularRepository implements CircularRepository {
  /// Creates a [LocalCircularRepository].
  const LocalCircularRepository(this._db);

  final AppDatabase _db;

  @override
  Future<List<Circular>> getCirculars({CircularFilter? filter}) async {
    final query = _db.select(_db.localCirculars)
      ..orderBy([
        (t) => OrderingTerm(
              expression: t.deadline,
              nulls: NullsOrder.last,
            ),
        (t) => OrderingTerm(
              expression: t.updatedAt,
              mode: OrderingMode.desc,
              nulls: NullsOrder.last,
            ),
      ]);

    final rows = await query.get();
    final examDates = await _db.select(_db.localCircularExamDates).get();

    final examDatesByCircular = <String, List<CircularExamDate>>{};
    for (final d in examDates) {
      examDatesByCircular
          .putIfAbsent(d.circularId, () => <CircularExamDate>[])
          .add(_mapExamDate(d));
    }

    final circulars = rows.map((row) {
      final dates = examDatesByCircular[row.id] ?? const <CircularExamDate>[];
      return _mapCircular(row, dates);
    }).toList();

    if (filter != null) {
      return filter.apply(circulars);
    }
    return List.unmodifiable(circulars);
  }

  @override
  Future<Circular?> getCircularById(String id) async {
    final trimmedId = id.trim();
    if (trimmedId.isEmpty) return null;

    final query = _db.select(_db.localCirculars)
      ..where((t) => t.id.equals(trimmedId));
    final row = await query.getSingleOrNull();
    if (row == null) return null;

    final datesQuery = _db.select(_db.localCircularExamDates)
      ..where((t) => t.circularId.equals(trimmedId))
      ..orderBy([(t) => OrderingTerm.asc(t.examDate)]);
    final dateRows = await datesQuery.get();

    return _mapCircular(row, dateRows.map(_mapExamDate).toList());
  }

  @override
  Future<Circular> createCircular(Circular circular) async {
    _validateForWrite(circular);

    final id =
        circular.id.trim().isEmpty ? const Uuid().v4() : circular.id.trim();
    final now = DateTime.now().toUtc();
    final entry = _toCompanion(circular, id: id, now: now);

    await _db.into(_db.localCirculars).insertOnConflictUpdate(entry);
    return circular.copyWith(
      id: id,
      createdAt: circular.createdAt ?? now,
      updatedAt: now,
    );
  }

  @override
  Future<Circular> updateCircular(Circular circular) async {
    final trimmedId = circular.id.trim();
    if (trimmedId.isEmpty) {
      throw const CircularValidationFailure(
        code: 'missing_circular_id',
        message: 'Cannot update a circular without an id.',
      );
    }
    _validateForWrite(circular);

    final existing = await (_db.select(_db.localCirculars)
          ..where((t) => t.id.equals(trimmedId)))
        .getSingleOrNull();
    if (existing == null) {
      throw const CircularNotFoundFailure();
    }

    final now = DateTime.now().toUtc();
    final entry = _toCompanion(
      circular,
      id: trimmedId,
      now: now,
      createdAt: existing.createdAt,
    );

    await _db.update(_db.localCirculars).replace(entry);
    return circular.copyWith(
      id: trimmedId,
      createdAt: existing.createdAt,
      updatedAt: now,
    );
  }

  @override
  Future<void> deleteCircular(String id) async {
    final trimmedId = id.trim();
    if (trimmedId.isEmpty) {
      throw const CircularValidationFailure(
        code: 'missing_circular_id',
        message: 'Cannot delete a circular without an id.',
      );
    }

    await _db.transaction(() async {
      await (_db.delete(_db.localCircularExamDates)
            ..where((t) => t.circularId.equals(trimmedId)))
          .go();
      await (_db.delete(_db.localCirculars)
            ..where((t) => t.id.equals(trimmedId)))
          .go();
    });
  }

  void _validateForWrite(Circular circular) {
    if (circular.title.trim().isEmpty) {
      throw const CircularValidationFailure(
        code: 'missing_title',
        message: 'A circular must have a non-empty title.',
      );
    }
    final vacancies = circular.vacancies;
    if (vacancies != null && vacancies < 0) {
      throw const CircularValidationFailure(
        code: 'invalid_vacancies',
        message: 'Vacancies cannot be negative.',
      );
    }
  }

  LocalCircularsCompanion _toCompanion(
    Circular c, {
    required String id,
    required DateTime now,
    DateTime? createdAt,
  }) {
    return LocalCircularsCompanion(
      id: Value(id),
      title: Value(c.title.trim()),
      sector: Value(c.sector.value),
      organizationName: Value(c.organizationName),
      organizationWebsite: Value(c.organizationWebsite),
      circularUrl: Value(c.circularUrl),
      applicationUrl: Value(c.applicationUrl),
      deadline: Value(c.deadline),
      vacancies: Value(c.vacancies),
      salaryMin: Value(c.salaryMin),
      salaryMax: Value(c.salaryMax),
      salaryNote: Value(c.salaryNote),
      applicationFee: Value(c.applicationFee),
      feeNote: Value(c.feeNote),
      applicationStatus: Value(c.applicationStatus.value),
      admitCardStatus: Value(c.admitCardStatus.value),
      priority: Value(c.priority.value),
      workflowStatus: Value(c.workflowStatus.value),
      instructions: Value(c.instructions),
      notes: Value(c.notes),
      syllabus: Value(c.syllabus),
      isQuickCapture: Value(c.isQuickCapture),
      checklistPhoto: Value(c.checklist.photo),
      checklistCertificates: Value(c.checklist.certificates),
      checklistFeePaid: Value(c.checklist.feePaid),
      checklistSubmitted: Value(c.checklist.submitted),
      checklistAdmitCardDownloaded: Value(c.checklist.admitCardDownloaded),
      createdAt: Value(c.createdAt ?? createdAt ?? now),
      updatedAt: Value(now),
    );
  }

  Circular _mapCircular(LocalCircular row, List<CircularExamDate> examDates) {
    return Circular(
      id: row.id,
      title: row.title,
      sector: CircularSector.fromValue(row.sector),
      organizationName: row.organizationName,
      organizationWebsite: row.organizationWebsite,
      circularUrl: row.circularUrl,
      applicationUrl: row.applicationUrl,
      deadline: row.deadline,
      vacancies: row.vacancies,
      salaryMin: row.salaryMin,
      salaryMax: row.salaryMax,
      salaryNote: row.salaryNote,
      applicationFee: row.applicationFee,
      feeNote: row.feeNote,
      applicationStatus: ApplicationStatus.fromValue(row.applicationStatus),
      admitCardStatus: AdmitCardStatus.fromValue(row.admitCardStatus),
      priority: CircularPriority.fromValue(row.priority),
      workflowStatus: CircularWorkflowStatus.fromValue(row.workflowStatus),
      instructions: row.instructions,
      notes: row.notes,
      syllabus: row.syllabus,
      isQuickCapture: row.isQuickCapture,
      checklist: ApplicationChecklist(
        photo: row.checklistPhoto,
        certificates: row.checklistCertificates,
        feePaid: row.checklistFeePaid,
        submitted: row.checklistSubmitted,
        admitCardDownloaded: row.checklistAdmitCardDownloaded,
      ),
      createdAt: row.createdAt,
      updatedAt: row.updatedAt,
      examDates: examDates,
    );
  }

  CircularExamDate _mapExamDate(LocalCircularExamDate row) {
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
