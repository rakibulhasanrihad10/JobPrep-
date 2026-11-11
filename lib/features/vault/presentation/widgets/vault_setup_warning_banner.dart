import 'package:flutter/material.dart';
import 'package:job_prep/core/localization/app_localizations_extension.dart';
import 'package:job_prep/core/theme/app_theme_tokens.dart';

/// Highlighted warning banner reminding users during first-time vault setup
/// that a forgotten passphrase cannot be recovered or reset.
class VaultSetupWarningBanner extends StatelessWidget {
  /// Creates a [VaultSetupWarningBanner].
  const VaultSetupWarningBanner({super.key});

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final colors = tokens.colors;
    final spacing = tokens.spacing;
    final radii = tokens.radii;
    final textStyles = tokens.textStyles;

    return Container(
      key: const ValueKey('vault-setup-warning-banner'),
      padding: spacing.insetsAllMd,
      decoration: BoxDecoration(
        color: colors.warning.withValues(alpha: 0.14),
        borderRadius: radii.cardRadius,
        border: Border.all(
          color: colors.warning.withValues(alpha: 0.55),
        ),
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
              context.l10n.vaultUnrecoverableWarning,
              style: textStyles.bodySmall.copyWith(color: colors.textPrimary),
            ),
          ),
        ],
      ),
    );
  }
}

/// Checkbox acknowledgement row rendered directly on a transparent [Material]
/// so `InkWell` ripples work cleanly inside translucent `GlassDialog` shells
/// without triggering `ListTile` ancestor-material warnings.
class VaultSetupAckCheckbox extends StatelessWidget {
  /// Creates a [VaultSetupAckCheckbox].
  const VaultSetupAckCheckbox({
    required this.value,
    required this.onChanged,
    this.enabled = true,
    super.key,
  });

  /// Whether the non-recovery warning has been acknowledged.
  final bool value;

  /// Called when the acknowledgement state toggles.
  final ValueChanged<bool> onChanged;

  /// Whether the control accepts interaction.
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final colors = tokens.colors;
    final spacing = tokens.spacing;
    final radii = tokens.radii;
    final textStyles = tokens.textStyles;

    return Material(
      type: MaterialType.transparency,
      child: InkWell(
        key: const ValueKey('vault-setup-ack-checkbox'),
        borderRadius: radii.mdRadius,
        onTap: enabled ? () => onChanged(!value) : null,
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: spacing.xxs),
          child: Row(
            children: [
              Checkbox(
                value: value,
                activeColor: colors.goldAccent,
                onChanged:
                    enabled ? (checked) => onChanged(checked ?? false) : null,
              ),
              SizedBox(width: spacing.xs),
              Expanded(
                child: Text(
                  context.l10n.vaultAcknowledgeWarningLabel,
                  style: textStyles.bodySmall.copyWith(
                    color: colors.textPrimary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
