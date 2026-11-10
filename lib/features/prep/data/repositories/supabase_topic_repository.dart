import 'package:job_prep/features/prep/data/mappers/prep_error_mapper.dart';
import 'package:job_prep/features/prep/data/mappers/topic_mapper.dart';
import 'package:job_prep/features/prep/domain/entities/topic.dart';
import 'package:job_prep/features/prep/domain/errors/prep_failure.dart';
import 'package:job_prep/features/prep/domain/repositories/topic_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supabase;

/// Supabase PostgREST implementation of [TopicRepository] backed by
/// `public.topics`.
class SupabaseTopicRepository implements TopicRepository {
  /// Creates a [SupabaseTopicRepository].
  const SupabaseTopicRepository(this._client);

  static const String _table = 'topics';

  final supabase.SupabaseClient _client;

  @override
  Future<List<Topic>> getTopicsForSubject(String subjectId) async {
    final trimmedId = subjectId.trim();
    if (trimmedId.isEmpty) return const [];

    try {
      final rows = await _client
          .from(_table)
          .select()
          .eq('subject_id', trimmedId)
          .order('created_at', ascending: true);
      return TopicMapper.fromJsonList(rows);
    } on Object catch (error) {
      throw PrepErrorMapper.map(error);
    }
  }

  @override
  Future<Topic> createTopic(Topic topic) async {
    _validateForWrite(topic);

    try {
      final currentUserId = _client.auth.currentUser?.id;
      final payload = TopicMapper.toInsertJson(
        topic,
        userId: topic.userId.trim().isEmpty ? currentUserId : null,
      );
      final row = await _client.from(_table).insert(payload).select().single();
      return TopicMapper.fromJson(row);
    } on Object catch (error) {
      throw PrepErrorMapper.map(error);
    }
  }

  @override
  Future<Topic> updateTopic(Topic topic) async {
    final trimmedId = topic.id.trim();
    if (trimmedId.isEmpty) {
      throw const PrepValidationFailure(
        code: 'missing_topic_id',
        message: 'Cannot update a topic without an id.',
      );
    }
    _validateForWrite(topic);

    try {
      final row = await _client
          .from(_table)
          .update(TopicMapper.toUpdateJson(topic))
          .eq('id', trimmedId)
          .select()
          .single();
      return TopicMapper.fromJson(row);
    } on Object catch (error) {
      throw PrepErrorMapper.map(error);
    }
  }

  @override
  Future<void> deleteTopic(String id) async {
    final trimmedId = id.trim();
    if (trimmedId.isEmpty) {
      throw const PrepValidationFailure(
        code: 'missing_topic_id',
        message: 'Cannot delete a topic without an id.',
      );
    }

    try {
      await _client.from(_table).delete().eq('id', trimmedId);
    } on Object catch (error) {
      throw PrepErrorMapper.map(error);
    }
  }

  void _validateForWrite(Topic topic) {
    if (topic.subjectId.trim().isEmpty) {
      throw const PrepValidationFailure(
        code: 'missing_subject_id',
        message: 'Topic requires a parent subject id.',
      );
    }
    if (topic.name.trim().isEmpty) {
      throw const PrepValidationFailure(
        code: 'empty_topic_name',
        message: 'Topic name cannot be empty.',
      );
    }
  }
}
