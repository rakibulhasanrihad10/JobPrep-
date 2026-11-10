import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:job_prep/core/localization/app_localizations_extension.dart';
import 'package:job_prep/core/theme/app_theme_tokens.dart';
import 'package:job_prep/core/widgets/glass_chip.dart';
import 'package:job_prep/features/circulars/domain/entities/circular_enums.dart';
import 'package:job_prep/features/circulars/domain/entities/circular_filter.dart';
import 'package:job_prep/features/circulars/presentation/providers/circulars_providers.dart';
import 'package:job_prep/features/circulars/presentation/utils/circular_l10n.dart';
import 'package:job_prep/features/circulars/presentation/widgets/circular_deadline_range_filter.dart';

/// Expandable filter controls for sector, application status, priority,
/// workflow status, and deadline range.
class CircularsFilterPanel extends ConsumerWidget {
  /// Creates a [CircularsFilterPanel].
  const CircularsFilterPanel({
    required this.filter,
    super.key,
  });

  /// Active filter configuration.
  final CircularFilter filter;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tokens = context.tokens;
    final colors = tokens.colors;
    final spacing = tokens.spacing;
    final l10n = context.l10n;
    final filterNotifier = ref.read(circularFilterProvider.notifier);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Divider(color: colors.glassBorder, height: spacing.xl),
        _FilterChipSection(
          title: l10n.circularsFilterSector,
          children: [
            for (final sector in CircularSector.values)
              GlassChip(
                isSelected: filter.sectors.contains(sector),
                label: Text(CircularL10n.sectorLabel(sector, l10n)),
                onTap: () => filterNotifier.toggleSector(sector),
              ),
          ],
        ),
        SizedBox(height: spacing.md),
        _FilterChipSection(
          title: l10n.circularsFilterApplicationStatus,
          children: [
            for (final status in ApplicationStatus.values)
              GlassChip(
                isSelected: filter.applicationStatuses.contains(status),
                label: Text(CircularL10n.applicationStatusLabel(status, l10n)),
                onTap: () => filterNotifier.toggleApplicationStatus(status),
              ),
          ],
        ),
        SizedBox(height: spacing.md),
        _FilterChipSection(
          title: l10n.circularsFilterPriority,
          children: [
            for (final priority in CircularPriority.values)
              GlassChip(
                isSelected: filter.priorities.contains(priority),
                label: Text(CircularL10n.priorityLabel(priority, l10n)),
                onTap: () => filterNotifier.togglePriority(priority),
              ),
          ],
        ),
        SizedBox(height: spacing.md),
        _FilterChipSection(
          title: l10n.circularsFilterWorkflowStatus,
          children: [
            for (final status in CircularWorkflowStatus.values)
              GlassChip(
                isSelected: filter.workflowStatuses.contains(status),
                label: Text(CircularL10n.workflowStatusLabel(status, l10n)),
                onTap: () => filterNotifier.toggleWorkflowStatus(status),
              ),
          ],
        ),
        SizedBox(height: spacing.md),
        CircularDeadlineRangeFilter(filter: filter),
      ],
    );
  }
}

class _FilterChipSection extends StatelessWidget {
  const _FilterChipSection({
    required this.title,
    required this.children,
  });

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: tokens.textStyles.labelLarge),
        SizedBox(height: tokens.spacing.sm),
        Wrap(
          spacing: tokens.spacing.sm,
          runSpacing: tokens.spacing.sm,
          children: children,
        ),
      ],
    );
  }
}
