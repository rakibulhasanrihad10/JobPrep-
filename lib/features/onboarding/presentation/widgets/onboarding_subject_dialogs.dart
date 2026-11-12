import 'package:flutter/material.dart';
import 'package:job_prep/core/localization/app_localizations_extension.dart';
import 'package:job_prep/core/theme/app_theme_tokens.dart';
import 'package:job_prep/core/widgets/glass_button.dart';
import 'package:job_prep/core/widgets/glass_dialog.dart';
import 'package:job_prep/core/widgets/glass_text_field.dart';
import 'package:job_prep/features/onboarding/domain/utils/onboarding_planner.dart';
import 'package:job_prep/features/onboarding/presentation/providers/onboarding_wizard_controller.dart';

/// Opens a glass dialog to add a custom subject with an optional starter book.
Future<void> showOnboardingAddSubjectDialog(
  BuildContext context,
  OnboardingWizardController controller,
) {
  return showGlassDialog<void>(
    context: context,
    builder: (_) => _AddSubjectDialog(controller: controller),
  );
}

/// Opens a glass dialog to append a material to an onboarding subject.
Future<void> showOnboardingAddMaterialDialog(
  BuildContext context,
  OnboardingWizardController controller,
  String subjectLocalId,
) {
  return showGlassDialog<void>(
    context: context,
    builder: (_) => _AddMaterialDialog(
      controller: controller,
      subjectLocalId: subjectLocalId,
    ),
  );
}

class _AddSubjectDialog extends StatefulWidget {
  const _AddSubjectDialog({required this.controller});

  final OnboardingWizardController controller;

  @override
  State<_AddSubjectDialog> createState() => _AddSubjectDialogState();
}

class _AddSubjectDialogState extends State<_AddSubjectDialog> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _matTitleController = TextEditingController();
  final TextEditingController _unitsController = TextEditingController(
    text: '100',
  );
  String? _errorMsg;

  @override
  void dispose() {
    _nameController.dispose();
    _matTitleController.dispose();
    _unitsController.dispose();
    super.dispose();
  }

  void _submit() {
    final l10n = context.l10n;
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      setState(() => _errorMsg = l10n.onboardingValidationEmptySubject);
      return;
    }
    final units =
        OnboardingPlanner.parseNonNegativeInt(_unitsController.text) ?? 100;
    widget.controller.addCustomSubject(
      name: name,
      firstMaterialTitle: _matTitleController.text.trim(),
      firstMaterialUnits: units < 1 ? 100 : units,
    );
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final spacing = tokens.spacing;
    final colors = tokens.colors;
    final l10n = context.l10n;

    return GlassDialog(
      title: Text(l10n.onboardingAddSubjectDialogTitle),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            GlassTextField(
              key: const ValueKey('onboarding-new-subject-name-input'),
              controller: _nameController,
              labelText: l10n.onboardingSubjectNameLabel,
              autofocus: true,
            ),
            SizedBox(height: spacing.md),
            GlassTextField(
              key: const ValueKey('onboarding-new-subject-mat-input'),
              controller: _matTitleController,
              labelText: l10n.onboardingMaterialTitleLabel,
            ),
            SizedBox(height: spacing.md),
            GlassTextField(
              key: const ValueKey('onboarding-new-subject-units-input'),
              controller: _unitsController,
              keyboardType: TextInputType.number,
              labelText: l10n.onboardingMaterialUnitsLabel,
            ),
            if (_errorMsg != null) ...[
              SizedBox(height: spacing.sm),
              Text(
                _errorMsg!,
                style: tokens.textStyles.bodySmall.copyWith(
                  color: colors.danger,
                ),
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n.prepCancelButton),
        ),
        GlassButton(
          key: const ValueKey('onboarding-confirm-add-subject-btn'),
          variant: GlassButtonVariant.primary,
          onPressed: _submit,
          child: Text(l10n.onboardingAddSubjectButton),
        ),
      ],
    );
  }
}

class _AddMaterialDialog extends StatefulWidget {
  const _AddMaterialDialog({
    required this.controller,
    required this.subjectLocalId,
  });

  final OnboardingWizardController controller;
  final String subjectLocalId;

  @override
  State<_AddMaterialDialog> createState() => _AddMaterialDialogState();
}

class _AddMaterialDialogState extends State<_AddMaterialDialog> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _unitsController = TextEditingController(
    text: '200',
  );
  String? _errorMsg;

  @override
  void dispose() {
    _titleController.dispose();
    _unitsController.dispose();
    super.dispose();
  }

  void _submit() {
    final l10n = context.l10n;
    final title = _titleController.text.trim();
    final units = OnboardingPlanner.parseNonNegativeInt(_unitsController.text);
    if (title.isEmpty) {
      setState(() => _errorMsg = l10n.onboardingValidationEmptyMaterial);
      return;
    }
    if (units == null || units < 1) {
      setState(() => _errorMsg = l10n.onboardingValidationInvalidUnits);
      return;
    }
    widget.controller.addMaterial(
      widget.subjectLocalId,
      title: title,
      totalUnits: units,
    );
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final spacing = tokens.spacing;
    final colors = tokens.colors;
    final l10n = context.l10n;

    return GlassDialog(
      title: Text(l10n.onboardingAddMaterialDialogTitle),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            GlassTextField(
              key: const ValueKey('onboarding-new-mat-title-input'),
              controller: _titleController,
              labelText: l10n.onboardingMaterialTitleLabel,
              autofocus: true,
            ),
            SizedBox(height: spacing.md),
            GlassTextField(
              key: const ValueKey('onboarding-new-mat-units-input'),
              controller: _unitsController,
              keyboardType: TextInputType.number,
              labelText: l10n.onboardingMaterialUnitsLabel,
            ),
            if (_errorMsg != null) ...[
              SizedBox(height: spacing.sm),
              Text(
                _errorMsg!,
                style: tokens.textStyles.bodySmall.copyWith(
                  color: colors.danger,
                ),
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n.prepCancelButton),
        ),
        GlassButton(
          key: const ValueKey('onboarding-confirm-add-mat-btn'),
          variant: GlassButtonVariant.primary,
          onPressed: _submit,
          child: Text(l10n.onboardingAddMaterialButton),
        ),
      ],
    );
  }
}
