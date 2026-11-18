import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:job_prep/core/localization/app_localizations_extension.dart';
import 'package:job_prep/core/theme/app_theme_tokens.dart';
import 'package:job_prep/core/widgets/glass_button.dart';
import 'package:job_prep/core/widgets/glass_dialog.dart';
import 'package:job_prep/core/widgets/glass_text_field.dart';
import 'package:job_prep/features/prep/presentation/providers/syllabus_providers.dart';

/// Modal dialog to quickly add a topic to a chapter.
class TopicFormDialog extends ConsumerStatefulWidget {
  const TopicFormDialog({
    required this.subjectId,
    this.chapterId,
    super.key,
  });

  final String subjectId;
  final String? chapterId;

  static Future<void> show(
    BuildContext context, {
    required String subjectId,
    String? chapterId,
  }) {
    return showDialog<void>(
      context: context,
      builder: (_) => TopicFormDialog(
        subjectId: subjectId,
        chapterId: chapterId,
      ),
    );
  }

  @override
  ConsumerState<TopicFormDialog> createState() => _TopicFormDialogState();
}

class _TopicFormDialogState extends ConsumerState<TopicFormDialog> {
  late final TextEditingController _titleController;
  int _weight = 1;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController();
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    final title = _titleController.text.trim();
    if (title.isEmpty || _isSaving) return;

    setState(() => _isSaving = true);
    final controller = ref.read(syllabusControllerProvider);
    try {
      await controller.createTopic(
        subjectId: widget.subjectId,
        chapterId: widget.chapterId,
        title: title,
        weight: _weight,
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

    return GlassDialog(
      maxWidth: 440,
      title: Text(
        l10n.syllabusAddTopic,
        style: textStyles.titleMedium.copyWith(
          color: colors.textPrimary,
          fontWeight: FontWeight.bold,
        ),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          GlassTextField(
            controller: _titleController,
            labelText: l10n.syllabusTopicTitleLabel,
            autofocus: true,
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
        ],
      ),
      actions: [
        GlassButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(
            MaterialLocalizations.of(context).cancelButtonLabel,
          ),
        ),
        GlassButton(
          onPressed: _isSaving ? null : _handleSave,
          variant: GlassButtonVariant.primary,
          child: Text(
            MaterialLocalizations.of(context).saveButtonLabel,
          ),
        ),
      ],
    );
  }
}
