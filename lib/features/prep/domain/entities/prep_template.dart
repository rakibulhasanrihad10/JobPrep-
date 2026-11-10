import 'package:flutter/foundation.dart' show immutable, listEquals;
import 'package:job_prep/features/prep/domain/entities/prep_template_item.dart';

/// Grouped subject blueprint inside a [PrepTemplate] containing one subject and
/// all of its ordered starter material items.
@immutable
class PrepTemplateSubjectGroup {
  /// Creates a [PrepTemplateSubjectGroup].
  const PrepTemplateSubjectGroup({
    required this.subjectName,
    required this.subjectColor,
    required this.subjectIcon,
    required this.examType,
    required this.subjectSortOrder,
    required this.materials,
  });

  /// Display name of the subject.
  final String subjectName;

  /// Semantic color key (`PrepStyleTokens`).
  final String subjectColor;

  /// Semantic icon key (`PrepStyleTokens`).
  final String subjectIcon;

  /// Career/exam track label.
  final String examType;

  /// Ordering position among subjects inside the pack.
  final int subjectSortOrder;

  /// Starter material items belonging to this subject.
  final List<PrepTemplateItem> materials;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is PrepTemplateSubjectGroup &&
        other.subjectName == subjectName &&
        other.subjectColor == subjectColor &&
        other.subjectIcon == subjectIcon &&
        other.examType == examType &&
        other.subjectSortOrder == subjectSortOrder &&
        listEquals(other.materials, materials);
  }

  @override
  int get hashCode => Object.hash(
        subjectName,
        subjectColor,
        subjectIcon,
        examType,
        subjectSortOrder,
        Object.hashAll(materials),
      );
}

/// Immutable study template pack (`public.prep_templates`) consisting of
/// system starter packs and user-saved personal templates.
@immutable
class PrepTemplate {
  /// Creates a [PrepTemplate].
  const PrepTemplate({
    required this.title,
    this.id = '',
    this.userId,
    this.slug,
    this.description,
    this.examType = 'general',
    this.isSystem = false,
    this.sortOrder = 0,
    this.items = const [],
    this.createdAt,
    this.updatedAt,
  });

  static const Object _unset = Object();

  /// Unique template identifier (`prep_templates.id`).
  final String id;

  /// Owner user ID for personal templates (`null` for read-only system packs).
  final String? userId;

  /// Optional stable pack slug (e.g. `government_job`, `software_engineer`).
  final String? slug;

  /// Template pack display title.
  final String title;

  /// Optional concise summary explaining the pack contents.
  final String? description;

  /// Exam or career track badge label.
  final String examType;

  /// Whether this is a seeded read-only starter pack.
  final bool isSystem;

  /// Ordering index within system/personal template groups.
  final int sortOrder;

  /// Ordered template item rows belonging to this pack.
  final List<PrepTemplateItem> items;

  /// Creation timestamp managed by PostgreSQL.
  final DateTime? createdAt;

  /// Last update timestamp managed by PostgreSQL.
  final DateTime? updatedAt;

  /// Canonical UI key string preferring [slug] when present.
  String get stableKey =>
      (slug != null && slug!.trim().isNotEmpty) ? slug!.trim() : id;

  /// Distinct ordered subjects grouped with their material items.
  List<PrepTemplateSubjectGroup> get groupedSubjects {
    if (items.isEmpty) return const [];
    final ordered = List<PrepTemplateItem>.of(items)
      ..sort((a, b) {
        final bySub = a.subjectSortOrder.compareTo(b.subjectSortOrder);
        if (bySub != 0) return bySub;
        return a.itemSortOrder.compareTo(b.itemSortOrder);
      });

    final groups = <String, _MutableSubjectGroup>{};
    for (final item in ordered) {
      final key = normalizeNameKey(item.subjectName);
      if (key.isEmpty) continue;
      final group = groups.putIfAbsent(
        key,
        () => _MutableSubjectGroup(
          subjectName: item.subjectName.trim(),
          subjectColor: item.subjectColor,
          subjectIcon: item.subjectIcon,
          examType: item.examType,
          subjectSortOrder: item.subjectSortOrder,
        ),
      );
      if (item.hasMaterial) {
        group.materials.add(item);
      }
    }

    return List<PrepTemplateSubjectGroup>.unmodifiable(
      groups.values.map(
        (g) => PrepTemplateSubjectGroup(
          subjectName: g.subjectName,
          subjectColor: g.subjectColor,
          subjectIcon: g.subjectIcon,
          examType: g.examType,
          subjectSortOrder: g.subjectSortOrder,
          materials: List<PrepTemplateItem>.unmodifiable(g.materials),
        ),
      ),
    );
  }

  /// Total distinct subjects included in this template.
  int get subjectCount => groupedSubjects.length;

  /// Total example materials included across all subjects in this template.
  int get materialCount => items.where((item) => item.hasMaterial).length;

  /// Normalizes a subject or material name for case-insensitive matching.
  static String normalizeNameKey(String raw) {
    return raw.trim().toLowerCase().replaceAll(RegExp(r'\s+'), ' ');
  }

  /// Returns a copy with specified fields overridden.
  PrepTemplate copyWith({
    String? id,
    Object? userId = _unset,
    Object? slug = _unset,
    String? title,
    Object? description = _unset,
    String? examType,
    bool? isSystem,
    int? sortOrder,
    List<PrepTemplateItem>? items,
    Object? createdAt = _unset,
    Object? updatedAt = _unset,
  }) {
    return PrepTemplate(
      id: id ?? this.id,
      userId: identical(userId, _unset) ? this.userId : userId as String?,
      slug: identical(slug, _unset) ? this.slug : slug as String?,
      title: title ?? this.title,
      description: identical(description, _unset)
          ? this.description
          : description as String?,
      examType: examType ?? this.examType,
      isSystem: isSystem ?? this.isSystem,
      sortOrder: sortOrder ?? this.sortOrder,
      items: items ?? this.items,
      createdAt: identical(createdAt, _unset)
          ? this.createdAt
          : createdAt as DateTime?,
      updatedAt: identical(updatedAt, _unset)
          ? this.updatedAt
          : updatedAt as DateTime?,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is PrepTemplate &&
        other.id == id &&
        other.userId == userId &&
        other.slug == slug &&
        other.title == title &&
        other.description == description &&
        other.examType == examType &&
        other.isSystem == isSystem &&
        other.sortOrder == sortOrder &&
        listEquals(other.items, items) &&
        other.createdAt == createdAt &&
        other.updatedAt == updatedAt;
  }

  @override
  int get hashCode => Object.hash(
        id,
        userId,
        slug,
        title,
        description,
        examType,
        isSystem,
        sortOrder,
        Object.hashAll(items),
        createdAt,
        updatedAt,
      );
}

class _MutableSubjectGroup {
  _MutableSubjectGroup({
    required this.subjectName,
    required this.subjectColor,
    required this.subjectIcon,
    required this.examType,
    required this.subjectSortOrder,
  });

  final String subjectName;
  final String subjectColor;
  final String subjectIcon;
  final String examType;
  final int subjectSortOrder;
  final List<PrepTemplateItem> materials = <PrepTemplateItem>[];
}
