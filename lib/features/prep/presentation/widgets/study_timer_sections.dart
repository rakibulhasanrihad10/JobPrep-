import 'package:flutter/material.dart';
import 'package:job_prep/core/localization/app_localizations_extension.dart';
import 'package:job_prep/core/theme/app_theme_tokens.dart';
import 'package:job_prep/core/widgets/glass_button.dart';
import 'package:job_prep/core/widgets/glass_chip.dart';
import 'package:job_prep/features/prep/domain/entities/prep_enums.dart';
import 'package:job_prep/features/prep/domain/entities/prep_material.dart';
import 'package:job_prep/features/prep/domain/entities/subject.dart';

/// Top bar inside `StudyTimer` choosing `Focus` / `Stopwatch` mode, Pomodoro
/// duration configuration, and the optional soft sound toggle.
class StudyTimerHeaderBar extends StatelessWidget {
  /// Creates a [StudyTimerHeaderBar].
  const StudyTimerHeaderBar({
    required this.selectedMode,
    required this.hasActiveSession,
    required this.soundEnabled,
    required this.onSelectMode,
    required this.onOpenConfig,
    required this.onToggleSound,
    super.key,
  });

  /// Currently selected timer mode.
  final StudySessionMode selectedMode;

  /// Locks mode switching and length edits while a session is open.
  final bool hasActiveSession;

  /// Current soft chime toggle state.
  final bool soundEnabled;

  /// Called when switching between Focus & Stopwatch.
  final ValueChanged<StudySessionMode> onSelectMode;

  /// Opens Pomodoro length settings dialog.
  final VoidCallback onOpenConfig;

  /// Toggles soft chime playback on phase completion.
  final ValueChanged<bool> onToggleSound;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final spacing = tokens.spacing;
    final l10n = context.l10n;

    return Wrap(
      alignment: WrapAlignment.spaceBetween,
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: spacing.sm,
      runSpacing: spacing.xs,
      children: [
        Wrap(
          spacing: spacing.xs,
          runSpacing: spacing.xs,
          children: [
            GlassChip(
              key: const ValueKey('timer-mode-focus'),
              label: Text(l10n.prepTimerModeFocus),
              isSelected: selectedMode == StudySessionMode.focus,
              onTap: hasActiveSession
                  ? null
                  : () => onSelectMode(StudySessionMode.focus),
            ),
            GlassChip(
              key: const ValueKey('timer-mode-stopwatch'),
              label: Text(l10n.prepTimerModeStopwatch),
              isSelected: selectedMode == StudySessionMode.stopwatch,
              onTap: hasActiveSession
                  ? null
                  : () => onSelectMode(StudySessionMode.stopwatch),
            ),
          ],
        ),
        Wrap(
          spacing: spacing.sm,
          runSpacing: spacing.xs,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            if (selectedMode == StudySessionMode.focus)
              GlassButton(
                key: const ValueKey('timer-config-button'),
                onPressed: hasActiveSession ? null : onOpenConfig,
                leading: Icon(Icons.tune_rounded, size: spacing.lg),
                child: Text(l10n.prepTimerSettingsButton),
              ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  l10n.prepTimerSoundLabel,
                  style: tokens.textStyles.bodySmall,
                ),
                SizedBox(width: spacing.xs),
                Switch.adaptive(
                  key: const ValueKey('timer-sound-switch'),
                  value: soundEnabled,
                  onChanged: onToggleSound,
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }
}

/// Subject & optional Material dropdown pickers shared by Study Timer & forms.
class StudyTimerSubjectPickers extends StatelessWidget {
  /// Creates a [StudyTimerSubjectPickers].
  const StudyTimerSubjectPickers({
    required this.subjects,
    required this.scopedMaterials,
    required this.selectedSubjectId,
    required this.selectedMaterialId,
    required this.isLocked,
    required this.onSelectSubject,
    required this.onSelectMaterial,
    this.forceStacked = false,
    this.subjectFieldKey,
    this.materialFieldKey,
    super.key,
  });

  /// Sorted user subjects.
  final List<Subject> subjects;

  /// Materials belonging to [selectedSubjectId].
  final List<PrepMaterial> scopedMaterials;

  /// Active/draft subject ID.
  final String? selectedSubjectId;

  /// Optional active/draft material ID.
  final String? selectedMaterialId;

  /// Disables changes once a session starts or during saves.
  final bool isLocked;

  /// Always stacks pickers vertically (used inside compact dialogs).
  final bool forceStacked;

  /// Optional override key for the subject dropdown.
  final Key? subjectFieldKey;

  /// Optional override key for the material dropdown.
  final Key? materialFieldKey;

  /// Updates selected subject.
  final ValueChanged<String?> onSelectSubject;

  /// Updates optional selected material.
  final ValueChanged<String?> onSelectMaterial;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final colors = tokens.colors;
    final spacing = tokens.spacing;
    final radii = tokens.radii;
    final l10n = context.l10n;

    return LayoutBuilder(
      builder: (context, constraints) {
        final subjectDropdown = DropdownButtonFormField<String>(
          key: subjectFieldKey ?? ValueKey('timer-subject-$selectedSubjectId'),
          initialValue: selectedSubjectId,
          isExpanded: true,
          decoration: InputDecoration(
            labelText: l10n.prepRevisionSubjectLabel,
            border: OutlineInputBorder(borderRadius: radii.buttonRadius),
          ),
          dropdownColor: colors.surfaceElevated,
          items: [
            for (final subject in subjects)
              DropdownMenuItem<String>(
                value: subject.id,
                child: Text(
                  subject.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
          ],
          onChanged: isLocked ? null : onSelectSubject,
        );

        final materialDropdown = DropdownButtonFormField<String?>(
          key: materialFieldKey ??
              ValueKey('timer-material-$selectedSubjectId-$selectedMaterialId'),
          initialValue: selectedMaterialId,
          isExpanded: true,
          decoration: InputDecoration(
            labelText: l10n.prepRevisionMaterialOptionalLabel,
            border: OutlineInputBorder(borderRadius: radii.buttonRadius),
          ),
          dropdownColor: colors.surfaceElevated,
          items: [
            DropdownMenuItem<String?>(
              child: Text(l10n.prepRevisionNoMaterialOption),
            ),
            for (final mat in scopedMaterials)
              DropdownMenuItem<String?>(
                value: mat.id,
                child: Text(
                  mat.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
          ],
          onChanged: isLocked ? null : onSelectMaterial,
        );

        if (!forceStacked && constraints.maxWidth >= 560) {
          return Row(
            children: [
              Expanded(child: subjectDropdown),
              SizedBox(width: spacing.md),
              Expanded(child: materialDropdown),
            ],
          );
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            subjectDropdown,
            SizedBox(height: forceStacked ? spacing.md : spacing.sm),
            materialDropdown,
          ],
        );
      },
    );
  }
}
