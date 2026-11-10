import 'package:flutter/foundation.dart' show immutable;

/// Immutable domain entity representing file metadata attached to a circular.
@immutable
class CircularFile {
  /// Creates a [CircularFile].
  const CircularFile({
    required this.storagePath,
    required this.fileName,
    required this.mimeType,
    required this.sizeBytes,
    this.id = '',
    this.circularId = '',
    this.userId = '',
    this.createdAt,
    this.updatedAt,
  });

  static const _unset = Object();

  /// Unique identifier (`circular_files.id`).
  final String id;

  /// Parent circular identifier (`circular_files.circular_id`).
  final String circularId;

  /// Owner user identifier (`circular_files.user_id`).
  final String userId;

  /// Storage bucket object path (`circular_files.storage_path`).
  final String storagePath;

  /// Original display file name (`circular_files.file_name`).
  final String fileName;

  /// MIME type string (e.g. `application/pdf`).
  final String mimeType;

  /// File size in bytes.
  final int sizeBytes;

  /// Creation timestamp managed by PostgreSQL.
  final DateTime? createdAt;

  /// Last update timestamp managed by PostgreSQL.
  final DateTime? updatedAt;

  /// Returns a copy with specified fields overridden.
  CircularFile copyWith({
    String? id,
    String? circularId,
    String? userId,
    String? storagePath,
    String? fileName,
    String? mimeType,
    int? sizeBytes,
    Object? createdAt = _unset,
    Object? updatedAt = _unset,
  }) {
    return CircularFile(
      id: id ?? this.id,
      circularId: circularId ?? this.circularId,
      userId: userId ?? this.userId,
      storagePath: storagePath ?? this.storagePath,
      fileName: fileName ?? this.fileName,
      mimeType: mimeType ?? this.mimeType,
      sizeBytes: sizeBytes ?? this.sizeBytes,
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
    return other is CircularFile &&
        other.id == id &&
        other.circularId == circularId &&
        other.userId == userId &&
        other.storagePath == storagePath &&
        other.fileName == fileName &&
        other.mimeType == mimeType &&
        other.sizeBytes == sizeBytes &&
        other.createdAt == createdAt &&
        other.updatedAt == updatedAt;
  }

  @override
  int get hashCode => Object.hash(
        id,
        circularId,
        userId,
        storagePath,
        fileName,
        mimeType,
        sizeBytes,
        createdAt,
        updatedAt,
      );

  @override
  String toString() => 'CircularFile(id: $id, fileName: $fileName)';
}
