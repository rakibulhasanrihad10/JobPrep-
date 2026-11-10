import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:job_prep/core/localization/app_localizations_extension.dart';
import 'package:job_prep/core/localization/formatters.dart';
import 'package:job_prep/core/localization/locale_controller.dart';
import 'package:job_prep/core/theme/app_theme_tokens.dart';
import 'package:job_prep/core/widgets/glass_button.dart';
import 'package:job_prep/core/widgets/glass_dialog.dart';
import 'package:job_prep/core/widgets/glass_text_field.dart';
import 'package:job_prep/features/circulars/domain/entities/circular_enums.dart';
import 'package:job_prep/features/circulars/domain/entities/circular_exam_date.dart';
import 'package:job_prep/features/circulars/domain/errors/circular_failure.dart';
import 'package:job_prep/features/circulars/presentation/providers/circulars_providers.dart';
import 'package:job_prep/features/circulars/presentation/providers/exam_date_providers.dart';
import 'package:job_prep/features/circulars/presentation/utils/circular_l10n.dart';
import 'package:job_prep/features/circulars/presentation/widgets/circular_form_widgets.dart';

/// Opens a frosted glass dialog to add or edit a [CircularExamDate] for
/// [circularId]. Returns `true` when persisted successfully.
Future<bool> showExamDateDialog(
  BuildContext context, {
  required String circularId,
  CircularExamDate? existing,
}) async {
  final saved = await showGlassDialog<bool>(
    context: context,
    builder: (_) => ExamDateDialog(
      circularId: circularId,
      existing: existing,
    ),
  );
  return saved ?? false;
}

/// Frosted glass modal for creating or editing a circular's exam stage row.
class ExamDateDialog extends ConsumerStatefulWidget {
  /// Creates an [ExamDateDialog].
  const ExamDateDialog({
    required this.circularId,
    this.existing,
    super.key,
  });

  /// Parent circular identifier.
  final String circularId;

  /// Existing exam date when editing, or `null` when adding.
  final CircularExamDate? existing;

  @override
  ConsumerState<ExamDateDialog> createState() => _ExamDateDialogState();
}

class _ExamDateDialogState extends ConsumerState<ExamDateDialog> {
  late ExamStage _stage;
  late DateTime _scheduledDateTime;
  late final TextEditingController _venueController;
  late final TextEditingController _notesController;
  bool _isSaving = false;
  CircularFailure? _failure;

  @override
  void initState() {
    super.initState();
    final existing = widget.existing;
    final now = ref.read(circularNowProvider)();
    _stage = existing != null
        ? ExamStage.fromValue(existing.stage)
        : ExamStage.preliminary;
    _scheduledDateTime = existing?.examDate.toLocal() ??
        DateTime(now.year, now.month, now.day, 10).add(
          const Duration(days: 7),
        );
    _venueController = TextEditingController(text: existing?.venue ?? '');
    _notesController = TextEditingController(text: existing?.notes ?? '');
  }

  @override
  void dispose() {
    _venueController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _scheduledDateTime,
      firstDate: DateTime(2020),
      lastDate: DateTime(2040),
    );
    if (picked == null || !mounted) return;
    setState(() {
      _scheduledDateTime = DateTime(
        picked.year,
        picked.month,
        picked.day,
        _scheduledDateTime.hour,
        _scheduledDateTime.minute,
      );
      _failure = null;
    });
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_scheduledDateTime),
    );
    if (picked == null || !mounted) return;
    setState(() {
      _scheduledDateTime = DateTime(
        _scheduledDateTime.year,
        _scheduledDateTime.month,
        _scheduledDateTime.day,
        picked.hour,
        picked.minute,
      );
      _failure = null;
    });
  }

  Future<void> _handleSave() async {
    if (_isSaving) return;
    setState(() {
      _isSaving = true;
      _failure = null;
    });

    final trimmedVenue = _venueController.text.trim();
    final trimmedNotes = _notesController.text.trim();
    final notifier = ref.read(examDateMutationProvider.notifier);

    final base = widget.existing ??
        CircularExamDate(
          circularId: widget.circularId,
          stage: _stage.value,
          examDate: _scheduledDateTime,
        );

    final payload = base.copyWith(
      circularId: widget.circularId,
      stage: _stage.value,
      examDate: _scheduledDateTime.toUtc(),
      venue: trimmedVenue.isEmpty ? null : trimmedVenue,
      notes: trimmedNotes.isEmpty ? null : trimmedNotes,
    );

    final saved = widget.existing == null
        ? await notifier.createExamDate(payload)
        : await notifier.updateExamDate(payload);

    if (!mounted) return;
    if (saved != null) {
      Navigator.of(context).pop(true);
      return;
    }

    final mutationError = ref.read(examDateMutationProvider).error;
    setState(() {
      _isSaving = false;
      _failure = mutationError is CircularFailure
          ? mutationError
          : const UnknownCircularFailure();
    });
  }

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final colors = tokens.colors;
    final spacing = tokens.spacing;
    final textStyles = tokens.textStyles;
    final l10n = context.l10n;
    final locale = ref.watch(localeProvider);
    final useBanglaDigits = ref.watch(useBanglaDigitsProvider);
    final isEdit = widget.existing != null;
    final enabled = !_isSaving;

    final formattedDate = AppFormatters.formatDate(
      _scheduledDateTime,
      locale: locale,
      pattern: 'd MMM yyyy',
      useBanglaDigits: useBanglaDigits,
    );
    final formattedTime = AppFormatters.formatDate(
      _scheduledDateTime,
      locale: locale,
      pattern: 'hh:mm a',
      useBanglaDigits: useBanglaDigits,
    );

    return GlassDialog(
      key: const ValueKey('exam-date-dialog'),
      maxWidth: 460,
      title: Row(
        children: [
          Icon(
            Icons.event_note_rounded,
            color: colors.goldAccent,
            size: spacing.xl,
          ),
          SizedBox(width: spacing.sm),
          Expanded(
            child: Text(
              isEdit
                  ? l10n.examDateDialogEditTitle
                  : l10n.examDateDialogAddTitle,
            ),
          ),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            CircularEnumDropdown<ExamStage>(
              key: const ValueKey('exam-date-stage-field'),
              label: l10n.examDateStageLabel,
              value: _stage,
              items: ExamStage.values,
              enabled: enabled,
              labelBuilder: (item) => CircularL10n.examStageLabel(item, l10n),
              onChanged: (next) => setState(() => _stage = next),
            ),
            SizedBox(height: spacing.md),
            Text(
              l10n.examDateDateLabel,
              style: textStyles.labelLarge.copyWith(
                color: colors.textSecondary,
              ),
            ),
            SizedBox(height: spacing.sm),
            Wrap(
              spacing: spacing.sm,
              runSpacing: spacing.sm,
              children: [
                GlassButton(
                  key: const ValueKey('exam-date-picker-btn'),
                  onPressed: enabled ? _pickDate : null,
                  leading: Icon(
                    Icons.calendar_today_outlined,
                    size: spacing.lg,
                    color: colors.goldAccent,
                  ),
                  child: Text(formattedDate),
                ),
                GlassButton(
                  key: const ValueKey('exam-date-time-btn'),
                  onPressed: enabled ? _pickTime : null,
                  leading: Icon(
                    Icons.schedule_rounded,
                    size: spacing.lg,
                    color: colors.goldAccent,
                  ),
                  child: Text(formattedTime),
                ),
              ],
            ),
            SizedBox(height: spacing.md),
            GlassTextField(
              key: const ValueKey('exam-date-venue-field'),
              controller: _venueController,
              enabled: enabled,
              labelText: l10n.examDateVenueLabel,
              hintText: l10n.examDateVenueHint,
            ),
            SizedBox(height: spacing.md),
            GlassTextField(
              key: const ValueKey('exam-date-notes-field'),
              controller: _notesController,
              enabled: enabled,
              maxLines: 2,
              labelText: l10n.examDateNotesLabel,
              hintText: l10n.examDateNotesHint,
            ),
            if (_failure != null) ...[
              SizedBox(height: spacing.md),
              Container(
                key: const ValueKey('exam-date-error-banner'),
                padding: spacing.insetsAllMd,
                decoration: BoxDecoration(
                  color: colors.danger.withValues(alpha: 0.14),
                  borderRadius: tokens.radii.buttonRadius,
                  border: Border.all(
                    color: colors.danger.withValues(alpha: 0.55),
                  ),
                ),
                child: Text(
                  CircularL10n.circularErrorMessage(_failure!, l10n),
                  style: textStyles.bodySmall.copyWith(color: colors.danger),
                ),
              ),
            ],
          ],
        ),
      ),
      actions: [
        GlassButton(
          key: const ValueKey('exam-date-cancel-btn'),
          onPressed: enabled ? () => Navigator.of(context).pop(false) : null,
          child: Text(l10n.circularFormCancelButton),
        ),
        GlassButton(
          key: const ValueKey('exam-date-save-btn'),
          variant: GlassButtonVariant.primary,
          onPressed: enabled ? _handleSave : null,
          leading: _isSaving
              ? SizedBox(
                  width: spacing.lg,
                  height: spacing.lg,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: colors.background,
                  ),
                )
              : Icon(Icons.check_rounded, size: spacing.lg),
          child: Text(
            isEdit
                ? l10n.circularFormUpdateButton
                : l10n.circularFormSaveButton,
          ),
        ),
      ],
    );
  }
}
