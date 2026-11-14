import 'package:drift/drift.dart';
import 'package:job_prep/core/local/database/app_database.dart';
import 'package:job_prep/features/prep/domain/entities/mock_test.dart';
import 'package:job_prep/features/prep/domain/errors/prep_failure.dart';
import 'package:job_prep/features/prep/domain/repositories/mock_test_repository.dart';
import 'package:uuid/uuid.dart';

/// Local Drift SQLite implementation of [MockTestRepository].
class LocalMockTestRepository implements MockTestRepository {
  /// Creates a [LocalMockTestRepository].
  const LocalMockTestRepository(this._db);

  final AppDatabase _db;

  @override
  Future<List<MockTest>> getTests() async {
    final query = _db.select(_db.localMockTests)
      ..orderBy([
        (t) => OrderingTerm.desc(t.takenOn),
        (t) => OrderingTerm.desc(t.createdAt),
      ]);
    final rows = await query.get();
    return List.unmodifiable(rows.map(_mapRow));
  }

  @override
  Future<List<MockTest>> getTestsForSubject(String subjectId) async {
    final trimmedId = subjectId.trim();
    if (trimmedId.isEmpty) return const [];

    final query = _db.select(_db.localMockTests)
      ..where((t) => t.subjectId.equals(trimmedId))
      ..orderBy([
        (t) => OrderingTerm.desc(t.takenOn),
        (t) => OrderingTerm.desc(t.createdAt),
      ]);
    final rows = await query.get();
    return List.unmodifiable(rows.map(_mapRow));
  }

  @override
  Future<MockTest> createTest(MockTest test) async {
    _validateForWrite(test);

    final id = test.id.trim().isEmpty ? const Uuid().v4() : test.id.trim();
    final now = DateTime.now().toUtc();
    final entry = _toCompanion(test, id: id, now: now);

    await _db.into(_db.localMockTests).insertOnConflictUpdate(entry);
    return test.copyWith(
      id: id,
      createdAt: test.createdAt ?? now,
      updatedAt: now,
    );
  }

  @override
  Future<MockTest> updateTest(MockTest test) async {
    final trimmedId = test.id.trim();
    if (trimmedId.isEmpty) {
      throw const PrepValidationFailure(
        code: 'missing_mock_test_id',
        message: 'Cannot update a mock test without an id.',
      );
    }
    _validateForWrite(test);

    final existing = await (_db.select(_db.localMockTests)
          ..where((t) => t.id.equals(trimmedId)))
        .getSingleOrNull();
    if (existing == null) {
      throw const PrepNotFoundFailure(
        code: 'mock_test_not_found',
        message: 'Mock test not found.',
      );
    }

    final now = DateTime.now().toUtc();
    final entry = _toCompanion(
      test,
      id: trimmedId,
      now: now,
      createdAt: existing.createdAt,
    );

    await _db.update(_db.localMockTests).replace(entry);
    return test.copyWith(
      id: trimmedId,
      createdAt: existing.createdAt,
      updatedAt: now,
    );
  }

  @override
  Future<void> deleteTest(String id) async {
    final trimmedId = id.trim();
    if (trimmedId.isEmpty) {
      throw const PrepValidationFailure(
        code: 'missing_mock_test_id',
        message: 'Cannot delete a mock test without an id.',
      );
    }

    await (_db.delete(_db.localMockTests)..where((t) => t.id.equals(trimmedId)))
        .go();
  }

  void _validateForWrite(MockTest test) {
    if (test.subjectId.trim().isEmpty) {
      throw const PrepValidationFailure(
        code: 'missing_subject_id',
        message: 'A mock test must be associated with a subject.',
      );
    }
    if (test.title.trim().isEmpty) {
      throw const PrepValidationFailure(
        code: 'missing_mock_test_title',
        message: 'A mock test must have a non-empty title.',
      );
    }
    if (test.totalMarks <= 0) {
      throw const PrepValidationFailure(
        code: 'invalid_total_marks',
        message: 'Total marks must be greater than zero.',
      );
    }
    if (test.marksObtained < 0) {
      throw const PrepValidationFailure(
        code: 'invalid_marks_obtained',
        message: 'Marks obtained cannot be negative.',
      );
    }
  }

  LocalMockTestsCompanion _toCompanion(
    MockTest t, {
    required String id,
    required DateTime now,
    DateTime? createdAt,
  }) {
    return LocalMockTestsCompanion(
      id: Value(id),
      subjectId: Value(t.subjectId.trim()),
      circularId: Value(t.circularId?.trim()),
      materialId: Value(t.materialId?.trim()),
      topicId: Value(t.topicId?.trim()),
      title: Value(t.title.trim()),
      source: Value(t.source?.trim()),
      takenOn: Value(t.takenOn.toUtc()),
      marksObtained: Value(t.marksObtained),
      totalMarks: Value(t.totalMarks),
      negativeMarks: Value(t.negativeMarks),
      timeTakenMinutes: Value(t.timeTakenMinutes),
      timeLimitMinutes: Value(t.timeLimitMinutes),
      weakTopics: Value(t.weakTopics),
      notes: Value(t.notes),
      createdAt: Value(t.createdAt ?? createdAt ?? now),
      updatedAt: Value(now),
    );
  }

  MockTest _mapRow(LocalMockTest row) {
    return MockTest(
      id: row.id,
      subjectId: row.subjectId,
      circularId: row.circularId,
      materialId: row.materialId,
      topicId: row.topicId,
      title: row.title,
      source: row.source,
      takenOn: row.takenOn,
      marksObtained: row.marksObtained,
      totalMarks: row.totalMarks,
      negativeMarks: row.negativeMarks,
      timeTakenMinutes: row.timeTakenMinutes,
      timeLimitMinutes: row.timeLimitMinutes,
      weakTopics: row.weakTopics,
      notes: row.notes,
      createdAt: row.createdAt,
      updatedAt: row.updatedAt,
    );
  }
}
