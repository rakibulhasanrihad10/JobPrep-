import 'dart:async' show unawaited;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:job_prep/core/localization/app_localizations_extension.dart';
import 'package:job_prep/core/theme/app_theme_tokens.dart';
import 'package:job_prep/core/widgets/glass_card.dart';
import 'package:job_prep/features/onboarding/presentation/providers/onboarding_status_provider.dart';

/// Displays three concise dismissible quick tips on the Today screen after
/// completing onboarding.
class OnboardingTodayTipsCard extends ConsumerStatefulWidget {
  /// Creates an [OnboardingTodayTipsCard].
  const OnboardingTodayTipsCard({super.key});

  @override
  ConsumerState<OnboardingTodayTipsCard> createState() =>
      _OnboardingTodayTipsCardState();
}

class _OnboardingTodayTipsCardState
    extends ConsumerState<OnboardingTodayTipsCard> {
  final Set<int> _hiddenIndices = <int>{};

  void _dismissSingle(int index) {
    setState(() => _hiddenIndices.add(index));
    if (_hiddenIndices.length >= 3) {
      unawaited(
        ref.read(onboardingStatusProvider.notifier).dismissTodayTips(),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final colors = tokens.colors;
    final spacing = tokens.spacing;
    final radii = tokens.radii;
    final l10n = context.l10n;

    final tips = [
      l10n.onboardingTodayTip1,
      l10n.onboardingTodayTip2,
      l10n.onboardingTodayTip3,
    ];

    final visibleIndices = [
      for (var i = 0; i < tips.length; i++)
        if (!_hiddenIndices.contains(i)) i,
    ];
    if (visibleIndices.isEmpty) {
      return const SizedBox.shrink();
    }

    return GlassCard(
      key: const ValueKey('today-onboarding-tips-card'),
      padding: spacing.insetsAllLg,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Wrap(
            spacing: spacing.sm,
            runSpacing: spacing.xs,
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.lightbulb_outline_rounded,
                    size: spacing.lg,
                    color: colors.goldAccent,
                  ),
                  SizedBox(width: spacing.xs),
                  Flexible(
                    child: Text(
                      l10n.onboardingTodayTipsTitle,
                      style: tokens.textStyles.titleMedium,
                    ),
                  ),
                ],
              ),
              TextButton(
                key: const ValueKey('today-tips-dismiss-all-btn'),
                onPressed: () => unawaited(
                  ref
                      .read(onboardingStatusProvider.notifier)
                      .dismissTodayTips(),
                ),
                child: Text(l10n.onboardingTodayTipsDismissAll),
              ),
            ],
          ),
          SizedBox(height: spacing.sm),
          for (var idx = 0; idx < visibleIndices.length; idx++) ...[
            if (idx > 0) SizedBox(height: spacing.xs),
            Container(
              key: ValueKey('today-tip-row-${visibleIndices[idx]}'),
              padding: EdgeInsets.symmetric(
                horizontal: spacing.md,
                vertical: spacing.sm,
              ),
              decoration: BoxDecoration(
                color: colors.surfaceElevated,
                borderRadius: radii.buttonRadius,
                border: Border.all(color: colors.glassBorder),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      tips[visibleIndices[idx]],
                      style: tokens.textStyles.bodySmall.copyWith(
                        color: colors.textPrimary,
                      ),
                    ),
                  ),
                  SizedBox(width: spacing.xs),
                  IconButton(
                    key: ValueKey('today-tip-dismiss-${visibleIndices[idx]}'),
                    tooltip: l10n.onboardingTodayTipDismissTooltip,
                    visualDensity: VisualDensity.compact,
                    onPressed: () => _dismissSingle(visibleIndices[idx]),
                    icon: Icon(
                      Icons.close_rounded,
                      size: spacing.lg,
                      color: colors.textMuted,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
