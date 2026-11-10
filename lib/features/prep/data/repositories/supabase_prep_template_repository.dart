import 'package:job_prep/features/prep/data/mappers/prep_error_mapper.dart';
import 'package:job_prep/features/prep/data/mappers/prep_json_helpers.dart';
import 'package:job_prep/features/prep/data/mappers/prep_template_item_mapper.dart';
import 'package:job_prep/features/prep/data/mappers/prep_template_mapper.dart';
import 'package:job_prep/features/prep/domain/entities/prep_material.dart';
import 'package:job_prep/features/prep/domain/entities/prep_template.dart';
import 'package:job_prep/features/prep/domain/entities/subject.dart';
import 'package:job_prep/features/prep/domain/errors/prep_failure.dart';
import 'package:job_prep/features/prep/domain/repositories/prep_template_repository.dart';
import 'package:job_prep/features/prep/domain/utils/prep_template_planner.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supabase;

/// Supabase PostgREST implementation of [PrepTemplateRepository] backed by
/// `public.prep_templates` and `public.prep_template_items`.
class SupabasePrepTemplateRepository implements PrepTemplateRepository {
  /// Creates a [SupabasePrepTemplateRepository].
  const SupabasePrepTemplateRepository(this._client);

  static const String _templatesTable = 'prep_templates';
  static const String _itemsTable = 'prep_template_items';
  static const String _selectWithItems = '*, prep_template_items(*)';

  final supabase.SupabaseClient _client;

  @override
  Future<List<PrepTemplate>> getTemplates() async {
    try {
      final rows = await _client
          .from(_templatesTable)
          .select(_selectWithItems)
          .order('is_system', ascending: false)
          .order('sort_order', ascending: true)
          .order('created_at', ascending: true);
      return PrepTemplateMapper.fromJsonList(rows);
    } on Object catch (error) {
      throw PrepErrorMapper.map(error);
    }
  }

  @override
  Future<PrepTemplate> savePersonalTemplate({
    required String title,
    required List<Subject> subjects,
    required List<PrepMaterial> materials,
    String? description,
    String examType = 'general',
  }) async {
    final trimmedTitle = title.trim();
    if (trimmedTitle.isEmpty) {
      throw const PrepValidationFailure(
        code: 'missing_template_title',
        message: 'Template title must not be empty.',
      );
    }
    if (subjects.isEmpty) {
      throw const PrepValidationFailure(
        code: 'empty_template_subjects',
        message: 'At least one subject is required to save a template.',
      );
    }

    final snapshotItems = PrepTemplatePlanner.snapshotItemsFromSubjects(
      subjects: subjects,
      materials: materials,
      fallbackExamType: examType,
    );

    String? createdTemplateId;
    try {
      final currentUserId = _client.auth.currentUser?.id;
      final headerPayload = PrepTemplateMapper.toInsertJson(
        PrepTemplate(
          title: trimmedTitle,
          description: description,
          examType: examType,
        ),
        userId: currentUserId,
      );

      final createdRow = await _client
          .from(_templatesTable)
          .insert(headerPayload)
          .select()
          .single();

      createdTemplateId = PrepJsonHelpers.readRequiredString(createdRow, 'id');
      final resolvedOwnerId = PrepJsonHelpers.readOptionalString(
            createdRow,
            'user_id',
            trimEmptyToNull: true,
          ) ??
          currentUserId;

      final itemPayloads = snapshotItems
          .map(
            (item) => PrepTemplateItemMapper.toInsertJson(
              item,
              templateId: createdTemplateId!,
              userId: resolvedOwnerId,
            ),
          )
          .toList(growable: false);

      final insertedItemRows = itemPayloads.isEmpty
          ? const <Map<String, dynamic>>[]
          : await _client.from(_itemsTable).insert(itemPayloads).select();

      return PrepTemplateMapper.fromJson(
        createdRow,
        explicitItems: PrepTemplateItemMapper.fromJsonList(insertedItemRows),
      );
    } on Object catch (error) {
      if (createdTemplateId != null && createdTemplateId.isNotEmpty) {
        try {
          await _client
              .from(_templatesTable)
              .delete()
              .eq('id', createdTemplateId);
        } on Object {
          // Best-effort cleanup; surface original persistence failure.
        }
      }
      throw PrepErrorMapper.map(error);
    }
  }

  @override
  Future<void> deletePersonalTemplate(String templateId) async {
    final trimmedId = templateId.trim();
    if (trimmedId.isEmpty) {
      throw const PrepValidationFailure(
        code: 'missing_template_id',
        message: 'Cannot delete a template without an id.',
      );
    }

    try {
      await _client
          .from(_templatesTable)
          .delete()
          .eq('id', trimmedId)
          .eq('is_system', false);
    } on Object catch (error) {
      throw PrepErrorMapper.map(error);
    }
  }
}
