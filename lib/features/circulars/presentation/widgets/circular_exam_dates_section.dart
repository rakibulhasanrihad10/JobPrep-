import 'dart:async' show unawaited;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:job_prep/core/localization/app_localizations_extension.dart';
import 'package:job_prep/core/theme/app_theme_tokens.dart';
import 'package:job_prep/core/widgets/fade_slide_in.dart';
import 'package:job_prep/core/widgets/glass_button.dart';
import 'package:job_prep/core/widgets/glass_card.dart';
import 'package:job_prep/features/circulars/data/repositories/unconfigured_exam_date_repository.dart';
import 'package:job_prep/features/circulars/domain/entities/circular.dart';
import 'package:job_prep/features/circulars/domain/utils/exam_date_sorter.dart';
import 'package:job_prep/features/circulars/presentation/providers/circulars_providers.dart';
import 'package:job_prep/features/circulars/presentation/providers/exam_date_providers.dart';
import 'package:job_prep/features/circulars/presentation/utils/circular_l10n.dart';
import 'package:job_prep/features/circulars/presentation/widgets/exam_date_dialog.dart';
import 'package:job_prep/features/circulars/presentation/widgets/exam_date_tile.dart';

/// Manages and renders scheduled exam dates for [circular], ordering upcoming
/// stages soonest-first.
class CircularExamDatesSection extends ConsumerWidget {
  /// Creates a [CircularExamDatesSection].
  const CircularExamDatesSection({
    required this.circular,
    super.key,
  });

  /// Parent circular whose exam dates are displayed.
  final Circular circular;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tokens = context.tokens;
    final colors = tokens.colors;
    final spacing = tokens.spacing;
    final textStyles = tokens.textStyles;
    final l10n = context.l10n;
    final now = ref.watch(circularNowProvider)();
    final examRepo = ref.watch(examDateRepositoryProvider);
    final examDatesAsync = ref.watch(circularExamDatesProvider(circular.id));
    final mutationState = ref.watch(examDateMutationProvider);

    return GlassCard(
      key: const ValueKey('circular-detail-exam-dates-card'),
      padding: spacing.insetsAllLg,
      child: FadeSlideIn(
        index: 4,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Wrap(
              spacing: spacing.sm,
              runSpacing: spacing.sm,
              alignment: WrapAlignment.spaceBetween,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.event_available_rounded,
                      color: colors.goldAccent,
                      size: spacing.lg,
                    ),
                    SizedBox(width: spacing.sm),
                    Text(
                      l10n.circularDetailExamDatesTitle,
                      style: textStyles.titleMedium,
                    ),
                  ],
                ),
                GlassButton(
                  key: const ValueKey('detail-add-exam-date-btn'),
                  variant: GlassButtonVariant.primary,
                  onPressed: () => unawaited(
                    showExamDateDialog(context, circularId: circular.id),
                  ),
                  leading: Icon(Icons.add_rounded, size: spacing.lg),
                  child: Text(l10n.examDateAddAction),
                ),
              ],
            ),
            Divider(color: colors.glassBorder, height: spacing.xl),
            if (mutationState.hasError) ...[
              Container(
                key: const ValueKey('exam-date-mutation-error-banner'),
                margin: EdgeInsets.only(bottom: spacing.md),
                padding: spacing.insetsAllMd,
                decoration: BoxDecoration(
                  color: colors.danger.withValues(alpha: 0.14),
                  borderRadius: tokens.radii.buttonRadius,
                  border: Border.all(
                    color: colors.danger.withValues(alpha: 0.55),
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        CircularL10n.circularErrorMessage(
                          mutationState.error!,
                          l10n,
                        ),
                        style: textStyles.bodySmall.copyWith(
                          color: colors.danger,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => ref
                          .read(examDateMutationProvider.notifier)
                          .clearError(),
                      icon: Icon(Icons.close_rounded, color: colors.danger),
                    ),
                  ],
                ),
              ),
            ],
            examDatesAsync.when(
              loading: () => Center(
                child: Padding(
                  padding: spacing.insetsAllMd,
                  child: CircularProgressIndicator(color: colors.goldAccent),
                ),
              ),
              error: (error, _) => Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    CircularL10n.circularErrorMessage(error, l10n),
                    style: textStyles.bodySmall.copyWith(color: colors.danger),
                  ),
                  SizedBox(height: spacing.sm),
                  GlassButton(
                    onPressed: () => ref.invalidate(
                      circularExamDatesProvider(circular.id),
                    ),
                    child: Text(l10n.circularsRetryButton),
                  ),
                ],
              ),
              data: (fetchedDates) {
                final effectiveDates = fetchedDates.isNotEmpty ||
                        examRepo is! UnconfiguredExamDateRepository
                    ? fetchedDates
                    : circular.examDates;

                if (effectiveDates.isEmpty) {
                  return Text(
                    l10n.examDateEmptyMessage,
                    key: const ValueKey('exam-dates-empty-text'),
                    style: textStyles.bodyMedium.copyWith(
                      color: colors.textMuted,
                    ),
                  );
                }

                final grouped = partitionExamDates(effectiveDates, now: now);

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (grouped.upcoming.isNotEmpty) ...[
                      Text(
                        l10n.examDateUpcomingHeading,
                        style: textStyles.labelLarge.copyWith(
                          color: colors.goldAccent,
                        ),
                      ),
                      SizedBox(height: spacing.sm),
                      Column(
                        key: const ValueKey('exam-date-upcoming-list'),
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          for (final item in grouped.upcoming)
                            ExamDateTile(
                              examDate: item,
                              isPast: false,
                              onEdit: () => unawaited(
                                showExamDateDialog(
                                  context,
                                  circularId: circular.id,
                                  existing: item,
                                ),
                              ),
                              onDelete: () => unawaited(
                                ref
                                    .read(examDateMutationProvider.notifier)
                                    .deleteExamDate(
                                      examDateId: item.id,
                                      circularId: circular.id,
                                    ),
                              ),
                            ),
                        ],
                      ),
                    ],
                    if (grouped.past.isNotEmpty) ...[
                      if (grouped.upcoming.isNotEmpty)
                        SizedBox(height: spacing.md),
                      Text(
                        l10n.examDatePastHeading,
                        style: textStyles.labelLarge.copyWith(
                          color: colors.textMuted,
                        ),
                      ),
                      SizedBox(height: spacing.sm),
                      Column(
                        key: const ValueKey('exam-date-past-list'),
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          for (final item in grouped.past)
                            ExamDateTile(
                              examDate: item,
                              isPast: true,
                              onEdit: () => unawaited(
                                showExamDateDialog(
                                  context,
                                  circularId: circular.id,
                                  existing: item,
                                ),
                              ),
                              onDelete: () => unawaited(
                                ref
                                    .read(examDateMutationProvider.notifier)
                                    .deleteExamDate(
                                      examDateId: item.id,
                                      circularId: circular.id,
                                    ),
                              ),
                            ),
                        ],
                      ),
                    ],
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
