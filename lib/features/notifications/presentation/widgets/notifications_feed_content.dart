import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:job_prep/core/localization/app_localizations_extension.dart';
import 'package:job_prep/core/localization/formatters.dart';
import 'package:job_prep/core/localization/locale_controller.dart';
import 'package:job_prep/core/theme/app_theme_tokens.dart';
import 'package:job_prep/core/widgets/glass_button.dart';
import 'package:job_prep/core/widgets/glass_card.dart';
import 'package:job_prep/features/notifications/domain/entities/app_notification.dart';
import 'package:job_prep/features/notifications/presentation/providers/notifications_providers.dart';
import 'package:job_prep/features/notifications/presentation/utils/notification_message_formatter.dart';
import 'package:job_prep/features/notifications/presentation/widgets/notification_row_card.dart';

/// Interactive notifications list with in-app delivery notice, mark read,
/// mark all read, delete, and route navigation.
class NotificationsFeedContent extends ConsumerWidget {
  /// Creates a [NotificationsFeedContent].
  const NotificationsFeedContent({
    super.key,
    this.onNavigateRoute,
    this.shrinkWrap = false,
  });

  /// Optional callback fired after navigating to a notification target route
  /// (for example to close a modal panel).
  final ValueChanged<String>? onNavigateRoute;

  /// Whether to render without inner vertical scroll expansion (when inside
  /// a scrollable screen rather than a bounded dialog).
  final bool shrinkWrap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tokens = context.tokens;
    final colors = tokens.colors;
    final spacing = tokens.spacing;
    final radii = tokens.radii;
    final l10n = context.l10n;
    final locale = ref.watch(localeProvider);
    final useBanglaDigits = ref.watch(useBanglaDigitsProvider);
    final notificationsAsync = ref.watch(notificationsProvider);
    final items = notificationsAsync.asData?.value ?? const <AppNotification>[];
    final unreadCount = items.where((item) => item.isUnread).length;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          key: const ValueKey('notifications-in-app-notice'),
          padding: spacing.insetsAllMd,
          decoration: BoxDecoration(
            color: colors.surfaceElevated,
            borderRadius: radii.cardRadius,
            border: Border.all(color: colors.glassBorder),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                Icons.info_outline_rounded,
                size: spacing.lg,
                color: colors.goldAccent,
              ),
              SizedBox(width: spacing.sm),
              Expanded(
                child: Text(
                  l10n.notificationsInAppNotice,
                  style: tokens.textStyles.bodySmall,
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: spacing.md),
        Wrap(
          spacing: spacing.sm,
          runSpacing: spacing.sm,
          alignment: WrapAlignment.spaceBetween,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            GlassButton(
              key: const ValueKey('notifications-open-weekly-review-btn'),
              onPressed: () {
                if (onNavigateRoute != null) {
                  onNavigateRoute!('/weekly-review');
                } else {
                  GoRouter.maybeOf(context)?.go('/weekly-review');
                }
              },
              leading: Icon(
                Icons.insights_outlined,
                size: spacing.lg,
                color: colors.goldAccent,
              ),
              child: Text(l10n.notificationsOpenWeeklyReviewChip),
            ),
            if (unreadCount > 0)
              TextButton.icon(
                key: const ValueKey('notifications-mark-all-read-btn'),
                onPressed: () => unawaited(_handleMarkAllRead(context, ref)),
                icon: Icon(Icons.done_all_rounded, size: spacing.lg),
                label: Text(l10n.notificationsMarkAllReadButton),
              ),
          ],
        ),
        SizedBox(height: spacing.md),
        if (notificationsAsync.isLoading && !notificationsAsync.hasValue)
          Padding(
            padding: EdgeInsets.symmetric(vertical: spacing.xl),
            child: const Center(child: CircularProgressIndicator()),
          )
        else if (items.isEmpty)
          GlassCard(
            key: const ValueKey('notifications-empty-state'),
            padding: spacing.insetsAllLg,
            child: Column(
              children: [
                Icon(
                  Icons.notifications_none_rounded,
                  size: spacing.xxl,
                  color: colors.textMuted,
                ),
                SizedBox(height: spacing.sm),
                Text(
                  l10n.notificationsEmptyTitle,
                  style: tokens.textStyles.titleMedium,
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: spacing.xs),
                Text(
                  l10n.notificationsEmptyBody,
                  style: tokens.textStyles.bodySmall,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          )
        else if (shrinkWrap)
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (var i = 0; i < items.length; i++) ...[
                if (i > 0) SizedBox(height: spacing.sm),
                _buildRow(context, ref, items[i], locale, useBanglaDigits),
              ],
            ],
          )
        else
          Flexible(
            child: ListView.separated(
              shrinkWrap: true,
              itemCount: items.length,
              separatorBuilder: (_, __) => SizedBox(height: spacing.sm),
              itemBuilder: (context, index) => _buildRow(
                context,
                ref,
                items[index],
                locale,
                useBanglaDigits,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildRow(
    BuildContext context,
    WidgetRef ref,
    AppNotification item,
    Locale locale,
    bool useBanglaDigits,
  ) {
    final l10n = context.l10n;
    return NotificationRowCard(
      notification: item,
      message: NotificationMessageFormatter.formatMessage(
        notification: item,
        l10n: l10n,
        locale: locale,
        useBanglaDigits: useBanglaDigits,
      ),
      typeLabel: NotificationMessageFormatter.typeLabel(item.type, l10n),
      formattedDate: AppFormatters.formatDate(
        item.createdAt.toLocal(),
        locale: locale,
        pattern: 'd MMM, HH:mm',
        useBanglaDigits: useBanglaDigits,
      ),
      colors: context.tokens.colors,
      onTap: () => unawaited(_handleTap(context, ref, item)),
      onMarkRead: () => unawaited(_handleMarkRead(context, ref, item.id)),
      onDelete: () => unawaited(_handleDelete(context, ref, item.id)),
    );
  }

  Future<void> _handleTap(
    BuildContext context,
    WidgetRef ref,
    AppNotification notification,
  ) async {
    if (notification.isUnread) {
      await ref
          .read(notificationsProvider.notifier)
          .markAsRead(notification.id);
    }
    if (!context.mounted) return;
    if (onNavigateRoute != null) {
      onNavigateRoute!(notification.route);
    } else {
      GoRouter.maybeOf(context)?.go(notification.route);
    }
  }

  Future<void> _handleMarkRead(
    BuildContext context,
    WidgetRef ref,
    String id,
  ) async {
    final ok = await ref.read(notificationsProvider.notifier).markAsRead(id);
    if (!ok && context.mounted) {
      _showError(context);
    }
  }

  Future<void> _handleMarkAllRead(
    BuildContext context,
    WidgetRef ref,
  ) async {
    final ok = await ref.read(notificationsProvider.notifier).markAllAsRead();
    if (!ok && context.mounted) {
      _showError(context);
    }
  }

  Future<void> _handleDelete(
    BuildContext context,
    WidgetRef ref,
    String id,
  ) async {
    final ok =
        await ref.read(notificationsProvider.notifier).deleteNotification(id);
    if (!ok && context.mounted) {
      _showError(context);
    }
  }

  void _showError(BuildContext context) {
    final l10n = context.l10n;
    ScaffoldMessenger.maybeOf(context)?.showSnackBar(
      SnackBar(content: Text(l10n.notificationsSaveError)),
    );
  }
}
