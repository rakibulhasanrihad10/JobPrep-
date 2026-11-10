import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:job_prep/core/localization/app_localizations_extension.dart';
import 'package:job_prep/core/localization/locale_controller.dart';
import 'package:job_prep/core/theme/app_theme_tokens.dart';
import 'package:job_prep/core/widgets/fade_slide_in.dart';
import 'package:job_prep/features/circulars/domain/entities/circular.dart';
import 'package:job_prep/features/circulars/presentation/utils/circular_l10n.dart';
import 'package:job_prep/features/circulars/presentation/widgets/circular_badges.dart';

/// Mobile/tablet card list displaying circular entries without per-row blur
/// layers for smooth scrolling performance.
class CircularsCardList extends ConsumerWidget {
  /// Creates a [CircularsCardList].
  const CircularsCardList({
    required this.circulars,
    super.key,
    this.onTapCircular,
    this.selectedCircularId,
  });

  /// Circulars to display in order.
  final List<Circular> circulars;

  /// Optional callback invoked when a card is tapped.
  final ValueChanged<Circular>? onTapCircular;

  /// Optional selected circular ID highlighted in master-detail desktop view.
  final String? selectedCircularId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final spacing = context.tokens.spacing;
    final locale = ref.watch(localeProvider);
    final useBanglaDigits = ref.watch(useBanglaDigitsProvider);

    return ListView.separated(
      key: const ValueKey('circulars-mobile-list'),
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: circulars.length,
      separatorBuilder: (_, __) => SizedBox(height: spacing.md),
      itemBuilder: (context, index) {
        final circular = circulars[index];
        return _CircularMobileCard(
          circular: circular,
          index: index,
          locale: locale,
          useBanglaDigits: useBanglaDigits,
          isSelected: selectedCircularId == circular.id,
          onTap: onTapCircular != null ? () => onTapCircular!(circular) : null,
        );
      },
    );
  }
}

class _CircularMobileCard extends StatelessWidget {
  const _CircularMobileCard({
    required this.circular,
    required this.index,
    required this.locale,
    required this.useBanglaDigits,
    required this.isSelected,
    this.onTap,
  });

  final Circular circular;
  final int index;
  final Locale locale;
  final bool useBanglaDigits;
  final bool isSelected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final colors = tokens.colors;
    final spacing = tokens.spacing;
    final textStyles = tokens.textStyles;
    final l10n = context.l10n;

    final organizationText =
        circular.organizationName?.trim().isNotEmpty ?? false
            ? circular.organizationName!.trim()
            : l10n.circularsOrganizationUnspecified;

    return Container(
      key: ValueKey('circular-card-${circular.id}'),
      decoration: BoxDecoration(
        color: isSelected ? colors.goldAccentSubtle : colors.glassFillSolid,
        borderRadius: tokens.radii.cardRadius,
        border: Border.all(
          color: isSelected ? colors.goldAccent : colors.glassBorder,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: tokens.radii.cardRadius,
          hoverColor: colors.goldAccentSubtle.withValues(alpha: 0.35),
          onTap: onTap ?? () {},
          child: Padding(
            padding: spacing.insetsAllLg,
            child: FadeSlideIn(
              index: index.clamp(0, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              circular.title,
                              style: textStyles.titleMedium,
                            ),
                            SizedBox(height: spacing.xs),
                            Text(
                              organizationText,
                              style: textStyles.bodyMedium,
                            ),
                          ],
                        ),
                      ),
                      SizedBox(width: spacing.sm),
                      CircularSectorChip(sector: circular.sector),
                    ],
                  ),
                  SizedBox(height: spacing.md),
                  Wrap(
                    spacing: spacing.lg,
                    runSpacing: spacing.md,
                    alignment: WrapAlignment.spaceBetween,
                    children: [
                      CircularDeadlineCountdownBadge(
                        deadline: circular.deadline,
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10n.circularsColumnVacancies,
                            style: textStyles.labelSmall.copyWith(
                              color: colors.textMuted,
                            ),
                          ),
                          SizedBox(height: spacing.xs),
                          Text(
                            CircularL10n.vacanciesLabel(
                              circular.vacancies,
                              l10n,
                              locale: locale,
                              useBanglaDigits: useBanglaDigits,
                            ),
                            style: textStyles.bodyMedium.copyWith(
                              color: circular.vacancies != null
                                  ? colors.textPrimary
                                  : colors.textMuted,
                            ),
                          ),
                        ],
                      ),
                      CircularStatusBadge(
                        workflowStatus: circular.workflowStatus,
                        applicationStatus: circular.applicationStatus,
                        priority: circular.priority,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
