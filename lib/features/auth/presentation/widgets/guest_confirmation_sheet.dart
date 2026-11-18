import 'package:flutter/material.dart';
import 'package:job_prep/core/localization/app_localizations_extension.dart';
import 'package:job_prep/core/theme/app_theme_tokens.dart';
import 'package:job_prep/core/widgets/glass_button.dart';

/// Shows the guest mode plain-language confirmation bottom sheet.
Future<bool> showGuestConfirmationSheet(BuildContext context) async {
  final result = await showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (ctx) => const GuestConfirmationSheet(),
  );
  return result ?? false;
}

/// Bottom sheet explaining local device storage, data loss caveats,
/// absence of sync/email reminders, and account upgrade path.
class GuestConfirmationSheet extends StatelessWidget {
  /// Creates a [GuestConfirmationSheet].
  const GuestConfirmationSheet({super.key});

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final colors = tokens.colors;
    final spacing = tokens.spacing;
    final textStyles = tokens.textStyles;
    final radii = tokens.radii;
    final l10n = context.l10n;

    return Container(
      key: const ValueKey('guest-confirmation-sheet'),
      padding: spacing.insetsAllXl,
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.vertical(
          top: radii.cardRadius.topLeft,
        ),
        border: Border(
          top: BorderSide(color: colors.glassBorder, width: 1.5),
        ),
      ),
      child: SafeArea(
        top: false,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: EdgeInsets.only(bottom: spacing.md),
                  decoration: BoxDecoration(
                    color: colors.glassBorder,
                    borderRadius: radii.buttonRadius,
                  ),
                ),
              ),
              Row(
                children: [
                  Icon(
                    Icons.phonelink_setup_rounded,
                    color: colors.goldAccent,
                    size: spacing.xl,
                  ),
                  SizedBox(width: spacing.sm),
                  Expanded(
                    child: Text(
                      l10n.guestConfirmationTitle,
                      style: textStyles.titleLarge,
                    ),
                  ),
                ],
              ),
              SizedBox(height: spacing.lg),
              _BulletRow(
                icon: Icons.devices_outlined,
                iconColor: colors.goldAccent,
                text: l10n.guestConfirmDeviceOnly,
              ),
              SizedBox(height: spacing.md),
              _BulletRow(
                icon: Icons.warning_amber_rounded,
                iconColor: colors.warning,
                text: l10n.guestConfirmDataLoss,
              ),
              SizedBox(height: spacing.md),
              _BulletRow(
                icon: Icons.cloud_off_outlined,
                iconColor: colors.textSecondary,
                text: l10n.guestConfirmNoSync,
              ),
              SizedBox(height: spacing.md),
              _BulletRow(
                icon: Icons.arrow_upward_rounded,
                iconColor: colors.success,
                text: l10n.guestConfirmMoveDataLater,
              ),
              SizedBox(height: spacing.xl),
              GlassButton(
                key: const ValueKey('guest_confirm_understand_button'),
                variant: GlassButtonVariant.primary,
                onPressed: () => Navigator.of(context).pop(true),
                child: Text(l10n.guestConfirmUnderstandButton),
              ),
              SizedBox(height: spacing.sm),
              GlassButton(
                key: const ValueKey('guest_confirm_cancel_button'),
                onPressed: () => Navigator.of(context).pop(false),
                child: Text(l10n.guestConfirmCancelButton),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BulletRow extends StatelessWidget {
  const _BulletRow({
    required this.icon,
    required this.iconColor,
    required this.text,
  });

  final IconData icon;
  final Color iconColor;
  final String text;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final spacing = tokens.spacing;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: spacing.lg, color: iconColor),
        SizedBox(width: spacing.sm),
        Expanded(
          child: Text(
            text,
            style: tokens.textStyles.bodyMedium,
          ),
        ),
      ],
    );
  }
}
