import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:job_prep/features/auth/presentation/providers/auth_providers.dart';
import 'package:job_prep/features/prep/domain/entities/chapter.dart';
import 'package:job_prep/features/prep/domain/entities/prep_enums.dart';
import 'package:job_prep/features/prep/domain/entities/subject.dart';
import 'package:job_prep/features/prep/domain/entities/topic.dart';
import 'package:job_prep/features/prep/domain/repositories/chapter_repository.dart';
import 'package:job_prep/features/prep/domain/repositories/subject_repository.dart';
import 'package:job_prep/features/prep/domain/repositories/topic_repository.dart';
import 'package:job_prep/features/prep/domain/utils/syllabus_outline_parser.dart';
import 'package:job_prep/features/prep/presentation/providers/prep_providers.dart';
import 'package:job_prep/features/prep/presentation/providers/syllabus_providers.dart';
import 'package:uuid/uuid.dart';

const _uuid = Uuid();

/// Controller handling syllabus mutations: chapters, topics, checkpoints.
class SyllabusController {
  SyllabusController(this._ref);

  final Ref _ref;

  ChapterRepository get _chapterRepo => _ref.read(chapterRepositoryProvider);
  TopicRepository get _topicRepo => _ref.read(topicRepositoryProvider);
  SubjectRepository get _subjectRepo => _ref.read(subjectRepositoryProvider);
  String get _currentUserId => _ref.read(currentUserProvider)?.id ?? '';

  void _invalidateSubject(String subjectId) {
    _ref
      ..invalidate(chaptersForSubjectProvider(subjectId))
      ..invalidate(topicsForSubjectProvider(subjectId));
  }

  /// Toggles a topic checkpoint timestamp.
  Future<void> toggleCheckpoint({
    required Topic topic,
    required SyllabusCheckpoint checkpoint,
    required bool isDone,
  }) async {
    final stamp = isDone ? DateTime.now().toUtc() : null;
    final updated = switch (checkpoint) {
      SyllabusCheckpoint.study => topic.copyWith(studyDoneAt: stamp),
      SyllabusCheckpoint.practice => topic.copyWith(practiceDoneAt: stamp),
      SyllabusCheckpoint.modelTest => topic.copyWith(modelTestDoneAt: stamp),
      SyllabusCheckpoint.revision => topic.copyWith(revisionDoneAt: stamp),
    };
    await _topicRepo.updateTopic(updated);
    _invalidateSubject(topic.subjectId);
  }

  /// Updates exact completion date for a topic checkpoint.
  Future<void> updateTopicDate({
    required Topic topic,
    required SyllabusCheckpoint checkpoint,
    DateTime? date,
  }) async {
    final stamp = date?.toUtc();
    final updated = switch (checkpoint) {
      SyllabusCheckpoint.study => topic.copyWith(studyDoneAt: stamp),
      SyllabusCheckpoint.practice => topic.copyWith(practiceDoneAt: stamp),
      SyllabusCheckpoint.modelTest => topic.copyWith(modelTestDoneAt: stamp),
      SyllabusCheckpoint.revision => topic.copyWith(revisionDoneAt: stamp),
    };
    await _topicRepo.updateTopic(updated);
    _invalidateSubject(topic.subjectId);
  }

  /// Updates topic notes or weight.
  Future<void> updateTopicDetails({
    required Topic topic,
    String? title,
    String? notes,
    int? weight,
  }) async {
    final updated = topic.copyWith(
      title: title ?? topic.title,
      notes: notes ?? topic.notes,
      weight: weight ?? topic.weight,
    );
    await _topicRepo.updateTopic(updated);
    _invalidateSubject(topic.subjectId);
  }

  /// Bulk marks an enabled checkpoint for all topics inside a chapter.
  Future<void> markAllCheckpointInChapter({
    required String subjectId,
    required String chapterId,
    required SyllabusCheckpoint checkpoint,
    required bool isDone,
  }) async {
    final allTopics = await _topicRepo.getTopicsForChapter(chapterId);
    final stamp = isDone ? DateTime.now().toUtc() : null;

    final updatedTopics = allTopics.map((t) {
      return switch (checkpoint) {
        SyllabusCheckpoint.study => t.copyWith(studyDoneAt: stamp),
        SyllabusCheckpoint.practice => t.copyWith(practiceDoneAt: stamp),
        SyllabusCheckpoint.modelTest => t.copyWith(modelTestDoneAt: stamp),
        SyllabusCheckpoint.revision => t.copyWith(revisionDoneAt: stamp),
      };
    }).toList();

    for (final t in updatedTopics) {
      await _topicRepo.updateTopic(t);
    }
    _invalidateSubject(subjectId);
  }

  /// Adds a new chapter.
  Future<Chapter> createChapter({
    required String subjectId,
    required String title,
  }) async {
    final existing = await _chapterRepo.getChaptersForSubject(subjectId);
    final chapter = Chapter(
      id: _uuid.v4(),
      userId: _currentUserId,
      subjectId: subjectId,
      title: title.trim(),
      sortOrder: existing.length,
    );
    final saved = await _chapterRepo.createChapter(chapter);
    _invalidateSubject(subjectId);
    return saved;
  }

  /// Edits chapter title.
  Future<void> updateChapter({
    required Chapter chapter,
    required String title,
  }) async {
    final updated = chapter.copyWith(title: title.trim());
    await _chapterRepo.updateChapter(updated);
    _invalidateSubject(chapter.subjectId);
  }

  /// Deletes a chapter and all its topics.
  Future<void> deleteChapter({
    required String subjectId,
    required String chapterId,
  }) async {
    final topics = await _topicRepo.getTopicsForChapter(chapterId);
    for (final topic in topics) {
      await _topicRepo.deleteTopic(topic.id);
    }
    await _chapterRepo.deleteChapter(chapterId);
    _invalidateSubject(subjectId);
  }

  /// Adds a new topic.
  Future<Topic> createTopic({
    required String subjectId,
    required String title,
    String? chapterId,
    int weight = 1,
  }) async {
    final existing = await _topicRepo.getTopicsForSubject(subjectId);
    final topic = Topic(
      id: _uuid.v4(),
      userId: _currentUserId,
      subjectId: subjectId,
      chapterId: chapterId,
      title: title.trim(),
      weight: weight,
      sortOrder: existing.length,
    );
    final saved = await _topicRepo.createTopic(topic);
    _invalidateSubject(subjectId);
    return saved;
  }

  /// Deletes a topic.
  Future<void> deleteTopic({
    required String subjectId,
    required String topicId,
  }) async {
    await _topicRepo.deleteTopic(topicId);
    _invalidateSubject(subjectId);
  }

  /// Reorders topics by updating sort order.
  Future<void> reorderTopics({
    required String subjectId,
    required List<String> topicIds,
  }) async {
    await _topicRepo.reorderTopics(topicIds);
    _invalidateSubject(subjectId);
  }

  /// Configures enabled checkpoints on parent subject.
  Future<void> updateSubjectCheckpoints({
    required Subject subject,
    required List<String> enabledCheckpoints,
  }) async {
    final updated = subject.copyWith(enabledCheckpoints: enabledCheckpoints);
    await _subjectRepo.updateSubject(updated);
    _ref.invalidate(subjectsProvider);
    _invalidateSubject(subject.id);
  }

  /// Imports a parsed outline into chapters and topics.
  Future<void> importPastedOutline({
    required String subjectId,
    required ParsedSyllabusOutline outline,
  }) async {
    final existingChapters =
        await _chapterRepo.getChaptersForSubject(subjectId);
    var chapterOrder = existingChapters.length;

    // Create unassigned topics if any
    for (final topicTitle in outline.unassignedTopics) {
      await createTopic(
        subjectId: subjectId,
        title: topicTitle,
      );
    }

    // Create chapters with topics
    for (final parsedChapter in outline.chapters) {
      final chapter = Chapter(
        id: _uuid.v4(),
        userId: _currentUserId,
        subjectId: subjectId,
        title: parsedChapter.title,
        sortOrder: chapterOrder++,
      );
      await _chapterRepo.createChapter(chapter);

      final topicsToBatch = <Topic>[];
      var topicOrder = 0;
      for (final topicTitle in parsedChapter.topics) {
        topicsToBatch.add(
          Topic(
            id: _uuid.v4(),
            userId: _currentUserId,
            subjectId: subjectId,
            chapterId: chapter.id,
            title: topicTitle,
            sortOrder: topicOrder++,
          ),
        );
      }
      if (topicsToBatch.isNotEmpty) {
        await _topicRepo.batchCreateTopics(topicsToBatch);
      }
    }

    _invalidateSubject(subjectId);
  }
}
