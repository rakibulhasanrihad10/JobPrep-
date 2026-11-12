import 'dart:async';

import 'package:job_prep/features/prep/domain/entities/mock_test.dart';
import 'package:job_prep/features/prep/domain/errors/prep_failure.dart';
import 'package:job_prep/features/prep/domain/repositories/mock_test_repository.dart';

/// In-memory fake [MockTestRepository] for unit, widget, and golden tests.
class FakeMockTestRepository implements MockTestRepository {
  /// Creates a [FakeMockTestRepository].
  FakeMockTestRepository({
    List<MockTest> initialTests = const <MockTest>[],
    this.defaultUserId = 'user-1',
    DateTime Function()? clock,
  })  : _tests = List<MockTest>.of(initialTests),
        _clock = clock ?? (() => DateTime.utc(2026, 11, 10, 9));

  final List<MockTest> _tests;
  final String defaultUserId;
  final DateTime Function() _clock;
  int _nextId = 1;

  /// Optional failure thrown once on the next repository call when non-null.
  PrepFailure? nextError;

  /// Optional barrier awaited during `getTests()` to simulate loading states.
  Completer<void>? getTestsGate;

  /// Snapshot of stored tests.
  List<MockTest> get tests => List<MockTest>.unmodifiable(_tests);

  void _consumeError() {
    final err = nextError;
    if (err != null) {
      nextError = null;
      throw err;
    }
  }

  @override
  Future<List<MockTest>> getTests() async {
    final gate = getTestsGate;
    if (gate != null && !gate.isCompleted) {
      await gate.future;
    }
    _consumeError();
    final copy = List<MockTest>.of(_tests)
      ..sort((a, b) => b.takenOn.compareTo(a.takenOn));
    return List<MockTest>.unmodifiable(copy);
  }

  @override
  Future<List<MockTest>> getTestsForSubject(String subjectId) async {
    _consumeError();
    final copy = _tests
        .where((t) => t.subjectId == subjectId)
        .toList(growable: false)
      ..sort((a, b) => b.takenOn.compareTo(a.takenOn));
    return List<MockTest>.unmodifiable(copy);
  }

  @override
  Future<MockTest> createTest(MockTest test) async {
    _consumeError();
    final now = _clock().toUtc();
    final created = test.copyWith(
      id: test.id.trim().isEmpty ? 'mock-${_nextId++}' : test.id.trim(),
      userId: test.userId.trim().isEmpty ? defaultUserId : test.userId.trim(),
      createdAt: test.createdAt ?? now,
      updatedAt: now,
    );
    _tests.add(created);
    return created;
  }

  @override
  Future<MockTest> updateTest(MockTest test) async {
    _consumeError();
    final idx = _tests.indexWhere((t) => t.id == test.id);
    if (idx < 0) throw const PrepNotFoundFailure();
    final existing = _tests[idx];
    final updated = test.copyWith(
      userId: existing.userId.isNotEmpty ? existing.userId : defaultUserId,
      createdAt: existing.createdAt,
      updatedAt: _clock().toUtc(),
    );
    _tests[idx] = updated;
    return updated;
  }

  @override
  Future<void> deleteTest(String id) async {
    _consumeError();
    _tests.removeWhere((t) => t.id == id);
  }
}
