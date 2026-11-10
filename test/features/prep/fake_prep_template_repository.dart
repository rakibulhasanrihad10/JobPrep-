import 'package:job_prep/features/prep/domain/entities/prep_material.dart';
import 'package:job_prep/features/prep/domain/entities/prep_template.dart';
import 'package:job_prep/features/prep/domain/entities/subject.dart';
import 'package:job_prep/features/prep/domain/errors/prep_failure.dart';
import 'package:job_prep/features/prep/domain/repositories/prep_template_repository.dart';
import 'package:job_prep/features/prep/domain/utils/prep_seeded_templates.dart';
import 'package:job_prep/features/prep/domain/utils/prep_template_planner.dart';

/// In-memory fake [PrepTemplateRepository] simulating PostgreSQL RLS behavior
/// for read-only system packs and per-user personal templates.
class FakePrepTemplateRepository implements PrepTemplateRepository {
  /// Creates a [FakePrepTemplateRepository] seeded with both system packs by
  /// default.
  FakePrepTemplateRepository({
    List<PrepTemplate>? initialTemplates,
    this.activeUserId = 'user-1',
    DateTime Function()? clock,
  })  : _templates = List<PrepTemplate>.of(
          initialTemplates ?? PrepSeededTemplates.defaults(),
        ),
        _clock = clock ?? (() => DateTime.utc(2026, 11, 10, 12));

  final List<PrepTemplate> _templates;
  final DateTime Function() _clock;
  int _nextTemplateId = 1;
  int _nextItemId = 1;

  /// Active signed-in user ID simulated by RLS policies.
  String activeUserId;

  /// Optional error injected on next repository call.
  PrepFailure? nextError;

  /// Direct inspection view across all stored templates (admin view).
  List<PrepTemplate> get allStoredTemplates => List.unmodifiable(_templates);

  @override
  Future<List<PrepTemplate>> getTemplates() async {
    _consumeError();
    final visible = _templates
        .where(
          (t) => t.isSystem || t.userId == activeUserId,
        )
        .toList(growable: false)
      ..sort((a, b) {
        if (a.isSystem != b.isSystem) {
          return a.isSystem ? -1 : 1;
        }
        return a.sortOrder.compareTo(b.sortOrder);
      });
    return List<PrepTemplate>.unmodifiable(visible);
  }

  @override
  Future<PrepTemplate> savePersonalTemplate({
    required String title,
    required List<Subject> subjects,
    required List<PrepMaterial> materials,
    String? description,
    String examType = 'general',
  }) async {
    _consumeError();
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

    final now = _clock().toUtc();
    final templateId = 'personal-tpl-${_nextTemplateId++}';
    final snapshot = PrepTemplatePlanner.snapshotItemsFromSubjects(
      subjects: subjects,
      materials: materials,
      fallbackExamType: examType,
    );

    final materializedItems = snapshot
        .map(
          (item) => item.copyWith(
            id: 'personal-item-${_nextItemId++}',
            templateId: templateId,
            userId: activeUserId,
            createdAt: now,
            updatedAt: now,
          ),
        )
        .toList(growable: false);

    final trimmedDesc = description?.trim();
    final created = PrepTemplate(
      id: templateId,
      userId: activeUserId,
      title: trimmedTitle,
      description:
          (trimmedDesc != null && trimmedDesc.isNotEmpty) ? trimmedDesc : null,
      examType: examType.trim().isEmpty ? 'general' : examType.trim(),
      sortOrder: _templates.where((t) => !t.isSystem).length,
      items: List.unmodifiable(materializedItems),
      createdAt: now,
      updatedAt: now,
    );
    _templates.add(created);
    return created;
  }

  @override
  Future<void> deletePersonalTemplate(String templateId) async {
    _consumeError();
    final index = _templates.indexWhere((t) => t.id == templateId);
    if (index < 0) return;

    final target = _templates[index];
    if (target.isSystem || target.userId != activeUserId) {
      throw const PrepPermissionFailure(
        code: '42501',
        message: 'Cannot delete system or cross-user template.',
      );
    }
    _templates.removeAt(index);
  }

  void _consumeError() {
    final err = nextError;
    if (err != null) {
      nextError = null;
      throw err;
    }
  }
}
