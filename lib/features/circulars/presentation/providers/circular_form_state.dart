import 'package:flutter/foundation.dart' show immutable;
import 'package:job_prep/features/circulars/domain/entities/circular.dart';
import 'package:job_prep/features/circulars/domain/entities/circular_enums.dart';
import 'package:job_prep/features/circulars/domain/errors/circular_failure.dart';
import 'package:job_prep/features/circulars/domain/validators/circular_form_validators.dart';

const Object _unset = Object();

/// Immutable form state for adding or editing a [Circular].
@immutable
class CircularFormState {
  /// Creates a [CircularFormState].
  const CircularFormState({
    this.originalCircular,
    this.title = '',
    this.sector = CircularSector.government,
    this.organizationName = '',
    this.organizationWebsite = '',
    this.circularUrl = '',
    this.applicationUrl = '',
    this.deadline,
    this.vacanciesText = '',
    this.salaryMinText = '',
    this.salaryMaxText = '',
    this.salaryNote = '',
    this.applicationFeeText = '',
    this.feeNote = '',
    this.applicationStatus = ApplicationStatus.notApplied,
    this.admitCardStatus = AdmitCardStatus.notAvailable,
    this.priority = CircularPriority.medium,
    this.workflowStatus = CircularWorkflowStatus.saved,
    this.instructions = '',
    this.notes = '',
    this.syllabus = '',
    this.titleError,
    this.organizationWebsiteError,
    this.circularUrlError,
    this.applicationUrlError,
    this.vacanciesError,
    this.salaryMinError,
    this.salaryMaxError,
    this.salaryRangeError,
    this.applicationFeeError,
    this.duplicateCircular,
    this.hasAttemptedSubmit = false,
    this.isSubmitting = false,
    this.submitFailure,
    this.savedCircular,
  });

  /// Initialises [CircularFormState] from [existing] in edit mode, or uses
  /// clean defaults when [existing] is `null`.
  factory CircularFormState.fromCircular(
    Circular? existing, {
    List<Circular> existingCirculars = const [],
  }) {
    if (existing == null) {
      return const CircularFormState();
    }

    final duplicate = CircularFormValidators.findDuplicateCircularByLink(
      circularUrl: existing.circularUrl,
      existingCirculars: existingCirculars,
      editingCircularId: existing.id,
    );

    return CircularFormState(
      originalCircular: existing,
      title: existing.title,
      sector: existing.sector,
      organizationName: existing.organizationName ?? '',
      organizationWebsite: existing.organizationWebsite ?? '',
      circularUrl: existing.circularUrl ?? '',
      applicationUrl: existing.applicationUrl ?? '',
      deadline: existing.deadline,
      vacanciesText: existing.vacancies?.toString() ?? '',
      salaryMinText: _formatAmount(existing.salaryMin),
      salaryMaxText: _formatAmount(existing.salaryMax),
      salaryNote: existing.salaryNote ?? '',
      applicationFeeText: _formatAmount(existing.applicationFee),
      feeNote: existing.feeNote ?? '',
      applicationStatus: existing.applicationStatus,
      admitCardStatus: existing.admitCardStatus,
      priority: existing.priority,
      workflowStatus: existing.workflowStatus,
      instructions: existing.instructions ?? '',
      notes: existing.notes ?? '',
      syllabus: existing.syllabus ?? '',
      duplicateCircular: duplicate,
    );
  }

  /// Original entity when editing; `null` when adding a new circular.
  final Circular? originalCircular;

  final String title;
  final CircularSector sector;
  final String organizationName;
  final String organizationWebsite;
  final String circularUrl;
  final String applicationUrl;
  final DateTime? deadline;
  final String vacanciesText;
  final String salaryMinText;
  final String salaryMaxText;
  final String salaryNote;
  final String applicationFeeText;
  final String feeNote;
  final ApplicationStatus applicationStatus;
  final AdmitCardStatus admitCardStatus;
  final CircularPriority priority;
  final CircularWorkflowStatus workflowStatus;
  final String instructions;
  final String notes;
  final String syllabus;

  final CircularTitleValidationError? titleError;
  final CircularUrlValidationError? organizationWebsiteError;
  final CircularUrlValidationError? circularUrlError;
  final CircularUrlValidationError? applicationUrlError;
  final CircularNumberValidationError? vacanciesError;
  final CircularNumberValidationError? salaryMinError;
  final CircularNumberValidationError? salaryMaxError;
  final CircularSalaryRangeValidationError? salaryRangeError;
  final CircularNumberValidationError? applicationFeeError;

  /// Another existing circular sharing the same normalized `circularUrl`.
  final Circular? duplicateCircular;

  /// Whether submit has been triggered at least once.
  final bool hasAttemptedSubmit;

  /// Whether a save request is currently in flight.
  final bool isSubmitting;

  /// Backend failure returned on the latest submit attempt, if any.
  final CircularFailure? submitFailure;

  /// Persisted circular returned after a successful submit.
  final Circular? savedCircular;

  /// Whether this form is editing an existing circular.
  bool get isEditMode => originalCircular != null;

  /// Whether any validation error is currently active.
  bool get hasValidationErrors =>
      titleError != null ||
      organizationWebsiteError != null ||
      circularUrlError != null ||
      applicationUrlError != null ||
      vacanciesError != null ||
      salaryMinError != null ||
      salaryMaxError != null ||
      salaryRangeError != null ||
      applicationFeeError != null;

  /// Whether the user has unsaved edits compared with [originalCircular].
  bool get isDirty {
    if (savedCircular != null) return false;
    final baseline = CircularFormState.fromCircular(originalCircular);
    return toCircular() != baseline.toCircular() ||
        vacanciesText.trim() != baseline.vacanciesText ||
        salaryMinText.trim() != baseline.salaryMinText ||
        salaryMaxText.trim() != baseline.salaryMaxText ||
        applicationFeeText.trim() != baseline.applicationFeeText;
  }

  /// Builds a domain [Circular] from the current form values.
  Circular toCircular() {
    final base = originalCircular ?? const Circular(title: '');
    return base.copyWith(
      title: title.trim(),
      sector: sector,
      organizationName: _nullableTrimmed(organizationName),
      organizationWebsite: _nullableTrimmed(organizationWebsite),
      circularUrl: _nullableTrimmed(circularUrl),
      applicationUrl: _nullableTrimmed(applicationUrl),
      deadline: deadline,
      vacancies: CircularFormValidators.parseOptionalInt(vacanciesText),
      salaryMin: CircularFormValidators.parseOptionalDouble(salaryMinText),
      salaryMax: CircularFormValidators.parseOptionalDouble(salaryMaxText),
      salaryNote: _nullableTrimmed(salaryNote),
      applicationFee: CircularFormValidators.parseOptionalDouble(
        applicationFeeText,
      ),
      feeNote: _nullableTrimmed(feeNote),
      applicationStatus: applicationStatus,
      admitCardStatus: admitCardStatus,
      priority: priority,
      workflowStatus: workflowStatus,
      instructions: _nullableTrimmed(instructions),
      notes: _nullableTrimmed(notes),
      syllabus: _nullableTrimmed(syllabus),
    );
  }

  /// Returns an updated copy of this [CircularFormState].
  CircularFormState copyWith({
    String? title,
    CircularSector? sector,
    String? organizationName,
    String? organizationWebsite,
    String? circularUrl,
    String? applicationUrl,
    Object? deadline = _unset,
    String? vacanciesText,
    String? salaryMinText,
    String? salaryMaxText,
    String? salaryNote,
    String? applicationFeeText,
    String? feeNote,
    ApplicationStatus? applicationStatus,
    AdmitCardStatus? admitCardStatus,
    CircularPriority? priority,
    CircularWorkflowStatus? workflowStatus,
    String? instructions,
    String? notes,
    String? syllabus,
    Object? titleError = _unset,
    Object? organizationWebsiteError = _unset,
    Object? circularUrlError = _unset,
    Object? applicationUrlError = _unset,
    Object? vacanciesError = _unset,
    Object? salaryMinError = _unset,
    Object? salaryMaxError = _unset,
    Object? salaryRangeError = _unset,
    Object? applicationFeeError = _unset,
    Object? duplicateCircular = _unset,
    bool? hasAttemptedSubmit,
    bool? isSubmitting,
    Object? submitFailure = _unset,
    Object? savedCircular = _unset,
  }) {
    return CircularFormState(
      originalCircular: originalCircular,
      title: title ?? this.title,
      sector: sector ?? this.sector,
      organizationName: organizationName ?? this.organizationName,
      organizationWebsite: organizationWebsite ?? this.organizationWebsite,
      circularUrl: circularUrl ?? this.circularUrl,
      applicationUrl: applicationUrl ?? this.applicationUrl,
      deadline:
          identical(deadline, _unset) ? this.deadline : deadline as DateTime?,
      vacanciesText: vacanciesText ?? this.vacanciesText,
      salaryMinText: salaryMinText ?? this.salaryMinText,
      salaryMaxText: salaryMaxText ?? this.salaryMaxText,
      salaryNote: salaryNote ?? this.salaryNote,
      applicationFeeText: applicationFeeText ?? this.applicationFeeText,
      feeNote: feeNote ?? this.feeNote,
      applicationStatus: applicationStatus ?? this.applicationStatus,
      admitCardStatus: admitCardStatus ?? this.admitCardStatus,
      priority: priority ?? this.priority,
      workflowStatus: workflowStatus ?? this.workflowStatus,
      instructions: instructions ?? this.instructions,
      notes: notes ?? this.notes,
      syllabus: syllabus ?? this.syllabus,
      titleError: identical(titleError, _unset)
          ? this.titleError
          : titleError as CircularTitleValidationError?,
      organizationWebsiteError: identical(organizationWebsiteError, _unset)
          ? this.organizationWebsiteError
          : organizationWebsiteError as CircularUrlValidationError?,
      circularUrlError: identical(circularUrlError, _unset)
          ? this.circularUrlError
          : circularUrlError as CircularUrlValidationError?,
      applicationUrlError: identical(applicationUrlError, _unset)
          ? this.applicationUrlError
          : applicationUrlError as CircularUrlValidationError?,
      vacanciesError: identical(vacanciesError, _unset)
          ? this.vacanciesError
          : vacanciesError as CircularNumberValidationError?,
      salaryMinError: identical(salaryMinError, _unset)
          ? this.salaryMinError
          : salaryMinError as CircularNumberValidationError?,
      salaryMaxError: identical(salaryMaxError, _unset)
          ? this.salaryMaxError
          : salaryMaxError as CircularNumberValidationError?,
      salaryRangeError: identical(salaryRangeError, _unset)
          ? this.salaryRangeError
          : salaryRangeError as CircularSalaryRangeValidationError?,
      applicationFeeError: identical(applicationFeeError, _unset)
          ? this.applicationFeeError
          : applicationFeeError as CircularNumberValidationError?,
      duplicateCircular: identical(duplicateCircular, _unset)
          ? this.duplicateCircular
          : duplicateCircular as Circular?,
      hasAttemptedSubmit: hasAttemptedSubmit ?? this.hasAttemptedSubmit,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      submitFailure: identical(submitFailure, _unset)
          ? this.submitFailure
          : submitFailure as CircularFailure?,
      savedCircular: identical(savedCircular, _unset)
          ? this.savedCircular
          : savedCircular as Circular?,
    );
  }

  static String? _nullableTrimmed(String raw) {
    final trimmed = raw.trim();
    return trimmed.isEmpty ? null : trimmed;
  }

  static String _formatAmount(double? amount) {
    if (amount == null) return '';
    if (amount == amount.roundToDouble()) {
      return amount.toInt().toString();
    }
    return amount.toString();
  }
}
