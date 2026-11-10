import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:job_prep/core/theme/app_theme_tokens.dart';
import 'package:job_prep/core/widgets/app_bottom_nav_bar.dart';
import 'package:job_prep/core/widgets/app_nav_item.dart';
import 'package:job_prep/core/widgets/app_nav_rail.dart';
import 'package:job_prep/core/widgets/app_sidebar_nav.dart';

/// Responsive application scaffold adapting between compact (< 600 px),
/// medium (600 - 1024 px), and expanded (> 1024 px) form factors.
///
/// Under 600 px: Frosted bottom navigation bar.
/// 600 - 1024 px: Compact frosted navigation rail.
/// Above 1024 px: Permanent glass sidebar with content constrained to 1200 px
/// max width.
class AppScaffold extends StatelessWidget {
  /// Creates an [AppScaffold].
  const AppScaffold({
    required this.currentPath,
    required this.child,
    super.key,
  });

  /// Current route path from `GoRouterState`.
  final String currentPath;

  /// Active child content / screen from `ShellRoute`.
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final colors = tokens.colors;
    final breakpoints = tokens.breakpoints;
    final currentItem = AppNavItem.fromLocation(currentPath);

    void onNavigate(AppNavItem item) {
      if (item != currentItem) {
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
                bottomNavigationBar: AppBottomNavBar(
                  currentItem: currentItem,
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
