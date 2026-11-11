import 'dart:async' show unawaited;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:job_prep/core/localization/app_localizations_extension.dart';
import 'package:job_prep/core/localization/formatters.dart';
import 'package:job_prep/core/localization/locale_controller.dart';
import 'package:job_prep/core/theme/app_theme_tokens.dart';
import 'package:job_prep/core/theme/reduce_effects_controller.dart';
import 'package:job_prep/features/notifications/presentation/providers/notifications_providers.dart';
import 'package:job_prep/features/notifications/presentation/widgets/notifications_panel_dialog.dart';

/// App-shell notification bell with a live unread count badge.
class NotificationsBellButton extends ConsumerWidget {
  /// Creates a [NotificationsBellButton].
  const NotificationsBellButton({
    super.key,
    this.compact = true,
    this.onPressed,
  });

  /// Renders condensed padding suitable for navigation bars and rails.
  final bool compact;

  /// Optional override callback; defaults to opening [showNotificationsDialog].
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final unreadCount = ref.watch(unreadNotificationsCountProvider);
    final tokens = context.tokens;
    final colors = tokens.colors;
    final radii = tokens.radii;
    final spacing = tokens.spacing;
    final reduceEffects = ref.watch(reduceEffectsProvider);
    final l10n = context.l10n;
    final locale = ref.watch(localeProvider);
    final useBanglaDigits = ref.watch(useBanglaDigitsProvider);

    final maxBadgeNum = AppFormatters.formatNumber(
      99,
      locale: locale,
      useBanglaDigits: useBanglaDigits,
    );
    final formattedBadge = unreadCount > 99
        ? '$maxBadgeNum+'
        : AppFormatters.formatNumber(
            unreadCount,
            locale: locale,
            useBanglaDigits: useBanglaDigits,
          );
    final semanticsLabel = unreadCount > 0
        ? l10n.notificationsBellUnreadSemantics(formattedBadge)
        : l10n.notificationsBellTooltip;

    final fill = reduceEffects ? colors.glassFillSolid : colors.glassFill;

    return Semantics(
      button: true,
      label: semanticsLabel,
      child: Tooltip(
        message: semanticsLabel,
        child: Material(
          color: fill,
          borderRadius: radii.buttonRadius,
          child: InkWell(
            key: const ValueKey('shell-notifications-bell-btn'),
            borderRadius: radii.buttonRadius,
            onTap:
                onPressed ?? () => unawaited(showNotificationsDialog(context)),
            child: Container(
              padding: EdgeInsets.all(compact ? spacing.sm : spacing.md),
              decoration: BoxDecoration(
                borderRadius: radii.buttonRadius,
                border: Border.all(
                  color:
                      unreadCount > 0 ? colors.goldAccent : colors.glassBorder,
                ),
              ),
              child: Stack(
                clipBehavior: Clip.none,
                alignment: Alignment.center,
                children: [
                  Icon(
                    unreadCount > 0
                        ? Icons.notifications_active_outlined
                        : Icons.notifications_none_rounded,
                    size: tokens.textStyles.titleLarge.fontSize,
                    color: unreadCount > 0
                        ? colors.goldAccent
                        : colors.textSecondary,
                  ),
                  if (unreadCount > 0)
                    Positioned(
                      top: -spacing.xs,
                      right: -spacing.xs,
                      child: Container(
                        key: const ValueKey(
                          'shell-notifications-unread-badge',
                        ),
                        padding: EdgeInsets.symmetric(
                          horizontal: spacing.xs,
                          vertical: spacing.xxs,
                        ),
                        decoration: BoxDecoration(
                          color: colors.background,
                          borderRadius: radii.buttonRadius,
                          border: Border.all(color: colors.goldAccent),
                        ),
                        child: Text(
                          formattedBadge,
                          style: tokens.textStyles.labelSmall.copyWith(
                            color: colors.goldAccent,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
