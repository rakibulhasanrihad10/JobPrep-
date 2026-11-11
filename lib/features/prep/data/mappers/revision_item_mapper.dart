import 'package:job_prep/features/prep/data/mappers/prep_json_helpers.dart';
import 'package:job_prep/features/prep/domain/entities/prep_enums.dart';
import 'package:job_prep/features/prep/domain/entities/revision_item.dart';

/// Maps between PostgreSQL `public.revision_items` JSON rows and
/// [RevisionItem].
abstract final class RevisionItemMapper {
  /// Deserializes a single `revision_items` JSON row.
  static RevisionItem fromJson(Map<String, dynamic> json) {
    return RevisionItem(
      id: PrepJsonHelpers.readRequiredString(json, 'id'),
      userId: PrepJsonHelpers.readRequiredString(json, 'user_id'),
      materialId: PrepJsonHelpers.readOptionalString(
        json,
        'material_id',
        trimEmptyToNull: true,
      ),
      subjectId: PrepJsonHelpers.readRequiredString(json, 'subject_id'),
      topicId: PrepJsonHelpers.readOptionalString(
        json,
        'topic_id',
        trimEmptyToNull: true,
      ),
      referenceLabel:
          PrepJsonHelpers.readRequiredString(json, 'reference_label'),
      pageNumber: PrepJsonHelpers.readOptionalInt(json, 'page_number'),
      note: PrepJsonHelpers.readOptionalString(
        json,
        'note',
        trimEmptyToNull: true,
      ),
      reason: RevisionReason.fromValue(
        PrepJsonHelpers.readOptionalString(json, 'reason'),
      ),
      source: RevisionSource.fromValue(
        PrepJsonHelpers.readOptionalString(json, 'source'),
      ),
      progressLogId: PrepJsonHelpers.readOptionalString(
        json,
        'progress_log_id',
        trimEmptyToNull: true,
      ),
      mockTestId: PrepJsonHelpers.readOptionalString(
        json,
        'mock_test_id',
        trimEmptyToNull: true,
      ),
      status: RevisionStatus.fromValue(
        PrepJsonHelpers.readOptionalString(json, 'status'),
      ),
      dueOn: PrepJsonHelpers.readRequiredDateOnly(json, 'due_on'),
      reviewCount: PrepJsonHelpers.readRequiredInt(json, 'review_count'),
      lastReviewedOn: _readOptionalDateOnly(json, 'last_reviewed_on'),
      createdAt: PrepJsonHelpers.readOptionalDateTime(json, 'created_at'),
      updatedAt: PrepJsonHelpers.readOptionalDateTime(json, 'updated_at'),
    );
  }

  /// Deserializes a list of `revision_items` JSON rows.
  static List<RevisionItem> fromJsonList(List<Map<String, dynamic>> rows) {
    if (rows.isEmpty) return const <RevisionItem>[];
    return List<RevisionItem>.unmodifiable(rows.map(fromJson));
  }

  /// Serializes all fields of [item] into a JSON map.
  static Map<String, dynamic> toJson(RevisionItem item) {
    return <String, dynamic>{
      'id': item.id,
      'user_id': item.userId,
      'material_id': _nullableTrim(item.materialId),
      'subject_id': item.subjectId,
      'topic_id': _nullableTrim(item.topicId),
      'reference_label': item.referenceLabel.trim(),
      'page_number': item.pageNumber,
      'note': _nullableTrim(item.note),
      'reason': item.reason.value,
      'source': item.source.value,
      'progress_log_id': _nullableTrim(item.progressLogId),
      'mock_test_id': _nullableTrim(item.mockTestId),
      'status': item.status.value,
      'due_on': PrepJsonHelpers.formatDateOnly(item.dueOn),
      'review_count': item.reviewCount,
      'last_reviewed_on': item.lastReviewedOn == null
          ? null
          : PrepJsonHelpers.formatDateOnly(item.lastReviewedOn!),
      'created_at': item.createdAt?.toUtc().toIso8601String(),
      'updated_at': item.updatedAt?.toUtc().toIso8601String(),
    };
  }

  /// Serializes fields for `INSERT` into `public.revision_items`.
  static Map<String, dynamic> toInsertJson(
    RevisionItem item, {
    String? userId,
  }) {
    final resolvedUserId = (userId ?? item.userId).trim();
    return <String, dynamic>{
      if (item.id.trim().isNotEmpty) 'id': item.id.trim(),
      if (resolvedUserId.isNotEmpty) 'user_id': resolvedUserId,
      'material_id': _nullableTrim(item.materialId),
      'subject_id': item.subjectId.trim(),
      'topic_id': _nullableTrim(item.topicId),
      'reference_label': item.referenceLabel.trim(),
      'page_number': item.pageNumber,
      'note': _nullableTrim(item.note),
      'reason': item.reason.value,
      'source': item.source.value,
      'progress_log_id': _nullableTrim(item.progressLogId),
      'mock_test_id': _nullableTrim(item.mockTestId),
      'status': item.status.value,
      'due_on': PrepJsonHelpers.formatDateOnly(item.dueOn),
      'review_count': item.reviewCount,
      'last_reviewed_on': item.lastReviewedOn == null
          ? null
          : PrepJsonHelpers.formatDateOnly(item.lastReviewedOn!),
    };
  }

  /// Serializes mutable fields for `UPDATE` on `public.revision_items`.
  static Map<String, dynamic> toUpdateJson(RevisionItem item) {
    return <String, dynamic>{
      'material_id': _nullableTrim(item.materialId),
      'subject_id': item.subjectId.trim(),
      'topic_id': _nullableTrim(item.topicId),
      'reference_label': item.referenceLabel.trim(),
      'page_number': item.pageNumber,
      'note': _nullableTrim(item.note),
      'reason': item.reason.value,
      'source': item.source.value,
      'progress_log_id': _nullableTrim(item.progressLogId),
      'mock_test_id': _nullableTrim(item.mockTestId),
      'status': item.status.value,
      'due_on': PrepJsonHelpers.formatDateOnly(item.dueOn),
      'review_count': item.reviewCount,
      'last_reviewed_on': item.lastReviewedOn == null
          ? null
          : PrepJsonHelpers.formatDateOnly(item.lastReviewedOn!),
    };
  }

  static DateTime? _readOptionalDateOnly(
    Map<String, dynamic> json,
    String key,
  ) {
    final value = json[key];
    if (value == null) return null;
    if (value is DateTime) {
      return DateTime(value.year, value.month, value.day);
    }
    if (value is String) {
      final trimmed = value.trim();
      if (trimmed.isEmpty) return null;
      final parsed = DateTime.tryParse(trimmed);
      if (parsed == null) return null;
      return DateTime(parsed.year, parsed.month, parsed.day);
    }
    return null;
  }

  static String? _nullableTrim(String? value) {
    final trimmed = value?.trim();
    if (trimmed == null || trimmed.isEmpty) return null;
    return trimmed;
  }
}
