import 'package:flutter/material.dart';
import 'package:job_prep/core/theme/app_theme_tokens.dart';
import 'package:job_prep/core/widgets/animated_counter.dart';
import 'package:job_prep/core/widgets/animated_progress_ring.dart';
import 'package:job_prep/core/widgets/glass_card.dart';

/// Compact glass KPI card showing an icon, animated integer counter, and
/// localized label.
class DashboardCountMetricCard extends StatelessWidget {
  /// Creates a [DashboardCountMetricCard].
  const DashboardCountMetricCard({
    required this.label,
    required this.value,
    required this.replayKey,
    required this.icon,
    required this.accentColor,
    required this.onTap,
    super.key,
  });

  /// Localized metric label shown beneath the animated count.
  final String label;

  /// Precomputed integer KPI value rendered by [AnimatedCounter].
  final int value;

  /// Key forcing [AnimatedCounter] to replay from zero on tab entry.
  final Object replayKey;

  /// Leading accent icon displayed in the card header.
  final IconData icon;

  /// Token-derived color applied to [icon] and its tinted container.
  final Color accentColor;

  /// Navigation action triggered when the card is tapped.
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final spacing = tokens.spacing;
    final radii = tokens.radii;

    return GlassCard(
      padding: spacing.insetsAllLg,
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                padding: spacing.insetsAllXs,
                decoration: BoxDecoration(
                  color: accentColor.withValues(alpha: 0.14),
                  borderRadius: radii.smRadius,
                ),
                child: Icon(icon, size: spacing.lg, color: accentColor),
              ),
              const Spacer(),
              Icon(
                Icons.arrow_forward_ios_rounded,
                size: spacing.md,
                color: tokens.colors.textMuted,
              ),
            ],
          ),
          SizedBox(height: spacing.md),
          AnimatedCounter(
            value: value,
            replayKey: replayKey,
            style: tokens.textStyles.headlineMedium.copyWith(
              color: tokens.colors.textPrimary,
            ),
          ),
          SizedBox(height: spacing.xxs),
          Text(
            label,
            style: tokens.textStyles.bodySmall,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

/// Compact glass KPI card rendering overall preparation completion with an
/// [AnimatedProgressRing] and matching percentage counter.
class DashboardPrepProgressMetricCard extends StatelessWidget {
  /// Creates a [DashboardPrepProgressMetricCard].
  const DashboardPrepProgressMetricCard({
    required this.label,
    required this.progress,
    required this.ringReplayKey,
    required this.counterReplayKey,
    required this.onTap,
    super.key,
  });

  /// Localized KPI label rendered below the ring.
  final String label;

  /// Precomputed overall progress ratio (`0.0` to `1.0`).
  final double progress;

  /// Replay key passed to [AnimatedProgressRing].
  final Object ringReplayKey;

  /// Replay key passed to [AnimatedCounter].
  final Object counterReplayKey;

  /// Navigation action triggered when the card is tapped.
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final colors = tokens.colors;
    final spacing = tokens.spacing;
    final percentInt = (progress.clamp(0.0, 1.0) * 100).round();

    return GlassCard(
      padding: spacing.insetsAllLg,
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              AnimatedProgressRing(
                value: progress,
                replayKey: ringReplayKey,
                size: spacing.xxxl + spacing.sm,
                strokeWidth: spacing.xs + spacing.xxs,
                progressColor: colors.goldAccent,
                child: AnimatedCounter(
                  value: percentInt,
                  suffix: '%',
                  replayKey: counterReplayKey,
                  style: tokens.textStyles.labelMedium.copyWith(
                    color: colors.textPrimary,
                  ),
                ),
              ),
              const Spacer(),
              Icon(
                Icons.arrow_forward_ios_rounded,
                size: spacing.md,
                color: colors.textMuted,
              ),
            ],
          ),
          SizedBox(height: spacing.md),
          Text(
            label,
            style: tokens.textStyles.bodySmall,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
