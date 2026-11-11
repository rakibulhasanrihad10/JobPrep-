import 'dart:async';

import 'package:job_prep/features/prep/domain/entities/revision_item.dart';
import 'package:job_prep/features/prep/domain/errors/prep_failure.dart';
import 'package:job_prep/features/prep/domain/repositories/revision_item_repository.dart';

/// In-memory fake [RevisionItemRepository] for unit, widget, and golden tests.
class FakeRevisionItemRepository implements RevisionItemRepository {
  /// Creates a [FakeRevisionItemRepository].
  FakeRevisionItemRepository({
    List<RevisionItem> initialItems = const <RevisionItem>[],
    this.defaultUserId = 'user-1',
    DateTime Function()? clock,
  })  : _items = List<RevisionItem>.of(initialItems),
        _clock = clock ?? (() => DateTime.utc(2026, 11, 11, 10));

  final List<RevisionItem> _items;

  /// User ID populated when omitted in tests.
  final String defaultUserId;
  final DateTime Function() _clock;
  int _nextId = 1;

  /// Optional error thrown once on the next repository call when non-null.
  PrepFailure? nextError;

  /// Optional gate awaited during `getRevisionItems()` to simulate loading.
  Completer<void>? getItemsGate;

  /// Snapshot of stored revision marks.
  List<RevisionItem> get items => List<RevisionItem>.unmodifiable(_items);

  void _consumeError() {
    final err = nextError;
    if (err != null) {
      nextError = null;
      throw err;
    }
  }

  @override
  Future<List<RevisionItem>> getRevisionItems() async {
    final gate = getItemsGate;
    if (gate != null && !gate.isCompleted) {
      await gate.future;
    }
    _consumeError();
    return List<RevisionItem>.unmodifiable(_items);
  }

  @override
  Future<RevisionItem> createRevisionItem(RevisionItem item) async {
    _consumeError();
    final now = _clock().toUtc();
    final created = item.copyWith(
      id: item.id.trim().isEmpty ? 'rev-${_nextId++}' : item.id.trim(),
      userId: item.userId.trim().isEmpty ? defaultUserId : item.userId.trim(),
      createdAt: item.createdAt ?? now,
      updatedAt: now,
    );
    _items.add(created);
    return created;
  }

  @override
  Future<List<RevisionItem>> createRevisionItems(
    List<RevisionItem> items,
  ) async {
    _consumeError();
    final created = <RevisionItem>[];
    for (final item in items) {
      created.add(await createRevisionItem(item));
    }
    return List<RevisionItem>.unmodifiable(created);
  }

  @override
  Future<RevisionItem> updateRevisionItem(RevisionItem item) async {
    _consumeError();
    final idx = _items.indexWhere((element) => element.id == item.id);
    if (idx < 0) throw const PrepNotFoundFailure();
    final existing = _items[idx];
    final updated = item.copyWith(
      userId: existing.userId.isNotEmpty ? existing.userId : defaultUserId,
      createdAt: existing.createdAt,
      updatedAt: _clock().toUtc(),
    );
    _items[idx] = updated;
    return updated;
  }

  @override
  Future<void> deleteRevisionItem(String id) async {
    _consumeError();
    _items.removeWhere((element) => element.id == id);
  }
}
