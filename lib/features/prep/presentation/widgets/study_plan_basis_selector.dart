import 'package:flutter/material.dart';
import 'package:job_prep/core/localization/app_localizations_extension.dart';
import 'package:job_prep/core/theme/app_theme_tokens.dart';
import 'package:job_prep/features/prep/domain/entities/prep_enums.dart';
import 'package:job_prep/features/prep/presentation/widgets/prep_option_chip.dart';

/// Basis selector for study plans (reading units vs syllabus topics).
class StudyPlanBasisSelector extends StatelessWidget {
  /// Creates a [StudyPlanBasisSelector].
  const StudyPlanBasisSelector({
    required this.selectedBasis,
    required this.isBusy,
    required this.onBasisChanged,
    super.key,
  });

  /// The actively chosen basis.
  final StudyPlanBasis selectedBasis;

  /// Whether the form is submitting.
  final bool isBusy;

  /// Callback when a basis is selected.
  final ValueChanged<StudyPlanBasis> onBasisChanged;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final spacing = tokens.spacing;
    final l10n = context.l10n;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          l10n.studyPlanBasisLabel,
          style: tokens.textStyles.labelLarge,
        ),
        SizedBox(height: spacing.xs),
        Wrap(
          spacing: spacing.xs,
          runSpacing: spacing.xs,
          children: [
            PrepOptionChip(
              key: const ValueKey('study-plan-basis-reading-units'),
              label: l10n.studyPlanBasisReadingUnits,
              isSelected: selectedBasis == StudyPlanBasis.readingUnits,
              onTap: isBusy
                  ? null
                  : () => onBasisChanged(StudyPlanBasis.readingUnits),
            ),
            PrepOptionChip(
              key: const ValueKey('study-plan-basis-syllabus-topics'),
              label: l10n.studyPlanBasisSyllabusTopics,
              isSelected: selectedBasis == StudyPlanBasis.syllabusTopics,
              onTap: isBusy
                  ? null
                  : () => onBasisChanged(StudyPlanBasis.syllabusTopics),
            ),
          ],
        ),
      ],
    );
  }
}
