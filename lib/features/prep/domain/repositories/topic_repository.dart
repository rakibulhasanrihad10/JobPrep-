import 'package:job_prep/features/prep/domain/entities/topic.dart';

/// Contract for managing syllabus topics (`public.topics`).
abstract interface class TopicRepository {
  /// Fetches all syllabus topics belonging to [subjectId].
  Future<List<Topic>> getTopicsForSubject(String subjectId);

  /// Inserts a new [topic] and returns the persisted record.
  Future<Topic> createTopic(Topic topic);

  /// Updates an existing [topic] and returns the persisted record.
  Future<Topic> updateTopic(Topic topic);

  /// Permanently deletes the topic identified by [id].
  Future<void> deleteTopic(String id);
}
