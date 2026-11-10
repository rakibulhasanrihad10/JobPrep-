import 'package:job_prep/features/circulars/domain/entities/circular.dart';
import 'package:job_prep/features/circulars/domain/entities/circular_filter.dart';
import 'package:job_prep/features/circulars/domain/errors/circular_failure.dart';
import 'package:job_prep/features/circulars/domain/repositories/circular_repository.dart';

/// In-memory fake implementation of [CircularRepository] for unit and provider
/// tests without touching Supabase.
class FakeCircularRepository implements CircularRepository {
  /// Creates a [FakeCircularRepository] optionally seeded with [initialItems].
  FakeCircularRepository({
    List<Circular> initialItems = const [],
    this.defaultUserId = 'user-1',
    DateTime Function()? clock,
  })  : _items = List<Circular>.of(initialItems),
        _clock = clock ?? (() => DateTime.utc(2026, 11, 10, 12));

  final List<Circular> _items;
  final String defaultUserId;
  final DateTime Function() _clock;
  int _nextId = 1;

  /// Optional error thrown once on the next repository call when non-null.
  CircularFailure? nextError;

  /// Recorded operations for assertions.
  int getCircularsCalls = 0;
  final List<String> fetchedIds = <String>[];
  final List<Circular> createdItems = <Circular>[];
  final List<Circular> updatedItems = <Circular>[];
  final List<String> deletedIds = <String>[];

  /// Current stored items snapshot.
  List<Circular> get items => List.unmodifiable(_items);

  @override
  Future<List<Circular>> getCirculars({CircularFilter? filter}) async {
    getCircularsCalls += 1;
    _consumeNextErrorIfAny();

    final copy = List<Circular>.of(_items);
    if (filter != null) {
      return filter.apply(copy, now: _clock());
    }
    return const CircularFilter().apply(copy, now: _clock());
  }

  @override
  Future<Circular?> getCircularById(String id) async {
    fetchedIds.add(id);
    _consumeNextErrorIfAny();

    for (final item in _items) {
      if (item.id == id) return item;
    }
    return null;
  }

  @override
  Future<Circular> createCircular(Circular circular) async {
    _consumeNextErrorIfAny();

    if (circular.title.trim().isEmpty) {
      throw const CircularValidationFailure(
        code: 'empty_title',
        message: 'Circular title cannot be empty.',
      );
    }

    final timestamp = _clock().toUtc();
    final created = circular.copyWith(
      id: circular.id.trim().isEmpty ? 'circ-${_nextId++}' : circular.id.trim(),
      userId: circular.userId.trim().isEmpty
          ? defaultUserId
          : circular.userId.trim(),
      title: circular.title.trim(),
      createdAt: circular.createdAt ?? timestamp,
      updatedAt: timestamp,
    );
    _items.add(created);
    createdItems.add(created);
    return created;
  }

  @override
  Future<Circular> updateCircular(Circular circular) async {
    _consumeNextErrorIfAny();

    if (circular.id.trim().isEmpty) {
      throw const CircularValidationFailure(
        code: 'missing_circular_id',
        message: 'Cannot update a circular without an id.',
      );
    }
    if (circular.title.trim().isEmpty) {
      throw const CircularValidationFailure(
        code: 'empty_title',
        message: 'Circular title cannot be empty.',
      );
    }

    final index = _items.indexWhere((item) => item.id == circular.id);
    if (index == -1) {
      throw const CircularNotFoundFailure(code: 'PGRST116');
    }

    final updated = circular.copyWith(
      title: circular.title.trim(),
      createdAt: _items[index].createdAt,
      updatedAt: _clock().toUtc(),
    );
    _items[index] = updated;
    updatedItems.add(updated);
    return updated;
  }

  @override
  Future<void> deleteCircular(String id) async {
    _consumeNextErrorIfAny();

    if (id.trim().isEmpty) {
      throw const CircularValidationFailure(
        code: 'missing_circular_id',
        message: 'Cannot delete a circular without an id.',
      );
    }

    deletedIds.add(id);
    _items.removeWhere((item) => item.id == id);
  }

  void _consumeNextErrorIfAny() {
    final error = nextError;
    if (error != null) {
      nextError = null;
      throw error;
    }
  }
}
