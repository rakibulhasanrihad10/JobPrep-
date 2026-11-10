import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:job_prep/core/localization/app_localizations_extension.dart';
import 'package:job_prep/core/theme/app_theme_tokens.dart';
import 'package:job_prep/core/theme/reduce_effects_controller.dart';
import 'package:job_prep/core/widgets/fade_slide_in.dart';
import 'package:job_prep/core/widgets/glass_card.dart';

/// Shared centered glass layout shell for unauthenticated and recovery routes.
class AuthPageShell extends ConsumerWidget {
  /// Creates an [AuthPageShell].
  const AuthPageShell({
    required this.title,
    required this.subtitle,
    required this.child,
    super.key,
  });

  /// Main heading rendered at the top of the card.
  final String title;

  /// Supporting description rendered beneath [title].
  final String subtitle;

  /// Form or confirmation content inside the glass card.
  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tokens = context.tokens;
    final colors = tokens.colors;
    final spacing = tokens.spacing;
    final radii = tokens.radii;
    final textStyles = tokens.textStyles;
    final reduceEffects = ref.watch(reduceEffectsProvider);
    final l10n = context.l10n;

    final maxCardWidth = spacing.xxxl * 9; // 432 px
    final badgeSize = spacing.xxxl - spacing.sm; // 40 px
    final glowRadius = spacing.xxxl * 3; // 144 px

    return Scaffold(
      backgroundColor: colors.background,
      body: Stack(
        children: [
          if (!reduceEffects)
            Positioned.fill(
              child: IgnorePointer(
                child: CustomPaint(
                  painter: _SubtleAuthBackdropPainter(
                    accentGlow: colors.goldAccent.withValues(alpha: 0.08),
                    surfaceGlow: colors.surfaceElevated.withValues(alpha: 0.45),
                    radius: glowRadius,
                  ),
                ),
              ),
            ),
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: spacing.insetsAllLg,
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: maxCardWidth),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Brand mark header
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: badgeSize,
                            height: badgeSize,
                            decoration: BoxDecoration(
                              color: colors.goldAccentSubtle,
                              borderRadius: radii.buttonRadius,
                              border: Border.all(color: colors.glassBorder),
                            ),
                            child: Center(
                              child: Icon(
                                Icons.auto_stories_rounded,
                                color: colors.goldAccent,
                                size: spacing.lg + spacing.xs,
                              ),
                            ),
                          ),
                          SizedBox(width: spacing.sm),
                          Text(
                            l10n.appTitle,
                            style: textStyles.titleLarge,
                          ),
                        ],
                      ),
                      SizedBox(height: spacing.xl),
                      GlassCard(
                        padding: spacing.insetsAllXl,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            FadeSlideIn(
                              child: Text(
                                title,
                                style: textStyles.headlineMedium,
                              ),
                            ),
                            SizedBox(height: spacing.xs),
                            FadeSlideIn(
                              index: 1,
                              child: Text(
                                subtitle,
                                style: textStyles.bodyMedium,
                              ),
                            ),
                            SizedBox(height: spacing.xl),
                            FadeSlideIn(
                              index: 2,
                              child: child,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SubtleAuthBackdropPainter extends CustomPainter {
  const _SubtleAuthBackdropPainter({
    required this.accentGlow,
    required this.surfaceGlow,
    required this.radius,
  });

  final Color accentGlow;
  final Color surfaceGlow;
  final double radius;

  @override
  void paint(Canvas canvas, Size size) {
    final goldPaint = Paint()..color = accentGlow;
    final slatePaint = Paint()..color = surfaceGlow;

    canvas
      ..drawCircle(
        Offset(size.width * 0.2, size.height * 0.25),
        radius,
        goldPaint,
      )
      ..drawCircle(
        Offset(size.width * 0.82, size.height * 0.78),
        radius * 1.2,
        slatePaint,
      );
  }

  @override
  bool shouldRepaint(covariant _SubtleAuthBackdropPainter oldDelegate) {
    return oldDelegate.accentGlow != accentGlow ||
        oldDelegate.surfaceGlow != surfaceGlow ||
        oldDelegate.radius != radius;
  }
}
