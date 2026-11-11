import 'package:flutter/material.dart';
import 'package:job_prep/core/theme/app_theme_tokens.dart';

/// Responsive section header row used across Today cards; drops long localized
/// action buttons onto a second line cleanly on narrow mobile viewports.
class TodaySectionHeader extends StatelessWidget {
  /// Creates a [TodaySectionHeader].
  const TodaySectionHeader({
    required this.icon,
    required this.title,
    this.iconColor,
    this.action,
    super.key,
  });

  /// Leading section icon.
  final IconData icon;

  /// Optional custom icon color (defaults to `colors.goldAccent`).
  final Color? iconColor;

  /// Localized section heading text.
  final String title;

  /// Optional trailing action button (`TextButton`, badge, etc.).
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final colors = tokens.colors;
    final spacing = tokens.spacing;

    final titleRow = Row(
      children: [
        Icon(icon, size: spacing.lg, color: iconColor ?? colors.goldAccent),
        SizedBox(width: spacing.sm),
        Expanded(
          child: Text(title, style: tokens.textStyles.titleMedium),
        ),
      ],
    );

    final trailing = action;
    if (trailing == null) {
      return titleRow;
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 380) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              titleRow,
              Align(
                alignment: AlignmentDirectional.centerEnd,
                child: trailing,
              ),
            ],
          );
        }
        return Row(
          children: [
            Expanded(child: titleRow),
            SizedBox(width: spacing.xs),
            trailing,
          ],
        );
      },
    );
  }
}
