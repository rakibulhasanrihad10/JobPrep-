import 'package:flutter/material.dart';
import 'package:job_prep/core/localization/app_localizations_extension.dart';
import 'package:job_prep/core/theme/app_theme_tokens.dart';
import 'package:job_prep/features/prep/domain/entities/subject.dart';

/// Subject dropdown picker inside mock test dialog.
class MockTestSubjectSelector extends StatelessWidget {
  const MockTestSubjectSelector({
    required this.subjects,
    required this.effectiveSubjectId,
    required this.isBusy,
    required this.onChanged,
    super.key,
  });

  final List<Subject> subjects;
  final String? effectiveSubjectId;
  final bool isBusy;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final colors = tokens.colors;
    final spacing = tokens.spacing;
    final l10n = context.l10n;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          l10n.prepMockFormSubjectLabel,
          style: tokens.textStyles.labelLarge,
        ),
        SizedBox(height: spacing.xs),
        if (subjects.isNotEmpty)
          DropdownButtonFormField<String>(
            key: const ValueKey('mock-form-subject-dropdown'),
            initialValue: effectiveSubjectId,
            isExpanded: true,
            items: [
              for (final s in subjects)
                DropdownMenuItem<String>(
                  value: s.id,
                  child: Text(s.name, overflow: TextOverflow.ellipsis),
                ),
            ],
            onChanged: isBusy ? null : onChanged,
          )
        else
          Text(
            l10n.prepMockValidationSubjectRequired,
            style: tokens.textStyles.bodySmall.copyWith(
              color: colors.danger,
            ),
          ),
      ],
    );
  }
}
