import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:job_prep/core/localization/formatters.dart';
import 'package:job_prep/core/localization/locale_controller.dart';
import 'package:job_prep/core/theme/app_theme_tokens.dart';

/// Compact rectangular gold badge displaying the formatted pending Inbox count.
class NavInboxCountBadge extends ConsumerWidget {
  /// Creates a [NavInboxCountBadge].
  const NavInboxCountBadge({
    required this.count,
    super.key,
    this.compact = false,
  });

  /// Pending item count displayed inside the badge.
  final int count;

  /// Uses tighter padding suitable for overlaying nav rail or bottom bar icons.
  final bool compact;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tokens = context.tokens;
    final colors = tokens.colors;
    final spacing = tokens.spacing;
    final textStyles = tokens.textStyles;
    final locale = ref.watch(localeProvider);
    final useBanglaDigits = ref.watch(useBanglaDigitsProvider);

    final formatted = count > 99
        ? '${AppFormatters.formatNumber(
            99,
            locale: locale,
            useBanglaDigits: useBanglaDigits,
          )}+'
        : AppFormatters.formatNumber(
            count,
            locale: locale,
            useBanglaDigits: useBanglaDigits,
          );

    return Container(
      key: const ValueKey('nav-inbox-count-badge'),
      padding: EdgeInsets.symmetric(
        horizontal: compact ? spacing.xs : spacing.sm,
        vertical: compact ? spacing.xxs / 2 : spacing.xxs,
      ),
      decoration: BoxDecoration(
        color: colors.goldAccent,
        borderRadius: tokens.radii.smRadius,
      ),
      child: Text(
        formatted,
        style: textStyles.labelSmall.copyWith(
          color: colors.background,
          fontWeight: FontWeight.w700,
          height: 1.1,
        ),
      ),
    );
  }
}

/// Icon wrapper overlaying [NavInboxCountBadge] on top-right when [count] > 0.
class NavIconWithBadge extends StatelessWidget {
  /// Creates a [NavIconWithBadge].
  const NavIconWithBadge({
    required this.icon,
    required this.count,
    super.key,
  });

  /// Base navigation icon.
  final Widget icon;

  /// Pending count badge (`0` hides the badge).
  final int count;

  @override
  Widget build(BuildContext context) {
    if (count <= 0) return icon;

    final spacing = context.tokens.spacing;
    return Stack(
      clipBehavior: Clip.none,
      children: [
        icon,
        Positioned(
          top: -spacing.xs,
          right: -spacing.md,
          child: NavInboxCountBadge(count: count, compact: true),
        ),
      ],
    );
  }
}
