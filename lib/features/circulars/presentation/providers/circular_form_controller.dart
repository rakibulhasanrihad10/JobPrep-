import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show NotifierProviderFamily;
import 'package:job_prep/features/circulars/domain/entities/circular.dart';
import 'package:job_prep/features/circulars/domain/entities/circular_enums.dart';
import 'package:job_prep/features/circulars/domain/errors/circular_failure.dart';
import 'package:job_prep/features/circulars/domain/validators/circular_form_validators.dart';
import 'package:job_prep/features/circulars/presentation/providers/circular_form_state.dart';
import 'package:job_prep/features/circulars/presentation/providers/circular_mutation_providers.dart';
import 'package:job_prep/features/circulars/presentation/providers/circulars_providers.dart';

/// Controller managing validation, duplicate detection, dirty tracking, and
/// submission for the unified circular add/edit form.
class CircularFormController extends Notifier<CircularFormState> {
  /// Creates a [CircularFormController] seeded with [initialCircular] (`null`
  /// when adding a new circular).
  CircularFormController(this.initialCircular);

  /// Initial circular when editing, or `null` when adding.
  final Circular? initialCircular;

  List<Circular> _knownCirculars = const [];

  @override
  CircularFormState build() {
    _knownCirculars = ref.read(circularsListProvider).asData?.value ?? const [];

    ref.listen<AsyncValue<List<Circular>>>(circularsListProvider, (_, next) {
      final items = next.asData?.value;
      if (items == null) return;
      _knownCirculars = items;
      final duplicate = _detectDuplicate(state.circularUrl);
      if (duplicate != state.duplicateCircular) {
        state = state.copyWith(duplicateCircular: duplicate);
      }
    });

    return CircularFormState.fromCircular(
      initialCircular,
      existingCirculars: _knownCirculars,
    );
  }

  /// Updates the required circular title.
  void updateTitle(String value) {
    state = state.copyWith(
      title: value,
      submitFailure: null,
      titleError: state.hasAttemptedSubmit
          ? CircularFormValidators.validateTitle(value)
          : state.titleError,
    );
  }

  /// Updates the employment [sector].
  void updateSector(CircularSector sector) {
    state = state.copyWith(sector: sector, submitFailure: null);
  }

  /// Updates the optional recruiting organization name.
  void updateOrganizationName(String value) {
    state = state.copyWith(organizationName: value, submitFailure: null);
  }

  /// Updates the optional organization website URL.
  void updateOrganizationWebsite(String value) {
    state = state.copyWith(
      organizationWebsite: value,
      submitFailure: null,
      organizationWebsiteError: state.hasAttemptedSubmit
          ? CircularFormValidators.validateOptionalUrl(value)
          : state.organizationWebsiteError,
    );
  }

  /// Updates the original circular link and evaluates duplicate detection live.
  void updateCircularUrl(String value) {
    state = state.copyWith(
      circularUrl: value,
      submitFailure: null,
      circularUrlError: state.hasAttemptedSubmit
          ? CircularFormValidators.validateOptionalUrl(value)
          : state.circularUrlError,
      duplicateCircular: _detectDuplicate(value),
    );
  }

  /// Updates the online application portal URL.
  void updateApplicationUrl(String value) {
    state = state.copyWith(
      applicationUrl: value,
      submitFailure: null,
      applicationUrlError: state.hasAttemptedSubmit
          ? CircularFormValidators.validateOptionalUrl(value)
          : state.applicationUrlError,
    );
  }

  /// Updates or clears the application [deadline].
  void updateDeadline(DateTime? deadline) {
    state = state.copyWith(deadline: deadline, submitFailure: null);
  }

  /// Updates the optional vacancy count text.
  void updateVacancies(String value) {
    state = state.copyWith(
      vacanciesText: value,
      submitFailure: null,
      vacanciesError: state.hasAttemptedSubmit
          ? CircularFormValidators.validateOptionalNonNegativeInt(value)
          : state.vacanciesError,
    );
  }

  /// Updates minimum salary text and checks cross-field salary range.
  void updateSalaryMin(String value) {
    state = state.copyWith(
      salaryMinText: value,
      submitFailure: null,
      salaryMinError: state.hasAttemptedSubmit
          ? CircularFormValidators.validateOptionalNonNegativeNumber(value)
          : state.salaryMinError,
      salaryRangeError: CircularFormValidators.validateSalaryRange(
        salaryMinText: value,
        salaryMaxText: state.salaryMaxText,
      ),
    );
  }

  /// Updates maximum salary text and checks cross-field salary range.
  void updateSalaryMax(String value) {
    state = state.copyWith(
      salaryMaxText: value,
      submitFailure: null,
      salaryMaxError: state.hasAttemptedSubmit
          ? CircularFormValidators.validateOptionalNonNegativeNumber(value)
          : state.salaryMaxError,
      salaryRangeError: CircularFormValidators.validateSalaryRange(
        salaryMinText: state.salaryMinText,
        salaryMaxText: value,
      ),
    );
  }

  /// Updates the optional salary note.
  void updateSalaryNote(String value) {
    state = state.copyWith(salaryNote: value, submitFailure: null);
  }

  /// Updates the optional application fee text.
  void updateApplicationFee(String value) {
    state = state.copyWith(
      applicationFeeText: value,
      submitFailure: null,
      applicationFeeError: state.hasAttemptedSubmit
          ? CircularFormValidators.validateOptionalNonNegativeNumber(value)
          : state.applicationFeeError,
    );
  }

  /// Updates the optional fee note.
  void updateFeeNote(String value) {
    state = state.copyWith(feeNote: value, submitFailure: null);
  }

  /// Updates the application progression [status].
  void updateApplicationStatus(ApplicationStatus status) {
    state = state.copyWith(applicationStatus: status, submitFailure: null);
  }

  /// Updates the admit card [status].
  void updateAdmitCardStatus(AdmitCardStatus status) {
    state = state.copyWith(admitCardStatus: status, submitFailure: null);
  }

  /// Updates the circular [priority].
  void updatePriority(CircularPriority priority) {
    state = state.copyWith(priority: priority, submitFailure: null);
  }

  /// Updates the workflow [status].
  void updateWorkflowStatus(CircularWorkflowStatus status) {
    state = state.copyWith(workflowStatus: status, submitFailure: null);
  }

  /// Updates the instructions text.
  void updateInstructions(String value) {
    state = state.copyWith(instructions: value, submitFailure: null);
  }

  /// Updates personal preparation/reminder notes.
  void updateNotes(String value) {
    state = state.copyWith(notes: value, submitFailure: null);
  }

  /// Updates syllabus notes.
  void updateSyllabus(String value) {
    state = state.copyWith(syllabus: value, submitFailure: null);
  }

  /// Runs full field and cross-field validation, updating state errors.
  bool validateAll() {
    final nextState = state.copyWith(
      hasAttemptedSubmit: true,
      titleError: CircularFormValidators.validateTitle(state.title),
      organizationWebsiteError: CircularFormValidators.validateOptionalUrl(
        state.organizationWebsite,
      ),
      circularUrlError:
          CircularFormValidators.validateOptionalUrl(state.circularUrl),
      applicationUrlError:
          CircularFormValidators.validateOptionalUrl(state.applicationUrl),
      vacanciesError: CircularFormValidators.validateOptionalNonNegativeInt(
        state.vacanciesText,
      ),
      salaryMinError: CircularFormValidators.validateOptionalNonNegativeNumber(
        state.salaryMinText,
      ),
      salaryMaxError: CircularFormValidators.validateOptionalNonNegativeNumber(
        state.salaryMaxText,
      ),
      salaryRangeError: CircularFormValidators.validateSalaryRange(
        salaryMinText: state.salaryMinText,
        salaryMaxText: state.salaryMaxText,
      ),
      applicationFeeError:
          CircularFormValidators.validateOptionalNonNegativeNumber(
        state.applicationFeeText,
      ),
      duplicateCircular: _detectDuplicate(state.circularUrl),
    );
    state = nextState;
    return !nextState.hasValidationErrors;
  }

  /// Validates and submits the form to create or update the circular.
  ///
  /// Returns the persisted [Circular] on success, or `null` when validation
  /// fails or the repository rejects the write.
  Future<Circular?> submit() async {
    if (state.isSubmitting) return null;
    if (!validateAll()) return null;

    state = state.copyWith(isSubmitting: true, submitFailure: null);
    final payload = state.toCircular();

    final Circular? saved;
    final Object? mutationError;
    if (state.isEditMode) {
      saved = await ref
          .read(updateCircularProvider.notifier)
          .updateCircular(payload);
      mutationError = ref.read(updateCircularProvider).error;
    } else {
      saved = await ref.read(createCircularProvider.notifier).create(payload);
      mutationError = ref.read(createCircularProvider).error;
    }

    if (!ref.mounted) return saved;

    if (saved != null) {
      state = state.copyWith(
        isSubmitting: false,
        submitFailure: null,
        savedCircular: saved,
      );
      return saved;
    }

    final failure = mutationError is CircularFailure
        ? mutationError
        : const UnknownCircularFailure();
    state = state.copyWith(
      isSubmitting: false,
      submitFailure: failure,
    );
    return null;
  }

  Circular? _detectDuplicate(String circularUrl) {
    return CircularFormValidators.findDuplicateCircularByLink(
      circularUrl: circularUrl,
      existingCirculars: _knownCirculars,
      editingCircularId: state.originalCircular?.id,
    );
  }
}

/// Family provider scoping [CircularFormController] to the optional existing
/// [Circular] being edited (or `null` when adding a new circular).
final NotifierProviderFamily<CircularFormController, CircularFormState,
        Circular?> circularFormControllerProvider =
    NotifierProvider.autoDispose
        .family<CircularFormController, CircularFormState, Circular?>(
  CircularFormController.new,
);
