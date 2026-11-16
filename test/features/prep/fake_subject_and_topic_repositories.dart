import 'package:job_prep/features/prep/domain/entities/chapter.dart';
import 'package:job_prep/features/prep/domain/entities/subject.dart';
import 'package:job_prep/features/prep/domain/entities/topic.dart';
import 'package:job_prep/features/prep/domain/errors/prep_failure.dart';
import 'package:job_prep/features/prep/domain/repositories/chapter_repository.dart';
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

  Future<void> reorderSubjects(List<String> orderedSubjectIds) async {
    _consumeError();
    for (var i = 0; i < orderedSubjectIds.length; i++) {
      final id = orderedSubjectIds[i];
      final index = _subjects.indexWhere((s) => s.id == id);
      if (index >= 0) {
        _subjects[index] = _subjects[index].copyWith(sortOrder: i);
      }
    }
  }

  @override
  Future<List<String>> getSubjectIdsForCircular(String circularId) async {
    _consumeError();
    final set = _circularSubjectLinks[circularId];
    if (set == null || set.isEmpty) return const [];
    return List.unmodifiable(set);
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

/// In-memory fake [ChapterRepository] for unit tests.
class FakeChapterRepository implements ChapterRepository {
  /// Creates a [FakeChapterRepository].
  FakeChapterRepository({
    List<Chapter> initialChapters = const [],
    this.defaultUserId = 'user-1',
    DateTime Function()? clock,
  })  : _chapters = List<Chapter>.of(initialChapters),
        _clock = clock ?? (() => DateTime.utc(2026, 11, 10, 12));

  final List<Chapter> _chapters;
  final String defaultUserId;
  final DateTime Function() _clock;
  int _nextId = 1;

  /// Optional error thrown on the next operation when set.
  PrepFailure? nextError;

  @override
  Future<List<Chapter>> getChaptersForSubject(String subjectId) async {
    _consumeError();
    final filtered = _chapters.where((c) => c.subjectId == subjectId).toList()
      ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
    return List.unmodifiable(filtered);
  }

  @override
  Future<Chapter?> getChapterById(String id) async {
    _consumeError();
    return _chapters.where((c) => c.id == id).firstOrNull;
  }

  @override
  Future<Chapter> createChapter(Chapter chapter) async {
    _consumeError();
    final now = _clock().toUtc();
    final created = chapter.copyWith(
      id: chapter.id.trim().isEmpty ? 'chap-${_nextId++}' : chapter.id.trim(),
      userId: chapter.userId.trim().isEmpty ? defaultUserId : chapter.userId,
      createdAt: chapter.createdAt ?? now,
      updatedAt: now,
    );
    _chapters.add(created);
    return created;
  }

  @override
  Future<Chapter> updateChapter(Chapter chapter) async {
    _consumeError();
    final index = _chapters.indexWhere((c) => c.id == chapter.id);
    if (index < 0) throw const PrepNotFoundFailure();
    final updated = chapter.copyWith(updatedAt: _clock().toUtc());
    _chapters[index] = updated;
    return updated;
  }

  @override
  Future<void> deleteChapter(String id) async {
    _consumeError();
    _chapters.removeWhere((c) => c.id == id);
  }

  @override
  Future<void> reorderChapters(List<String> orderedChapterIds) async {
    _consumeError();
    for (var i = 0; i < orderedChapterIds.length; i++) {
      final id = orderedChapterIds[i];
      final index = _chapters.indexWhere((c) => c.id == id);
      if (index >= 0) {
        _chapters[index] = _chapters[index].copyWith(sortOrder: i);
      }
    }
  }

  void _consumeError() {
    final failure = nextError;
    if (failure != null) {
      nextError = null;
      throw failure;
    }
  }
}

/// In-memory fake [TopicRepository] for unit tests.
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
  Future<List<Topic>> getTopicsForChapter(String chapterId) async {
    _consumeError();
    return List.unmodifiable(_topics.where((t) => t.chapterId == chapterId));
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
  Future<List<Topic>> batchCreateTopics(List<Topic> topics) async {
    final result = <Topic>[];
    for (final t in topics) {
      result.add(await createTopic(t));
    }
    return List.unmodifiable(result);
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

  @override
  Future<void> reorderTopics(List<String> orderedTopicIds) async {
    _consumeError();
    for (var i = 0; i < orderedTopicIds.length; i++) {
      final id = orderedTopicIds[i];
      final index = _topics.indexWhere((t) => t.id == id);
      if (index >= 0) {
        _topics[index] = _topics[index].copyWith(sortOrder: i);
      }
    }
  }

  void _consumeError() {
    final failure = nextError;
    if (failure != null) {
      nextError = null;
      throw failure;
    }
  }
}
