import 'package:flutter/material.dart';
import 'package:job_prep/core/localization/app_localizations_extension.dart';
import 'package:job_prep/core/localization/formatters.dart';
import 'package:job_prep/core/theme/app_theme_tokens.dart';
import 'package:job_prep/features/circulars/domain/entities/circular.dart';
import 'package:job_prep/features/circulars/domain/entities/circular_exam_date.dart';
import 'package:job_prep/features/prep/presentation/widgets/prep_option_chip.dart';

/// Optional linked circular and exam stage date selector block for study plans.
class StudyPlanCircularLinkFields extends StatelessWidget {
  /// Creates a [StudyPlanCircularLinkFields].
  const StudyPlanCircularLinkFields({
    required this.circulars,
    required this.selectedCircularId,
    required this.selectedExamDateId,
    required this.isBusy,
    required this.locale,
    required this.useBanglaDigits,
    required this.onCircularChanged,
    required this.onExamDateSelected,
    super.key,
  });

  /// Available saved circulars for linking.
  final List<Circular> circulars;

  /// Currently selected circular ID, if any.
  final String? selectedCircularId;

  /// Currently selected exam stage ID within the circular, if any.
  final String? selectedExamDateId;

  /// Disables inputs while saving.
  final bool isBusy;

  /// Active display locale.
  final Locale locale;

  /// Whether Bangla digits are active.
  final bool useBanglaDigits;

  /// Callback invoked when the circular dropdown changes.
  final ValueChanged<String?> onCircularChanged;

  /// Callback invoked when a circular exam stage chip is chosen.
  final ValueChanged<CircularExamDate> onExamDateSelected;

  @override
  Widget build(BuildContext context) {
    if (circulars.isEmpty) {
      return const SizedBox.shrink();
    }

    final tokens = context.tokens;
    final spacing = tokens.spacing;
    final l10n = context.l10n;
    final selectedCircular = selectedCircularId == null
        ? null
        : circulars.where((c) => c.id == selectedCircularId).firstOrNull;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          l10n.prepStudyPlanCircularLabel,
          style: tokens.textStyles.labelLarge,
        ),
        SizedBox(height: spacing.xs),
        DropdownButtonFormField<String?>(
          key: const ValueKey('study-plan-circular-dropdown'),
          initialValue: selectedCircular?.id,
          isExpanded: true,
          items: [
            DropdownMenuItem<String?>(
              child: Text(l10n.prepStudyPlanNoCircularOption),
            ),
            for (final c in circulars)
              DropdownMenuItem<String?>(
                value: c.id,
                child: Text(c.title, overflow: TextOverflow.ellipsis),
              ),
          ],
          onChanged: isBusy ? null : onCircularChanged,
        ),
        if (selectedCircular != null &&
            selectedCircular.examDates.isNotEmpty) ...[
          SizedBox(height: spacing.sm),
          Text(
            l10n.prepStudyPlanExamStageLabel,
            style: tokens.textStyles.labelLarge,
          ),
          SizedBox(height: spacing.xs),
          Wrap(
            spacing: spacing.xs,
            runSpacing: spacing.xs,
            children: [
              for (final exam in selectedCircular.examDates)
                Builder(
                  builder: (_) {
                    final dateLabel = AppFormatters.formatDate(
                      exam.examDate,
                      locale: locale,
                      pattern: 'd MMM',
                      useBanglaDigits: useBanglaDigits,
                    );
                    return PrepOptionChip(
                      key: ValueKey('study-plan-exam-stage-${exam.id}'),
                      label: '${exam.stage} ($dateLabel)',
                      isSelected: selectedExamDateId == exam.id,
                      onTap: isBusy ? null : () => onExamDateSelected(exam),
                    );
                  },
                ),
            ],
          ),
        ],
      ],
    );
  }
}
