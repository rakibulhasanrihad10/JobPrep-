import 'package:job_prep/features/prep/domain/entities/topic.dart';
import 'package:job_prep/features/prep/domain/errors/prep_failure.dart';
import 'package:job_prep/features/prep/domain/repositories/topic_repository.dart';

/// Safe fallback [TopicRepository] used when Supabase is unconfigured.
class UnconfiguredTopicRepository implements TopicRepository {
  /// Creates an [UnconfiguredTopicRepository].
  const UnconfiguredTopicRepository();

  static const _failure = UnknownPrepFailure(
    code: 'supabase_not_configured',
    message: 'Supabase environment variables are not configured.',
  );

  @override
  Future<List<Topic>> getTopicsForSubject(String subjectId) async => const [];

  @override
  Future<Topic> createTopic(Topic topic) => Future.error(_failure);

  @override
  Future<Topic> updateTopic(Topic topic) => Future.error(_failure);

  @override
  Future<void> deleteTopic(String id) => Future.error(_failure);
}
