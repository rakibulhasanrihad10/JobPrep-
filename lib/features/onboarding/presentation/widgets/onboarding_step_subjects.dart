import 'dart:async' show unawaited;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:job_prep/core/localization/app_localizations_extension.dart';
import 'package:job_prep/core/theme/app_theme_tokens.dart';
import 'package:job_prep/core/widgets/glass_button.dart';
import 'package:job_prep/core/widgets/glass_card.dart';
import 'package:job_prep/core/widgets/glass_text_field.dart';
import 'package:job_prep/features/onboarding/domain/entities/onboarding_draft.dart';
import 'package:job_prep/features/onboarding/domain/utils/onboarding_planner.dart';
import 'package:job_prep/features/onboarding/presentation/providers/onboarding_wizard_controller.dart';
import 'package:job_prep/features/onboarding/presentation/widgets/onboarding_subject_dialogs.dart';
import 'package:job_prep/l10n/app_localizations.dart';

/// Step 3: Lets users toggle starter subjects, rename them, edit material
/// titles & total units, remove items, or add custom subjects and materials.
class OnboardingStepSubjects extends ConsumerWidget {
  /// Creates an [OnboardingStepSubjects].
  const OnboardingStepSubjects({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tokens = context.tokens;
    final colors = tokens.colors;
    final spacing = tokens.spacing;
    final l10n = context.l10n;
    final state = ref.watch(onboardingWizardControllerProvider);
    final subjects = state.draft.subjects;
    final error = state.subjectsError;
    final controller = ref.read(onboardingWizardControllerProvider.notifier);

    return Column(
      key: const ValueKey('onboarding-step-3'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        GlassCard(
          padding: spacing.insetsAllXl,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Wrap(
                spacing: spacing.md,
                runSpacing: spacing.sm,
                alignment: WrapAlignment.spaceBetween,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.onboardingSubjectsTitle,
                        style: tokens.textStyles.headlineMedium,
                      ),
                      SizedBox(height: spacing.xs),
                      Text(
                        l10n.onboardingSubjectsSubtitle,
                        style: tokens.textStyles.bodyMedium,
                      ),
                    ],
                  ),
                  GlassButton(
                    key: const ValueKey('onboarding-add-subject-btn'),
                    onPressed: () => unawaited(
                      showOnboardingAddSubjectDialog(context, controller),
                    ),
                    leading: Icon(Icons.add_rounded, size: spacing.lg),
                    child: Text(l10n.onboardingAddSubjectButton),
                  ),
                ],
              ),
              if (error != null) ...[
                SizedBox(height: spacing.md),
                Text(
                  _errorText(error, l10n),
                  key: const ValueKey('onboarding-step3-error'),
                  style: tokens.textStyles.bodySmall.copyWith(
                    color: colors.danger,
                  ),
                ),
              ],
            ],
          ),
        ),
        SizedBox(height: spacing.md),
        if (subjects.isEmpty)
          GlassCard(
            key: const ValueKey('onboarding-step3-empty-blank'),
            padding: spacing.insetsAllLg,
            child: Text(
              l10n.onboardingSubjectsEmptyBlankNote,
              style: tokens.textStyles.bodyMedium,
            ),
          )
        else
          for (var i = 0; i < subjects.length; i++) ...[
            if (i > 0) SizedBox(height: spacing.md),
            _SubjectDraftCard(
              key: ValueKey('onboarding-sub-${subjects[i].localId}'),
              subject: subjects[i],
              onToggle: (val) =>
                  controller.toggleSubject(subjects[i].localId, enabled: val),
              onRename: (val) =>
                  controller.renameSubject(subjects[i].localId, val),
              onAddMaterial: () => unawaited(
                showOnboardingAddMaterialDialog(
                  context,
                  controller,
                  subjects[i].localId,
                ),
              ),
              onUpdateMaterialTitle: (matId, val) =>
                  controller.updateMaterialTitle(
                subjects[i].localId,
                matId,
                val,
              ),
              onUpdateMaterialUnits: (matId, val) =>
                  controller.updateMaterialUnits(
                subjects[i].localId,
                matId,
                val,
              ),
              onRemoveMaterial: (matId) =>
                  controller.removeMaterial(subjects[i].localId, matId),
            ),
          ],
      ],
    );
  }

  String _errorText(
    OnboardingSubjectsValidationError error,
    AppLocalizations l10n,
  ) {
    return switch (error) {
      OnboardingSubjectsValidationError.emptySubjectName =>
        l10n.onboardingValidationEmptySubject,
      OnboardingSubjectsValidationError.duplicateSubjectName =>
        l10n.onboardingValidationDuplicateSubject,
      OnboardingSubjectsValidationError.emptyMaterialTitle =>
        l10n.onboardingValidationEmptyMaterial,
      OnboardingSubjectsValidationError.invalidMaterialUnits =>
        l10n.onboardingValidationInvalidUnits,
    };
  }
}

class _SubjectDraftCard extends StatelessWidget {
  const _SubjectDraftCard({
    required this.subject,
    required this.onToggle,
    required this.onRename,
    required this.onAddMaterial,
    required this.onUpdateMaterialTitle,
    required this.onUpdateMaterialUnits,
    required this.onRemoveMaterial,
    super.key,
  });

  final OnboardingSubjectDraft subject;
  final ValueChanged<bool> onToggle;
  final ValueChanged<String> onRename;
  final VoidCallback onAddMaterial;
  final void Function(String matId, String title) onUpdateMaterialTitle;
  final void Function(String matId, String units) onUpdateMaterialUnits;
  final ValueChanged<String> onRemoveMaterial;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final colors = tokens.colors;
    final spacing = tokens.spacing;
    final l10n = context.l10n;

    return GlassCard(
      padding: spacing.insetsAllLg,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Switch(
                key: ValueKey('onboarding-sub-toggle-${subject.localId}'),
                value: subject.enabled,
                onChanged: onToggle,
              ),
              SizedBox(width: spacing.sm),
              Expanded(
                child: GlassTextField(
                  key: ValueKey('onboarding-sub-name-${subject.localId}'),
                  initialValue: subject.name,
                  enabled: subject.enabled,
                  labelText: l10n.onboardingSubjectNameLabel,
                  onChanged: onRename,
                ),
              ),
            ],
          ),
          if (subject.enabled) ...[
            SizedBox(height: spacing.md),
            for (var i = 0; i < subject.materials.length; i++) ...[
              if (i > 0) SizedBox(height: spacing.sm),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 3,
                    child: GlassTextField(
                      key: ValueKey(
                        'onboarding-mat-title-${subject.materials[i].localId}',
                      ),
                      initialValue: subject.materials[i].title,
                      labelText: l10n.onboardingMaterialTitleLabel,
                      onChanged: (val) => onUpdateMaterialTitle(
                        subject.materials[i].localId,
                        val,
                      ),
                    ),
                  ),
                  SizedBox(width: spacing.sm),
                  Expanded(
                    flex: 2,
                    child: GlassTextField(
                      key: ValueKey(
                        'onboarding-mat-units-${subject.materials[i].localId}',
                      ),
                      initialValue: '${subject.materials[i].totalUnits}',
                      keyboardType: TextInputType.number,
                      labelText: l10n.onboardingMaterialUnitsLabel,
                      onChanged: (val) => onUpdateMaterialUnits(
                        subject.materials[i].localId,
                        val,
                      ),
                    ),
                  ),
                  SizedBox(width: spacing.xs),
                  IconButton(
                    key: ValueKey(
                      'onboarding-mat-del-${subject.materials[i].localId}',
                    ),
                    tooltip: l10n.onboardingRemoveMaterialTooltip,
                    onPressed: () =>
                        onRemoveMaterial(subject.materials[i].localId),
                    icon: Icon(
                      Icons.close_rounded,
                      color: colors.textMuted,
                    ),
                  ),
                ],
              ),
            ],
            SizedBox(height: spacing.sm),
            Align(
              alignment: AlignmentDirectional.centerStart,
              child: TextButton.icon(
                key: ValueKey('onboarding-add-mat-btn-${subject.localId}'),
                onPressed: onAddMaterial,
                icon: Icon(Icons.add_rounded, size: spacing.lg),
                label: Text(l10n.onboardingAddMaterialButton),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
