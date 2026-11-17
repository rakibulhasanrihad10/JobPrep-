import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:job_prep/core/localization/app_localizations_extension.dart';
import 'package:job_prep/core/localization/formatters.dart';
import 'package:job_prep/core/localization/locale_controller.dart';
import 'package:job_prep/core/theme/app_theme_tokens.dart';
import 'package:job_prep/core/widgets/glass_card.dart';
import 'package:job_prep/features/prep/domain/entities/topic.dart';
import 'package:job_prep/features/prep/domain/utils/syllabus_progress_calculator.dart';
import 'package:job_prep/features/prep/presentation/widgets/syllabus/topic_detail_sheet.dart';

/// Grid of topics colored by completion percentage level.
class SyllabusTopicGrid extends ConsumerWidget {
  /// Creates a [SyllabusTopicGrid].
  const SyllabusTopicGrid({
    required this.topics,
    required this.enabledCheckpoints,
    super.key,
  });

  /// All topics in the subject.
  final List<Topic> topics;

  /// Checkpoints configured for the subject.
  final List<String> enabledCheckpoints;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tokens = context.tokens;
    final colors = tokens.colors;
    final spacing = tokens.spacing;
    final radii = tokens.radii;
    final l10n = context.l10n;
    final locale = ref.watch(localeProvider);
    final useBanglaDigits = ref.watch(useBanglaDigitsProvider);

    if (topics.isEmpty) {
      return const SizedBox.shrink();
    }

    return GlassCard(
      key: const ValueKey('syllabus-topic-grid-card'),
      padding: spacing.insetsAllLg,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Icon(Icons.grid_view_rounded, size: 20, color: colors.goldAccent),
              SizedBox(width: spacing.xs),
              Text(
                l10n.syllabusTopicGridTitle,
                style: tokens.textStyles.titleMedium,
              ),
            ],
          ),
          SizedBox(height: spacing.md),
          Wrap(
            spacing: spacing.sm,
            runSpacing: spacing.sm,
            children: topics.map((topic) {
              final progress =
                  SyllabusProgressCalculator.calculateTopicProgress(
                topic: topic,
                enabledCheckpoints: enabledCheckpoints,
              );
              final pct = (progress * 100).round();

              Color borderColor;
              Color bgTint;
              if (progress >= 1.0) {
                borderColor = colors.success;
                bgTint = colors.success.withValues(alpha: 0.15);
              } else if (progress >= 0.5) {
                borderColor = colors.info;
                bgTint = colors.info.withValues(alpha: 0.15);
              } else if (progress > 0) {
                borderColor = colors.warning;
                bgTint = colors.warning.withValues(alpha: 0.12);
              } else {
                borderColor = colors.glassBorder;
                bgTint = colors.surfaceElevated;
              }

              final pctLabel = AppFormatters.formatNumber(
                pct,
                locale: locale,
                useBanglaDigits: useBanglaDigits,
              );

              return InkWell(
                key: ValueKey('grid-topic-${topic.id}'),
                onTap: () => TopicDetailSheet.show(
                  context,
                  topic: topic,
                  enabledCheckpoints: enabledCheckpoints,
                ),
                borderRadius: radii.smRadius,
                child: Container(
                  constraints:
                      const BoxConstraints(minWidth: 120, maxWidth: 180),
                  padding: EdgeInsets.symmetric(
                    horizontal: spacing.sm,
                    vertical: spacing.xs,
                  ),
                  decoration: BoxDecoration(
                    color: bgTint,
                    borderRadius: radii.smRadius,
                    border: Border.all(color: borderColor, width: 1.5),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        topic.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: tokens.textStyles.labelMedium.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: spacing.xxs),
                      Text(
                        '$pctLabel%',
                        style: tokens.textStyles.bodySmall.copyWith(
                          color: colors.textSecondary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
