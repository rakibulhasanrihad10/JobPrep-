import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:job_prep/core/localization/app_localizations_extension.dart';
import 'package:job_prep/core/theme/app_theme_tokens.dart';
import 'package:job_prep/core/widgets/glass_button.dart';
import 'package:job_prep/core/widgets/glass_card.dart';
import 'package:job_prep/core/widgets/glass_text_field.dart';
import 'package:job_prep/features/prep/domain/entities/prep_enums.dart';
import 'package:job_prep/features/prep/domain/entities/topic.dart';
import 'package:job_prep/features/prep/presentation/providers/syllabus_providers.dart';

/// Modal bottom sheet or dialog to edit topic notes, weights, and exact dates.
class TopicDetailSheet extends ConsumerStatefulWidget {
  const TopicDetailSheet({
    required this.topic,
    required this.enabledCheckpoints,
    super.key,
  });

  final Topic topic;
  final List<String> enabledCheckpoints;

  static Future<void> show(
    BuildContext context, {
    required Topic topic,
    required List<String> enabledCheckpoints,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => TopicDetailSheet(
        topic: topic,
        enabledCheckpoints: enabledCheckpoints,
      ),
    );
  }

  @override
  ConsumerState<TopicDetailSheet> createState() => _TopicDetailSheetState();
}

class _TopicDetailSheetState extends ConsumerState<TopicDetailSheet> {
  late final TextEditingController _titleController;
  late final TextEditingController _notesController;
  late int _weight;
  late DateTime? _studyDate;
  late DateTime? _practiceDate;
  late DateTime? _modelTestDate;
  late DateTime? _revisionDate;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.topic.title);
    _notesController = TextEditingController(text: widget.topic.notes);
    _weight = widget.topic.weight;
    _studyDate = widget.topic.studyDoneAt;
    _practiceDate = widget.topic.practiceDoneAt;
    _modelTestDate = widget.topic.modelTestDoneAt;
    _revisionDate = widget.topic.revisionDoneAt;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _pickDate(
    SyllabusCheckpoint cp,
    DateTime? currentDate,
    ValueChanged<DateTime?> onSelected,
  ) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: currentDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2035),
    );
    if (picked != null) {
      onSelected(picked);
    }
  }

  Future<void> _handleSave() async {
    if (_isSaving) return;
    setState(() => _isSaving = true);

    try {
      final updated = widget.topic.copyWith(
        title: _titleController.text.trim(),
        notes: _notesController.text.trim(),
        weight: _weight,
        studyDoneAt: _studyDate,
        practiceDoneAt: _practiceDate,
        modelTestDoneAt: _modelTestDate,
        revisionDoneAt: _revisionDate,
      );

      final controller = ref.read(syllabusControllerProvider);
      await controller.updateTopicDetails(
        topic: updated,
        title: updated.title,
        notes: updated.notes,
        weight: updated.weight,
      );
      if (mounted) Navigator.of(context).pop();
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final spacing = tokens.spacing;
    final textStyles = tokens.textStyles;
    final colors = tokens.colors;
    final l10n = context.l10n;
    final dateFmt = DateFormat.yMMMd();

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: GlassCard(
        padding: spacing.insetsAllLg,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                l10n.syllabusEditTopic,
                style: textStyles.titleMedium.copyWith(
                  color: colors.textPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: spacing.md),
              GlassTextField(
                controller: _titleController,
                labelText: l10n.syllabusTopicTitleLabel,
              ),
              SizedBox(height: spacing.sm),
              Row(
                children: [
                  Text(
                    '${l10n.syllabusTopicWeightLabel}: $_weight',
                    style: textStyles.bodyMedium.copyWith(
                      color: colors.textSecondary,
                    ),
                  ),
                  Expanded(
                    child: Slider(
                      value: _weight.toDouble(),
                      min: 1,
                      max: 5,
                      divisions: 4,
                      activeColor: colors.goldAccent,
                      onChanged: (val) => setState(() => _weight = val.round()),
                    ),
                  ),
                ],
              ),
              SizedBox(height: spacing.sm),
              GlassTextField(
                controller: _notesController,
                labelText: l10n.syllabusTopicNotesLabel,
                hintText: l10n.syllabusTopicNotesHint,
                maxLines: 4,
              ),
              SizedBox(height: spacing.md),
              Text(
                l10n.syllabusTopicDateLabel,
                style: textStyles.bodyLarge.copyWith(
                  color: colors.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: spacing.xs),
              ...SyllabusCheckpoint.values.where((cp) {
                return widget.enabledCheckpoints.contains(cp.value);
              }).map((cp) {
                final (date, setter) = switch (cp) {
                  SyllabusCheckpoint.study => (
                      _studyDate,
                      (DateTime? d) => setState(() => _studyDate = d)
                    ),
                  SyllabusCheckpoint.practice => (
                      _practiceDate,
                      (DateTime? d) => setState(() => _practiceDate = d)
                    ),
                  SyllabusCheckpoint.modelTest => (
                      _modelTestDate,
                      (DateTime? d) => setState(() => _modelTestDate = d)
                    ),
                  SyllabusCheckpoint.revision => (
                      _revisionDate,
                      (DateTime? d) => setState(() => _revisionDate = d)
                    ),
                };

                final label = switch (cp) {
                  SyllabusCheckpoint.study => l10n.syllabusCheckpointStudy,
                  SyllabusCheckpoint.practice =>
                    l10n.syllabusCheckpointPractice,
                  SyllabusCheckpoint.modelTest =>
                    l10n.syllabusCheckpointModelTest,
                  SyllabusCheckpoint.revision =>
                    l10n.syllabusCheckpointRevision,
                };

                return Padding(
                  padding: EdgeInsets.symmetric(vertical: spacing.xxs),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          label,
                          style: textStyles.bodySmall.copyWith(
                            color: colors.textSecondary,
                          ),
                        ),
                      ),
                      Text(
                        date != null ? dateFmt.format(date) : '—',
                        style: textStyles.bodySmall.copyWith(
                          color: colors.textPrimary,
                        ),
                      ),
                      SizedBox(width: spacing.xs),
                      IconButton(
                        icon: Icon(
                          Icons.calendar_month_rounded,
                          size: 18,
                          color: colors.goldAccent,
                        ),
                        onPressed: () => _pickDate(cp, date, setter),
                      ),
                      if (date != null)
                        IconButton(
                          icon: Icon(
                            Icons.close_rounded,
                            size: 18,
                            color: colors.danger,
                          ),
                          onPressed: () => setter(null),
                        ),
                    ],
                  ),
                );
              }),
              SizedBox(height: spacing.lg),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  GlassButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text(
                      MaterialLocalizations.of(context).cancelButtonLabel,
                    ),
                  ),
                  SizedBox(width: spacing.sm),
                  GlassButton(
                    onPressed: _isSaving ? null : _handleSave,
                    variant: GlassButtonVariant.primary,
                    child: Text(
                      MaterialLocalizations.of(context).saveButtonLabel,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
