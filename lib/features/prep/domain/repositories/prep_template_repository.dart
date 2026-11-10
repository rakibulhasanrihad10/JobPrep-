import 'package:job_prep/features/prep/domain/entities/prep_material.dart';
import 'package:job_prep/features/prep/domain/entities/prep_template.dart';
import 'package:job_prep/features/prep/domain/entities/subject.dart';

/// Repository interface for reading seeded starter templates and managing
/// personal reusable preparation templates.
abstract interface class PrepTemplateRepository {
  /// Fetches all visible system packs plus the signed-in user's personal
  /// templates along with their ordered items.
  Future<List<PrepTemplate>> getTemplates();

  /// Saves the signed-in user's [subjects] and [materials] as a personal
  /// reusable template pack.
  Future<PrepTemplate> savePersonalTemplate({
    required String title,
    required List<Subject> subjects,
    required List<PrepMaterial> materials,
    String? description,
    String examType = 'general',
  });

  /// Deletes a user-owned personal template identified by [templateId].
  Future<void> deletePersonalTemplate(String templateId);
}
