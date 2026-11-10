import 'package:flutter/material.dart';
import 'package:job_prep/core/localization/app_localizations_extension.dart';
import 'package:job_prep/core/theme/app_theme_tokens.dart';
import 'package:job_prep/features/prep/domain/entities/prep_material.dart';
import 'package:job_prep/features/prep/domain/utils/prep_progress.dart';
import 'package:job_prep/features/prep/presentation/utils/prep_l10n.dart';
import 'package:job_prep/features/prep/presentation/widgets/material_cover_thumbnail.dart';

/// Compact summary row at the top of the material logs dialog showing live
/// unit completion totals alongside the cover thumbnail.
class MaterialLogSummaryHeader extends StatelessWidget {
  /// Creates a [MaterialLogSummaryHeader].
  const MaterialLogSummaryHeader({
    required this.material,
    required this.subjectColor,
    super.key,
  });

  /// Material whose live progress is displayed.
  final PrepMaterial material;

  /// Subject accent color used behind cover initial placeholders.
  final Color subjectColor;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final colors = tokens.colors;
    final spacing = tokens.spacing;
    final l10n = context.l10n;
    final locale = Localizations.localeOf(context);
    final progress = calculateMaterialProgress(material);

    return Row(
      children: [
        MaterialCoverThumbnail(
          title: material.title,
          subjectColor: subjectColor,
          coverImagePath: material.coverImagePath,
          coverImageUrl: material.coverImageUrl,
          width: spacing.xxl + spacing.md,
          height: spacing.xxxl + spacing.sm,
        ),
        SizedBox(width: spacing.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                material.title,
                style: tokens.textStyles.titleMedium,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(height: spacing.xs),
              Text(
                l10n.prepMaterialProgressSummary(
                  PrepL10n.formatInt(material.completedUnits, locale),
                  PrepL10n.formatInt(material.totalUnits, locale),
                  material.unitLabel,
                ),
                style: tokens.textStyles.bodySmall,
              ),
              SizedBox(height: spacing.xxs),
              Text(
                l10n.prepPercentComplete(
                  PrepL10n.formatPercent(progress, locale),
                ),
                style: tokens.textStyles.labelMedium.copyWith(
                  color: colors.goldAccent,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
