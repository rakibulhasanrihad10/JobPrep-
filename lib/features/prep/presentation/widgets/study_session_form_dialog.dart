import 'dart:async' show unawaited;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:job_prep/core/localization/app_localizations_extension.dart';
import 'package:job_prep/core/localization/formatters.dart';
import 'package:job_prep/core/localization/locale_controller.dart';
import 'package:job_prep/core/theme/app_theme_tokens.dart';
import 'package:job_prep/core/widgets/glass_button.dart';
import 'package:job_prep/core/widgets/glass_dialog.dart';
import 'package:job_prep/core/widgets/glass_text_field.dart';
import 'package:job_prep/features/prep/domain/entities/prep_material.dart';
import 'package:job_prep/features/prep/domain/entities/study_session.dart';
import 'package:job_prep/features/prep/domain/entities/subject.dart';
import 'package:job_prep/features/prep/presentation/providers/prep_providers.dart';
import 'package:job_prep/features/prep/presentation/providers/study_session_crud_controller.dart';
import 'package:job_prep/features/prep/presentation/providers/study_session_providers.dart';
import 'package:job_prep/features/prep/presentation/utils/prep_l10n.dart';
import 'package:job_prep/features/prep/presentation/widgets/study_timer_sections.dart';

/// Opens a glass dialog to log a manual study session or edit an existing one.
Future<bool> showStudySessionFormDialog(
  BuildContext context, {
  StudySession? existing,
  String? initialSubjectId,
}) async {
  final saved = await showGlassDialog<bool>(
    context: context,
    builder: (_) => _StudySessionFormDialog(
      existing: existing,
      initialSubjectId: initialSubjectId,
    ),
  );
  return saved ?? false;
}

class _StudySessionFormDialog extends ConsumerStatefulWidget {
  const _StudySessionFormDialog({
    this.existing,
    this.initialSubjectId,
  });

  final StudySession? existing;
  final String? initialSubjectId;

  @override
  ConsumerState<_StudySessionFormDialog> createState() =>
      _StudySessionFormDialogState();
}

class _StudySessionFormDialogState
    extends ConsumerState<_StudySessionFormDialog> {
  String? _subjectId;
  String? _materialId;
  late DateTime _selectedDate;
  late TimeOfDay _selectedTime;
  late final TextEditingController _hoursController;
  late final TextEditingController _minutesController;
  late final TextEditingController _noteController;
  String? _durationError;

  @override
  void initState() {
    super.initState();
    final existing = widget.existing;
    final nowLocal = ref.read(studyTimerNowProvider)().toLocal();
    final startLocal = existing?.startedAt.toLocal() ?? nowLocal;

    _subjectId = existing?.subjectId ?? widget.initialSubjectId;
    _materialId = existing?.materialId;
    _selectedDate = DateTime(startLocal.year, startLocal.month, startLocal.day);
    _selectedTime = TimeOfDay.fromDateTime(startLocal);

    final totalMinutes =
        existing != null ? (existing.durationSeconds / 60).round() : 45;
    _hoursController = TextEditingController(text: '${totalMinutes ~/ 60}');
    _minutesController = TextEditingController(text: '${totalMinutes % 60}');
    _noteController = TextEditingController(text: existing?.note ?? '');
  }

  @override
  void dispose() {
    _hoursController.dispose();
    _minutesController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  int _parseSegment(String raw) {
    final normalized = AppFormatters.toEnglishDigits(raw.trim());
    if (normalized.isEmpty) return 0;
    return int.tryParse(normalized) ?? -1;
  }

  Future<void> _pickDate() async {
    final now = ref.read(studyTimerNowProvider)().toLocal();
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(now.year - 5),
      lastDate: DateTime(now.year + 1),
    );
    if (picked != null && mounted) {
      setState(() => _selectedDate = picked);
    }
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );
    if (picked != null && mounted) {
      setState(() => _selectedTime = picked);
    }
  }

  Future<void> _submit(List<Subject> subjects) async {
    final l10n = context.l10n;
    final subjectId =
        _subjectId ?? (subjects.isNotEmpty ? subjects.first.id : '');
    if (subjectId.isEmpty) return;

    final hours = _parseSegment(_hoursController.text);
    final minutes = _parseSegment(_minutesController.text);
    if (hours < 0 || minutes < 0 || (hours * 60 + minutes) <= 0) {
      setState(() => _durationError = l10n.prepTimerDurationPositiveError);
      return;
    }

    setState(() => _durationError = null);
    final durationSeconds = (hours * 60 + minutes) * 60;
    final localStart = DateTime(
      _selectedDate.year,
      _selectedDate.month,
      _selectedDate.day,
      _selectedTime.hour,
      _selectedTime.minute,
    );

    final notifier = ref.read(studySessionCrudControllerProvider.notifier);
    final existing = widget.existing;
    final saved = existing == null
        ? await notifier.createManualSession(
            subjectId: subjectId,
            materialId: _materialId,
            startedAt: localStart,
            durationSeconds: durationSeconds,
            note: _noteController.text,
          )
        : await notifier.updateCompletedSession(
            existing: existing,
            subjectId: subjectId,
            materialId: _materialId,
            startedAt: localStart,
            durationSeconds: durationSeconds,
            note: _noteController.text,
          );

    if (mounted && saved != null) {
      Navigator.of(context).pop(true);
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
    final crudState = ref.watch(studySessionCrudControllerProvider);

    final subjects = List<Subject>.of(
      ref.watch(subjectsProvider).asData?.value ?? const <Subject>[],
    )..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
    final allMaterials =
        ref.watch(allMaterialsProvider).asData?.value ?? const <PrepMaterial>[];

    final effectiveSubjectId = subjects.any((s) => s.id == _subjectId)
        ? _subjectId
        : (subjects.isNotEmpty ? subjects.first.id : null);
    final subjectMaterials = effectiveSubjectId == null
        ? const <PrepMaterial>[]
        : allMaterials
            .where((m) => m.subjectId == effectiveSubjectId)
            .toList(growable: false);
    final effectiveMaterialId =
        subjectMaterials.any((m) => m.id == _materialId) ? _materialId : null;

    final dateLabel = AppFormatters.formatDate(
      _selectedDate,
      locale: locale,
      pattern: 'yMMMd',
      useBanglaDigits: useBanglaDigits,
    );
    final rawTime = _selectedTime.format(context);
    final timeLabel = (useBanglaDigits || locale.languageCode == 'bn')
        ? AppFormatters.toBanglaDigits(rawTime)
        : rawTime;

    return GlassDialog(
      key: const ValueKey('session-form-dialog'),
      maxWidth: 500,
      title: Text(
        widget.existing == null
            ? l10n.prepTimerManualDialogTitle
            : l10n.prepTimerEditDialogTitle,
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            StudyTimerSubjectPickers(
              subjects: subjects,
              scopedMaterials: subjectMaterials,
              selectedSubjectId: effectiveSubjectId,
              selectedMaterialId: effectiveMaterialId,
              isLocked: crudState.isSaving,
              forceStacked: true,
              subjectFieldKey: const ValueKey('session-form-subject-dropdown'),
              materialFieldKey: ValueKey(
                'session-form-material-$effectiveSubjectId',
              ),
              onSelectSubject: (id) => setState(() {
                _subjectId = id;
                _materialId = null;
              }),
              onSelectMaterial: (id) => setState(() => _materialId = id),
            ),
            SizedBox(height: spacing.md),
            Wrap(
              spacing: spacing.sm,
              runSpacing: spacing.sm,
              children: [
                GlassButton(
                  key: const ValueKey('session-form-date-btn'),
                  onPressed:
                      crudState.isSaving ? null : () => unawaited(_pickDate()),
                  leading:
                      Icon(Icons.calendar_today_outlined, size: spacing.lg),
                  child: Text(l10n.prepTimerStartDateValue(dateLabel)),
                ),
                GlassButton(
                  key: const ValueKey('session-form-time-btn'),
                  onPressed:
                      crudState.isSaving ? null : () => unawaited(_pickTime()),
                  leading: Icon(Icons.schedule_outlined, size: spacing.lg),
                  child: Text(l10n.prepTimerStartTimeValue(timeLabel)),
                ),
              ],
            ),
            SizedBox(height: spacing.md),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: GlassTextField(
                    key: const ValueKey('session-form-hours-field'),
                    controller: _hoursController,
                    enabled: !crudState.isSaving,
                    labelText: l10n.prepTimerHoursLabel,
                    keyboardType: TextInputType.number,
                    onChanged: (_) {
                      if (_durationError != null) {
                        setState(() => _durationError = null);
                      }
                    },
                  ),
                ),
                SizedBox(width: spacing.sm),
                Expanded(
                  child: GlassTextField(
                    key: const ValueKey('session-form-minutes-field'),
                    controller: _minutesController,
                    enabled: !crudState.isSaving,
                    labelText: l10n.prepTimerMinutesLabel,
                    keyboardType: TextInputType.number,
                    onChanged: (_) {
                      if (_durationError != null) {
                        setState(() => _durationError = null);
                      }
                    },
                  ),
                ),
              ],
            ),
            if (_durationError != null) ...[
              SizedBox(height: spacing.xs),
              Text(
                _durationError!,
                style: tokens.textStyles.bodySmall.copyWith(
                  color: colors.danger,
                ),
              ),
            ],
            SizedBox(height: spacing.md),
            GlassTextField(
              key: const ValueKey('session-form-note-field'),
              controller: _noteController,
              enabled: !crudState.isSaving,
              labelText: l10n.prepTimerFinishNoteLabel,
              hintText: l10n.prepTimerFinishNoteHint,
            ),
            if (crudState.error != null) ...[
              SizedBox(height: spacing.xs),
              Text(
                PrepL10n.failureMessage(crudState.error!, l10n),
                style: tokens.textStyles.bodySmall.copyWith(
                  color: colors.danger,
                ),
              ),
            ],
          ],
        ),
      ),
      actions: [
        GlassButton(
          onPressed: crudState.isSaving
              ? null
              : () => Navigator.of(context).pop(false),
          child: Text(l10n.prepCancelButton),
        ),
        GlassButton(
          key: const ValueKey('session-form-save-btn'),
          variant: GlassButtonVariant.primary,
          onPressed: crudState.isSaving ? null : () => _submit(subjects),
          child: Text(l10n.prepSaveButton),
        ),
      ],
    );
  }
}
