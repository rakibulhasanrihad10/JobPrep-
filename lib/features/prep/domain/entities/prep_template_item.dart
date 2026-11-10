import 'package:flutter/foundation.dart' show immutable;
import 'package:job_prep/features/prep/domain/entities/prep_enums.dart';

/// Immutable item inside a preparation template representing one subject slot
/// and an optional starter study material (`public.prep_template_items`).
@immutable
class PrepTemplateItem {
  /// Creates a [PrepTemplateItem].
  const PrepTemplateItem({
    required this.subjectName,
    this.id = '',
    this.templateId = '',
    this.userId,
    this.subjectColor = 'gold',
    this.subjectIcon = 'menu_book',
    this.examType = 'general',
    this.subjectSortOrder = 0,
    this.materialTitle,
    this.materialKind = MaterialKind.book,
    this.unitLabel = 'pages',
    this.totalUnits = 0,
    this.itemSortOrder = 0,
    this.createdAt,
    this.updatedAt,
  });

  static const Object _unset = Object();

  /// Unique identifier (`prep_template_items.id`).
  final String id;

  /// Parent template identifier (`prep_template_items.template_id`).
  final String templateId;

  /// Optional owner identifier (`null` for system packs).
  final String? userId;

  /// Subject name copied into `public.subjects.name`.
  final String subjectName;

  /// Semantic subject color key copied into `public.subjects.color`.
  final String subjectColor;

  /// Semantic subject icon key copied into `public.subjects.icon`.
  final String subjectIcon;

  /// Target career/exam track copied into `public.subjects.exam_type`.
  final String examType;

  /// Display ordering index of the subject inside its pack (`>= 0`).
  final int subjectSortOrder;

  /// Optional starter material title (`null` when saving an empty subject).
  final String? materialTitle;

  /// Study resource kind copied into `public.materials.kind`.
  final MaterialKind materialKind;

  /// Unit label copied into `public.materials.unit_label`.
  final String unitLabel;

  /// Editable planned unit target copied into `public.materials.total_units`.
  final int totalUnits;

  /// Item ordering index inside [templateId] (`>= 0`).
  final int itemSortOrder;

  /// Creation timestamp managed by PostgreSQL.
  final DateTime? createdAt;

  /// Last update timestamp managed by PostgreSQL.
  final DateTime? updatedAt;

  /// Whether this row carries a starter material definition.
  bool get hasMaterial =>
      materialTitle != null && materialTitle!.trim().isNotEmpty;

  /// Returns a copy with specified fields replaced.
  PrepTemplateItem copyWith({
    String? id,
    String? templateId,
    Object? userId = _unset,
    String? subjectName,
    String? subjectColor,
    String? subjectIcon,
    String? examType,
    int? subjectSortOrder,
    Object? materialTitle = _unset,
    MaterialKind? materialKind,
    String? unitLabel,
    int? totalUnits,
    int? itemSortOrder,
    Object? createdAt = _unset,
    Object? updatedAt = _unset,
  }) {
    return PrepTemplateItem(
      id: id ?? this.id,
      templateId: templateId ?? this.templateId,
      userId: identical(userId, _unset) ? this.userId : userId as String?,
      subjectName: subjectName ?? this.subjectName,
      subjectColor: subjectColor ?? this.subjectColor,
      subjectIcon: subjectIcon ?? this.subjectIcon,
      examType: examType ?? this.examType,
      subjectSortOrder: subjectSortOrder ?? this.subjectSortOrder,
      materialTitle: identical(materialTitle, _unset)
          ? this.materialTitle
          : materialTitle as String?,
      materialKind: materialKind ?? this.materialKind,
      unitLabel: unitLabel ?? this.unitLabel,
      totalUnits: totalUnits ?? this.totalUnits,
      itemSortOrder: itemSortOrder ?? this.itemSortOrder,
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
    return other is PrepTemplateItem &&
        other.id == id &&
        other.templateId == templateId &&
        other.userId == userId &&
        other.subjectName == subjectName &&
        other.subjectColor == subjectColor &&
        other.subjectIcon == subjectIcon &&
        other.examType == examType &&
        other.subjectSortOrder == subjectSortOrder &&
        other.materialTitle == materialTitle &&
        other.materialKind == materialKind &&
        other.unitLabel == unitLabel &&
        other.totalUnits == totalUnits &&
        other.itemSortOrder == itemSortOrder &&
        other.createdAt == createdAt &&
        other.updatedAt == updatedAt;
  }

  @override
  int get hashCode => Object.hash(
        id,
        templateId,
        userId,
        subjectName,
        subjectColor,
        subjectIcon,
        examType,
        subjectSortOrder,
        materialTitle,
        materialKind,
        unitLabel,
        totalUnits,
        itemSortOrder,
        createdAt,
        updatedAt,
      );
}
