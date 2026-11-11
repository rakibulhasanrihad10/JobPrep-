import 'package:flutter/material.dart';
import 'package:job_prep/core/localization/app_localizations_extension.dart';
import 'package:job_prep/core/theme/app_colors.dart';
import 'package:job_prep/core/theme/app_theme_tokens.dart';
import 'package:job_prep/features/notifications/domain/entities/app_notification.dart';
import 'package:job_prep/features/notifications/domain/entities/notification_type.dart';

/// Card row displaying a single localized in-app notification with unread
/// accent indicator, read toggle, and delete action.
class NotificationRowCard extends StatelessWidget {
  /// Creates a [NotificationRowCard].
  const NotificationRowCard({
    required this.notification,
    required this.message,
    required this.typeLabel,
    required this.formattedDate,
    required this.colors,
    required this.onTap,
    required this.onMarkRead,
    required this.onDelete,
    super.key,
  });

  /// Notification record rendered by this row.
  final AppNotification notification;

  /// Pre-formatted localized notification message.
  final String message;

  /// Pre-formatted localized type badge label.
  final String typeLabel;

  /// Localized creation timestamp.
  final String formattedDate;

  /// Active palette tokens.
  final AppColorsToken colors;

  /// Triggered when tapping the row body to open its target route.
  final VoidCallback onTap;

  /// Marks this notification as read individually.
  final VoidCallback onMarkRead;

  /// Permanently removes this notification.
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final spacing = tokens.spacing;
    final radii = tokens.radii;
    final l10n = context.l10n;
    final accent = _accentColor(notification.type);
    final isUnread = notification.isUnread;

    return Container(
      key: ValueKey('notification-item-${notification.id}'),
      decoration: BoxDecoration(
        color: isUnread ? colors.goldAccentSubtle : colors.surfaceElevated,
        borderRadius: radii.cardRadius,
        border: Border.all(
          color: isUnread
              ? colors.goldAccent.withValues(alpha: 0.55)
              : colors.glassBorder,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: radii.cardRadius,
        child: InkWell(
          borderRadius: radii.cardRadius,
          onTap: onTap,
          child: Padding(
            padding: spacing.insetsAllMd,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Icon(
                      _iconFor(notification.type),
                      size: spacing.lg,
                      color: accent,
                    ),
                    SizedBox(width: spacing.xs),
                    Expanded(
                      child: Wrap(
                        spacing: spacing.xs,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          Text(
                            typeLabel,
                            style: tokens.textStyles.labelMedium.copyWith(
                              color: accent,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          if (isUnread)
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: spacing.xs,
                                vertical: spacing.xxs,
                              ),
                              decoration: BoxDecoration(
                                color: colors.goldAccentSubtle,
                                borderRadius: radii.smRadius,
                                border: Border.all(color: colors.goldAccent),
                              ),
                              child: Text(
                                l10n.notificationsUnreadBadge,
                                style: tokens.textStyles.labelSmall.copyWith(
                                  color: colors.goldAccent,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                    if (isUnread)
                      IconButton(
                        key: ValueKey(
                          'notification-mark-read-${notification.id}',
                        ),
                        tooltip: l10n.notificationsMarkReadTooltip,
                        visualDensity: VisualDensity.compact,
                        onPressed: onMarkRead,
                        icon: Icon(
                          Icons.mark_email_read_outlined,
                          size: spacing.lg,
                        ),
                      ),
                    IconButton(
                      key: ValueKey('notification-delete-${notification.id}'),
                      tooltip: l10n.notificationsDeleteTooltip,
                      visualDensity: VisualDensity.compact,
                      onPressed: onDelete,
                      icon: Icon(
                        Icons.delete_outline_rounded,
                        size: spacing.lg,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: spacing.xs),
                Text(
                  message,
                  style: tokens.textStyles.bodyMedium.copyWith(
                    color: colors.textPrimary,
                    fontWeight: isUnread ? FontWeight.w600 : FontWeight.w400,
                  ),
                ),
                SizedBox(height: spacing.xs),
                Text(
                  formattedDate,
                  style: tokens.textStyles.labelSmall,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  IconData _iconFor(AppNotificationType type) {
    return switch (type) {
      AppNotificationType.deadlineSoon => Icons.event_available_outlined,
      AppNotificationType.examSoon => Icons.school_outlined,
      AppNotificationType.revisionDue => Icons.history_edu_outlined,
      AppNotificationType.behindSchedule => Icons.trending_down_rounded,
      AppNotificationType.weeklyReview => Icons.insights_outlined,
    };
  }

  Color _accentColor(AppNotificationType type) {
    return switch (type) {
      AppNotificationType.deadlineSoon => colors.warning,
      AppNotificationType.examSoon => colors.danger,
      AppNotificationType.revisionDue => colors.info,
      AppNotificationType.behindSchedule => colors.warning,
      AppNotificationType.weeklyReview => colors.goldAccent,
    };
  }
}
