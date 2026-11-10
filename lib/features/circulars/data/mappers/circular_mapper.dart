import 'package:job_prep/features/circulars/data/mappers/circular_exam_date_mapper.dart';
import 'package:job_prep/features/circulars/data/mappers/circular_file_mapper.dart';
import 'package:job_prep/features/circulars/data/mappers/circular_json_helpers.dart';
import 'package:job_prep/features/circulars/domain/entities/application_checklist.dart';
import 'package:job_prep/features/circulars/domain/entities/circular.dart';
import 'package:job_prep/features/circulars/domain/entities/circular_enums.dart';

/// Maps between PostgreSQL `public.circulars` PostgREST JSON payloads and
/// [Circular] domain entities.
abstract final class CircularMapper {
  /// Deserializes a `public.circulars` JSON object (and optional nested
  /// `circular_exam_dates` / `circular_files` relations) into a [Circular].
  static Circular fromJson(Map<String, dynamic> json) {
    final examDateRows = CircularJsonHelpers.readJsonList(
      json,
      'circular_exam_dates',
    );
    final fileRows = CircularJsonHelpers.readJsonList(
      json,
      'circular_files',
    );

    return Circular(
      id: CircularJsonHelpers.readRequiredString(json, 'id'),
      userId: CircularJsonHelpers.readRequiredString(json, 'user_id'),
      title: CircularJsonHelpers.readRequiredString(json, 'title'),
      sector: CircularSector.fromValue(
        CircularJsonHelpers.readOptionalString(json, 'sector'),
      ),
      organizationName: CircularJsonHelpers.readOptionalString(
        json,
        'organization_name',
      ),
      organizationWebsite: CircularJsonHelpers.readOptionalString(
        json,
        'organization_website',
      ),
      circularUrl: CircularJsonHelpers.readOptionalString(
        json,
        'circular_url',
      ),
      applicationUrl: CircularJsonHelpers.readOptionalString(
        json,
        'application_url',
      ),
      deadline: CircularJsonHelpers.readOptionalDateTime(json, 'deadline'),
      vacancies: CircularJsonHelpers.readOptionalInt(json, 'vacancies'),
      salaryMin: CircularJsonHelpers.readOptionalDouble(json, 'salary_min'),
      salaryMax: CircularJsonHelpers.readOptionalDouble(json, 'salary_max'),
      salaryNote: CircularJsonHelpers.readOptionalString(json, 'salary_note'),
      applicationFee: CircularJsonHelpers.readOptionalDouble(
        json,
        'application_fee',
      ),
      feeNote: CircularJsonHelpers.readOptionalString(json, 'fee_note'),
      applicationStatus: ApplicationStatus.fromValue(
        CircularJsonHelpers.readOptionalString(json, 'application_status'),
      ),
      admitCardStatus: AdmitCardStatus.fromValue(
        CircularJsonHelpers.readOptionalString(json, 'admit_card_status'),
      ),
      priority: CircularPriority.fromValue(
        CircularJsonHelpers.readOptionalString(json, 'priority'),
      ),
      workflowStatus: CircularWorkflowStatus.fromValue(
        CircularJsonHelpers.readOptionalString(json, 'workflow_status'),
      ),
      instructions: CircularJsonHelpers.readOptionalString(
        json,
        'instructions',
      ),
      notes: CircularJsonHelpers.readOptionalString(json, 'notes'),
      syllabus: CircularJsonHelpers.readOptionalString(json, 'syllabus'),
      isQuickCapture: CircularJsonHelpers.readBool(
        json,
        'is_quick_capture',
      ),
      checklist: ApplicationChecklist(
        photo: CircularJsonHelpers.readBool(json, 'checklist_photo'),
        certificates: CircularJsonHelpers.readBool(
          json,
          'checklist_certificates',
        ),
        feePaid: CircularJsonHelpers.readBool(json, 'checklist_fee_paid'),
        submitted: CircularJsonHelpers.readBool(json, 'checklist_submitted'),
        admitCardDownloaded: CircularJsonHelpers.readBool(
          json,
          'checklist_admit_card_downloaded',
        ),
      ),
      createdAt: CircularJsonHelpers.readOptionalDateTime(json, 'created_at'),
      updatedAt: CircularJsonHelpers.readOptionalDateTime(json, 'updated_at'),
      examDates: CircularExamDateMapper.fromJsonList(examDateRows),
      files: CircularFileMapper.fromJsonList(fileRows),
    );
  }

  /// Serializes a full [circular] (including metadata and child lists) to JSON.
  static Map<String, dynamic> toJson(Circular circular) {
    return <String, dynamic>{
      'id': circular.id,
      'user_id': circular.userId,
      ...toUpdateJson(circular),
      'created_at': circular.createdAt?.toUtc().toIso8601String(),
      'updated_at': circular.updatedAt?.toUtc().toIso8601String(),
      'circular_exam_dates':
          circular.examDates.map(CircularExamDateMapper.toJson).toList(),
      'circular_files': circular.files.map(CircularFileMapper.toJson).toList(),
    };
  }

  /// Serializes mutable fields of [circular] for an `INSERT` request.
  ///
  /// Omits blank `id`, `user_id`, and server timestamps so PostgreSQL defaults
  /// (`gen_random_uuid()`, `auth.uid()`, `now()`) populate them automatically.
  static Map<String, dynamic> toInsertJson(
    Circular circular, {
    String? userId,
  }) {
    final resolvedUserId = (userId ?? circular.userId).trim();
    return <String, dynamic>{
      if (circular.id.trim().isNotEmpty) 'id': circular.id.trim(),
      if (resolvedUserId.isNotEmpty) 'user_id': resolvedUserId,
      ...toUpdateJson(circular),
    };
  }

  /// Serializes mutable columns of [circular] for an `UPDATE` request.
  ///
  /// Retains explicit `null` values so clearing optional fields updates the
  /// corresponding PostgreSQL columns back to `NULL`.
  static Map<String, dynamic> toUpdateJson(Circular circular) {
    return <String, dynamic>{
      'title': circular.title.trim(),
      'sector': circular.sector.value,
      'organization_name': circular.organizationName,
      'organization_website': circular.organizationWebsite,
      'circular_url': circular.circularUrl,
      'application_url': circular.applicationUrl,
      'deadline': circular.deadline?.toUtc().toIso8601String(),
      'vacancies': circular.vacancies,
      'salary_min': circular.salaryMin,
      'salary_max': circular.salaryMax,
      'salary_note': circular.salaryNote,
      'application_fee': circular.applicationFee,
      'fee_note': circular.feeNote,
      'application_status': circular.applicationStatus.value,
      'admit_card_status': circular.admitCardStatus.value,
      'priority': circular.priority.value,
      'workflow_status': circular.workflowStatus.value,
      'instructions': circular.instructions,
      'notes': circular.notes,
      'syllabus': circular.syllabus,
      'is_quick_capture': circular.isQuickCapture,
      'checklist_photo': circular.checklist.photo,
      'checklist_certificates': circular.checklist.certificates,
      'checklist_fee_paid': circular.checklist.feePaid,
      'checklist_submitted': circular.checklist.submitted,
      'checklist_admit_card_downloaded': circular.checklist.admitCardDownloaded,
    };
  }
}
