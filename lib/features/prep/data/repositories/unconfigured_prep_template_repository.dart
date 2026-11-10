import 'package:job_prep/features/prep/domain/entities/prep_material.dart';
import 'package:job_prep/features/prep/domain/entities/prep_template.dart';
import 'package:job_prep/features/prep/domain/entities/subject.dart';
import 'package:job_prep/features/prep/domain/errors/prep_failure.dart';
import 'package:job_prep/features/prep/domain/repositories/prep_template_repository.dart';
import 'package:job_prep/features/prep/domain/utils/prep_seeded_templates.dart';

/// Safe fallback [PrepTemplateRepository] used when Supabase is not configured.
///
/// Serves the seeded starter packs read-only while rejecting personal-template
/// writes until Supabase credentials are provided.
class UnconfiguredPrepTemplateRepository implements PrepTemplateRepository {
  /// Creates an [UnconfiguredPrepTemplateRepository].
  const UnconfiguredPrepTemplateRepository();

  static const _failure = UnknownPrepFailure(
    code: 'supabase_not_configured',
    message: 'Supabase environment variables are not configured.',
  );

  @override
  Future<List<PrepTemplate>> getTemplates() async =>
      PrepSeededTemplates.defaults();

  @override
  Future<PrepTemplate> savePersonalTemplate({
    required String title,
    required List<Subject> subjects,
    required List<PrepMaterial> materials,
    String? description,
    String examType = 'general',
  }) =>
      Future.error(_failure);

  @override
  Future<void> deletePersonalTemplate(String templateId) =>
      Future.error(_failure);
}
