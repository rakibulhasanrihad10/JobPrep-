import 'package:flutter/material.dart';
import 'package:job_prep/core/localization/app_localizations_extension.dart';
import 'package:job_prep/core/theme/app_theme_tokens.dart';
import 'package:job_prep/core/widgets/fade_slide_in.dart';
import 'package:job_prep/core/widgets/glass_card.dart';
import 'package:job_prep/features/circulars/domain/entities/circular.dart';

/// Long-form instructions, personal preparation notes, and syllabus card.
class CircularDetailTextCard extends StatelessWidget {
  /// Creates a [CircularDetailTextCard].
  const CircularDetailTextCard({
    required this.circular,
    super.key,
  });

  /// Active circular to display.
  final Circular circular;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final colors = tokens.colors;
    final spacing = tokens.spacing;
    final textStyles = tokens.textStyles;
    final l10n = context.l10n;

    return GlassCard(
      key: const ValueKey('circular-detail-notes-card'),
      padding: spacing.insetsAllLg,
      child: FadeSlideIn(
        index: 5,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Icon(
                  Icons.notes_rounded,
                  color: colors.goldAccent,
                  size: spacing.lg,
                ),
                SizedBox(width: spacing.sm),
                Expanded(
                  child: Text(
                    l10n.circularDetailNotesTitle,
                    style: textStyles.titleMedium,
                  ),
                ),
              ],
            ),
            Divider(color: colors.glassBorder, height: spacing.xl),
            _TextSubsection(
              title: l10n.circularFieldInstructionsLabel,
              body: circular.instructions,
            ),
            SizedBox(height: spacing.md),
            _TextSubsection(
              title: l10n.circularFieldNotesLabel,
              body: circular.notes,
            ),
            SizedBox(height: spacing.md),
            _TextSubsection(
              title: l10n.circularFieldSyllabusLabel,
              body: circular.syllabus,
            ),
          ],
        ),
      ),
    );
  }
}

class _TextSubsection extends StatelessWidget {
  const _TextSubsection({
    required this.title,
    required this.body,
  });

  final String title;
  final String? body;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final colors = tokens.colors;
    final l10n = context.l10n;
    final trimmed = body?.trim() ?? '';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: tokens.textStyles.labelLarge.copyWith(
            color: colors.textSecondary,
          ),
        ),
        SizedBox(height: tokens.spacing.xs),
        Text(
          trimmed.isEmpty ? l10n.circularDetailNotProvided : trimmed,
          style: tokens.textStyles.bodyMedium.copyWith(
            color: trimmed.isEmpty ? colors.textMuted : colors.textPrimary,
          ),
        ),
      ],
    );
  }
}
