import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:job_prep/core/localization/app_localizations_extension.dart';
import 'package:job_prep/core/localization/formatters.dart';
import 'package:job_prep/core/localization/locale_controller.dart';
import 'package:job_prep/core/theme/app_theme_tokens.dart';
import 'package:job_prep/core/theme/reduce_effects_controller.dart';
import 'package:job_prep/core/widgets/app_nav_badge.dart';
import 'package:job_prep/core/widgets/app_nav_item.dart';

/// Glassmorphic bottom navigation bar for compact / mobile viewports (< 600 px).
class AppBottomNavBar extends ConsumerWidget {
  /// Creates an [AppBottomNavBar].
  const AppBottomNavBar({
    required this.currentItem,
    required this.onSelect,
    super.key,
    this.inboxCount = 0,
  });

  /// Currently selected navigation destination.
  final AppNavItem currentItem;

  /// Callback when a navigation destination is tapped.
  final ValueChanged<AppNavItem> onSelect;

  /// Pending quick-captured items waiting in Inbox.
  final int inboxCount;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tokens = context.tokens;
    final colors = tokens.colors;
    final reduceEffects = ref.watch(reduceEffectsProvider);

    final effectiveFill =
        reduceEffects ? colors.glassFillSolid : colors.glassFill;

    final Widget barContent = Container(
      decoration: BoxDecoration(
        color: effectiveFill,
        border: Border(
          top: BorderSide(color: colors.glassBorder),
        ),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 64,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: AppNavItem.values.map((item) {
              final isSelected = item == currentItem;
              return Expanded(
                child: _BottomNavItemTile(
                  item: item,
                  isSelected: isSelected,
                  badgeCount: item == AppNavItem.inbox ? inboxCount : 0,
                  onTap: () => onSelect(item),
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );

    if (reduceEffects) {
      return barContent;
    }

    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: barContent,
      ),
    );
  }
}

class _BottomNavItemTile extends ConsumerStatefulWidget {
  const _BottomNavItemTile({
    required this.item,
    required this.isSelected,
    required this.badgeCount,
    required this.onTap,
  });

  final AppNavItem item;
  final bool isSelected;
  final int badgeCount;
  final VoidCallback onTap;

  @override
  ConsumerState<_BottomNavItemTile> createState() => _BottomNavItemTileState();
}

class _BottomNavItemTileState extends ConsumerState<_BottomNavItemTile> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final colors = tokens.colors;
    final radii = tokens.radii;
    final spacing = tokens.spacing;
    final textStyles = tokens.textStyles;
    final durations = tokens.durations;
    final l10n = context.l10n;
    final locale = ref.watch(localeProvider);
    final useBanglaDigits = ref.watch(useBanglaDigitsProvider);

    final activeColor = widget.isSelected
        ? colors.goldAccent
        : (_isHovered ? colors.textPrimary : colors.textSecondary);

    final backgroundColor = widget.isSelected
        ? colors.goldAccentSubtle
        : (_isHovered ? colors.glassFillSolid : Colors.transparent);

    final semanticLabel = widget.badgeCount > 0
        ? l10n.navInboxCountSemantic(
            widget.item.label(l10n),
            AppFormatters.formatNumber(
              widget.badgeCount,
              locale: locale,
              useBanglaDigits: useBanglaDigits,
            ),
          )
        : widget.item.label(l10n);

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: Semantics(
        button: true,
        selected: widget.isSelected,
        label: semanticLabel,
        child: InkWell(
          onTap: widget.onTap,
          borderRadius: radii.buttonRadius,
          child: AnimatedContainer(
            duration: durations.fast,
            margin: EdgeInsets.symmetric(
              horizontal: spacing.xxs,
              vertical: spacing.xs,
            ),
            padding: EdgeInsets.symmetric(
              horizontal: spacing.xs,
              vertical: spacing.xxs,
            ),
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: radii.buttonRadius,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                NavIconWithBadge(
                  count: widget.badgeCount,
                  icon: Icon(
                    widget.isSelected
                        ? widget.item.selectedIcon
                        : widget.item.icon,
                    size: 22,
                    color: activeColor,
                  ),
                ),
                SizedBox(height: spacing.xxs),
                Text(
                  widget.item.label(l10n),
                  style: textStyles.bodySmall.copyWith(
                    color: activeColor,
                    fontSize: 10,
                    fontWeight:
                        widget.isSelected ? FontWeight.w600 : FontWeight.w400,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
