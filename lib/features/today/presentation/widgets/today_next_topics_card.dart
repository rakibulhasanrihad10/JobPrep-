import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:job_prep/core/localization/app_localizations_extension.dart';
import 'package:job_prep/core/localization/formatters.dart';
import 'package:job_prep/core/localization/locale_controller.dart';
import 'package:job_prep/core/theme/app_theme_tokens.dart';
import 'package:job_prep/core/widgets/glass_card.dart';
import 'package:job_prep/features/prep/presentation/widgets/syllabus/topic_detail_sheet.dart';
import 'package:job_prep/features/today/presentation/providers/today_next_topics_provider.dart';

/// Card displayed on the Today screen showing the first 3 incomplete topics
/// belonging to subjects with active study plans.
class TodayNextTopicsCard extends ConsumerWidget {
  /// Creates a [TodayNextTopicsCard].
  const TodayNextTopicsCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tokens = context.tokens;
    final colors = tokens.colors;
    final spacing = tokens.spacing;
    final radii = tokens.radii;
    final l10n = context.l10n;
    final locale = ref.watch(localeProvider);
    final useBanglaDigits = ref.watch(useBanglaDigitsProvider);

    final nextTopicsAsync = ref.watch(todayNextTopicsProvider);

    return nextTopicsAsync.when(
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
      data: (items) {
        if (items.isEmpty) {
          return const SizedBox.shrink();
        }

        return GlassCard(
          key: const ValueKey('today-next-topics-card'),
          padding: spacing.insetsAllLg,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.auto_stories_outlined,
                    size: 20,
                    color: colors.goldAccent,
                  ),
                  SizedBox(width: spacing.xs),
                  Text(
                    l10n.todayNextTopicsTitle,
                    style: tokens.textStyles.titleMedium,
                  ),
                ],
              ),
              SizedBox(height: spacing.md),
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: items.length,
                separatorBuilder: (_, __) => Divider(
                  height: 1,
                  color: colors.glassBorder,
                ),
                itemBuilder: (ctx, idx) {
                  final item = items[idx];
                  final pct = (item.progress * 100).round();
                  final pctStr = AppFormatters.formatNumber(
                    pct,
                    locale: locale,
                    useBanglaDigits: useBanglaDigits,
                  );

                  return InkWell(
                    key: ValueKey('today-next-topic-${item.topic.id}'),
                    onTap: () => TopicDetailSheet.show(
                      context,
                      topic: item.topic,
                      enabledCheckpoints: item.enabledCheckpoints,
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
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item.topic.title,
                                  style: tokens.textStyles.bodyMedium.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                SizedBox(height: spacing.xxs),
                                Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: spacing.xs,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: colors.goldAccent
                                        .withValues(alpha: 0.15),
                                    borderRadius: radii.smRadius,
                                  ),
                                  child: Text(
                                    item.subject.name,
                                    style: tokens.textStyles.bodySmall.copyWith(
                                      color: colors.goldAccent,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(width: spacing.sm),
                          Text(
                            '$pctStr%',
                            style: tokens.textStyles.labelMedium.copyWith(
                              color: item.progress > 0
                                  ? colors.goldAccent
                                  : colors.textSecondary,
                              fontWeight: FontWeight.bold,
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
      },
    );
  }
}
