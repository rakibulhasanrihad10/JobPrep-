import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:job_prep/core/localization/app_localizations_extension.dart';
import 'package:job_prep/core/localization/formatters.dart';
import 'package:job_prep/core/localization/locale_controller.dart';
import 'package:job_prep/core/theme/app_theme_tokens.dart';
import 'package:job_prep/core/widgets/app_nav_badge.dart';
import 'package:job_prep/core/widgets/app_nav_item.dart';
import 'package:job_prep/core/widgets/glass_button.dart';
import 'package:job_prep/core/widgets/glass_sidebar.dart';

/// Permanent glass sidebar navigation for expanded / desktop viewports (> 1024 px).
class AppSidebarNav extends StatelessWidget {
  /// Creates an [AppSidebarNav].
  const AppSidebarNav({
    required this.currentItem,
    required this.onSelect,
    super.key,
    this.width = 260.0,
    this.inboxCount = 0,
    this.onQuickCapture,
  });

  /// Currently selected navigation destination.
  final AppNavItem currentItem;

  /// Callback when a navigation destination is clicked.
  final ValueChanged<AppNavItem> onSelect;

  /// Sidebar width.
  final double width;

  /// Pending quick-captured items waiting in Inbox.
  final int inboxCount;

  /// Optional callback opening the Quick Capture dialog.
  final VoidCallback? onQuickCapture;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final colors = tokens.colors;
    final spacing = tokens.spacing;
    final textStyles = tokens.textStyles;
    final l10n = context.l10n;

    return GlassSidebar(
      width: width,
      header: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
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
              SizedBox(width: spacing.sm),
              Expanded(
                child: Text(
                  l10n.appTitle,
                  style: textStyles.titleLarge.copyWith(
                    fontWeight: FontWeight.w700,
                    color: colors.textPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          if (onQuickCapture != null) ...[
            SizedBox(height: spacing.md),
            Tooltip(
              message: l10n.quickCaptureShortcutTooltip(
                l10n.navShortcutBadge('Q'),
              ),
              child: GlassButton(
                key: const ValueKey('shell-quick-capture-btn'),
                variant: GlassButtonVariant.primary,
                width: double.infinity,
                onPressed: onQuickCapture,
                leading: Icon(Icons.add_link_rounded, size: spacing.lg),
                child: Text(
                  l10n.quickCaptureButton,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          ],
        ],
      ),
      children: AppNavItem.values.map((item) {
        return Padding(
          padding: EdgeInsets.only(bottom: spacing.xs),
          child: _SidebarNavTile(
            item: item,
            isSelected: item == currentItem,
            badgeCount: item == AppNavItem.inbox ? inboxCount : 0,
            onTap: () => onSelect(item),
          ),
        );
      }).toList(),
    );
  }
}

class _SidebarNavTile extends ConsumerStatefulWidget {
  const _SidebarNavTile({
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
  ConsumerState<_SidebarNavTile> createState() => _SidebarNavTileState();
}

class _SidebarNavTileState extends ConsumerState<_SidebarNavTile> {
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

    final borderColor =
        widget.isSelected ? colors.glassBorder : Colors.transparent;

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
            padding: EdgeInsets.symmetric(
              horizontal: spacing.md,
              vertical: spacing.sm,
            ),
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: radii.buttonRadius,
              border: Border.all(color: borderColor),
            ),
            child: Row(
              children: [
                Icon(
                  widget.isSelected
                      ? widget.item.selectedIcon
                      : widget.item.icon,
                  size: 20,
                  color: activeColor,
                ),
                SizedBox(width: spacing.sm),
                Expanded(
                  child: Text(
                    widget.item.label(l10n),
                    style: textStyles.bodyMedium.copyWith(
                      color: activeColor,
                      fontWeight:
                          widget.isSelected ? FontWeight.w600 : FontWeight.w400,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (widget.badgeCount > 0) ...[
                  NavInboxCountBadge(count: widget.badgeCount),
                  SizedBox(width: spacing.xs),
                ],
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: spacing.xs,
                    vertical: spacing.xxs,
                  ),
                  decoration: BoxDecoration(
                    color: colors.surfaceElevated,
                    borderRadius: radii.smRadius,
                    border: Border.all(color: colors.glassBorder),
                  ),
                  child: Text(
                    l10n.navShortcutBadge(widget.item.shortcutDigit.toString()),
                    style: textStyles.bodySmall.copyWith(
                      color: colors.textMuted,
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
