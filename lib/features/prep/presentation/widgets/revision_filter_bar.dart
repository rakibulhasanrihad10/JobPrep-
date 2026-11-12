import 'package:flutter/material.dart';
import 'package:job_prep/core/localization/app_localizations_extension.dart';
import 'package:job_prep/core/theme/app_theme_tokens.dart';
import 'package:job_prep/core/widgets/glass_card.dart';
import 'package:job_prep/features/prep/domain/entities/prep_material.dart';
import 'package:job_prep/features/prep/domain/entities/subject.dart';
import 'package:job_prep/features/prep/domain/utils/revision_scheduler.dart';
import 'package:job_prep/features/prep/presentation/providers/revision_state.dart';
import 'package:job_prep/features/prep/presentation/utils/revision_l10n.dart';

/// Queue sub-tab bar (`Due today`, `Overdue`, `Upcoming`, `Done`) paired with
/// subject and material dropdown filters on the Revision Queue view.
class RevisionFilterBar extends StatelessWidget {
  /// Creates a [RevisionFilterBar].
  const RevisionFilterBar({
    required this.activeTab,
    required this.counts,
    required this.filter,
    required this.subjects,
    required this.materials,
    required this.locale,
    required this.useBanglaDigits,
    required this.onSelectTab,
    required this.onSelectSubject,
    required this.onSelectMaterial,
    required this.onClearFilters,
    super.key,
  });

  /// Currently selected queue tab.
  final RevisionQueueTab activeTab;

  /// Count per queue tab honoring active subject/material filters.
  final RevisionTabCounts counts;

  /// Active subject & material filter criteria.
  final RevisionFilterState filter;

  /// Sorted user subjects.
  final List<Subject> subjects;

  /// Study materials available across subjects.
  final List<PrepMaterial> materials;

  /// Active UI locale.
  final Locale locale;

  /// Whether Bangla numerals are enabled.
  final bool useBanglaDigits;

  /// Invoked when the user taps a queue tab button.
  final ValueChanged<RevisionQueueTab> onSelectTab;

  /// Invoked when the user selects or clears the subject filter.
  final ValueChanged<String?> onSelectSubject;

  /// Invoked when the user selects or clears the material filter.
  final ValueChanged<String?> onSelectMaterial;

  /// Invoked to clear both filters.
  final VoidCallback onClearFilters;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final colors = tokens.colors;
    final spacing = tokens.spacing;
    final radii = tokens.radii;
    final l10n = context.l10n;

    final activeSubjectId =
        subjects.any((s) => s.id == filter.subjectId) ? filter.subjectId : null;
    final scopedMaterials = activeSubjectId == null
        ? materials
        : materials
            .where((m) => m.subjectId == activeSubjectId)
            .toList(growable: false);
    final activeMaterialId =
        scopedMaterials.any((m) => m.id == filter.materialId)
            ? filter.materialId
            : null;

    return GlassCard(
      padding: spacing.insetsAllLg,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Wrap(
            spacing: spacing.xs,
            runSpacing: spacing.xs,
            children: [
              for (final tab in RevisionQueueTab.values)
                _QueueTabChip(
                  key: ValueKey('revision-queue-tab-${tab.name}'),
                  label: RevisionL10n.tabLabel(
                    tab,
                    count: counts.countFor(tab),
                    l10n: l10n,
                    locale: locale,
                    useBanglaDigits: useBanglaDigits,
                  ),
                  isSelected: activeTab == tab,
                  isOverdueHighlighted:
                      tab == RevisionQueueTab.overdue && counts.overdue > 0,
                  onTap: () => onSelectTab(tab),
                ),
            ],
          ),
          SizedBox(height: spacing.md),
          LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth >= 560;
              final subjectField = DropdownButtonFormField<String?>(
                key: ValueKey('revision-subject-filter-$activeSubjectId'),
                initialValue: activeSubjectId,
                isExpanded: true,
                decoration: InputDecoration(
                  labelText: l10n.prepRevisionSubjectLabel,
                  border: OutlineInputBorder(
                    borderRadius: radii.buttonRadius,
                  ),
                ),
                dropdownColor: colors.surfaceElevated,
                items: [
                  DropdownMenuItem<String?>(
                    child: Text(l10n.prepRevisionAllSubjects),
                  ),
                  for (final subject in subjects)
                    DropdownMenuItem<String?>(
                      value: subject.id,
                      child: Text(
                        subject.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                ],
                onChanged: onSelectSubject,
              );

              final materialField = DropdownButtonFormField<String?>(
                key: ValueKey(
                  'revision-material-filter-$activeSubjectId-$activeMaterialId',
                ),
                initialValue: activeMaterialId,
                isExpanded: true,
                decoration: InputDecoration(
                  labelText: l10n.prepRevisionMaterialOptionalLabel,
                  border: OutlineInputBorder(
                    borderRadius: radii.buttonRadius,
                  ),
                ),
                dropdownColor: colors.surfaceElevated,
                items: [
                  DropdownMenuItem<String?>(
                    child: Text(l10n.prepRevisionAllMaterials),
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
                onChanged: onSelectMaterial,
              );

              if (isWide) {
                return Row(
                  children: [
                    Expanded(child: subjectField),
                    SizedBox(width: spacing.md),
                    Expanded(child: materialField),
                    if (filter.hasActiveFilters) ...[
                      SizedBox(width: spacing.sm),
                      TextButton(
                        key: const ValueKey('revision-clear-filters-button'),
                        onPressed: onClearFilters,
                        child: Text(l10n.prepRevisionClearFilters),
                      ),
                    ],
                  ],
                );
              }

              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  subjectField,
                  SizedBox(height: spacing.sm),
                  materialField,
                  if (filter.hasActiveFilters) ...[
                    SizedBox(height: spacing.xs),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: TextButton(
                        key: const ValueKey('revision-clear-filters-button'),
                        onPressed: onClearFilters,
                        child: Text(l10n.prepRevisionClearFilters),
                      ),
                    ),
                  ],
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class _QueueTabChip extends StatelessWidget {
  const _QueueTabChip({
    required this.label,
    required this.isSelected,
    required this.isOverdueHighlighted,
    required this.onTap,
    super.key,
  });

  final String label;
  final bool isSelected;
  final bool isOverdueHighlighted;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final colors = tokens.colors;
    final spacing = tokens.spacing;

    final accent = isOverdueHighlighted ? colors.danger : colors.goldAccent;
    final background =
        isSelected ? accent.withValues(alpha: 0.16) : colors.surfaceElevated;
    final borderColor = isSelected ? accent : colors.glassBorder;
    final foreground = isSelected ? accent : colors.textSecondary;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: tokens.radii.buttonRadius,
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: spacing.md,
            vertical: spacing.sm,
          ),
          decoration: BoxDecoration(
            color: background,
            borderRadius: tokens.radii.buttonRadius,
            border: Border.all(color: borderColor),
          ),
          child: Text(
            label,
            style: tokens.textStyles.labelLarge.copyWith(
              color: foreground,
            ),
          ),
        ),
      ),
    );
  }
}
