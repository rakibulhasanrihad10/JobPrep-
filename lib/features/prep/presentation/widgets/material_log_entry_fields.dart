import 'package:flutter/material.dart';
import 'package:job_prep/core/localization/app_localizations_extension.dart';
import 'package:job_prep/core/localization/formatters.dart';
import 'package:job_prep/core/theme/app_theme_tokens.dart';
import 'package:job_prep/core/widgets/glass_button.dart';
import 'package:job_prep/core/widgets/glass_text_field.dart';
import 'package:job_prep/features/prep/presentation/utils/prep_l10n.dart';
import 'package:job_prep/features/prep/presentation/widgets/prep_option_chip.dart';

/// Input section inside [Form] for entering or editing a study progress log
/// (preset chips, custom units, date selector, note, and submit button).
class MaterialLogEntryFields extends StatelessWidget {
  /// Creates a [MaterialLogEntryFields].
  const MaterialLogEntryFields({
    required this.unitsController,
    required this.noteController,
    required this.selectedDate,
    required this.isEditing,
    required this.isSaving,
    required this.validateUnits,
    required this.onPickDate,
    required this.onCancelEdit,
    required this.onSubmit,
    super.key,
    this.errorText,
  });

  /// Controller for positive integer unit count.
  final TextEditingController unitsController;

  /// Controller for optional study note.
  final TextEditingController noteController;

  /// Chosen calendar date for the log entry.
  final DateTime selectedDate;

  /// Whether the form is currently editing an existing past log.
  final bool isEditing;

  /// Disables actions while saving.
  final bool isSaving;

  /// Validator for numeric unit input.
  final FormFieldValidator<String> validateUnits;

  /// Opens date picker dialog.
  final VoidCallback onPickDate;

  /// Cancels active edit and resets form fields.
  final VoidCallback onCancelEdit;

  /// Validates and persists the log entry.
  final VoidCallback onSubmit;

  /// Optional localized repository/validation error text.
  final String? errorText;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final colors = tokens.colors;
    final spacing = tokens.spacing;
    final radii = tokens.radii;
    final l10n = context.l10n;
    final locale = Localizations.localeOf(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (isEditing) ...[
          Container(
            padding: spacing.insetsAllSm,
            decoration: BoxDecoration(
              color: colors.goldAccentSubtle,
              borderRadius: radii.buttonRadius,
              border: Border.all(color: colors.goldAccent),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    l10n.prepEditingLogBanner,
                    style: tokens.textStyles.labelMedium.copyWith(
                      color: colors.textPrimary,
                    ),
                  ),
                ),
                TextButton(
                  key: const ValueKey('log-cancel-edit'),
                  onPressed: isSaving ? null : onCancelEdit,
                  child: Text(l10n.prepLogCancelEditButton),
                ),
              ],
            ),
          ),
          SizedBox(height: spacing.md),
        ],
        Wrap(
          spacing: spacing.xs,
          runSpacing: spacing.xs,
          children: [
            for (final preset in const [10, 20, 50])
              PrepOptionChip(
                label: l10n.prepQuickLogPlus(
                  PrepL10n.formatInt(preset, locale),
                ),
                onTap: () => unitsController.text = preset.toString(),
              ),
          ],
        ),
        SizedBox(height: spacing.md),
        GlassTextField(
          key: const ValueKey('log-units-field'),
          controller: unitsController,
          labelText: l10n.prepCustomUnitsLabel,
          hintText: l10n.prepCustomUnitsHint,
          keyboardType: TextInputType.number,
          textInputAction: TextInputAction.next,
          validator: validateUnits,
        ),
        SizedBox(height: spacing.md),
        InkWell(
          key: const ValueKey('log-date-button'),
          borderRadius: radii.buttonRadius,
          onTap: isSaving ? null : onPickDate,
          child: Container(
            padding: spacing.insetsAllMd,
            decoration: BoxDecoration(
              color: colors.surfaceElevated,
              borderRadius: radii.buttonRadius,
              border: Border.all(color: colors.glassBorder),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.calendar_today_outlined,
                  size: spacing.lg,
                  color: colors.goldAccent,
                ),
                SizedBox(width: spacing.sm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.prepLogDateLabel,
                        style: tokens.textStyles.labelSmall,
                      ),
                      SizedBox(height: spacing.xxs),
                      Text(
                        AppFormatters.formatDate(
                          selectedDate,
                          locale: locale,
                          pattern: 'yMMMd',
                        ),
                        style: tokens.textStyles.bodyMedium.copyWith(
                          color: colors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        SizedBox(height: spacing.md),
        GlassTextField(
          key: const ValueKey('log-note-field'),
          controller: noteController,
          labelText: l10n.prepLogNoteLabel,
          hintText: l10n.prepLogNoteHint,
          textInputAction: TextInputAction.done,
        ),
        SizedBox(height: spacing.md),
        GlassButton(
          key: const ValueKey('log-save-button'),
          variant: GlassButtonVariant.primary,
          onPressed: isSaving ? null : onSubmit,
          child: Text(
            isEditing ? l10n.prepLogUpdateButton : l10n.prepLogSaveButton,
          ),
        ),
        if (errorText != null) ...[
          SizedBox(height: spacing.sm),
          Text(
            errorText!,
            style: tokens.textStyles.bodySmall.copyWith(color: colors.danger),
          ),
        ],
      ],
    );
  }
}
