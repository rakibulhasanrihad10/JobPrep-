import 'package:job_prep/features/prep/data/mappers/mock_test_topic_mapper.dart';
import 'package:job_prep/features/prep/data/mappers/prep_error_mapper.dart';
import 'package:job_prep/features/prep/domain/entities/mock_test_topic.dart';
import 'package:job_prep/features/prep/domain/repositories/mock_test_topic_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supabase;
import 'package:uuid/uuid.dart';

const _uuid = Uuid();

/// Supabase PostgREST implementation of [MockTestTopicRepository].
class SupabaseMockTestTopicRepository implements MockTestTopicRepository {
  const SupabaseMockTestTopicRepository(this._client);

  static const String _table = 'mock_test_topics';

  final supabase.SupabaseClient _client;

  @override
  Future<List<MockTestTopic>> getTopicsForMockTest(String mockTestId) async {
    final trimmedId = mockTestId.trim();
    if (trimmedId.isEmpty) return const [];
    try {
      final rows =
          await _client.from(_table).select().eq('mock_test_id', trimmedId);
      return MockTestTopicMapper.fromJsonList(rows);
    } on Object catch (error) {
      throw PrepErrorMapper.map(error);
    }
  }

  @override
  Future<List<MockTestTopic>> getMockTestsForTopic(String topicId) async {
    final trimmedId = topicId.trim();
    if (trimmedId.isEmpty) return const [];
    try {
      final rows =
          await _client.from(_table).select().eq('topic_id', trimmedId);
      return MockTestTopicMapper.fromJsonList(rows);
    } on Object catch (error) {
      throw PrepErrorMapper.map(error);
    }
  }

  @override
  Future<void> setTopicsForMockTest(
    String mockTestId,
    List<String> topicIds,
  ) async {
    final trimmedMock = mockTestId.trim();
    if (trimmedMock.isEmpty) return;
    try {
      await _client.from(_table).delete().eq('mock_test_id', trimmedMock);
      if (topicIds.isNotEmpty) {
        final currentUserId = _client.auth.currentUser?.id ?? '';
        final payload = topicIds.map((tId) {
          return {
            'id': _uuid.v4(),
            'user_id': currentUserId,
            'mock_test_id': trimmedMock,
            'topic_id': tId.trim(),
          };
        }).toList();
        await _client.from(_table).insert(payload);
      }
    } on Object catch (error) {
      throw PrepErrorMapper.map(error);
    }
  }

  @override
  Future<MockTestTopic> linkTopic({
    required String mockTestId,
    required String topicId,
    String? id,
  }) async {
    try {
      final currentUserId = _client.auth.currentUser?.id ?? '';
      final linkId = id ?? _uuid.v4();
      final payload = {
        'id': linkId,
        'user_id': currentUserId,
        'mock_test_id': mockTestId.trim(),
        'topic_id': topicId.trim(),
      };
      final row = await _client
          .from(_table)
          .upsert(payload, onConflict: 'mock_test_id,topic_id')
          .select()
          .single();
      return MockTestTopicMapper.fromJson(row);
    } on Object catch (error) {
      throw PrepErrorMapper.map(error);
    }
  }

  @override
  Future<void> unlinkTopic({
    required String mockTestId,
    required String topicId,
  }) async {
    try {
      await _client
          .from(_table)
          .delete()
          .eq('mock_test_id', mockTestId.trim())
          .eq('topic_id', topicId.trim());
    } on Object catch (error) {
      throw PrepErrorMapper.map(error);
    }
  }

  @override
  Future<void> batchCreate(List<MockTestTopic> links) async {
    if (links.isEmpty) return;
    try {
      final currentUserId = _client.auth.currentUser?.id ?? '';
      final payload = links.map((link) {
        return MockTestTopicMapper.toInsertJson(link, userId: currentUserId);
      }).toList();
      await _client.from(_table).upsert(payload, onConflict: 'id');
    } on Object catch (error) {
      throw PrepErrorMapper.map(error);
    }
  }

  @override
  Future<List<MockTestTopic>> getAll() async {
    try {
      final rows = await _client.from(_table).select();
      return MockTestTopicMapper.fromJsonList(rows);
    } on Object catch (error) {
      throw PrepErrorMapper.map(error);
    }
  }
}
