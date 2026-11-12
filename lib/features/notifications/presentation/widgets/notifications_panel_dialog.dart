import 'dart:async' show unawaited;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:job_prep/core/localization/app_localizations_extension.dart';
import 'package:job_prep/core/theme/app_theme_tokens.dart';
import 'package:job_prep/core/widgets/glass_dialog.dart';
import 'package:job_prep/features/notifications/presentation/widgets/notifications_feed_content.dart';

/// Opens the frosted-glass Notifications feed dialog and routes cleanly when
/// the user selects an alert or opens the Weekly Review screen.
Future<void> showNotificationsDialog(BuildContext context) {
  final outerRouter = GoRouter.maybeOf(context);
  return showGlassDialog<void>(
    context: context,
    builder: (dialogContext) => NotificationsPanelDialog(
      onNavigate: (route) {
        Navigator.of(dialogContext).pop();
        outerRouter?.go(route);
      },
    ),
  );
}

/// Frosted-glass dialog hosting the live notifications feed.
class NotificationsPanelDialog extends ConsumerWidget {
  /// Creates a [NotificationsPanelDialog].
  const NotificationsPanelDialog({
    required this.onNavigate,
    super.key,
  });

  /// Invoked when the user taps a notification item or opens Weekly Review.
  final ValueChanged<String> onNavigate;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final tokens = context.tokens;
    final spacing = tokens.spacing;
    final maxHeight = MediaQuery.sizeOf(context).height * 0.72;

    return GlassDialog(
      key: const ValueKey('notifications-panel-dialog'),
      maxWidth: 520,
      title: Row(
        children: [
          Icon(
            Icons.notifications_outlined,
            color: tokens.colors.goldAccent,
          ),
          SizedBox(width: spacing.sm),
          Expanded(child: Text(l10n.notificationsPanelTitle)),
          IconButton(
            key: const ValueKey('notifications-panel-close-btn'),
            visualDensity: VisualDensity.compact,
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.close_rounded),
          ),
        ],
      ),
      content: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: maxHeight),
        child: NotificationsFeedContent(
          onNavigateRoute: (route) => unawaited(
            Future<void>.microtask(() => onNavigate(route)),
          ),
        ),
      ),
    );
  }
}
