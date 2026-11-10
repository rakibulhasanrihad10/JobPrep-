import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:job_prep/core/localization/app_localizations_extension.dart';
import 'package:job_prep/core/localization/formatters.dart';
import 'package:job_prep/core/localization/locale_controller.dart';
import 'package:job_prep/core/theme/app_theme_tokens.dart';
import 'package:job_prep/features/circulars/domain/entities/circular_exam_date.dart';
import 'package:job_prep/features/circulars/presentation/utils/circular_l10n.dart';
import 'package:job_prep/features/circulars/presentation/widgets/circular_badges.dart';

/// Solid translucent row card displaying a single scheduled [CircularExamDate]
/// with edit and delete controls.
class ExamDateTile extends ConsumerWidget {
  /// Creates an [ExamDateTile].
  const ExamDateTile({
    required this.examDate,
    required this.isPast,
    required this.onEdit,
    required this.onDelete,
    super.key,
  });

  /// Scheduled exam date record.
  final CircularExamDate examDate;

  /// Whether the scheduled exam falls before today.
  final bool isPast;

  /// Callback opening the edit dialog.
  final VoidCallback onEdit;

  /// Callback deleting this exam date row.
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tokens = context.tokens;
    final colors = tokens.colors;
    final spacing = tokens.spacing;
    final textStyles = tokens.textStyles;
    final l10n = context.l10n;
    final locale = ref.watch(localeProvider);
    final useBanglaDigits = ref.watch(useBanglaDigitsProvider);

    final formattedDate = AppFormatters.formatDate(
      examDate.examDate.toLocal(),
      locale: locale,
      pattern: 'd MMM yyyy, hh:mm a',
      useBanglaDigits: useBanglaDigits,
    );
    final venue = examDate.venue?.trim() ?? '';
    final notes = examDate.notes?.trim() ?? '';

    return Container(
      key: ValueKey('exam-date-card-${examDate.id}'),
      margin: EdgeInsets.only(bottom: spacing.sm),
      padding: spacing.insetsAllMd,
      decoration: BoxDecoration(
        color: colors.glassFillSolid,
        borderRadius: tokens.radii.buttonRadius,
        border: Border.all(
          color: isPast
              ? colors.glassBorder
              : colors.goldAccent.withValues(alpha: 0.45),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: spacing.sm,
                  vertical: spacing.xxs,
                ),
                decoration: BoxDecoration(
                  color:
                      isPast ? colors.surfaceElevated : colors.goldAccentSubtle,
                  borderRadius: tokens.radii.smRadius,
                  border: Border.all(color: colors.glassBorder),
                ),
                child: Text(
                  CircularL10n.examStageDisplayLabel(examDate.stage, l10n),
                  style: textStyles.labelMedium.copyWith(
                    color: isPast ? colors.textMuted : colors.goldAccent,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              SizedBox(width: spacing.sm),
              Expanded(
                child: Text(
                  formattedDate,
                  style: textStyles.bodyMedium.copyWith(
                    color: isPast ? colors.textSecondary : colors.textPrimary,
                  ),
                ),
              ),
              IconButton(
                key: ValueKey('exam-date-edit-${examDate.id}'),
                tooltip: l10n.examDateEditTooltip,
                onPressed: onEdit,
                icon: Icon(
                  Icons.edit_outlined,
                  size: spacing.lg,
                  color: colors.goldAccent,
                ),
              ),
              IconButton(
                key: ValueKey('exam-date-delete-${examDate.id}'),
                tooltip: l10n.examDateDeleteTooltip,
                onPressed: onDelete,
                icon: Icon(
                  Icons.delete_outline_rounded,
                  size: spacing.lg,
                  color: colors.danger,
                ),
              ),
            ],
          ),
          if (!isPast) ...[
            SizedBox(height: spacing.xs),
            CircularDeadlineCountdownBadge(
              deadline: examDate.examDate,
              showFormattedDate: false,
            ),
          ],
          if (venue.isNotEmpty) ...[
            SizedBox(height: spacing.xs),
            Row(
              children: [
                Icon(
                  Icons.location_on_outlined,
                  size: spacing.lg,
                  color: colors.textSecondary,
                ),
                SizedBox(width: spacing.xs),
                Expanded(
                  child: Text(
                    venue,
                    style: textStyles.bodySmall.copyWith(
                      color: colors.textPrimary,
                    ),
                  ),
                ),
              ],
            ),
          ],
          if (notes.isNotEmpty) ...[
            SizedBox(height: spacing.xs),
            Text(
              notes,
              style: textStyles.bodySmall.copyWith(color: colors.textSecondary),
            ),
          ],
        ],
      ),
    );
  }
}
