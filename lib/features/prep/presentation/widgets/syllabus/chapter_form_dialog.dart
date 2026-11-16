import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:job_prep/core/localization/app_localizations_extension.dart';
import 'package:job_prep/core/theme/app_theme_tokens.dart';
import 'package:job_prep/core/widgets/glass_button.dart';
import 'package:job_prep/core/widgets/glass_dialog.dart';
import 'package:job_prep/core/widgets/glass_text_field.dart';
import 'package:job_prep/features/prep/domain/entities/chapter.dart';
import 'package:job_prep/features/prep/presentation/providers/syllabus_providers.dart';

/// Modal dialog to create or edit a chapter title.
class ChapterFormDialog extends ConsumerStatefulWidget {
  const ChapterFormDialog({
    required this.subjectId,
    this.existing,
    super.key,
  });

  final String subjectId;
  final Chapter? existing;

  static Future<void> show(
    BuildContext context, {
    required String subjectId,
    Chapter? existing,
  }) {
    return showDialog<void>(
      context: context,
      builder: (_) => ChapterFormDialog(
        subjectId: subjectId,
        existing: existing,
      ),
    );
  }

  @override
  ConsumerState<ChapterFormDialog> createState() => _ChapterFormDialogState();
}

class _ChapterFormDialogState extends ConsumerState<ChapterFormDialog> {
  late final TextEditingController _titleController;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _titleController =
        TextEditingController(text: widget.existing?.title ?? '');
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
      if (widget.existing != null) {
        await controller.updateChapter(
          chapter: widget.existing!,
          title: title,
        );
      } else {
        await controller.createChapter(
          subjectId: widget.subjectId,
          title: title,
        );
      }
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

    final isEdit = widget.existing != null;

    return GlassDialog(
      maxWidth: 440,
      title: Text(
        isEdit ? l10n.syllabusEditChapter : l10n.syllabusAddChapter,
        style: textStyles.titleMedium.copyWith(
          color: colors.textPrimary,
          fontWeight: FontWeight.bold,
        ),
      ),
      content: Padding(
        padding: EdgeInsets.only(top: spacing.xs),
        child: GlassTextField(
          controller: _titleController,
          labelText: l10n.syllabusChapterTitleLabel,
          autofocus: true,
        ),
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
