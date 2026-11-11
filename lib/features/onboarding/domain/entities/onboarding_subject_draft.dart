import 'package:flutter/foundation.dart' show immutable, listEquals;
import 'package:job_prep/features/prep/domain/entities/prep_enums.dart';

/// Editable material item staged during Step 3 of onboarding.
@immutable
class OnboardingMaterialDraft {
  /// Creates an [OnboardingMaterialDraft].
  const OnboardingMaterialDraft({
    required this.localId,
    required this.title,
    required this.totalUnits,
    this.kind = MaterialKind.book,
    this.unitLabel = 'pages',
  });

  /// Restores an [OnboardingMaterialDraft] from JSON.
  factory OnboardingMaterialDraft.fromJson(Map<String, dynamic> json) {
    final rawUnits = json['totalUnits'];
    final totalUnits = rawUnits is num ? rawUnits.toInt() : 0;
    return OnboardingMaterialDraft(
      localId: (json['localId'] as String?) ?? '',
      title: (json['title'] as String?) ?? '',
      totalUnits: totalUnits < 0 ? 0 : totalUnits,
      kind: MaterialKind.fromValue(json['kind'] as String?),
      unitLabel: (json['unitLabel'] as String?) ?? 'pages',
    );
  }

  /// Client-side draft identifier preserving input controllers cleanly.
  final String localId;

  /// Editable display title.
  final String title;

  /// Material kind token.
  final MaterialKind kind;

  /// Unit label such as `pages` or `problems`.
  final String unitLabel;

  /// Editable positive total unit target.
  final int totalUnits;

  /// Serializes this material draft to JSON for `onboarding_draft`.
  Map<String, dynamic> toJson() => <String, dynamic>{
        'localId': localId,
        'title': title,
        'kind': kind.value,
        'unitLabel': unitLabel,
        'totalUnits': totalUnits,
      };

  /// Returns a copy with overridden properties.
  OnboardingMaterialDraft copyWith({
    String? localId,
    String? title,
    MaterialKind? kind,
    String? unitLabel,
    int? totalUnits,
  }) {
    return OnboardingMaterialDraft(
      localId: localId ?? this.localId,
      title: title ?? this.title,
      kind: kind ?? this.kind,
      unitLabel: unitLabel ?? this.unitLabel,
      totalUnits: totalUnits ?? this.totalUnits,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is OnboardingMaterialDraft &&
        other.localId == localId &&
        other.title == title &&
        other.kind == kind &&
        other.unitLabel == unitLabel &&
        other.totalUnits == totalUnits;
  }

  @override
  int get hashCode => Object.hash(localId, title, kind, unitLabel, totalUnits);
}

/// Editable subject group staged during Step 3 of onboarding.
@immutable
class OnboardingSubjectDraft {
  /// Creates an [OnboardingSubjectDraft].
  const OnboardingSubjectDraft({
    required this.localId,
    required this.name,
    this.color = 'gold',
    this.icon = 'menu_book',
    this.examType = 'general',
    this.enabled = true,
    this.materials = const <OnboardingMaterialDraft>[],
  });

  /// Restores an [OnboardingSubjectDraft] from JSON.
  factory OnboardingSubjectDraft.fromJson(Map<String, dynamic> json) {
    final rawMaterials = json['materials'];
    final materials = rawMaterials is List
        ? rawMaterials
            .whereType<Map<Object?, Object?>>()
            .map(
              (entry) => OnboardingMaterialDraft.fromJson(
                Map<String, dynamic>.from(entry),
              ),
            )
            .toList(growable: false)
        : const <OnboardingMaterialDraft>[];

    return OnboardingSubjectDraft(
      localId: (json['localId'] as String?) ?? '',
      name: (json['name'] as String?) ?? '',
      color: (json['color'] as String?) ?? 'gold',
      icon: (json['icon'] as String?) ?? 'menu_book',
      examType: (json['examType'] as String?) ?? 'general',
      enabled: (json['enabled'] as bool?) ?? true,
      materials: materials,
    );
  }

  /// Client-side draft identifier.
  final String localId;

  /// Editable display name.
  final String name;

  /// Semantic subject color key (`PrepStyleTokens`).
  final String color;

  /// Semantic subject icon key (`PrepStyleTokens`).
  final String icon;

  /// Preparation track key (`government`, `software`, `general`).
  final String examType;

  /// Whether this subject will be created on Finish.
  final bool enabled;

  /// Editable starter/custom materials inside this subject.
  final List<OnboardingMaterialDraft> materials;

  /// Serializes this subject draft to JSON.
  Map<String, dynamic> toJson() => <String, dynamic>{
        'localId': localId,
        'name': name,
        'color': color,
        'icon': icon,
        'examType': examType,
        'enabled': enabled,
        'materials': materials.map((m) => m.toJson()).toList(growable: false),
      };

  /// Returns a copy with specified fields replaced.
  OnboardingSubjectDraft copyWith({
    String? localId,
    String? name,
    String? color,
    String? icon,
    String? examType,
    bool? enabled,
    List<OnboardingMaterialDraft>? materials,
  }) {
    return OnboardingSubjectDraft(
      localId: localId ?? this.localId,
      name: name ?? this.name,
      color: color ?? this.color,
      icon: icon ?? this.icon,
      examType: examType ?? this.examType,
      enabled: enabled ?? this.enabled,
      materials: materials ?? this.materials,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is OnboardingSubjectDraft &&
        other.localId == localId &&
        other.name == name &&
        other.color == color &&
        other.icon == icon &&
        other.examType == examType &&
        other.enabled == enabled &&
        listEquals(other.materials, materials);
  }

  @override
  int get hashCode => Object.hash(
        localId,
        name,
        color,
        icon,
        examType,
        enabled,
        Object.hashAll(materials),
      );
}
