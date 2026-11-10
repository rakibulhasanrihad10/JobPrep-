import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:job_prep/core/localization/app_localizations_extension.dart';
import 'package:job_prep/core/theme/app_theme_tokens.dart';
import 'package:job_prep/core/widgets/glass_button.dart';
import 'package:job_prep/core/widgets/glass_dialog.dart';
import 'package:job_prep/core/widgets/glass_text_field.dart';
import 'package:job_prep/features/prep/domain/entities/prep_material.dart';
import 'package:job_prep/features/prep/domain/entities/prep_template.dart';
import 'package:job_prep/features/prep/domain/entities/subject.dart';
import 'package:job_prep/features/prep/presentation/providers/prep_template_providers.dart';
import 'package:job_prep/features/prep/presentation/utils/prep_l10n.dart';
import 'package:job_prep/features/prep/presentation/widgets/prep_option_chip.dart';

/// Opens a glass dialog to save the user's current subjects & materials as a
/// personal reusable [PrepTemplate].
Future<PrepTemplate?> showSavePersonalTemplateDialog(
  BuildContext context, {
  required List<Subject> subjects,
  required List<PrepMaterial> materials,
}) {
  return showGlassDialog<PrepTemplate?>(
    context: context,
    barrierDismissible: false,
    builder: (_) => SavePersonalTemplateDialog(
      subjects: subjects,
      materials: materials,
    ),
  );
}

/// Dialog capturing title, optional description, and track when saving current
/// subjects/materials into `public.prep_templates` (`is_system = false`).
class SavePersonalTemplateDialog extends ConsumerStatefulWidget {
  /// Creates a [SavePersonalTemplateDialog].
  const SavePersonalTemplateDialog({
    required this.subjects,
    required this.materials,
    super.key,
  });

  /// User subjects to snapshot.
  final List<Subject> subjects;

  /// User materials belonging to [subjects] to snapshot.
  final List<PrepMaterial> materials;

  @override
  ConsumerState<SavePersonalTemplateDialog> createState() =>
      _SavePersonalTemplateDialogState();
}

class _SavePersonalTemplateDialogState
    extends ConsumerState<SavePersonalTemplateDialog> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  late final TextEditingController _examTrackController;

  @override
  void initState() {
    super.initState();
    final initialExam =
        widget.subjects.isNotEmpty ? widget.subjects.first.examType : '';
    _examTrackController = TextEditingController(text: initialExam);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _examTrackController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }
    final saved = await ref
        .read(prepTemplateActionControllerProvider.notifier)
        .savePersonalTemplate(
          title: _titleController.text,
          description: _descriptionController.text,
          examType: _examTrackController.text,
          subjects: widget.subjects,
          materials: widget.materials,
        );
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
    final radii = tokens.radii;
    final l10n = context.l10n;
    final locale = Localizations.localeOf(context);
    final actionState = ref.watch(prepTemplateActionControllerProvider);
    final trackSuggestions = PrepL10n.examTrackSuggestions(l10n);

    final subjectIds = widget.subjects.map((s) => s.id).toSet();
    final scopedMaterialCount =
        widget.materials.where((m) => subjectIds.contains(m.subjectId)).length;

    return GlassDialog(
      title: Text(l10n.prepSaveTemplateDialogTitle),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                padding: spacing.insetsAllMd,
                decoration: BoxDecoration(
                  color: colors.goldAccentSubtle,
                  borderRadius: radii.buttonRadius,
                  border: Border.all(color: colors.goldAccent),
                ),
                child: Text(
                  l10n.prepSaveTemplatePreviewSummary(
                    PrepL10n.formatInt(widget.subjects.length, locale),
                    PrepL10n.formatInt(scopedMaterialCount, locale),
                  ),
                  style: tokens.textStyles.bodySmall.copyWith(
                    color: colors.textPrimary,
                  ),
                ),
              ),
              SizedBox(height: spacing.md),
              GlassTextField(
                key: const ValueKey('personal-template-title-field'),
                controller: _titleController,
                labelText: l10n.prepSaveTemplateTitleLabel,
                hintText: l10n.prepSaveTemplateTitleHint,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return l10n.prepSaveTemplateTitleRequired;
                  }
                  return null;
                },
              ),
              SizedBox(height: spacing.md),
              GlassTextField(
                key: const ValueKey('personal-template-description-field'),
                controller: _descriptionController,
                labelText: l10n.prepSaveTemplateDescLabel,
                hintText: l10n.prepSaveTemplateDescHint,
                maxLines: 2,
              ),
              SizedBox(height: spacing.md),
              GlassTextField(
                key: const ValueKey('personal-template-exam-field'),
                controller: _examTrackController,
                labelText: l10n.prepSaveTemplateExamLabel,
                hintText: l10n.prepExamTypeHint,
              ),
              SizedBox(height: spacing.sm),
              Wrap(
                spacing: spacing.xs,
                runSpacing: spacing.xs,
                children: [
                  for (final track in trackSuggestions)
                    PrepOptionChip(
                      label: track,
                      isSelected: _examTrackController.text.trim() == track,
                      onTap: () =>
                          setState(() => _examTrackController.text = track),
                    ),
                ],
              ),
              if (actionState.error != null) ...[
                SizedBox(height: spacing.md),
                Text(
                  PrepL10n.failureMessage(actionState.error!, l10n),
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
          onPressed:
              actionState.isBusy ? null : () => Navigator.of(context).pop(),
          child: Text(l10n.prepCancelButton),
        ),
        GlassButton(
          key: const ValueKey('save-personal-template-submit'),
          variant: GlassButtonVariant.primary,
          onPressed: actionState.isBusy ? null : _submit,
          child: actionState.isBusy
              ? SizedBox(
                  width: spacing.lg,
                  height: spacing.lg,
                  child: const CircularProgressIndicator(strokeWidth: 2),
                )
              : Text(l10n.prepSaveTemplateSaveAction),
        ),
      ],
    );
  }
}
