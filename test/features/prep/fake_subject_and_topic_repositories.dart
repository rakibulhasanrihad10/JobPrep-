import 'package:job_prep/features/prep/domain/entities/subject.dart';
import 'package:job_prep/features/prep/domain/entities/topic.dart';
import 'package:job_prep/features/prep/domain/errors/prep_failure.dart';
import 'package:job_prep/features/prep/domain/repositories/subject_repository.dart';
import 'package:job_prep/features/prep/domain/repositories/topic_repository.dart';

/// In-memory fake [SubjectRepository] for unit and provider tests.
class FakeSubjectRepository implements SubjectRepository {
  /// Creates a [FakeSubjectRepository].
  FakeSubjectRepository({
    List<Subject> initialSubjects = const [],
    this.defaultUserId = 'user-1',
    DateTime Function()? clock,
  })  : _subjects = List<Subject>.of(initialSubjects),
        _clock = clock ?? (() => DateTime.utc(2026, 11, 10, 12));

  final List<Subject> _subjects;
  final Map<String, Set<String>> _circularSubjectLinks =
      <String, Set<String>>{};
  final String defaultUserId;
  final DateTime Function() _clock;
  int _nextId = 1;

  /// Optional error thrown on the next operation when set.
  PrepFailure? nextError;

  /// Current stored subjects.
  List<Subject> get subjects => List.unmodifiable(_subjects);

  @override
  Future<List<Subject>> getSubjects() async {
    _consumeError();
    final sorted = List<Subject>.of(_subjects)
      ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
    return List.unmodifiable(sorted);
  }

  @override
  Future<Subject?> getSubjectById(String id) async {
    _consumeError();
    for (final s in _subjects) {
      if (s.id == id) return s;
    }
    return null;
  }

  @override
  Future<Subject> createSubject(Subject subject) async {
    _consumeError();
    final now = _clock().toUtc();
    final created = subject.copyWith(
      id: subject.id.trim().isEmpty ? 'sub-${_nextId++}' : subject.id.trim(),
      userId: subject.userId.trim().isEmpty ? defaultUserId : subject.userId,
      createdAt: subject.createdAt ?? now,
      updatedAt: now,
    );
    _subjects.add(created);
    return created;
  }

  @override
  Future<Subject> updateSubject(Subject subject) async {
    _consumeError();
    final index = _subjects.indexWhere((s) => s.id == subject.id);
    if (index < 0) throw const PrepNotFoundFailure();
    final updated = subject.copyWith(updatedAt: _clock().toUtc());
    _subjects[index] = updated;
    return updated;
  }

  @override
  Future<void> deleteSubject(String id) async {
    _consumeError();
    _subjects.removeWhere((s) => s.id == id);
  }

  @override
  Future<List<String>> getSubjectIdsForCircular(String circularId) async {
    _consumeError();
    return List<String>.unmodifiable(
      _circularSubjectLinks[circularId] ?? const <String>{},
    );
  }

  @override
  Future<void> linkSubjectToCircular({
    required String circularId,
    required String subjectId,
  }) async {
    _consumeError();
    _circularSubjectLinks
        .putIfAbsent(circularId, () => <String>{})
        .add(subjectId);
  }

  @override
  Future<void> unlinkSubjectFromCircular({
    required String circularId,
    required String subjectId,
  }) async {
    _consumeError();
    _circularSubjectLinks[circularId]?.remove(subjectId);
  }

  void _consumeError() {
    final failure = nextError;
    if (failure != null) {
      nextError = null;
      throw failure;
    }
  }
}

/// In-memory fake [TopicRepository].
class FakeTopicRepository implements TopicRepository {
  /// Creates a [FakeTopicRepository].
  FakeTopicRepository({
    List<Topic> initialTopics = const [],
    this.defaultUserId = 'user-1',
    DateTime Function()? clock,
  })  : _topics = List<Topic>.of(initialTopics),
        _clock = clock ?? (() => DateTime.utc(2026, 11, 10, 12));

  final List<Topic> _topics;
  final String defaultUserId;
  final DateTime Function() _clock;
  int _nextId = 1;

  /// Optional error thrown on the next operation when set.
  PrepFailure? nextError;

  @override
  Future<List<Topic>> getTopicsForSubject(String subjectId) async {
    _consumeError();
    return List.unmodifiable(_topics.where((t) => t.subjectId == subjectId));
  }

  @override
  Future<Topic> createTopic(Topic topic) async {
    _consumeError();
    final now = _clock().toUtc();
    final created = topic.copyWith(
      id: topic.id.trim().isEmpty ? 'top-${_nextId++}' : topic.id.trim(),
      userId: topic.userId.trim().isEmpty ? defaultUserId : topic.userId,
      createdAt: topic.createdAt ?? now,
      updatedAt: now,
    );
    _topics.add(created);
    return created;
  }

  @override
  Future<Topic> updateTopic(Topic topic) async {
    _consumeError();
    final index = _topics.indexWhere((t) => t.id == topic.id);
    if (index < 0) throw const PrepNotFoundFailure();
    final updated = topic.copyWith(updatedAt: _clock().toUtc());
    _topics[index] = updated;
    return updated;
  }

  @override
  Future<void> deleteTopic(String id) async {
    _consumeError();
    _topics.removeWhere((t) => t.id == id);
  }

  void _consumeError() {
    final failure = nextError;
    if (failure != null) {
      nextError = null;
      throw failure;
    }
  }
}
