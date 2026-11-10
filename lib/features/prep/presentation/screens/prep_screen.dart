import 'package:flutter/material.dart';
import 'package:job_prep/core/localization/app_localizations_extension.dart';
import 'package:job_prep/core/theme/app_theme_tokens.dart';
import 'package:job_prep/core/widgets/fade_slide_in.dart';
import 'package:job_prep/core/widgets/glass_card.dart';

/// Screen for tracking exam preparation, syllabi, and study books.
class PrepScreen extends StatelessWidget {
  /// Creates a [PrepScreen].
  const PrepScreen({super.key});

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
              l10n.prepTitle,
              style: textStyles.headlineMedium,
            ),
          ),
          SizedBox(height: spacing.xs),
          FadeSlideIn(
            index: 1,
            child: Text(
              l10n.prepSubtitle,
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
                    Icons.menu_book_outlined,
                    color: tokens.colors.goldAccent,
                    size: 28,
                  ),
                  SizedBox(width: spacing.md),
                  Expanded(
                    child: Text(
                      l10n.prepSubtitle,
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
