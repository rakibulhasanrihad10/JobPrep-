import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:job_prep/core/localization/app_localizations_extension.dart';
import 'package:job_prep/core/localization/formatters.dart';
import 'package:job_prep/core/localization/locale_controller.dart';
import 'package:job_prep/core/theme/app_theme_tokens.dart';
import 'package:job_prep/core/widgets/glass_button.dart';
import 'package:job_prep/core/widgets/glass_dialog.dart';
import 'package:job_prep/features/prep/domain/entities/mock_test.dart';
import 'package:job_prep/features/prep/domain/entities/subject.dart';
import 'package:job_prep/features/prep/presentation/providers/mock_test_providers.dart';
import 'package:job_prep/features/prep/presentation/providers/prep_progress_log_controller.dart';
import 'package:job_prep/features/prep/presentation/providers/prep_providers.dart';
import 'package:job_prep/features/prep/presentation/utils/mock_test_form_validator.dart';
import 'package:job_prep/features/prep/presentation/utils/prep_l10n.dart';
import 'package:job_prep/features/prep/presentation/widgets/mock_test_attachment_fields.dart';
import 'package:job_prep/features/prep/presentation/widgets/mock_test_form_fields.dart';

/// Opens a glassmorphic dialog to create or edit a [MockTest].
Future<MockTest?> showMockTestFormDialog(
  BuildContext context, {
  MockTest? existing,
  String? initialSubjectId,
}) {
  return showGlassDialog<MockTest>(
    context: context,
    builder: (_) => _MockTestFormDialog(
      existing: existing,
      initialSubjectId: initialSubjectId,
    ),
  );
}

class _MockTestFormDialog extends ConsumerStatefulWidget {
  const _MockTestFormDialog({
    this.existing,
    this.initialSubjectId,
  });

  final MockTest? existing;
  final String? initialSubjectId;

  @override
  ConsumerState<_MockTestFormDialog> createState() =>
      _MockTestFormDialogState();
}

class _MockTestFormDialogState extends ConsumerState<_MockTestFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _sourceController;
  late final TextEditingController _marksObtainedController;
  late final TextEditingController _totalMarksController;
  late final TextEditingController _negativeMarksController;
  late final TextEditingController _timeTakenController;
  late final TextEditingController _timeLimitController;
  late final TextEditingController _weakTopicsController;
  late final TextEditingController _notesController;

  String? _subjectId;
  String? _circularId;
  String? _materialId;
  String? _topicId;
  late DateTime _takenOn;
  String? _validationError;

  @override
  void initState() {
    super.initState();
    final existing = widget.existing;
    _titleController = TextEditingController(text: existing?.title ?? '');
    _sourceController = TextEditingController(text: existing?.source ?? '');
    _marksObtainedController = TextEditingController(
      text: existing != null ? _formatCleanNumber(existing.marksObtained) : '',
    );
    _totalMarksController = TextEditingController(
      text: existing != null ? _formatCleanNumber(existing.totalMarks) : '',
    );
    _negativeMarksController = TextEditingController(
      text: existing?.negativeMarks != null
          ? _formatCleanNumber(existing!.negativeMarks!)
          : '',
    );
    _timeTakenController = TextEditingController(
      text: existing?.timeTakenMinutes?.toString() ?? '',
    );
    _timeLimitController = TextEditingController(
      text: existing?.timeLimitMinutes?.toString() ?? '',
    );
    _weakTopicsController =
        TextEditingController(text: existing?.weakTopics ?? '');
    _notesController = TextEditingController(text: existing?.notes ?? '');

    _subjectId = existing?.subjectId ?? widget.initialSubjectId;
    _circularId = existing?.circularId;
    _materialId = existing?.materialId;
    _topicId = existing?.topicId;

    final now = ref.read(prepNowProvider)();
    final rawDate = existing?.takenOn ?? now;
    _takenOn = DateTime.utc(rawDate.year, rawDate.month, rawDate.day);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _sourceController.dispose();
    _marksObtainedController.dispose();
    _totalMarksController.dispose();
    _negativeMarksController.dispose();
    _timeTakenController.dispose();
    _timeLimitController.dispose();
    _weakTopicsController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  String _formatCleanNumber(double value) =>
      value % 1 == 0 ? value.round().toString() : value.toString();

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _takenOn.toLocal(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (!mounted || picked == null) return;
    setState(() {
      _takenOn = DateTime.utc(picked.year, picked.month, picked.day);
    });
  }

  Future<void> _submit(List<Subject> subjects) async {
    final result = MockTestFormValidator.validateAndBuildDraft(
      l10n: context.l10n,
      subjects: subjects,
      subjectId: _subjectId,
      titleRaw: _titleController.text,
      sourceRaw: _sourceController.text,
      takenOn: _takenOn,
      marksObtainedRaw: _marksObtainedController.text,
      totalMarksRaw: _totalMarksController.text,
      negativeMarksRaw: _negativeMarksController.text,
      timeTakenRaw: _timeTakenController.text,
      timeLimitRaw: _timeLimitController.text,
      weakTopicsRaw: _weakTopicsController.text,
      notesRaw: _notesController.text,
      circularId: _circularId,
      materialId: _materialId,
      topicId: _topicId,
      existing: widget.existing,
    );

    setState(() => _validationError = result.errorMessage);
    final draft = result.draft;
    if (draft == null) return;

    ref.read(mockTestControllerProvider.notifier).clearError();
    final saved =
        await ref.read(mockTestControllerProvider.notifier).saveTest(draft);
    if (!mounted) return;
    if (saved != null) {
      Navigator.of(context).pop(saved);
    }
  }

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final colors = tokens.colors;
    final spacing = tokens.spacing;
    final l10n = context.l10n;
    final locale = ref.watch(localeProvider);
    final useBanglaDigits = ref.watch(useBanglaDigitsProvider);
    final mutationState = ref.watch(mockTestControllerProvider);
    final isBusy = mutationState.isBusy;

    final subjects = List<Subject>.of(
      ref.watch(subjectsProvider).asData?.value ?? const <Subject>[],
    )..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));

    final effectiveSubjectId =
        MockTestFormValidator.resolveSubjectId(subjects, _subjectId);
    final formattedDate = AppFormatters.formatDate(
      _takenOn,
      locale: locale,
      pattern: 'd MMM yyyy',
      useBanglaDigits: useBanglaDigits,
    );
    final errorMessage = _validationError ??
        (mutationState.error != null
            ? PrepL10n.failureMessage(mutationState.error!, l10n)
            : null);

    return GlassDialog(
      key: const ValueKey('mock-test-form-dialog'),
      maxWidth: 540,
      title: Text(
        widget.existing == null
            ? l10n.prepMockFormCreateTitle
            : l10n.prepMockFormEditTitle,
        style: tokens.textStyles.titleLarge,
      ),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                l10n.prepMockFormSubjectLabel,
                style: tokens.textStyles.labelLarge,
              ),
              SizedBox(height: spacing.xs),
              if (subjects.isNotEmpty)
                DropdownButtonFormField<String>(
                  key: const ValueKey('mock-form-subject-dropdown'),
                  initialValue: effectiveSubjectId,
                  isExpanded: true,
                  items: [
                    for (final s in subjects)
                      DropdownMenuItem<String>(
                        value: s.id,
                        child: Text(s.name, overflow: TextOverflow.ellipsis),
                      ),
                  ],
                  onChanged: isBusy
                      ? null
                      : (value) => setState(() {
                            _subjectId = value;
                            _materialId = null;
                            _topicId = null;
                          }),
                )
              else
                Text(
                  l10n.prepMockValidationSubjectRequired,
                  style: tokens.textStyles.bodySmall.copyWith(
                    color: colors.danger,
                  ),
                ),
              SizedBox(height: spacing.md),
              MockTestFormFields(
                titleController: _titleController,
                sourceController: _sourceController,
                marksObtainedController: _marksObtainedController,
                totalMarksController: _totalMarksController,
                negativeMarksController: _negativeMarksController,
                timeTakenController: _timeTakenController,
                timeLimitController: _timeLimitController,
                weakTopicsController: _weakTopicsController,
                notesController: _notesController,
                formattedDate: formattedDate,
                isBusy: isBusy,
                onPickDate: _pickDate,
              ),
              SizedBox(height: spacing.md),
              MockTestAttachmentFields(
                selectedSubjectId: effectiveSubjectId,
                selectedCircularId: _circularId,
                selectedMaterialId: _materialId,
                selectedTopicId: _topicId,
                isBusy: isBusy,
                onCircularChanged: (v) => setState(() => _circularId = v),
                onMaterialChanged: (v) => setState(() => _materialId = v),
                onTopicChanged: (v) => setState(() => _topicId = v),
              ),
              if (errorMessage != null) ...[
                SizedBox(height: spacing.md),
                Text(
                  errorMessage,
                  key: const ValueKey('mock-form-error-text'),
                  style: tokens.textStyles.bodySmall.copyWith(
                    color: colors.danger,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
      actions: [
        GlassButton(
          onPressed: isBusy ? null : () => Navigator.of(context).pop(),
          child: Text(l10n.prepCancelButton),
        ),
        GlassButton(
          key: const ValueKey('mock-form-submit-button'),
          variant: GlassButtonVariant.primary,
          onPressed: isBusy ? null : () => _submit(subjects),
          child: Text(l10n.prepMockFormSaveAction),
        ),
      ],
    );
  }
}
