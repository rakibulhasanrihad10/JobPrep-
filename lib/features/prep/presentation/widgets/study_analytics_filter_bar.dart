import 'package:flutter/material.dart';
import 'package:job_prep/core/localization/app_localizations_extension.dart';
import 'package:job_prep/core/theme/app_theme_tokens.dart';
import 'package:job_prep/core/widgets/glass_button.dart';
import 'package:job_prep/core/widgets/glass_card.dart';
import 'package:job_prep/features/prep/domain/entities/study_analytics.dart';
import 'package:job_prep/features/prep/domain/entities/subject.dart';
import 'package:job_prep/features/prep/presentation/widgets/prep_option_chip.dart';
import 'package:job_prep/l10n/app_localizations.dart';

/// Filter controls bar allowing users to select the analytics date window
/// (`7`, `30`, or `90` days) and scope by subject.
class StudyAnalyticsFilterBar extends StatelessWidget {
  /// Creates a [StudyAnalyticsFilterBar].
  const StudyAnalyticsFilterBar({
    required this.range,
    required this.subjects,
    required this.selectedSubjectId,
    required this.onRangeChanged,
    required this.onSubjectChanged,
    required this.onClear,
    super.key,
  });

  /// Currently selected date range window.
  final StudyAnalyticsRange range;

  /// Ordered list of available subjects.
  final List<Subject> subjects;

  /// Currently selected subject identifier (`null` = all subjects).
  final String? selectedSubjectId;

  /// Updates the selected [StudyAnalyticsRange].
  final ValueChanged<StudyAnalyticsRange> onRangeChanged;

  /// Updates the selected subject filter.
  final ValueChanged<String?> onSubjectChanged;

  /// Resets filters back to defaults (`7 days`, all subjects).
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final spacing = tokens.spacing;
    final l10n = context.l10n;

    final activeSubjectId = subjects.any((s) => s.id == selectedSubjectId)
        ? selectedSubjectId
        : null;
    final hasNonDefaultFilter =
        activeSubjectId != null || range != StudyAnalyticsRange.days7;

    return GlassCard(
      padding: spacing.insetsAllLg,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            l10n.prepAnalyticsFilterRangeLabel,
            style: tokens.textStyles.labelLarge,
          ),
          SizedBox(height: spacing.xs),
          Wrap(
            spacing: spacing.xs,
            runSpacing: spacing.xs,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              for (final option in StudyAnalyticsRange.values)
                PrepOptionChip(
                  key: ValueKey('analytics-range-${option.name}'),
                  label: _rangeLabel(l10n, option),
                  isSelected: range == option,
                  onTap: () => onRangeChanged(option),
                ),
            ],
          ),
          SizedBox(height: spacing.md),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.prepAnalyticsFilterSubjectLabel,
                      style: tokens.textStyles.labelLarge,
                    ),
                    SizedBox(height: spacing.xs),
                    DropdownButtonFormField<String?>(
                      key: const ValueKey('analytics-subject-dropdown'),
                      initialValue: activeSubjectId,
                      isExpanded: true,
                      items: [
                        DropdownMenuItem<String?>(
                          child: Text(l10n.prepAnalyticsAllSubjects),
                        ),
                        for (final s in subjects)
                          DropdownMenuItem<String?>(
                            value: s.id,
                            child: Text(
                              s.name,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                      ],
                      onChanged: onSubjectChanged,
                    ),
                  ],
                ),
              ),
              if (hasNonDefaultFilter) ...[
                SizedBox(width: spacing.md),
                GlassButton(
                  key: const ValueKey('analytics-clear-filter-button'),
                  onPressed: onClear,
                  child: Text(l10n.prepAnalyticsClearFilter),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  String _rangeLabel(AppLocalizations l10n, StudyAnalyticsRange value) {
    return switch (value) {
      StudyAnalyticsRange.days7 => l10n.prepAnalyticsRange7Days,
      StudyAnalyticsRange.days30 => l10n.prepAnalyticsRange30Days,
      StudyAnalyticsRange.days90 => l10n.prepAnalyticsRange90Days,
    };
  }
}
