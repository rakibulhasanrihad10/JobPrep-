import 'package:flutter/material.dart';
import 'package:job_prep/core/localization/app_localizations_extension.dart';
import 'package:job_prep/core/theme/app_theme_tokens.dart';
import 'package:job_prep/core/widgets/fade_slide_in.dart';
import 'package:job_prep/core/widgets/glass_card.dart';
import 'package:job_prep/features/circulars/domain/entities/circular.dart';

/// Glass section container used by the unified circular add/edit form.
class CircularFormSectionCard extends StatelessWidget {
  /// Creates a [CircularFormSectionCard].
  const CircularFormSectionCard({
    required this.title,
    required this.icon,
    required this.children,
    super.key,
    this.index = 0,
  });

  /// Localized section heading.
  final String title;

  /// Leading section icon.
  final IconData icon;

  /// Section form fields.
  final List<Widget> children;

  /// Entrance stagger index for [FadeSlideIn].
  final int index;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final colors = tokens.colors;
    final spacing = tokens.spacing;
    final textStyles = tokens.textStyles;

    return GlassCard(
      padding: spacing.insetsAllLg,
      child: FadeSlideIn(
        index: index,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Icon(icon, color: colors.goldAccent, size: spacing.lg),
                SizedBox(width: spacing.sm),
                Expanded(
                  child: Text(
                    title,
                    style: textStyles.titleMedium,
                  ),
                ),
              ],
            ),
            Divider(color: colors.glassBorder, height: spacing.xl),
            for (var i = 0; i < children.length; i++) ...[
              if (i > 0) SizedBox(height: spacing.md),
              children[i],
            ],
          ],
        ),
      ),
    );
  }
}

/// Labeled rectangular dropdown matching [AppThemeTokens] styling.
class CircularEnumDropdown<T> extends StatelessWidget {
  /// Creates a [CircularEnumDropdown].
  const CircularEnumDropdown({
    required this.label,
    required this.value,
    required this.items,
    required this.labelBuilder,
    required this.onChanged,
    super.key,
    this.enabled = true,
  });

  /// Field label rendered above the dropdown.
  final String label;

  /// Currently selected enum value.
  final T value;

  /// Selectable enum options.
  final List<T> items;

  /// Resolves localized display text for an option.
  final String Function(T item) labelBuilder;

  /// Callback when a new option is chosen.
  final ValueChanged<T> onChanged;

  /// Whether user interaction is enabled.
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final colors = tokens.colors;
    final spacing = tokens.spacing;
    final textStyles = tokens.textStyles;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: textStyles.labelLarge.copyWith(color: colors.textSecondary),
        ),
        SizedBox(height: spacing.sm),
        Container(
          padding: EdgeInsets.symmetric(horizontal: spacing.md),
          decoration: BoxDecoration(
            color: colors.surfaceElevated,
            borderRadius: tokens.radii.buttonRadius,
            border: Border.all(color: colors.glassBorder),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<T>(
              value: value,
              isExpanded: true,
              dropdownColor: colors.surfaceElevated,
              iconEnabledColor: colors.goldAccent,
              style: textStyles.bodyMedium.copyWith(color: colors.textPrimary),
              onChanged: enabled
                  ? (next) {
                      if (next != null) onChanged(next);
                    }
                  : null,
              items: [
                for (final item in items)
                  DropdownMenuItem<T>(
                    value: item,
                    child: Text(
                      labelBuilder(item),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

/// Non-blocking warning banner surfaced when another saved circular shares
/// the same circular URL.
class CircularDuplicateWarningBanner extends StatelessWidget {
  /// Creates a [CircularDuplicateWarningBanner].
  const CircularDuplicateWarningBanner({
    required this.duplicate,
    super.key,
  });

  /// Existing matching circular detected by URL comparison.
  final Circular duplicate;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final colors = tokens.colors;
    final spacing = tokens.spacing;
    final l10n = context.l10n;

    return Container(
      key: const ValueKey('circular-form-duplicate-warning'),
      padding: spacing.insetsAllMd,
      decoration: BoxDecoration(
        color: colors.warning.withValues(alpha: 0.14),
        borderRadius: tokens.radii.buttonRadius,
        border: Border.all(color: colors.warning.withValues(alpha: 0.55)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.warning_amber_rounded,
            color: colors.warning,
            size: spacing.lg,
          ),
          SizedBox(width: spacing.sm),
          Expanded(
            child: Text(
              l10n.circularDuplicateLinkWarning(duplicate.title),
              style: tokens.textStyles.bodySmall.copyWith(
                color: colors.warning,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Lays out [first] and [second] side-by-side on wide screens and stacked
/// vertically on compact viewports.
class CircularFormResponsivePair extends StatelessWidget {
  /// Creates a [CircularFormResponsivePair].
  const CircularFormResponsivePair({
    required this.first,
    required this.second,
    super.key,
  });

  /// First field widget.
  final Widget first;

  /// Second field widget.
  final Widget second;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final spacing = tokens.spacing;

    return LayoutBuilder(
      builder: (context, constraints) {
        if (tokens.breakpoints.isCompact(constraints.maxWidth)) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              first,
              SizedBox(height: spacing.md),
              second,
            ],
          );
        }

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: first),
            SizedBox(width: spacing.md),
            Expanded(child: second),
          ],
        );
      },
    );
  }
}
