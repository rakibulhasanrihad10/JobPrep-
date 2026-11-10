import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:job_prep/l10n/app_localizations.dart';

/// Top-level navigation items supported across mobile, tablet, and
/// desktop shells.
enum AppNavItem {
  /// Dashboard screen with overview metrics and activity.
  dashboard(
    route: '/dashboard',
    icon: Icons.space_dashboard_outlined,
    selectedIcon: Icons.space_dashboard,
    shortcutDigit: 1,
    shortcutKey: LogicalKeyboardKey.digit1,
  ),

  /// Circulars screen for tracking job circulars.
  circulars(
    route: '/circulars',
    icon: Icons.work_outline,
    selectedIcon: Icons.work,
    shortcutDigit: 2,
    shortcutKey: LogicalKeyboardKey.digit2,
  ),

  /// Exam preparation tracking and subject syllabi.
  prep(
    route: '/prep',
    icon: Icons.menu_book_outlined,
    selectedIcon: Icons.menu_book,
    shortcutDigit: 3,
    shortcutKey: LogicalKeyboardKey.digit3,
  ),

  /// Exam calendar and deadlines.
  calendar(
    route: '/calendar',
    icon: Icons.calendar_month_outlined,
    selectedIcon: Icons.calendar_month,
    shortcutDigit: 4,
    shortcutKey: LogicalKeyboardKey.digit4,
  ),

  /// Application settings and preferences.
  settings(
    route: '/settings',
    icon: Icons.settings_outlined,
    selectedIcon: Icons.settings,
    shortcutDigit: 5,
    shortcutKey: LogicalKeyboardKey.digit5,
  ),

  /// Quick-captured circulars awaiting triage.
  inbox(
    route: '/inbox',
    icon: Icons.inbox_outlined,
    selectedIcon: Icons.inbox_rounded,
    shortcutDigit: 6,
    shortcutKey: LogicalKeyboardKey.digit6,
  );

  const AppNavItem({
    required this.route,
    required this.icon,
    required this.selectedIcon,
    required this.shortcutDigit,
    required this.shortcutKey,
  });

  /// Target route path in `GoRouter`.
  final String route;

  /// Inactive outlined icon.
  final IconData icon;

  /// Active solid icon.
  final IconData selectedIcon;

  /// Numerical digit index (1-based) for keyboard shortcuts.
  final int shortcutDigit;

  /// Logical keyboard key for web shortcuts.
  final LogicalKeyboardKey shortcutKey;

  /// Resolves the localized display label.
  String label(AppLocalizations l10n) {
    switch (this) {
      case AppNavItem.dashboard:
        return l10n.navDashboard;
      case AppNavItem.circulars:
        return l10n.navCirculars;
      case AppNavItem.prep:
        return l10n.navPrep;
      case AppNavItem.calendar:
        return l10n.navCalendar;
      case AppNavItem.settings:
        return l10n.navSettings;
      case AppNavItem.inbox:
        return l10n.navInbox;
    }
  }

  /// Finds the navigation item matching the current [location] URL path.
  static AppNavItem fromLocation(String location) {
    for (final item in AppNavItem.values) {
      if (location == item.route || location.startsWith('${item.route}/')) {
        return item;
      }
    }
    return AppNavItem.dashboard;
  }
}
