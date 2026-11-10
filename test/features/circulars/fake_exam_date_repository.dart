import 'package:job_prep/features/circulars/domain/entities/circular_exam_date.dart';
import 'package:job_prep/features/circulars/domain/errors/circular_failure.dart';
import 'package:job_prep/features/circulars/domain/repositories/exam_date_repository.dart';

/// In-memory fake implementation of [ExamDateRepository] for unit and widget
/// tests without touching Supabase.
class FakeExamDateRepository implements ExamDateRepository {
  /// Creates a [FakeExamDateRepository] optionally seeded with [initialItems].
  FakeExamDateRepository({
    List<CircularExamDate> initialItems = const [],
    this.defaultUserId = 'user-1',
    DateTime Function()? clock,
  })  : _items = List<CircularExamDate>.of(initialItems),
        _clock = clock ?? (() => DateTime.utc(2026, 11, 10, 12));

  final List<CircularExamDate> _items;
  final String defaultUserId;
  final DateTime Function() _clock;
  int _nextId = 1;

  /// Optional failure thrown on the next repository operation when non-null.
  CircularFailure? nextError;

  /// Recorded operations for assertions.
  int fetchCalls = 0;
  final List<CircularExamDate> createdItems = <CircularExamDate>[];
  final List<CircularExamDate> updatedItems = <CircularExamDate>[];
  final List<String> deletedIds = <String>[];

  /// Snapshot of stored exam dates.
  List<CircularExamDate> get items => List.unmodifiable(_items);

  @override
  Future<List<CircularExamDate>> getExamDatesForCircular(
    String circularId,
  ) async {
    fetchCalls += 1;
    _consumeNextErrorIfAny();

    final matching = _items
        .where((item) => item.circularId == circularId)
        .toList()
      ..sort((a, b) => a.examDate.compareTo(b.examDate));
    return List.unmodifiable(matching);
  }

  @override
  Future<CircularExamDate> createExamDate(CircularExamDate examDate) async {
    _consumeNextErrorIfAny();

    if (examDate.circularId.trim().isEmpty) {
      throw const CircularValidationFailure(
        code: 'missing_circular_id',
        message: 'Exam date requires a circular id.',
      );
    }
    if (examDate.stage.trim().isEmpty) {
      throw const CircularValidationFailure(
        code: 'empty_stage',
        message: 'Exam stage cannot be empty.',
      );
    }

    final timestamp = _clock().toUtc();
    final created = examDate.copyWith(
      id: examDate.id.trim().isEmpty ? 'ed-${_nextId++}' : examDate.id.trim(),
      userId: examDate.userId.trim().isEmpty
          ? defaultUserId
          : examDate.userId.trim(),
      stage: examDate.stage.trim(),
      createdAt: examDate.createdAt ?? timestamp,
      updatedAt: timestamp,
    );
    _items.add(created);
    createdItems.add(created);
    return created;
  }

  @override
  Future<CircularExamDate> updateExamDate(CircularExamDate examDate) async {
    _consumeNextErrorIfAny();

    if (examDate.id.trim().isEmpty) {
      throw const CircularValidationFailure(
        code: 'missing_exam_date_id',
        message: 'Cannot update an exam date without an id.',
      );
    }
    if (examDate.stage.trim().isEmpty) {
      throw const CircularValidationFailure(
        code: 'empty_stage',
        message: 'Exam stage cannot be empty.',
      );
    }

    final index = _items.indexWhere((item) => item.id == examDate.id);
    if (index == -1) {
      throw const CircularNotFoundFailure(code: 'PGRST116');
    }

    final updated = examDate.copyWith(
      stage: examDate.stage.trim(),
      createdAt: _items[index].createdAt,
      updatedAt: _clock().toUtc(),
    );
    _items[index] = updated;
    updatedItems.add(updated);
    return updated;
  }

  @override
  Future<void> deleteExamDate(String id) async {
    _consumeNextErrorIfAny();

    if (id.trim().isEmpty) {
      throw const CircularValidationFailure(
        code: 'missing_exam_date_id',
        message: 'Cannot delete an exam date without an id.',
      );
    }

    _items.removeWhere((item) => item.id == id);
    deletedIds.add(id);
  }

  void _consumeNextErrorIfAny() {
    final error = nextError;
    if (error != null) {
      nextError = null;
      throw error;
    }
  }
}
