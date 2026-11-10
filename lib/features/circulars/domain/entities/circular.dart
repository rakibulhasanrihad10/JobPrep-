import 'package:flutter/foundation.dart' show immutable, listEquals;
import 'package:job_prep/features/circulars/domain/entities/application_checklist.dart';
import 'package:job_prep/features/circulars/domain/entities/circular_enums.dart';
import 'package:job_prep/features/circulars/domain/entities/circular_exam_date.dart';
import 'package:job_prep/features/circulars/domain/entities/circular_file.dart';
import 'package:job_prep/features/circulars/domain/utils/deadline_countdown.dart';

/// Immutable domain entity representing a tracked job circular.
@immutable
class Circular {
  /// Creates a [Circular].
  const Circular({
    required this.title,
    this.id = '',
    this.userId = '',
    this.sector = CircularSector.government,
    this.organizationName,
    this.organizationWebsite,
    this.circularUrl,
    this.applicationUrl,
    this.deadline,
    this.vacancies,
    this.salaryMin,
    this.salaryMax,
    this.salaryNote,
    this.applicationFee,
    this.feeNote,
    this.applicationStatus = ApplicationStatus.notApplied,
    this.admitCardStatus = AdmitCardStatus.notAvailable,
    this.priority = CircularPriority.medium,
    this.workflowStatus = CircularWorkflowStatus.saved,
    this.instructions,
    this.notes,
    this.syllabus,
    this.isQuickCapture = false,
    this.checklist = const ApplicationChecklist(),
    this.createdAt,
    this.updatedAt,
    this.examDates = const [],
    this.files = const [],
  });

  static const _unset = Object();

  /// Unique circular identifier (`circulars.id`).
  final String id;

  /// Owner user identifier (`circulars.user_id`).
  final String userId;

  /// Job circular title or post name.
  final String title;

  /// Employment sector (`government`, `bcs`, `bank`, etc.).
  final CircularSector sector;

  /// Recruiting agency or company name.
  final String? organizationName;

  /// Official website URL of the recruiting organization.
  final String? organizationWebsite;

  /// Link to the published job circular announcement.
  final String? circularUrl;

  /// Online application portal URL.
  final String? applicationUrl;

  /// Submission deadline timestamp (`timestamptz`).
  final DateTime? deadline;

  /// Total advertised vacancy count.
  final int? vacancies;

  /// Minimum monthly salary or grade pay.
  final double? salaryMin;

  /// Maximum monthly salary or grade pay.
  final double? salaryMax;

  /// Additional pay scale or benefits note.
  final String? salaryNote;

  /// Required application fee amount.
  final double? applicationFee;

  /// Fee payment instructions or exemption note.
  final String? feeNote;

  /// Application progression status.
  final ApplicationStatus applicationStatus;

  /// Admit card availability status.
  final AdmitCardStatus admitCardStatus;

  /// Personal priority level.
  final CircularPriority priority;

  /// Overall tracking workflow status.
  final CircularWorkflowStatus workflowStatus;

  /// Application instructions or eligibility notes.
  final String? instructions;

  /// Personal preparation or reminder notes.
  final String? notes;

  /// Syllabus summary or exam topics.
  final String? syllabus;

  /// Whether the circular was saved via minimal quick-capture entry.
  final bool isQuickCapture;

  /// Checklist tracking key application milestones for this circular.
  final ApplicationChecklist checklist;

  /// Creation timestamp managed by PostgreSQL.
  final DateTime? createdAt;

  /// Last update timestamp managed by PostgreSQL.
  final DateTime? updatedAt;

  /// Scheduled exam stages attached to this circular.
  final List<CircularExamDate> examDates;

  /// Stored document metadata attached to this circular.
  final List<CircularFile> files;

  /// Computes remaining calendar days and urgency band relative to [now].
  DeadlineCountdown deadlineCountdown({DateTime? now}) {
    return computeDeadlineCountdown(deadline, now: now);
  }

  /// Returns a modified copy of this [Circular].
  ///
  /// Passing `null` for nullable fields (e.g. `deadline: null`, `notes: null`)
  /// explicitly clears those fields.
  Circular copyWith({
    String? id,
    String? userId,
    String? title,
    CircularSector? sector,
    Object? organizationName = _unset,
    Object? organizationWebsite = _unset,
    Object? circularUrl = _unset,
    Object? applicationUrl = _unset,
    Object? deadline = _unset,
    Object? vacancies = _unset,
    Object? salaryMin = _unset,
    Object? salaryMax = _unset,
    Object? salaryNote = _unset,
    Object? applicationFee = _unset,
    Object? feeNote = _unset,
    ApplicationStatus? applicationStatus,
    AdmitCardStatus? admitCardStatus,
    CircularPriority? priority,
    CircularWorkflowStatus? workflowStatus,
    Object? instructions = _unset,
    Object? notes = _unset,
    Object? syllabus = _unset,
    bool? isQuickCapture,
    ApplicationChecklist? checklist,
    Object? createdAt = _unset,
    Object? updatedAt = _unset,
    List<CircularExamDate>? examDates,
    List<CircularFile>? files,
  }) {
    return Circular(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      sector: sector ?? this.sector,
      organizationName: identical(organizationName, _unset)
          ? this.organizationName
          : organizationName as String?,
      organizationWebsite: identical(organizationWebsite, _unset)
          ? this.organizationWebsite
          : organizationWebsite as String?,
      circularUrl: identical(circularUrl, _unset)
          ? this.circularUrl
          : circularUrl as String?,
      applicationUrl: identical(applicationUrl, _unset)
          ? this.applicationUrl
          : applicationUrl as String?,
      deadline:
          identical(deadline, _unset) ? this.deadline : deadline as DateTime?,
      vacancies:
          identical(vacancies, _unset) ? this.vacancies : vacancies as int?,
      salaryMin:
          identical(salaryMin, _unset) ? this.salaryMin : salaryMin as double?,
      salaryMax:
          identical(salaryMax, _unset) ? this.salaryMax : salaryMax as double?,
      salaryNote: identical(salaryNote, _unset)
          ? this.salaryNote
          : salaryNote as String?,
      applicationFee: identical(applicationFee, _unset)
          ? this.applicationFee
          : applicationFee as double?,
      feeNote: identical(feeNote, _unset) ? this.feeNote : feeNote as String?,
      applicationStatus: applicationStatus ?? this.applicationStatus,
      admitCardStatus: admitCardStatus ?? this.admitCardStatus,
      priority: priority ?? this.priority,
      workflowStatus: workflowStatus ?? this.workflowStatus,
      instructions: identical(instructions, _unset)
          ? this.instructions
          : instructions as String?,
      notes: identical(notes, _unset) ? this.notes : notes as String?,
      syllabus:
          identical(syllabus, _unset) ? this.syllabus : syllabus as String?,
      isQuickCapture: isQuickCapture ?? this.isQuickCapture,
      checklist: checklist ?? this.checklist,
      createdAt: identical(createdAt, _unset)
          ? this.createdAt
          : createdAt as DateTime?,
      updatedAt: identical(updatedAt, _unset)
          ? this.updatedAt
          : updatedAt as DateTime?,
      examDates:
          examDates != null ? List.unmodifiable(examDates) : this.examDates,
      files: files != null ? List.unmodifiable(files) : this.files,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Circular &&
        other.id == id &&
        other.userId == userId &&
        other.title == title &&
        other.sector == sector &&
        other.organizationName == organizationName &&
        other.organizationWebsite == organizationWebsite &&
        other.circularUrl == circularUrl &&
        other.applicationUrl == applicationUrl &&
        other.deadline == deadline &&
        other.vacancies == vacancies &&
        other.salaryMin == salaryMin &&
        other.salaryMax == salaryMax &&
        other.salaryNote == salaryNote &&
        other.applicationFee == applicationFee &&
        other.feeNote == feeNote &&
        other.applicationStatus == applicationStatus &&
        other.admitCardStatus == admitCardStatus &&
        other.priority == priority &&
        other.workflowStatus == workflowStatus &&
        other.instructions == instructions &&
        other.notes == notes &&
        other.syllabus == syllabus &&
        other.isQuickCapture == isQuickCapture &&
        other.checklist == checklist &&
        other.createdAt == createdAt &&
        other.updatedAt == updatedAt &&
        listEquals(other.examDates, examDates) &&
        listEquals(other.files, files);
  }

  @override
  int get hashCode => Object.hashAll([
        id,
        userId,
        title,
        sector,
        organizationName,
        organizationWebsite,
        circularUrl,
        applicationUrl,
        deadline,
        vacancies,
        salaryMin,
        salaryMax,
        salaryNote,
        applicationFee,
        feeNote,
        applicationStatus,
        admitCardStatus,
        priority,
        workflowStatus,
        instructions,
        notes,
        syllabus,
        isQuickCapture,
        checklist,
        createdAt,
        updatedAt,
        Object.hashAll(examDates),
        Object.hashAll(files),
      ]);

  @override
  String toString() => 'Circular(id: $id, title: $title)';
}
