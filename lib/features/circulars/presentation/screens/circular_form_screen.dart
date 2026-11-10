import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:job_prep/core/theme/app_theme_tokens.dart';
import 'package:job_prep/features/circulars/domain/entities/circular.dart';
import 'package:job_prep/features/circulars/presentation/providers/circular_form_controller.dart';
import 'package:job_prep/features/circulars/presentation/providers/circular_form_state.dart';
import 'package:job_prep/features/circulars/presentation/providers/circulars_providers.dart';
import 'package:job_prep/features/circulars/presentation/widgets/circular_form_chrome.dart';
import 'package:job_prep/features/circulars/presentation/widgets/circular_form_sections.dart';
import 'package:job_prep/features/circulars/presentation/widgets/circulars_states.dart';

/// Unified add and edit screen for job circulars.
class CircularFormScreen extends ConsumerWidget {
  /// Creates a [CircularFormScreen].
  ///
  /// Opens in add mode when both [circularId] and [initialCircular] are
  /// `null`. In edit mode, pass [circularId] and optionally [initialCircular].
  const CircularFormScreen({
    super.key,
    this.circularId,
    this.initialCircular,
    this.onSaved,
    this.onDiscarded,
  });

  /// Identifier of the circular being edited, or `null` when adding.
  final String? circularId;

  /// Preloaded circular instance if already in memory.
  final Circular? initialCircular;

  /// Optional callback fired after saving succeeds.
  final ValueChanged<Circular>? onSaved;

  /// Optional callback fired when cancelling or discarding the form.
  final VoidCallback? onDiscarded;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (initialCircular != null || circularId == null) {
      return _CircularFormBody(
        seedCircular: initialCircular,
        onSaved: onSaved,
        onDiscarded: onDiscarded,
      );
    }

    final circularAsync = ref.watch(circularByIdProvider(circularId!));
    return circularAsync.when(
      loading: () => Padding(
        padding: context.tokens.spacing.insetsAllXl,
        child: const CircularsLoadingState(),
      ),
      error: (error, _) => Padding(
        padding: context.tokens.spacing.insetsAllXl,
        child: CircularsErrorState(
          error: error,
          onRetry: () => ref.invalidate(circularByIdProvider(circularId!)),
        ),
      ),
      data: (circular) {
        if (circular == null) {
          return CircularFormNotFoundCard(
            onBack: () => _exitScreen(context),
          );
        }
        return _CircularFormBody(
          seedCircular: circular,
          onSaved: onSaved,
          onDiscarded: onDiscarded,
        );
      },
    );
  }

  void _exitScreen(BuildContext context) {
    if (onDiscarded != null) {
      onDiscarded!();
      return;
    }
    final router = GoRouter.maybeOf(context);
    if (router != null) {
      if (router.canPop()) {
        router.pop();
      } else {
        router.go('/circulars');
      }
      return;
    }
    Navigator.of(context).maybePop();
  }
}

class _CircularFormBody extends ConsumerStatefulWidget {
  const _CircularFormBody({
    required this.seedCircular,
    this.onSaved,
    this.onDiscarded,
  });

  final Circular? seedCircular;
  final ValueChanged<Circular>? onSaved;
  final VoidCallback? onDiscarded;

  @override
  ConsumerState<_CircularFormBody> createState() => _CircularFormBodyState();
}

class _CircularFormBodyState extends ConsumerState<_CircularFormBody> {
  late final TextEditingController _titleController;
  late final TextEditingController _orgNameController;
  late final TextEditingController _orgWebsiteController;
  late final TextEditingController _circularUrlController;
  late final TextEditingController _applicationUrlController;
  late final TextEditingController _vacanciesController;
  late final TextEditingController _salaryMinController;
  late final TextEditingController _salaryMaxController;
  late final TextEditingController _salaryNoteController;
  late final TextEditingController _feeController;
  late final TextEditingController _feeNoteController;
  late final TextEditingController _instructionsController;
  late final TextEditingController _notesController;
  late final TextEditingController _syllabusController;

  bool _discardConfirmed = false;

  @override
  void initState() {
    super.initState();
    final initial = ref.read(
      circularFormControllerProvider(widget.seedCircular),
    );
    _titleController = TextEditingController(text: initial.title);
    _orgNameController = TextEditingController(text: initial.organizationName);
    _orgWebsiteController = TextEditingController(
      text: initial.organizationWebsite,
    );
    _circularUrlController = TextEditingController(text: initial.circularUrl);
    _applicationUrlController = TextEditingController(
      text: initial.applicationUrl,
    );
    _vacanciesController = TextEditingController(text: initial.vacanciesText);
    _salaryMinController = TextEditingController(text: initial.salaryMinText);
    _salaryMaxController = TextEditingController(text: initial.salaryMaxText);
    _salaryNoteController = TextEditingController(text: initial.salaryNote);
    _feeController = TextEditingController(text: initial.applicationFeeText);
    _feeNoteController = TextEditingController(text: initial.feeNote);
    _instructionsController = TextEditingController(text: initial.instructions);
    _notesController = TextEditingController(text: initial.notes);
    _syllabusController = TextEditingController(text: initial.syllabus);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _orgNameController.dispose();
    _orgWebsiteController.dispose();
    _circularUrlController.dispose();
    _applicationUrlController.dispose();
    _vacanciesController.dispose();
    _salaryMinController.dispose();
    _salaryMaxController.dispose();
    _salaryNoteController.dispose();
    _feeController.dispose();
    _feeNoteController.dispose();
    _instructionsController.dispose();
    _notesController.dispose();
    _syllabusController.dispose();
    super.dispose();
  }

  Future<bool> _confirmDiscard() async {
    final confirmed = await showDiscardCircularChangesDialog(context);
    if (confirmed && mounted) {
      setState(() => _discardConfirmed = true);
    }
    return confirmed;
  }

  Future<void> _handleAttemptClose(CircularFormState formState) async {
    if (formState.isSubmitting) return;
    if (formState.isDirty && !_discardConfirmed) {
      final confirmed = await _confirmDiscard();
      if (!confirmed || !mounted) return;
    }
    _leaveScreen();
  }

  Future<void> _handleSubmit(CircularFormController controller) async {
    final saved = await controller.submit();
    if (!mounted || saved == null) return;
    if (widget.onSaved != null) {
      widget.onSaved!(saved);
      return;
    }
    _leaveScreen();
  }

  void _leaveScreen() {
    if (widget.onDiscarded != null) {
      widget.onDiscarded!();
      return;
    }
    final router = GoRouter.maybeOf(context);
    if (router != null) {
      if (router.canPop()) {
        router.pop();
      } else {
        router.go('/circulars');
      }
      return;
    }
    Navigator.of(context).maybePop();
  }

  @override
  Widget build(BuildContext context) {
    final formProvider = circularFormControllerProvider(widget.seedCircular);
    final formState = ref.watch(formProvider);
    final controller = ref.read(formProvider.notifier);

    final tokens = context.tokens;
    final spacing = tokens.spacing;

    final canPop = _discardConfirmed ||
        !formState.isDirty ||
        formState.savedCircular != null;

    return PopScope(
      canPop: canPop,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        final confirmed = await _confirmDiscard();
        if (confirmed && mounted) {
          _leaveScreen();
        }
      },
      child: SingleChildScrollView(
        padding: spacing.insetsAllXl,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            CircularFormHeaderCard(
              isEditMode: formState.isEditMode,
              isSubmitting: formState.isSubmitting,
              onBack: () => _handleAttemptClose(formState),
            ),
            if (formState.submitFailure != null) ...[
              SizedBox(height: spacing.md),
              CircularFormFailureBanner(failure: formState.submitFailure!),
            ],
            SizedBox(height: spacing.lg),
            CircularFormSections(
              formState: formState,
              controller: controller,
              titleController: _titleController,
              orgNameController: _orgNameController,
              orgWebsiteController: _orgWebsiteController,
              circularUrlController: _circularUrlController,
              applicationUrlController: _applicationUrlController,
              vacanciesController: _vacanciesController,
              salaryMinController: _salaryMinController,
              salaryMaxController: _salaryMaxController,
              salaryNoteController: _salaryNoteController,
              feeController: _feeController,
              feeNoteController: _feeNoteController,
              instructionsController: _instructionsController,
              notesController: _notesController,
              syllabusController: _syllabusController,
            ),
            SizedBox(height: spacing.xl),
            CircularFormFooterActions(
              isEditMode: formState.isEditMode,
              isSubmitting: formState.isSubmitting,
              onCancel: () => _handleAttemptClose(formState),
              onSubmit: () => _handleSubmit(controller),
            ),
          ],
        ),
      ),
    );
  }
}
