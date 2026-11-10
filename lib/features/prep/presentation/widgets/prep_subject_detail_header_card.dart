import 'package:flutter/material.dart';
import 'package:job_prep/core/localization/app_localizations_extension.dart';
import 'package:job_prep/core/theme/app_theme_tokens.dart';
import 'package:job_prep/core/widgets/animated_progress_ring.dart';
import 'package:job_prep/core/widgets/glass_button.dart';
import 'package:job_prep/core/widgets/glass_card.dart';
import 'package:job_prep/features/prep/domain/entities/subject.dart';
import 'package:job_prep/features/prep/presentation/utils/prep_l10n.dart';
import 'package:job_prep/features/prep/presentation/utils/prep_style_tokens.dart';

/// Header card displayed above a subject's study materials list.
class PrepSubjectDetailHeaderCard extends StatelessWidget {
  /// Creates a [PrepSubjectDetailHeaderCard].
  const PrepSubjectDetailHeaderCard({
    required this.subject,
    required this.subjectColor,
    required this.subjectProgress,
    required this.materialCount,
    required this.onAddMaterial,
    required this.onEditSubject,
    required this.onDeleteSubject,
    super.key,
    this.onBack,
    this.replayKey,
  });

  /// Subject displayed in this header.
  final Subject subject;

  /// Resolved theme accent color for [subject].
  final Color subjectColor;

  /// Normalized completion fraction `[0..1]`.
  final double subjectProgress;

  /// Number of materials in [subject].
  final int materialCount;

  /// Optional back action rendered on mobile/tablet routes.
  final VoidCallback? onBack;

  /// Optional animation replay key for [AnimatedProgressRing].
  final Object? replayKey;

  /// Callback opening add-material dialog.
  final VoidCallback onAddMaterial;

  /// Callback opening edit-subject dialog.
  final VoidCallback onEditSubject;

  /// Callback initiating delete-subject confirmation.
  final VoidCallback onDeleteSubject;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final colors = tokens.colors;
    final spacing = tokens.spacing;
    final radii = tokens.radii;
    final l10n = context.l10n;
    final locale = Localizations.localeOf(context);
    final percentText = PrepL10n.formatPercent(subjectProgress, locale);

    return GlassCard(
      padding: spacing.insetsAllXl,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (onBack != null) ...[
            Align(
              alignment: Alignment.centerLeft,
              child: GlassButton(
                key: const ValueKey('prep-detail-back-button'),
                leading: Icon(
                  Icons.arrow_back,
                  size: spacing.lg,
                  color: colors.textPrimary,
                ),
                onPressed: onBack,
                child: Text(l10n.prepBackToSubjects),
              ),
            ),
            SizedBox(height: spacing.md),
          ],
          Row(
            children: [
              AnimatedProgressRing(
                value: subjectProgress,
                replayKey: replayKey ?? subject.id,
                size: spacing.xxxl + spacing.xl,
                progressColor: subjectColor,
                child: Text(
                  '$percentText%',
                  style: tokens.textStyles.labelMedium.copyWith(
                    color: colors.textPrimary,
                  ),
                ),
              ),
              SizedBox(width: spacing.lg),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          PrepStyleTokens.resolveSubjectIcon(subject.icon),
                          color: subjectColor,
                          size: spacing.lg + spacing.xs,
                        ),
                        SizedBox(width: spacing.xs),
                        Expanded(
                          child: Text(
                            subject.name,
                            style: tokens.textStyles.headlineMedium,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: spacing.xs),
                    Wrap(
                      spacing: spacing.sm,
                      runSpacing: spacing.xs,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: spacing.sm,
                            vertical: spacing.xxs,
                          ),
                          decoration: BoxDecoration(
                            color: subjectColor.withValues(alpha: 0.16),
                            borderRadius: radii.smRadius,
                            border: Border.all(
                              color: subjectColor.withValues(alpha: 0.40),
                            ),
                          ),
                          child: Text(
                            subject.examType,
                            style: tokens.textStyles.labelSmall.copyWith(
                              color: colors.textPrimary,
                            ),
                          ),
                        ),
                        Text(
                          l10n.prepMaterialCount(
                            materialCount,
                            PrepL10n.formatInt(materialCount, locale),
                          ),
                          style: tokens.textStyles.bodyMedium,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: spacing.lg),
          Wrap(
            spacing: spacing.sm,
            runSpacing: spacing.sm,
            children: [
              GlassButton(
                key: const ValueKey('add-material-button'),
                variant: GlassButtonVariant.primary,
                leading: Icon(
                  Icons.add,
                  size: spacing.lg,
                  color: colors.goldAccent,
                ),
                onPressed: onAddMaterial,
                child: Text(l10n.prepAddMaterialButton),
              ),
              GlassButton(
                key: ValueKey('detail-edit-subject-${subject.id}'),
                onPressed: onEditSubject,
                child: Text(l10n.prepEditAction),
              ),
              GlassButton(
                key: ValueKey('detail-delete-subject-${subject.id}'),
                onPressed: onDeleteSubject,
                child: Text(
                  l10n.prepDeleteAction,
                  style: tokens.textStyles.labelLarge.copyWith(
                    color: colors.danger,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
