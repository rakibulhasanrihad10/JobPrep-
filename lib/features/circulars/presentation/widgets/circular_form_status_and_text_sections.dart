import 'package:flutter/material.dart';
import 'package:job_prep/core/localization/app_localizations_extension.dart';
import 'package:job_prep/core/widgets/glass_text_field.dart';
import 'package:job_prep/features/circulars/domain/entities/circular_enums.dart';
import 'package:job_prep/features/circulars/presentation/providers/circular_form_controller.dart';
import 'package:job_prep/features/circulars/presentation/providers/circular_form_state.dart';
import 'package:job_prep/features/circulars/presentation/utils/circular_l10n.dart';
import 'package:job_prep/features/circulars/presentation/widgets/circular_form_widgets.dart';

/// Status dropdowns section (application, admit card, priority, workflow).
class CircularStatusSection extends StatelessWidget {
  /// Creates a [CircularStatusSection].
  const CircularStatusSection({
    required this.formState,
    required this.controller,
    required this.enabled,
    super.key,
  });

  final CircularFormState formState;
  final CircularFormController controller;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return CircularFormSectionCard(
      index: 3,
      title: l10n.circularFormSectionStatus,
      icon: Icons.track_changes_outlined,
      children: [
        CircularFormResponsivePair(
          first: CircularEnumDropdown<ApplicationStatus>(
            key: const ValueKey('circular-form-app-status'),
            label: l10n.circularFieldAppStatusLabel,
            value: formState.applicationStatus,
            items: ApplicationStatus.values,
            enabled: enabled,
            labelBuilder: (item) =>
                CircularL10n.applicationStatusLabel(item, l10n),
            onChanged: controller.updateApplicationStatus,
          ),
          second: CircularEnumDropdown<AdmitCardStatus>(
            key: const ValueKey('circular-form-admit-status'),
            label: l10n.circularFieldAdmitStatusLabel,
            value: formState.admitCardStatus,
            items: AdmitCardStatus.values,
            enabled: enabled,
            labelBuilder: (item) =>
                CircularL10n.admitCardStatusLabel(item, l10n),
            onChanged: controller.updateAdmitCardStatus,
          ),
        ),
        CircularFormResponsivePair(
          first: CircularEnumDropdown<CircularPriority>(
            key: const ValueKey('circular-form-priority'),
            label: l10n.circularFieldPriorityLabel,
            value: formState.priority,
            items: CircularPriority.values,
            enabled: enabled,
            labelBuilder: (item) => CircularL10n.priorityLabel(item, l10n),
            onChanged: controller.updatePriority,
          ),
          second: CircularEnumDropdown<CircularWorkflowStatus>(
            key: const ValueKey('circular-form-workflow-status'),
            label: l10n.circularFieldWorkflowStatusLabel,
            value: formState.workflowStatus,
            items: CircularWorkflowStatus.values,
            enabled: enabled,
            labelBuilder: (item) =>
                CircularL10n.workflowStatusLabel(item, l10n),
            onChanged: controller.updateWorkflowStatus,
          ),
        ),
      ],
    );
  }
}

/// Long-form text fields section (instructions, personal notes, syllabus).
class CircularTextDetailsSection extends StatelessWidget {
  /// Creates a [CircularTextDetailsSection].
  const CircularTextDetailsSection({
    required this.controller,
    required this.instructionsController,
    required this.notesController,
    required this.syllabusController,
    required this.enabled,
    super.key,
  });

  final CircularFormController controller;
  final TextEditingController instructionsController;
  final TextEditingController notesController;
  final TextEditingController syllabusController;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return CircularFormSectionCard(
      index: 4,
      title: l10n.circularFormSectionText,
      icon: Icons.notes_rounded,
      children: [
        GlassTextField(
          key: const ValueKey('circular-form-instructions'),
          controller: instructionsController,
          enabled: enabled,
          maxLines: 3,
          labelText: l10n.circularFieldInstructionsLabel,
          hintText: l10n.circularFieldInstructionsHint,
          onChanged: controller.updateInstructions,
        ),
        GlassTextField(
          key: const ValueKey('circular-form-notes'),
          controller: notesController,
          enabled: enabled,
          maxLines: 3,
          labelText: l10n.circularFieldNotesLabel,
          hintText: l10n.circularFieldNotesHint,
          onChanged: controller.updateNotes,
        ),
        GlassTextField(
          key: const ValueKey('circular-form-syllabus'),
          controller: syllabusController,
          enabled: enabled,
          maxLines: 3,
          labelText: l10n.circularFieldSyllabusLabel,
          hintText: l10n.circularFieldSyllabusHint,
          onChanged: controller.updateSyllabus,
        ),
      ],
    );
  }
}
