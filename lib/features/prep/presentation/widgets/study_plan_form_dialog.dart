import 'dart:async' show unawaited;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:job_prep/core/localization/app_localizations_extension.dart';
import 'package:job_prep/core/localization/formatters.dart';
import 'package:job_prep/core/localization/locale_controller.dart';
import 'package:job_prep/core/theme/app_theme_tokens.dart';
import 'package:job_prep/core/widgets/glass_button.dart';
import 'package:job_prep/core/widgets/glass_dialog.dart';
import 'package:job_prep/features/circulars/domain/entities/circular.dart';
import 'package:job_prep/features/circulars/presentation/providers/circulars_providers.dart';
import 'package:job_prep/features/prep/domain/entities/study_plan.dart';
import 'package:job_prep/features/prep/domain/utils/study_plan_calculator.dart';
import 'package:job_prep/features/prep/presentation/providers/prep_providers.dart';
import 'package:job_prep/features/prep/presentation/providers/study_plan_providers.dart';
import 'package:job_prep/features/prep/presentation/widgets/prep_option_chip.dart';
import 'package:job_prep/features/prep/presentation/widgets/study_plan_circular_link_fields.dart';
import 'package:job_prep/features/prep/presentation/widgets/study_plan_schedule_fields.dart';

/// Opens the create/edit modal dialog for a combined or per-subject [StudyPlan].
Future<StudyPlan?> showStudyPlanFormDialog(
  BuildContext context, {
  StudyPlan? existing,
  String? initialSubjectId,
}) {
  return showGlassDialog<StudyPlan?>(
    context: context,
    barrierDismissible: false,
    builder: (_) => StudyPlanFormDialog(
      existing: existing,
      initialSubjectId: initialSubjectId,
    ),
  );
}

/// Modal form dialog creating or editing a [StudyPlan] with circular/exam-date
/// auto-fill, finish buffer days, weekly rest days, and pace limit settings.
class StudyPlanFormDialog extends ConsumerStatefulWidget {
  /// Creates a [StudyPlanFormDialog].
  const StudyPlanFormDialog({
    super.key,
    this.existing,
    this.initialSubjectId,
  });

  /// Existing plan when editing, or `null` to create a new plan.
  final StudyPlan? existing;

  /// Preselected subject scope when creating from a subject context.
  final String? initialSubjectId;

  @override
  ConsumerState<StudyPlanFormDialog> createState() =>
      _StudyPlanFormDialogState();
}

class _StudyPlanFormDialogState extends ConsumerState<StudyPlanFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _bufferController;
  late final TextEditingController _maxPaceController;
  late DateTime _startDate;
  late DateTime _targetDate;
  String? _selectedSubjectId;
  String? _selectedCircularId;
  String? _selectedExamDateId;
  late int _restDaysPerWeek;
  String? _dateError;

  @override
  void initState() {
    super.initState();
    final today = StudyPlanCalculator.normalizeUtcDate(
      ref.read(studyPlanNowProvider)(),
    );
    final existing = widget.existing;
    _selectedSubjectId = existing?.subjectId ?? widget.initialSubjectId;
    _selectedCircularId = existing?.circularId;
    _selectedExamDateId = existing?.examDateId;
    _startDate = existing?.startDate ?? today;
    _targetDate = existing?.targetDate ?? today.add(const Duration(days: 37));
    _restDaysPerWeek = existing?.restDaysPerWeek ?? 0;
    _bufferController = TextEditingController(
      text: '${existing?.finishBufferDays ?? 7}',
    );
    _maxPaceController = TextEditingController(
      text: existing?.maxDailyPace != null ? '${existing!.maxDailyPace}' : '',
    );
  }

  @override
  void dispose() {
    _bufferController.dispose();
    _maxPaceController.dispose();
    super.dispose();
  }

  Future<void> _pickDate({required bool isStart}) async {
    final initial = isStart ? _startDate : _targetDate;
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime(initial.year, initial.month, initial.day),
      firstDate: DateTime(2020),
      lastDate: DateTime(2035),
    );
    if (picked == null || !mounted) return;
    setState(() {
      _dateError = null;
      final normalized = StudyPlanCalculator.normalizeUtcDate(picked);
      if (isStart) {
        _startDate = normalized;
      } else {
        _targetDate = normalized;
        _selectedExamDateId = null;
      }
    });
  }

  void _selectCircular(String? circularId, List<Circular> circulars) {
    setState(() {
      _selectedCircularId = circularId;
      _selectedExamDateId = null;
      _dateError = null;
      if (circularId == null) return;
      final circular = circulars.where((c) => c.id == circularId).firstOrNull;
      if (circular == null) return;
      if (circular.examDates.isNotEmpty) {
        final sorted = [...circular.examDates]
          ..sort((a, b) => a.examDate.compareTo(b.examDate));
        _selectedExamDateId = sorted.first.id;
        _targetDate = StudyPlanCalculator.normalizeUtcDate(
          sorted.first.examDate,
        );
      } else if (circular.deadline != null) {
        _targetDate = StudyPlanCalculator.normalizeUtcDate(
          circular.deadline!,
        );
      }
    });
  }

  int? _parseInt(String raw) {
    final ascii = AppFormatters.toEnglishDigits(raw.trim());
    return int.tryParse(ascii);
  }

  Future<void> _submit() async {
    final l10n = context.l10n;
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final start = StudyPlanCalculator.normalizeUtcDate(_startDate);
    final target = StudyPlanCalculator.normalizeUtcDate(_targetDate);
    if (target.isBefore(start)) {
      setState(() => _dateError = l10n.prepStudyPlanValidationDates);
      return;
    }

    final buffer = _parseInt(_bufferController.text) ?? 7;
    final maxPaceText = _maxPaceController.text.trim();
    final maxPace = maxPaceText.isEmpty ? null : _parseInt(maxPaceText);
    final existing = widget.existing;

    final draft =
        (existing ?? StudyPlan(startDate: start, targetDate: target)).copyWith(
      subjectId: _selectedSubjectId,
      circularId: _selectedCircularId,
      examDateId: _selectedExamDateId,
      startDate: start,
      targetDate: target,
      finishBufferDays: buffer,
      restDaysPerWeek: _restDaysPerWeek,
      maxDailyPace: maxPace,
    );

    final saved =
        await ref.read(studyPlanControllerProvider.notifier).savePlan(draft);
    if (!mounted) return;
    if (saved != null) {
      Navigator.of(context).pop(saved);
    }
  }

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final spacing = tokens.spacing;
    final l10n = context.l10n;
    final locale = ref.watch(localeProvider);
    final useBanglaDigits = ref.watch(useBanglaDigitsProvider);
    final subjects = ref.watch(subjectsProvider).asData?.value ?? const [];
    final circulars =
        ref.watch(circularsListProvider).asData?.value ?? const [];
    final isBusy = ref.watch(studyPlanControllerProvider).isBusy;

    return GlassDialog(
      key: const ValueKey('study-plan-form-dialog'),
      title: Text(
        widget.existing == null
            ? l10n.prepStudyPlanCreateTitle
            : l10n.prepStudyPlanEditTitle,
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
                l10n.prepStudyPlanScopeLabel,
                style: tokens.textStyles.labelLarge,
              ),
              SizedBox(height: spacing.xs),
              Wrap(
                spacing: spacing.xs,
                runSpacing: spacing.xs,
                children: [
                  PrepOptionChip(
                    key: const ValueKey('study-plan-scope-all'),
                    label: l10n.prepStudyPlanAllSubjectsLabel,
                    isSelected: _selectedSubjectId == null,
                    onTap: isBusy
                        ? null
                        : () => setState(() => _selectedSubjectId = null),
                  ),
                  for (final subject in subjects)
                    PrepOptionChip(
                      key: ValueKey('study-plan-scope-${subject.id}'),
                      label: subject.name,
                      isSelected: _selectedSubjectId == subject.id,
                      onTap: isBusy
                          ? null
                          : () =>
                              setState(() => _selectedSubjectId = subject.id),
                    ),
                ],
              ),
              if (circulars.isNotEmpty) ...[
                SizedBox(height: spacing.md),
                StudyPlanCircularLinkFields(
                  circulars: circulars,
                  selectedCircularId: _selectedCircularId,
                  selectedExamDateId: _selectedExamDateId,
                  isBusy: isBusy,
                  locale: locale,
                  useBanglaDigits: useBanglaDigits,
                  onCircularChanged: (val) => _selectCircular(val, circulars),
                  onExamDateSelected: (exam) => setState(() {
                    _selectedExamDateId = exam.id;
                    _targetDate =
                        StudyPlanCalculator.normalizeUtcDate(exam.examDate);
                    _dateError = null;
                  }),
                ),
              ],
              SizedBox(height: spacing.md),
              StudyPlanScheduleFields(
                startDate: _startDate,
                targetDate: _targetDate,
                dateError: _dateError,
                bufferController: _bufferController,
                maxPaceController: _maxPaceController,
                restDaysPerWeek: _restDaysPerWeek,
                isBusy: isBusy,
                locale: locale,
                useBanglaDigits: useBanglaDigits,
                onPickDate: _pickDate,
                onRestDaysChanged: (val) =>
                    setState(() => _restDaysPerWeek = val),
              ),
            ],
          ),
        ),
      ),
      actions: [
        GlassButton(
          onPressed: isBusy ? null : () => Navigator.of(context).pop(),
          child: Text(l10n.circularFormCancelButton),
        ),
        GlassButton(
          key: const ValueKey('study-plan-save-button'),
          variant: GlassButtonVariant.primary,
          onPressed: isBusy ? null : () => unawaited(_submit()),
          child: Text(l10n.prepStudyPlanSaveButton),
        ),
      ],
    );
  }
}
