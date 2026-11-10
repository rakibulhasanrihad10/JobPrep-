import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:job_prep/core/localization/app_localizations_extension.dart';
import 'package:job_prep/core/theme/app_theme_tokens.dart';
import 'package:job_prep/core/widgets/glass_button.dart';
import 'package:job_prep/core/widgets/glass_dialog.dart';
import 'package:job_prep/core/widgets/glass_text_field.dart';
import 'package:job_prep/features/prep/domain/entities/subject.dart';
import 'package:job_prep/features/prep/presentation/providers/prep_subjects_controller.dart';
import 'package:job_prep/features/prep/presentation/utils/prep_l10n.dart';
import 'package:job_prep/features/prep/presentation/utils/prep_style_tokens.dart';
import 'package:job_prep/features/prep/presentation/widgets/prep_option_chip.dart';

/// Opens a dialog to create a new [Subject] or edit [existing].
Future<Subject?> showSubjectFormDialog(
  BuildContext context, {
  Subject? existing,
}) {
  return showGlassDialog<Subject?>(
    context: context,
    barrierDismissible: false,
    builder: (_) => SubjectFormDialog(existing: existing),
  );
}

/// Glass dialog for creating or editing a user-defined study subject.
class SubjectFormDialog extends ConsumerStatefulWidget {
  /// Creates a [SubjectFormDialog].
  const SubjectFormDialog({super.key, this.existing});

  /// Subject being edited, or `null` when creating a new subject.
  final Subject? existing;

  @override
  ConsumerState<SubjectFormDialog> createState() => _SubjectFormDialogState();
}

class _SubjectFormDialogState extends ConsumerState<SubjectFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _examTypeController;
  late String _selectedColor;
  late String _selectedIcon;

  @override
  void initState() {
    super.initState();
    final existing = widget.existing;
    _nameController = TextEditingController(text: existing?.name ?? '');
    _examTypeController = TextEditingController(
      text: existing?.examType ?? '',
    );
    _selectedColor = existing?.color ?? PrepStyleTokens.colorKeys.first;
    _selectedIcon = existing?.icon ?? PrepStyleTokens.iconKeys.first;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _examTypeController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    final saved =
        await ref.read(prepSubjectsControllerProvider.notifier).saveSubject(
              existing: widget.existing,
              name: _nameController.text,
              color: _selectedColor,
              icon: _selectedIcon,
              examType: _examTypeController.text,
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
    final l10n = context.l10n;
    final mutationState = ref.watch(prepSubjectsControllerProvider);
    final suggestions = PrepL10n.examTrackSuggestions(l10n);

    return GlassDialog(
      title: Text(
        widget.existing == null
            ? l10n.prepCreateSubjectTitle
            : l10n.prepEditSubjectTitle,
        style: tokens.textStyles.titleLarge,
      ),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              GlassTextField(
                key: const ValueKey('subject-name-field'),
                controller: _nameController,
                labelText: l10n.prepSubjectNameLabel,
                hintText: l10n.prepSubjectNameHint,
                textInputAction: TextInputAction.next,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return l10n.prepSubjectNameRequired;
                  }
                  return null;
                },
              ),
              SizedBox(height: spacing.lg),
              GlassTextField(
                key: const ValueKey('subject-exam-type-field'),
                controller: _examTypeController,
                labelText: l10n.prepExamTypeLabel,
                hintText: l10n.prepExamTypeHint,
                textInputAction: TextInputAction.done,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return l10n.prepExamTypeRequired;
                  }
                  return null;
                },
              ),
              SizedBox(height: spacing.sm),
              Wrap(
                spacing: spacing.xs,
                runSpacing: spacing.xs,
                children: [
                  for (final track in suggestions)
                    PrepOptionChip(
                      label: track,
                      onTap: () => _examTypeController.text = track,
                    ),
                ],
              ),
              SizedBox(height: spacing.lg),
              Text(
                l10n.prepSubjectColorLabel,
                style: tokens.textStyles.labelMedium,
              ),
              SizedBox(height: spacing.sm),
              Wrap(
                spacing: spacing.sm,
                runSpacing: spacing.sm,
                children: [
                  for (final colorKey in PrepStyleTokens.colorKeys)
                    _buildColorOption(colorKey, tokens),
                ],
              ),
              SizedBox(height: spacing.lg),
              Text(
                l10n.prepSubjectIconLabel,
                style: tokens.textStyles.labelMedium,
              ),
              SizedBox(height: spacing.sm),
              Wrap(
                spacing: spacing.sm,
                runSpacing: spacing.sm,
                children: [
                  for (final iconKey in PrepStyleTokens.iconKeys)
                    _buildIconOption(iconKey, tokens),
                ],
              ),
              if (mutationState.error != null) ...[
                SizedBox(height: spacing.md),
                Text(
                  PrepL10n.failureMessage(mutationState.error!, l10n),
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
          onPressed: mutationState.isSubmitting
              ? null
              : () {
                  ref
                      .read(prepSubjectsControllerProvider.notifier)
                      .clearError();
                  Navigator.of(context).pop();
                },
          child: Text(l10n.prepCancelButton),
        ),
        GlassButton(
          key: const ValueKey('subject-save-button'),
          variant: GlassButtonVariant.primary,
          onPressed: mutationState.isSubmitting ? null : _submit,
          child: Text(l10n.prepSaveButton),
        ),
      ],
    );
  }

  Widget _buildColorOption(String colorKey, AppThemeTokens tokens) {
    final colors = tokens.colors;
    final spacing = tokens.spacing;
    final isSelected = _selectedColor == colorKey;
    final swatchColor = PrepStyleTokens.resolveSubjectColor(colorKey, colors);
    final label = PrepStyleTokens.resolveColorLabel(colorKey, context.l10n);

    return Tooltip(
      message: label,
      child: Semantics(
        button: true,
        selected: isSelected,
        label: label,
        child: InkWell(
          key: ValueKey('subject-color-$colorKey'),
          borderRadius: tokens.radii.buttonRadius,
          onTap: () => setState(() => _selectedColor = colorKey),
          child: Container(
            width: spacing.xl + spacing.sm,
            height: spacing.xl + spacing.sm,
            decoration: BoxDecoration(
              color: swatchColor,
              borderRadius: tokens.radii.buttonRadius,
              border: Border.all(
                color: isSelected ? colors.textPrimary : colors.glassBorder,
                width: isSelected ? 2 : 1,
              ),
            ),
            child: isSelected
                ? Icon(
                    Icons.check,
                    color: colors.background,
                    size: spacing.lg,
                  )
                : null,
          ),
        ),
      ),
    );
  }

  Widget _buildIconOption(String iconKey, AppThemeTokens tokens) {
    final colors = tokens.colors;
    final spacing = tokens.spacing;
    final isSelected = _selectedIcon == iconKey;
    final activeColor = PrepStyleTokens.resolveSubjectColor(
      _selectedColor,
      colors,
    );
    final label = PrepStyleTokens.resolveIconLabel(iconKey, context.l10n);

    return Tooltip(
      message: label,
      child: Semantics(
        button: true,
        selected: isSelected,
        label: label,
        child: InkWell(
          key: ValueKey('subject-icon-$iconKey'),
          borderRadius: tokens.radii.buttonRadius,
          onTap: () => setState(() => _selectedIcon = iconKey),
          child: Container(
            width: spacing.xl + spacing.md,
            height: spacing.xl + spacing.md,
            decoration: BoxDecoration(
              color: isSelected
                  ? activeColor.withValues(alpha: 0.22)
                  : colors.surfaceElevated,
              borderRadius: tokens.radii.buttonRadius,
              border: Border.all(
                color: isSelected ? activeColor : colors.glassBorder,
              ),
            ),
            child: Icon(
              PrepStyleTokens.resolveSubjectIcon(iconKey),
              color: isSelected ? activeColor : colors.textSecondary,
              size: spacing.lg + spacing.xs,
            ),
          ),
        ),
      ),
    );
  }
}
