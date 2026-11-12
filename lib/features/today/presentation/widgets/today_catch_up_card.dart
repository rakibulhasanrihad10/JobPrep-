import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:job_prep/core/localization/app_localizations_extension.dart';
import 'package:job_prep/core/localization/locale_controller.dart';
import 'package:job_prep/core/theme/app_theme_tokens.dart';
import 'package:job_prep/core/widgets/glass_card.dart';
import 'package:job_prep/features/prep/presentation/widgets/study_plan_stat_pill.dart';
import 'package:job_prep/features/today/domain/entities/today_summary.dart';
import 'package:job_prep/features/today/presentation/utils/today_l10n.dart';

/// Phase 6C missed-days catch-up and past-buffer banner section shown on Today
/// whenever any active study plan has missed units or entered its buffer.
class TodayCatchUpCard extends ConsumerWidget {
  /// Creates a [TodayCatchUpCard].
  const TodayCatchUpCard({
    required this.notices,
    super.key,
  });

  /// Ordered catch-up notices computed by `TodayWindowSelectors`.
  final List<TodayCatchUpNotice> notices;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (notices.isEmpty) {
      return const SizedBox.shrink();
    }

    final tokens = context.tokens;
    final colors = tokens.colors;
    final spacing = tokens.spacing;
    final l10n = context.l10n;
    final locale = ref.watch(localeProvider);
    final useBanglaDigits = ref.watch(useBanglaDigitsProvider);

    return GlassCard(
      key: const ValueKey('today-catch-up-card'),
      padding: spacing.insetsAllLg,
      borderColor: colors.info.withValues(alpha: 0.45),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Icon(
                Icons.autorenew_rounded,
                size: spacing.lg,
                color: colors.info,
              ),
              SizedBox(width: spacing.sm),
              Expanded(
                child: Text(
                  l10n.todayCatchUpTitle,
                  style: tokens.textStyles.titleMedium,
                ),
              ),
            ],
          ),
          SizedBox(height: spacing.md),
          for (var i = 0; i < notices.length; i++) ...[
            if (i > 0) SizedBox(height: spacing.sm),
            Builder(
              builder: (_) {
                final plan = notices[i].planSnapshot.plan;
                final slug =
                    plan.isAllSubjects ? 'all' : (plan.subjectId ?? plan.id);
                return StudyPlanAlertBox(
                  boxKey: ValueKey('today-catch-up-notice-$slug'),
                  accent: notices[i].isPastBufferOrTarget
                      ? colors.warning
                      : colors.info,
                  icon: notices[i].isPastBufferOrTarget
                      ? Icons.event_busy_outlined
                      : Icons.autorenew_rounded,
                  message: TodayL10n.formatCatchUpMessage(
                    notice: notices[i],
                    l10n: l10n,
                    locale: locale,
                    useBanglaDigits: useBanglaDigits,
                  ),
                );
              },
            ),
          ],
        ],
      ),
    );
  }
}
