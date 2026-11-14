import 'dart:convert';

import 'package:flutter/services.dart' show AssetBundle, rootBundle;
import 'package:job_prep/features/prep/domain/entities/prep_enums.dart';
import 'package:job_prep/features/prep/domain/entities/prep_material.dart';
import 'package:job_prep/features/prep/domain/entities/prep_template.dart';
import 'package:job_prep/features/prep/domain/entities/prep_template_item.dart';
import 'package:job_prep/features/prep/domain/entities/subject.dart';
import 'package:job_prep/features/prep/domain/repositories/prep_template_repository.dart';
import 'package:uuid/uuid.dart';

/// Local device implementation of [PrepTemplateRepository] reading bundled JSON
/// asset template packs and persisting personal templates locally.
class LocalPrepTemplateRepository implements PrepTemplateRepository {
  /// Creates a [LocalPrepTemplateRepository].
  LocalPrepTemplateRepository({
    AssetBundle? bundle,
  }) : _bundle = bundle ?? rootBundle;

  final AssetBundle _bundle;
  final List<PrepTemplate> _personalTemplates = [];

  static const List<String> _bundledAssetPaths = [
    'assets/templates/government_job.json',
    'assets/templates/software_engineer.json',
  ];

  @override
  Future<List<PrepTemplate>> getTemplates() async {
    final templates = <PrepTemplate>[];

    for (final path in _bundledAssetPaths) {
      try {
        final jsonString = await _bundle.loadString(path);
        final map = jsonDecode(jsonString) as Map<String, dynamic>;
        templates.add(_parseTemplate(map));
      } on Object catch (_) {
        // Safe fallback if asset bundle is unavailable in unit tests
      }
    }

    templates
      ..addAll(_personalTemplates)
      ..sort((a, b) {
        if (a.isSystem != b.isSystem) {
          return a.isSystem ? -1 : 1;
        }
        return a.sortOrder.compareTo(b.sortOrder);
      });

    return List.unmodifiable(templates);
  }

  @override
  Future<PrepTemplate> savePersonalTemplate({
    required String title,
    required List<Subject> subjects,
    required List<PrepMaterial> materials,
    String? description,
    String examType = 'general',
  }) async {
    final templateId = const Uuid().v4();
    final items = <PrepTemplateItem>[];
    var itemSort = 0;

    for (var i = 0; i < subjects.length; i++) {
      final subject = subjects[i];
      final subjectMaterials =
          materials.where((m) => m.subjectId == subject.id).toList();

      for (final material in subjectMaterials) {
        items.add(
          PrepTemplateItem(
            id: const Uuid().v4(),
            templateId: templateId,
            subjectName: subject.name,
            subjectColor: subject.color,
            subjectIcon: subject.icon,
            examType: examType,
            subjectSortOrder: i,
            materialTitle: material.title,
            materialKind: material.kind,
            unitLabel: material.unitLabel,
            totalUnits: material.totalUnits,
            itemSortOrder: itemSort++,
          ),
        );
      }
    }

    final template = PrepTemplate(
      id: templateId,
      slug: 'personal_${DateTime.now().millisecondsSinceEpoch}',
      title: title.trim(),
      description: description?.trim(),
      examType: examType,
      sortOrder: 100 + _personalTemplates.length,
      items: items,
      createdAt: DateTime.now().toUtc(),
      updatedAt: DateTime.now().toUtc(),
    );

    _personalTemplates.add(template);
    return template;
  }

  @override
  Future<void> deletePersonalTemplate(String templateId) async {
    _personalTemplates.removeWhere((t) => t.id == templateId && !t.isSystem);
  }

  PrepTemplate _parseTemplate(Map<String, dynamic> json) {
    final itemsRaw = json['items'] as List<dynamic>? ?? const [];
    final items = itemsRaw.map((e) {
      final itemMap = e as Map<String, dynamic>;
      return PrepTemplateItem(
        id: itemMap['id'] as String,
        templateId: itemMap['template_id'] as String,
        subjectName: itemMap['subject_name'] as String,
        subjectColor: itemMap['subject_color'] as String,
        subjectIcon: itemMap['subject_icon'] as String,
        examType: itemMap['exam_type'] as String,
        subjectSortOrder: itemMap['subject_sort_order'] as int,
        materialTitle: itemMap['material_title'] as String,
        materialKind: MaterialKind.fromValue(
          itemMap['material_kind'] as String?,
        ),
        unitLabel: itemMap['unit_label'] as String,
        totalUnits: itemMap['total_units'] as int,
        itemSortOrder: itemMap['item_sort_order'] as int,
      );
    }).toList();

    return PrepTemplate(
      id: json['id'] as String,
      slug: json['slug'] as String,
      title: json['title'] as String,
      description: json['description'] as String?,
      examType: json['exam_type'] as String,
      isSystem: json['is_system'] as bool? ?? false,
      sortOrder: json['sort_order'] as int? ?? 0,
      items: items,
    );
  }
}
