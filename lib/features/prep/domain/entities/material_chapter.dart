import 'package:flutter/foundation.dart' show immutable;

/// Immutable domain entity representing a link between a study material and a
/// syllabus chapter (`public.material_chapters`).
@immutable
class MaterialChapter {
  const MaterialChapter({
    required this.id,
    required this.userId,
    required this.materialId,
    required this.chapterId,
    this.createdAt,
  });

  /// Unique link identifier.
  final String id;

  /// Owning user identifier.
  final String userId;

  /// Linked study material identifier.
  final String materialId;

  /// Linked syllabus chapter identifier.
  final String chapterId;

  /// Creation timestamp.
  final DateTime? createdAt;

  MaterialChapter copyWith({
    String? id,
    String? userId,
    String? materialId,
    String? chapterId,
    DateTime? createdAt,
  }) {
    return MaterialChapter(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      materialId: materialId ?? this.materialId,
      chapterId: chapterId ?? this.chapterId,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is MaterialChapter &&
        other.id == id &&
        other.userId == userId &&
        other.materialId == materialId &&
        other.chapterId == chapterId;
  }

  @override
  int get hashCode => Object.hash(id, userId, materialId, chapterId);
}
