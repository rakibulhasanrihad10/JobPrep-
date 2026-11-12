import 'package:job_prep/features/prep/data/mappers/prep_error_mapper.dart';
import 'package:job_prep/features/prep/data/mappers/revision_item_mapper.dart';
import 'package:job_prep/features/prep/domain/entities/revision_item.dart';
import 'package:job_prep/features/prep/domain/errors/prep_failure.dart';
import 'package:job_prep/features/prep/domain/repositories/revision_item_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supabase;

/// Supabase PostgREST implementation of [RevisionItemRepository] backed by
/// `public.revision_items`.
class SupabaseRevisionItemRepository implements RevisionItemRepository {
  /// Creates a [SupabaseRevisionItemRepository].
  const SupabaseRevisionItemRepository(this._client);

  static const String _table = 'revision_items';

  final supabase.SupabaseClient _client;

  @override
  Future<List<RevisionItem>> getRevisionItems() async {
    try {
      final rows = await _client
          .from(_table)
          .select()
          .order('due_on', ascending: true)
          .order('created_at', ascending: true);
      return RevisionItemMapper.fromJsonList(rows);
    } on Object catch (error) {
      throw PrepErrorMapper.map(error);
    }
  }

  @override
  Future<RevisionItem> createRevisionItem(RevisionItem item) async {
    _validateForWrite(item);

    try {
      final currentUserId = _client.auth.currentUser?.id;
      final payload = RevisionItemMapper.toInsertJson(
        item,
        userId: item.userId.trim().isEmpty ? currentUserId : null,
      );
      final row = await _client.from(_table).insert(payload).select().single();
      return RevisionItemMapper.fromJson(row);
    } on Object catch (error) {
      throw PrepErrorMapper.map(error);
    }
  }

  @override
  Future<List<RevisionItem>> createRevisionItems(
    List<RevisionItem> items,
  ) async {
    if (items.isEmpty) return const <RevisionItem>[];
    items.forEach(_validateForWrite);

    try {
      final currentUserId = _client.auth.currentUser?.id;
      final payloads = items
          .map(
            (item) => RevisionItemMapper.toInsertJson(
              item,
              userId: item.userId.trim().isEmpty ? currentUserId : null,
            ),
          )
          .toList(growable: false);
      final rows = await _client.from(_table).insert(payloads).select();
      return RevisionItemMapper.fromJsonList(rows);
    } on Object catch (error) {
      throw PrepErrorMapper.map(error);
    }
  }

  @override
  Future<RevisionItem> updateRevisionItem(RevisionItem item) async {
    final trimmedId = item.id.trim();
    if (trimmedId.isEmpty) {
      throw const PrepValidationFailure(
        code: 'missing_revision_id',
        message: 'Cannot update a revision item without an id.',
      );
    }
    _validateForWrite(item);

    try {
      final row = await _client
          .from(_table)
          .update(RevisionItemMapper.toUpdateJson(item))
          .eq('id', trimmedId)
          .select()
          .single();
      return RevisionItemMapper.fromJson(row);
    } on Object catch (error) {
      throw PrepErrorMapper.map(error);
    }
  }

  @override
  Future<void> deleteRevisionItem(String id) async {
    final trimmedId = id.trim();
    if (trimmedId.isEmpty) {
      throw const PrepValidationFailure(
        code: 'missing_revision_id',
        message: 'Cannot delete a revision item without an id.',
      );
    }

    try {
      await _client.from(_table).delete().eq('id', trimmedId);
    } on Object catch (error) {
      throw PrepErrorMapper.map(error);
    }
  }

  void _validateForWrite(RevisionItem item) {
    if (item.subjectId.trim().isEmpty) {
      throw const PrepValidationFailure(
        code: 'missing_subject_id',
        message: 'Revision item requires a subject id.',
      );
    }
    if (item.referenceLabel.trim().isEmpty) {
      throw const PrepValidationFailure(
        code: 'missing_reference_label',
        message: 'Revision item requires a reference label.',
      );
    }
    if (item.pageNumber != null && item.pageNumber! < 0) {
      throw const PrepValidationFailure(
        code: 'invalid_page_number',
        message: 'Page number cannot be negative.',
      );
    }
    if (item.reviewCount < 0) {
      throw const PrepValidationFailure(
        code: 'invalid_review_count',
        message: 'Review count cannot be negative.',
      );
    }
  }
}
