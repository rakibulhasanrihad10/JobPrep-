import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show NotifierProviderFamily;
import 'package:job_prep/features/circulars/domain/entities/circular.dart';
import 'package:job_prep/features/circulars/domain/errors/circular_failure.dart';
import 'package:job_prep/features/circulars/domain/utils/quick_capture_helpers.dart';
import 'package:job_prep/features/circulars/domain/validators/circular_form_validators.dart';
import 'package:job_prep/features/circulars/presentation/providers/circular_mutation_providers.dart';
import 'package:job_prep/features/circulars/presentation/providers/circulars_providers.dart';
import 'package:job_prep/features/circulars/presentation/providers/quick_capture_state.dart';

/// Controller handling Quick Capture validation, duplicate link checking,
/// fallback title derivation, and saving directly to Inbox.
class QuickCaptureController extends Notifier<QuickCaptureState> {
  /// Creates a [QuickCaptureController] optionally seeded with [initialLink]
  /// (for example from a `?capture=` query parameter).
  QuickCaptureController(this.initialLink);

  /// Optional prefilled circular link.
  final String? initialLink;

  List<Circular> _knownCirculars = const [];

  @override
  QuickCaptureState build() {
    _knownCirculars = ref.read(circularsListProvider).asData?.value ?? const [];

    ref.listen<AsyncValue<List<Circular>>>(circularsListProvider, (_, next) {
      final items = next.asData?.value;
      if (items == null) return;
      _knownCirculars = items;
      final duplicate = _detectDuplicate(state.link);
      if (duplicate != state.duplicateCircular) {
        state = state.copyWith(duplicateCircular: duplicate);
      }
    });

    final trimmedInitial = initialLink?.trim() ?? '';
    return QuickCaptureState(
      link: trimmedInitial,
      duplicateCircular: _detectDuplicate(trimmedInitial),
    );
  }

  /// Updates the circular link and performs live duplicate link detection.
  void updateLink(String value) {
    state = state.copyWith(
      link: value,
      submitFailure: null,
      linkError: state.hasAttemptedSubmit
          ? validateRequiredCircularLink(value)
          : state.linkError,
      duplicateCircular: _detectDuplicate(value),
    );
  }

  /// Updates the optional custom circular title.
  void updateTitle(String value) {
    state = state.copyWith(
      title: value,
      submitFailure: null,
    );
  }

  /// Updates or clears the optional [deadline].
  void updateDeadline(DateTime? deadline) {
    state = state.copyWith(
      deadline: deadline,
      submitFailure: null,
    );
  }

  /// Validates the link and saves an inbox circular (`workflow_status: inbox`,
  /// `is_quick_capture: true`) with as few interactions as possible.
  Future<Circular?> submit() async {
    if (state.isSubmitting) return null;

    final linkError = validateRequiredCircularLink(state.link);
    final duplicate = _detectDuplicate(state.link);
    state = state.copyWith(
      hasAttemptedSubmit: true,
      linkError: linkError,
      duplicateCircular: duplicate,
      submitFailure: null,
    );

    if (linkError != null) return null;

    state = state.copyWith(isSubmitting: true);
    final payload = state.toInboxCircular();
    final saved =
        await ref.read(createCircularProvider.notifier).create(payload);

    if (!ref.mounted) return saved;

    if (saved != null) {
      state = state.copyWith(
        isSubmitting: false,
        savedCircular: saved,
        submitFailure: null,
      );
      return saved;
    }

    final mutationError = ref.read(createCircularProvider).error;
    final failure = mutationError is CircularFailure
        ? mutationError
        : const UnknownCircularFailure();
    state = state.copyWith(
      isSubmitting: false,
      submitFailure: failure,
    );
    return null;
  }

  Circular? _detectDuplicate(String url) {
    return CircularFormValidators.findDuplicateCircularByLink(
      circularUrl: url,
      existingCirculars: _knownCirculars,
    );
  }
}

/// Auto-disposed family provider scoping [QuickCaptureController] per initial
/// link (null when opened manually via button or keyboard shortcut).
final NotifierProviderFamily<QuickCaptureController, QuickCaptureState, String?>
    quickCaptureControllerProvider = NotifierProvider.autoDispose
        .family<QuickCaptureController, QuickCaptureState, String?>(
  QuickCaptureController.new,
);
