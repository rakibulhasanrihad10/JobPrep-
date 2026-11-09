import 'package:flutter/material.dart';
import 'package:job_prep/core/localization/app_localizations_extension.dart';
import 'package:job_prep/core/theme/app_theme_tokens.dart';

/// Card widget demonstrating design tokens (buttons, radii, badges).
class TokensPreviewCard extends StatelessWidget {
  /// Creates a [TokensPreviewCard].
  const TokensPreviewCard({super.key});

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final colors = tokens.colors;
    final spacing = tokens.spacing;
    final radii = tokens.radii;
    final textStyles = tokens.textStyles;
    final l10n = context.l10n;

    return Container(
      padding: spacing.insetsAllLg,
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: radii.cardRadius,
        border: Border.all(color: colors.glassBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.tokensPreviewTitle,
            style: textStyles.titleMedium,
          ),
          SizedBox(height: spacing.md),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () {},
                  child: Text(l10n.goldAccentButton),
                ),
              ),
              SizedBox(width: spacing.md),
              Expanded(
                child: OutlinedButton(
                  onPressed: () {},
                  child: Text(l10n.outlinedButton),
                ),
              ),
            ],
          ),
          SizedBox(height: spacing.md),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _StatusBadge(
                label: l10n.statusSuccess,
                color: colors.success,
              ),
              _StatusBadge(
                label: l10n.statusWarning,
                color: colors.warning,
              ),
              _StatusBadge(
                label: l10n.statusDanger,
                color: colors.danger,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({
    required this.label,
    required this.color,
  });

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final spacing = tokens.spacing;
    final radii = tokens.radii;
    final textStyles = tokens.textStyles;

    return Container(
      padding: spacing.insetsHorizontalMd + spacing.insetsVerticalSm,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: radii.buttonRadius,
        border: Border.all(color: color),
      ),
      child: Text(
        label,
        style: textStyles.labelSmall.copyWith(
          color: color,
        ),
      ),
    );
  }
}
