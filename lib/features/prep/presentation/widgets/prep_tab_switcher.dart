import 'package:flutter/material.dart';
import 'package:job_prep/core/localization/app_localizations_extension.dart';
import 'package:job_prep/core/theme/app_theme_tokens.dart';
import 'package:job_prep/core/widgets/glass_card.dart';

/// Top-level sections hosted inside `PrepScreen`.
enum PrepSectionTab {
  /// Subjects, syllabus progress, materials, and study plans.
  subjects,

  /// Cross-subject mock test history, filters, analytics, and trend chart.
  mockTests,

  /// Cross-subject study analytics, streaks, charts, and heatmap.
  analytics,
}

/// Tokenized glass tab switcher bar for `PrepScreen`.
class PrepTabSwitcher extends StatelessWidget {
  /// Creates a [PrepTabSwitcher].
  const PrepTabSwitcher({
    required this.activeTab,
    required this.onChanged,
    super.key,
  });

  /// Currently selected tab section.
  final PrepSectionTab activeTab;

  /// Callback invoked when the user switches tabs.
  final ValueChanged<PrepSectionTab> onChanged;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final spacing = tokens.spacing;
    final l10n = context.l10n;

    return Align(
      alignment: Alignment.centerLeft,
      child: GlassCard(
        padding: spacing.insetsAllXs,
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _TabButton(
                key: const ValueKey('prep-tab-subjects'),
                icon: Icons.menu_book_outlined,
                label: l10n.prepTabSubjects,
                isSelected: activeTab == PrepSectionTab.subjects,
                onTap: () => onChanged(PrepSectionTab.subjects),
              ),
              SizedBox(width: spacing.xs),
              _TabButton(
                key: const ValueKey('prep-tab-mock-tests'),
                icon: Icons.analytics_outlined,
                label: l10n.prepTabMockTests,
                isSelected: activeTab == PrepSectionTab.mockTests,
                onTap: () => onChanged(PrepSectionTab.mockTests),
              ),
              SizedBox(width: spacing.xs),
              _TabButton(
                key: const ValueKey('prep-tab-analytics'),
                icon: Icons.query_stats_rounded,
                label: l10n.prepTabAnalytics,
                isSelected: activeTab == PrepSectionTab.analytics,
                onTap: () => onChanged(PrepSectionTab.analytics),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TabButton extends StatelessWidget {
  const _TabButton({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
    super.key,
  });

  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final colors = tokens.colors;
    final spacing = tokens.spacing;

    final background = isSelected ? colors.goldAccentSubtle : colors.surface;
    final border = isSelected ? colors.goldAccent : colors.glassBorder;
    final foreground = isSelected ? colors.goldAccent : colors.textSecondary;

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
            border: Border.all(color: border),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: spacing.lg, color: foreground),
              SizedBox(width: spacing.xs),
              Text(
                label,
                style: tokens.textStyles.labelLarge.copyWith(color: foreground),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
