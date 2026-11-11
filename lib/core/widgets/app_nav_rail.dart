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
import 'package:job_prep/core/widgets/glass_button.dart';
import 'package:job_prep/features/notifications/presentation/widgets/notifications_bell_button.dart';

/// Glassmorphic navigation rail for medium / tablet viewports (600 - 1024 px).
class AppNavRail extends ConsumerWidget {
  /// Creates an [AppNavRail].
  const AppNavRail({
    required this.currentItem,
    required this.onSelect,
    super.key,
    this.inboxCount = 0,
    this.onQuickCapture,
  });

  /// Currently selected navigation destination.
  final AppNavItem currentItem;

  /// Callback when a navigation destination is tapped.
  final ValueChanged<AppNavItem> onSelect;

  /// Pending quick-captured items waiting in Inbox.
  final int inboxCount;

  /// Optional callback opening the Quick Capture dialog.
  final VoidCallback? onQuickCapture;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tokens = context.tokens;
    final colors = tokens.colors;
    final spacing = tokens.spacing;
    final l10n = context.l10n;
    final reduceEffects = ref.watch(reduceEffectsProvider);

    final effectiveFill =
        reduceEffects ? colors.glassFillSolid : colors.glassFill;

    final Widget railContent = Container(
      width: 76,
      height: double.infinity,
      decoration: BoxDecoration(
        color: effectiveFill,
        border: Border(
          right: BorderSide(color: colors.glassBorder),
        ),
      ),
      child: SafeArea(
        right: false,
        child: Column(
          children: [
            SizedBox(height: spacing.md),
            // App mark
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: colors.goldAccentSubtle,
                borderRadius: tokens.radii.buttonRadius,
                border: Border.all(color: colors.glassBorder),
              ),
              child: Center(
                child: Icon(
                  Icons.auto_stories_rounded,
                  color: colors.goldAccent,
                  size: 20,
                ),
              ),
            ),
            if (onQuickCapture != null) ...[
              SizedBox(height: spacing.md),
              Tooltip(
                message: l10n.quickCaptureShortcutTooltip(
                  l10n.navShortcutBadge('Q'),
                ),
                child: Semantics(
                  button: true,
                  label: l10n.quickCaptureButton,
                  child: GlassButton(
                    key: const ValueKey('shell-quick-capture-btn'),
                    variant: GlassButtonVariant.primary,
                    padding: EdgeInsets.all(spacing.sm),
                    onPressed: onQuickCapture,
                    child: const Icon(Icons.add_link_rounded, size: 20),
                  ),
                ),
              ),
            ],
            SizedBox(height: spacing.sm),
            const NotificationsBellButton(),
            SizedBox(height: spacing.lg),
            // Navigation destination items
            Expanded(
              child: ListView(
                padding: EdgeInsets.symmetric(horizontal: spacing.xs),
                children: AppNavItem.values.map((item) {
                  return Padding(
                    padding: EdgeInsets.only(bottom: spacing.xs),
                    child: _NavRailTile(
                      item: item,
                      isSelected: item == currentItem,
                      badgeCount: item == AppNavItem.inbox ? inboxCount : 0,
                      onTap: () => onSelect(item),
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );

    if (reduceEffects) {
      return railContent;
    }

    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: railContent,
      ),
    );
  }
}

class _NavRailTile extends ConsumerStatefulWidget {
  const _NavRailTile({
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
  ConsumerState<_NavRailTile> createState() => _NavRailTileState();
}

class _NavRailTileState extends ConsumerState<_NavRailTile> {
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

    final shortcut = l10n.navShortcutBadge(
      widget.item.shortcutDigit.toString(),
    );
    final tooltipText = l10n.navShortcutTooltip(shortcut);
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

    return Tooltip(
      message: '${widget.item.label(l10n)} ($tooltipText)',
      child: MouseRegion(
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
              padding: EdgeInsets.symmetric(
                vertical: spacing.sm,
                horizontal: spacing.xs,
              ),
              decoration: BoxDecoration(
                color: backgroundColor,
                borderRadius: radii.buttonRadius,
              ),
              child: Column(
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
                    textAlign: TextAlign.center,
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
