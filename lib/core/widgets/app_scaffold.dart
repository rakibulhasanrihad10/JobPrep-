import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:job_prep/core/localization/app_localizations_extension.dart';
import 'package:job_prep/core/theme/app_theme_tokens.dart';
import 'package:job_prep/core/widgets/app_bottom_nav_bar.dart';
import 'package:job_prep/core/widgets/app_nav_item.dart';
import 'package:job_prep/core/widgets/app_nav_rail.dart';
import 'package:job_prep/core/widgets/app_sidebar_nav.dart';
import 'package:job_prep/core/widgets/glass_button.dart';

/// Responsive application scaffold adapting between compact (< 600 px),
/// medium (600 - 1024 px), and expanded (> 1024 px) form factors.
///
/// Under 600 px: Frosted bottom navigation bar + compact quick-capture button.
/// 600 - 1024 px: Compact frosted navigation rail.
/// Above 1024 px: Permanent glass sidebar with content constrained to 1200 px
/// max width.
class AppScaffold extends StatelessWidget {
  /// Creates an [AppScaffold].
  const AppScaffold({
    required this.currentPath,
    required this.child,
    super.key,
    this.inboxCount = 0,
    this.onQuickCapture,
  });

  /// Current route path from `GoRouterState`.
  final String currentPath;

  /// Active child content / screen from `ShellRoute`.
  final Widget child;

  /// Pending quick-captured item count displayed in navigation.
  final int inboxCount;

  /// Optional callback opening the Quick Capture dialog from any screen.
  final VoidCallback? onQuickCapture;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final colors = tokens.colors;
    final spacing = tokens.spacing;
    final breakpoints = tokens.breakpoints;
    final l10n = context.l10n;
    final currentItem = AppNavItem.fromLocation(currentPath);

    void onNavigate(AppNavItem item) {
      if (item != currentItem) {
        ScaffoldMessenger.maybeOf(context)?.removeCurrentSnackBar();
        context.go(item.route);
      }
    }

    final shortcutBindings = <ShortcutActivator, VoidCallback>{};
    for (final item in AppNavItem.values) {
      shortcutBindings[SingleActivator(item.shortcutKey, alt: true)] =
          () => onNavigate(item);
      shortcutBindings[SingleActivator(item.shortcutKey, control: true)] =
          () => onNavigate(item);
    }
    if (onQuickCapture != null) {
      shortcutBindings[const SingleActivator(
        LogicalKeyboardKey.keyQ,
        alt: true,
      )] = onQuickCapture!;
      shortcutBindings[const SingleActivator(
        LogicalKeyboardKey.keyQ,
        control: true,
        shift: true,
      )] = onQuickCapture!;
      shortcutBindings[const SingleActivator(
        LogicalKeyboardKey.keyQ,
        meta: true,
        shift: true,
      )] = onQuickCapture!;
    }

    return CallbackShortcuts(
      bindings: shortcutBindings,
      child: Focus(
        autofocus: true,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final width = constraints.maxWidth;

            if (breakpoints.isCompact(width)) {
              return Scaffold(
                backgroundColor: colors.background,
                body: child,
                floatingActionButton: onQuickCapture == null
                    ? null
                    : Semantics(
                        button: true,
                        label: l10n.quickCaptureButton,
                        child: GlassButton(
                          key: const ValueKey('shell-quick-capture-btn'),
                          variant: GlassButtonVariant.primary,
                          onPressed: onQuickCapture,
                          leading: Icon(
                            Icons.add_link_rounded,
                            size: spacing.lg,
                          ),
                          child: Text(l10n.quickCaptureButton),
                        ),
                      ),
                bottomNavigationBar: AppBottomNavBar(
                  currentItem: currentItem,
                  inboxCount: inboxCount,
                  onSelect: onNavigate,
                ),
              );
            }

            if (breakpoints.isMedium(width)) {
              return Scaffold(
                backgroundColor: colors.background,
                body: Row(
                  children: [
                    AppNavRail(
                      currentItem: currentItem,
                      inboxCount: inboxCount,
                      onQuickCapture: onQuickCapture,
                      onSelect: onNavigate,
                    ),
                    Expanded(
                      child: Align(
                        alignment: Alignment.topCenter,
                        child: ConstrainedBox(
                          constraints: BoxConstraints(
                            maxWidth: breakpoints.maxContentWidth,
                          ),
                          child: child,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }

            return Scaffold(
              backgroundColor: colors.background,
              body: Row(
                children: [
                  AppSidebarNav(
                    currentItem: currentItem,
                    inboxCount: inboxCount,
                    onQuickCapture: onQuickCapture,
                    onSelect: onNavigate,
                  ),
                  Expanded(
                    child: Align(
                      alignment: Alignment.topCenter,
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          maxWidth: breakpoints.maxContentWidth,
                        ),
                        child: child,
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
