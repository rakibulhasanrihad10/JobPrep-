import 'package:flutter/material.dart';
import 'package:job_prep/core/localization/app_localizations_extension.dart';
import 'package:job_prep/core/theme/app_theme_tokens.dart';
import 'package:job_prep/core/widgets/fade_slide_in.dart';
import 'package:job_prep/core/widgets/glass_card.dart';

/// Screen for tracking government and private job circulars.
class CircularsScreen extends StatelessWidget {
  /// Creates a [CircularsScreen].
  const CircularsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final spacing = tokens.spacing;
    final textStyles = tokens.textStyles;
    final l10n = context.l10n;

    return SingleChildScrollView(
      padding: spacing.insetsAllXl,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          FadeSlideIn(
            child: Text(
              l10n.circularsTitle,
              style: textStyles.headlineMedium,
            ),
          ),
          SizedBox(height: spacing.xs),
          FadeSlideIn(
            index: 1,
            child: Text(
              l10n.circularsSubtitle,
              style: textStyles.bodyMedium,
            ),
          ),
          SizedBox(height: spacing.xl),
          FadeSlideIn(
            index: 2,
            child: GlassCard(
              padding: spacing.insetsAllLg,
              child: Row(
                children: [
                  Icon(
                    Icons.work_outline,
                    color: tokens.colors.goldAccent,
                    size: 28,
                  ),
                  SizedBox(width: spacing.md),
                  Expanded(
                    child: Text(
                      l10n.circularsSubtitle,
                      style: textStyles.bodyMedium,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
