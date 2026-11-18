import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:job_prep/core/localization/app_localizations_extension.dart';
import 'package:job_prep/core/theme/app_theme_tokens.dart';
import 'package:job_prep/core/widgets/glass_card.dart';
import 'package:job_prep/features/prep/domain/entities/topic.dart';
import 'package:job_prep/features/prep/domain/utils/syllabus_gaps_calculator.dart';
import 'package:job_prep/features/prep/presentation/widgets/syllabus/topic_detail_sheet.dart';

/// List displaying syllabus topics that are studied but missing practice
/// or testing.
class SyllabusGapsList extends ConsumerWidget {
  /// Creates a [SyllabusGapsList].
  const SyllabusGapsList({
    required this.topics,
    required this.enabledCheckpoints,
    super.key,
  });

  /// All topics in the current subject.
  final List<Topic> topics;

  /// Checkpoints enabled for the current subject.
  final List<String> enabledCheckpoints;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tokens = context.tokens;
    final colors = tokens.colors;
    final spacing = tokens.spacing;
    final radii = tokens.radii;
    final l10n = context.l10n;

    final gaps = SyllabusGapsCalculator.findGaps(
      topics,
      enabledCheckpoints: enabledCheckpoints,
    );

    return GlassCard(
      key: const ValueKey('syllabus-gaps-list-card'),
      padding: spacing.insetsAllLg,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Icon(
                Icons.warning_amber_rounded,
                size: 20,
                color: gaps.isEmpty ? colors.success : colors.warning,
              ),
              SizedBox(width: spacing.xs),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.syllabusGapsTitle,
                      style: tokens.textStyles.titleMedium,
                    ),
                    Text(
                      l10n.syllabusGapsSubtitle,
                      style: tokens.textStyles.bodySmall.copyWith(
                        color: colors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: spacing.md),
          if (gaps.isEmpty)
            Padding(
              padding: EdgeInsets.symmetric(vertical: spacing.md),
              child: Row(
                children: [
                  Icon(
                    Icons.check_circle_outline,
                    color: colors.success,
                    size: 20,
                  ),
                  SizedBox(width: spacing.sm),
                  Expanded(
                    child: Text(
                      l10n.syllabusGapsEmpty,
                      style: tokens.textStyles.bodyMedium.copyWith(
                        color: colors.success,
                      ),
                    ),
                  ),
                ],
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: gaps.length,
              separatorBuilder: (_, __) => Divider(
                height: 1,
                color: colors.glassBorder,
              ),
              itemBuilder: (ctx, idx) {
                final gap = gaps[idx];
                return InkWell(
                  key: ValueKey('gap-topic-${gap.topic.id}'),
                  onTap: () => TopicDetailSheet.show(
                    context,
                    topic: gap.topic,
                    enabledCheckpoints: enabledCheckpoints,
                  ),
                  borderRadius: radii.smRadius,
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      vertical: spacing.sm,
                      horizontal: spacing.xs,
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            gap.topic.title,
                            style: tokens.textStyles.bodyMedium.copyWith(
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        SizedBox(width: spacing.sm),
                        if (gap.isMissingPractice)
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: spacing.xs,
                              vertical: spacing.xxs,
                            ),
                            margin: EdgeInsets.only(right: spacing.xs),
                            decoration: BoxDecoration(
                              color: colors.warning.withValues(alpha: 0.15),
                              borderRadius: radii.smRadius,
                              border: Border.all(color: colors.warning),
                            ),
                            child: Text(
                              l10n.syllabusGapNeedsPractice,
                              style: tokens.textStyles.bodySmall.copyWith(
                                color: colors.warning,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        if (gap.isMissingModelTest)
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: spacing.xs,
                              vertical: spacing.xxs,
                            ),
                            decoration: BoxDecoration(
                              color: colors.info.withValues(alpha: 0.15),
                              borderRadius: radii.smRadius,
                              border: Border.all(color: colors.info),
                            ),
                            child: Text(
                              l10n.syllabusGapNeedsModelTest,
                              style: tokens.textStyles.bodySmall.copyWith(
                                color: colors.info,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
        ],
      ),
    );
  }
}
