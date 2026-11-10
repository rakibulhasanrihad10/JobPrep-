import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:job_prep/core/localization/app_localizations_extension.dart';
import 'package:job_prep/core/localization/formatters.dart';
import 'package:job_prep/core/localization/locale_controller.dart';
import 'package:job_prep/core/theme/app_theme_tokens.dart';
import 'package:job_prep/core/widgets/glass_chip.dart';
import 'package:job_prep/features/circulars/domain/entities/circular_enums.dart';
import 'package:job_prep/features/circulars/domain/utils/deadline_countdown.dart';
import 'package:job_prep/features/circulars/presentation/providers/circulars_providers.dart';
import 'package:job_prep/features/circulars/presentation/utils/circular_l10n.dart';

/// Displays a circular's [CircularSector] using the standard rectangular
/// [GlassChip].
class CircularSectorChip extends StatelessWidget {
  /// Creates a [CircularSectorChip].
  const CircularSectorChip({
    required this.sector,
    super.key,
  });

  /// Sector enum displayed on the chip.
  final CircularSector sector;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final l10n = context.l10n;

    return GlassChip(
      padding: EdgeInsets.symmetric(
        horizontal: tokens.spacing.sm,
        vertical: tokens.spacing.xs,
      ),
      label: Text(CircularL10n.sectorLabel(sector, l10n)),
    );
  }
}

/// Color-coded deadline countdown badge reflecting green (> 7d), amber (3-7d),
/// red (< 3d or overdue), or muted (no deadline) bands.
class CircularDeadlineCountdownBadge extends ConsumerWidget {
  /// Creates a [CircularDeadlineCountdownBadge].
  const CircularDeadlineCountdownBadge({
    required this.deadline,
    super.key,
    this.showFormattedDate = true,
  });

  /// Circular deadline timestamp (`null` when unspecified).
  final DateTime? deadline;

  /// Whether to render the formatted calendar deadline above/beside the badge.
  final bool showFormattedDate;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tokens = context.tokens;
    final colors = tokens.colors;
    final spacing = tokens.spacing;
    final l10n = context.l10n;
    final locale = ref.watch(localeProvider);
    final useBanglaDigits = ref.watch(useBanglaDigitsProvider);
    final now = ref.watch(circularNowProvider)();

    final countdown = computeDeadlineCountdown(deadline, now: now);
    final bandColor = CircularL10n.deadlineBandColor(countdown.band, colors);
    final countdownText = CircularL10n.deadlineCountdownLabel(
      countdown,
      l10n,
      locale: locale,
      useBanglaDigits: useBanglaDigits,
    );

    final formattedDate = deadline != null
        ? AppFormatters.formatDate(
            now.isUtc ? deadline!.toUtc() : deadline!.toLocal(),
            locale: locale,
            pattern: 'd MMM yyyy',
            useBanglaDigits: useBanglaDigits,
          )
        : null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (showFormattedDate && formattedDate != null) ...[
          Text(
            formattedDate,
            style: tokens.textStyles.bodySmall.copyWith(
              color: colors.textSecondary,
            ),
          ),
          SizedBox(height: spacing.xs),
        ],
        Semantics(
          label: countdown.band.name,
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: spacing.sm,
              vertical: spacing.xs,
            ),
            decoration: BoxDecoration(
              color: bandColor.withValues(alpha: 0.14),
              borderRadius: tokens.radii.smRadius,
              border: Border.all(
                color: bandColor.withValues(alpha: 0.55),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  countdown.isOverdue
                      ? Icons.warning_amber_rounded
                      : Icons.schedule_rounded,
                  size: spacing.md,
                  color: bandColor,
                ),
                SizedBox(width: spacing.xs),
                Flexible(
                  child: Text(
                    countdownText,
                    style: tokens.textStyles.labelSmall.copyWith(
                      color: bandColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

/// Rectangular status badge showing workflow status alongside application
/// status and priority indicator.
class CircularStatusBadge extends StatelessWidget {
  /// Creates a [CircularStatusBadge].
  const CircularStatusBadge({
    required this.workflowStatus,
    required this.applicationStatus,
    required this.priority,
    super.key,
  });

  /// Overall tracking workflow status.
  final CircularWorkflowStatus workflowStatus;

  /// Current application progression state.
  final ApplicationStatus applicationStatus;

  /// User-assigned priority level.
  final CircularPriority priority;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final colors = tokens.colors;
    final spacing = tokens.spacing;
    final l10n = context.l10n;

    final statusColor = switch (workflowStatus) {
      CircularWorkflowStatus.inbox ||
      CircularWorkflowStatus.examUpcoming ||
      CircularWorkflowStatus.preparing =>
        colors.goldAccent,
      CircularWorkflowStatus.applied ||
      CircularWorkflowStatus.resultAwaited =>
        colors.success,
      CircularWorkflowStatus.archived => colors.textMuted,
      CircularWorkflowStatus.saved => colors.textSecondary,
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: EdgeInsets.symmetric(
            horizontal: spacing.sm,
            vertical: spacing.xs,
          ),
          decoration: BoxDecoration(
            color: statusColor.withValues(alpha: 0.12),
            borderRadius: tokens.radii.smRadius,
            border: Border.all(color: statusColor.withValues(alpha: 0.45)),
          ),
          child: Text(
            CircularL10n.workflowStatusLabel(workflowStatus, l10n),
            style: tokens.textStyles.labelSmall.copyWith(
              color: statusColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        SizedBox(height: spacing.xs),
        Text(
          CircularL10n.applicationStatusLabel(applicationStatus, l10n),
          style: tokens.textStyles.bodySmall.copyWith(
            color: colors.textSecondary,
          ),
        ),
        if (priority == CircularPriority.high ||
            priority == CircularPriority.urgent) ...[
          SizedBox(height: spacing.xxs),
          Text(
            CircularL10n.priorityLabel(priority, l10n),
            style: tokens.textStyles.labelSmall.copyWith(
              color: priority == CircularPriority.urgent
                  ? colors.danger
                  : colors.warning,
            ),
          ),
        ],
      ],
    );
  }
}
