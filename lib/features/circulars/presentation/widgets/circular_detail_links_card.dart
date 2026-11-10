import 'dart:async' show unawaited;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:job_prep/core/localization/app_localizations_extension.dart';
import 'package:job_prep/core/theme/app_theme_tokens.dart';
import 'package:job_prep/core/widgets/fade_slide_in.dart';
import 'package:job_prep/core/widgets/glass_button.dart';
import 'package:job_prep/core/widgets/glass_card.dart';
import 'package:job_prep/features/circulars/domain/entities/circular.dart';
import 'package:job_prep/features/circulars/domain/validators/circular_form_validators.dart';
import 'package:job_prep/features/circulars/presentation/providers/url_launcher_provider.dart';

/// External link launch buttons for original circular URL, application portal,
/// and organization website.
class CircularDetailLinksCard extends ConsumerWidget {
  /// Creates a [CircularDetailLinksCard].
  const CircularDetailLinksCard({
    required this.circular,
    super.key,
  });

  /// Active circular holding optional external URLs.
  final Circular circular;

  Future<void> _openUrl(
    BuildContext context,
    WidgetRef ref,
    String rawUrl,
  ) async {
    final l10n = context.l10n;
    final messenger = ScaffoldMessenger.maybeOf(context);
    final uri = Uri.tryParse(rawUrl.trim());
    if (uri == null ||
        CircularFormValidators.validateOptionalUrl(rawUrl) != null) {
      messenger?.showSnackBar(
        SnackBar(content: Text(l10n.circularDetailLaunchFailed)),
      );
      return;
    }

    try {
      final launched = await ref.read(circularUrlLauncherProvider)(uri);
      if (!launched && context.mounted) {
        ScaffoldMessenger.maybeOf(context)?.showSnackBar(
          SnackBar(content: Text(l10n.circularDetailLaunchFailed)),
        );
      }
    } on Object {
      if (context.mounted) {
        ScaffoldMessenger.maybeOf(context)?.showSnackBar(
          SnackBar(content: Text(l10n.circularDetailLaunchFailed)),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tokens = context.tokens;
    final colors = tokens.colors;
    final spacing = tokens.spacing;
    final textStyles = tokens.textStyles;
    final l10n = context.l10n;

    return GlassCard(
      key: const ValueKey('circular-detail-links-card'),
      padding: spacing.insetsAllLg,
      child: FadeSlideIn(
        index: 2,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Icon(
                  Icons.link_rounded,
                  color: colors.goldAccent,
                  size: spacing.lg,
                ),
                SizedBox(width: spacing.sm),
                Expanded(
                  child: Text(
                    l10n.circularDetailLinksTitle,
                    style: textStyles.titleMedium,
                  ),
                ),
              ],
            ),
            Divider(color: colors.glassBorder, height: spacing.xl),
            Wrap(
              spacing: spacing.sm,
              runSpacing: spacing.sm,
              children: [
                _LinkLaunchTile(
                  buttonKey: const ValueKey('detail-open-circular-url'),
                  label: l10n.circularDetailOpenCircularLink,
                  icon: Icons.description_outlined,
                  rawUrl: circular.circularUrl,
                  onOpen: (url) => unawaited(_openUrl(context, ref, url)),
                ),
                _LinkLaunchTile(
                  buttonKey: const ValueKey('detail-open-application-url'),
                  label: l10n.circularDetailOpenApplicationPortal,
                  icon: Icons.open_in_new_rounded,
                  rawUrl: circular.applicationUrl,
                  onOpen: (url) => unawaited(_openUrl(context, ref, url)),
                ),
                _LinkLaunchTile(
                  buttonKey: const ValueKey('detail-open-org-website'),
                  label: l10n.circularDetailOpenOrgWebsite,
                  icon: Icons.public_rounded,
                  rawUrl: circular.organizationWebsite,
                  onOpen: (url) => unawaited(_openUrl(context, ref, url)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _LinkLaunchTile extends StatelessWidget {
  const _LinkLaunchTile({
    required this.buttonKey,
    required this.label,
    required this.icon,
    required this.rawUrl,
    required this.onOpen,
  });

  final Key buttonKey;
  final String label;
  final IconData icon;
  final String? rawUrl;
  final ValueChanged<String> onOpen;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final colors = tokens.colors;
    final spacing = tokens.spacing;
    final l10n = context.l10n;

    final trimmed = rawUrl?.trim() ?? '';
    final isValid = trimmed.isNotEmpty &&
        CircularFormValidators.validateOptionalUrl(trimmed) == null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        GlassButton(
          key: buttonKey,
          variant: isValid
              ? GlassButtonVariant.primary
              : GlassButtonVariant.standard,
          onPressed: isValid ? () => onOpen(trimmed) : null,
          leading: Icon(icon, size: spacing.lg),
          child: Text(label),
        ),
        SizedBox(height: spacing.xs),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 260),
          child: Text(
            isValid ? trimmed : l10n.circularDetailLinkMissing,
            style: tokens.textStyles.bodySmall.copyWith(
              color: isValid ? colors.textSecondary : colors.textMuted,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
