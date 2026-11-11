import 'package:flutter/material.dart';
import 'package:job_prep/core/localization/app_localizations_extension.dart';
import 'package:job_prep/core/theme/app_theme_tokens.dart';
import 'package:job_prep/core/widgets/glass_button.dart';
import 'package:job_prep/core/widgets/glass_card.dart';
import 'package:job_prep/features/prep/domain/entities/subject.dart';
import 'package:job_prep/features/prep/presentation/providers/mock_test_providers.dart';
import 'package:job_prep/features/prep/presentation/widgets/prep_option_chip.dart';
import 'package:job_prep/l10n/app_localizations.dart';

/// Filter controls card for the Mock Tests tab (subject dropdown and date
/// range presets).
class MockTestsFilterCard extends StatelessWidget {
  /// Creates a [MockTestsFilterCard].
  const MockTestsFilterCard({
    required this.subjects,
    required this.filter,
    required this.hasActiveFilters,
    required this.onSubjectChanged,
    required this.onDatePresetChanged,
    required this.onClear,
    super.key,
  });

  /// Available subjects sorted for display.
  final List<Subject> subjects;

  /// Active filter criteria.
  final MockTestFilterState filter;

  /// Whether at least one filter deviates from the default state.
  final bool hasActiveFilters;

  /// Updates the subject filter (`null` = all subjects).
  final ValueChanged<String?> onSubjectChanged;

  /// Updates the selected calendar window preset.
  final ValueChanged<MockDateFilterPreset> onDatePresetChanged;

  /// Resets all filters back to default.
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final spacing = tokens.spacing;
    final l10n = context.l10n;
    final activeSubjectId =
        subjects.any((s) => s.id == filter.subjectId) ? filter.subjectId : null;

    return GlassCard(
      padding: spacing.insetsAllLg,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.prepMockFilterSubjectLabel,
                      style: tokens.textStyles.labelLarge,
                    ),
                    SizedBox(height: spacing.xs),
                    DropdownButtonFormField<String?>(
                      key: const ValueKey('mock-filter-subject-dropdown'),
                      initialValue: activeSubjectId,
                      isExpanded: true,
                      items: [
                        DropdownMenuItem<String?>(
                          child: Text(l10n.prepMockFilterAllSubjects),
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
              if (hasActiveFilters) ...[
                SizedBox(width: spacing.md),
                GlassButton(
                  key: const ValueKey('mock-filter-clear-button'),
                  onPressed: onClear,
                  child: Text(l10n.prepMockFilterClear),
                ),
              ],
            ],
          ),
          SizedBox(height: spacing.md),
          Text(
            l10n.prepMockFilterDateLabel,
            style: tokens.textStyles.labelLarge,
          ),
          SizedBox(height: spacing.xs),
          Wrap(
            spacing: spacing.xs,
            runSpacing: spacing.xs,
            children: [
              for (final preset in MockDateFilterPreset.values)
                PrepOptionChip(
                  key: ValueKey('mock-filter-date-${preset.name}'),
                  label: _presetLabel(l10n, preset),
                  isSelected: filter.datePreset == preset,
                  onTap: () => onDatePresetChanged(preset),
                ),
            ],
          ),
        ],
      ),
    );
  }

  String _presetLabel(AppLocalizations l10n, MockDateFilterPreset preset) {
    return switch (preset) {
      MockDateFilterPreset.all => l10n.prepMockFilterDateAll,
      MockDateFilterPreset.last7Days => l10n.prepMockFilterDate7Days,
      MockDateFilterPreset.last30Days => l10n.prepMockFilterDate30Days,
      MockDateFilterPreset.last90Days => l10n.prepMockFilterDate90Days,
    };
  }
}
