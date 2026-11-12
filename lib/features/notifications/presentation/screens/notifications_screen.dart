import 'package:flutter/material.dart';
import 'package:job_prep/core/localization/app_localizations_extension.dart';
import 'package:job_prep/core/theme/app_theme_tokens.dart';
import 'package:job_prep/features/notifications/presentation/widgets/notifications_feed_content.dart';

/// Dedicated `/notifications` route rendering the live notification inbox.
class NotificationsScreen extends StatelessWidget {
  /// Creates a [NotificationsScreen].
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final spacing = tokens.spacing;
    final breakpoints = tokens.breakpoints;
    final l10n = context.l10n;
    final width = MediaQuery.sizeOf(context).width;
    final horizontalPad =
        breakpoints.isCompact(width) ? spacing.lg : spacing.xl;

    return SingleChildScrollView(
      key: const ValueKey('notifications-screen'),
      padding: EdgeInsets.fromLTRB(
        horizontalPad,
        spacing.xl,
        horizontalPad,
        spacing.xl + spacing.xxxl,
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 840),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.notifications_outlined,
                    size: spacing.xl,
                    color: tokens.colors.goldAccent,
                  ),
                  SizedBox(width: spacing.sm),
                  Expanded(
                    child: Text(
                      l10n.notificationsPanelTitle,
                      style: tokens.textStyles.headlineMedium,
                    ),
                  ),
                ],
              ),
              SizedBox(height: spacing.lg),
              const NotificationsFeedContent(shrinkWrap: true),
            ],
          ),
        ),
      ),
    );
  }
}
