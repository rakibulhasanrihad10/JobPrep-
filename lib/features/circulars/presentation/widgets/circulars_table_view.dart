import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:job_prep/core/localization/app_localizations_extension.dart';
import 'package:job_prep/core/localization/locale_controller.dart';
import 'package:job_prep/core/theme/app_theme_tokens.dart';
import 'package:job_prep/core/widgets/fade_slide_in.dart';
import 'package:job_prep/core/widgets/glass_card.dart';
import 'package:job_prep/features/circulars/domain/entities/circular.dart';
import 'package:job_prep/features/circulars/presentation/utils/circular_l10n.dart';
import 'package:job_prep/features/circulars/presentation/widgets/circular_badges.dart';

/// Desktop glass-wrapped table displaying circulars with title, organization,
/// sector chip, live deadline countdown, vacancies, and status.
class CircularsTableView extends ConsumerWidget {
  /// Creates a [CircularsTableView].
  const CircularsTableView({
    required this.circulars,
    super.key,
    this.onTapCircular,
  });

  /// Circulars to display in row order.
  final List<Circular> circulars;

  /// Optional callback invoked when a circular row is tapped.
  final ValueChanged<Circular>? onTapCircular;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tokens = context.tokens;
    final colors = tokens.colors;
    final spacing = tokens.spacing;
    final textStyles = tokens.textStyles;
    final l10n = context.l10n;
    final locale = ref.watch(localeProvider);
    final useBanglaDigits = ref.watch(useBanglaDigitsProvider);

    return GlassCard(
      key: const ValueKey('circulars-desktop-table'),
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: spacing.lg,
              vertical: spacing.md,
            ),
            decoration: BoxDecoration(
              color: colors.surfaceElevated.withValues(alpha: 0.6),
              border: Border(
                bottom: BorderSide(color: colors.glassBorder),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  flex: 4,
                  child: Text(
                    l10n.circularsColumnTitle,
                    style: textStyles.labelLarge,
                  ),
                ),
                SizedBox(width: spacing.md),
                Expanded(
                  flex: 2,
                  child: Text(
                    l10n.circularsColumnSector,
                    style: textStyles.labelLarge,
                  ),
                ),
                SizedBox(width: spacing.md),
                Expanded(
                  flex: 3,
                  child: Text(
                    l10n.circularsColumnDeadline,
                    style: textStyles.labelLarge,
                  ),
                ),
                SizedBox(width: spacing.md),
                Expanded(
                  flex: 2,
                  child: Text(
                    l10n.circularsColumnVacancies,
                    style: textStyles.labelLarge,
                  ),
                ),
                SizedBox(width: spacing.md),
                Expanded(
                  flex: 3,
                  child: Text(
                    l10n.circularsColumnStatus,
                    style: textStyles.labelLarge,
                  ),
                ),
              ],
            ),
          ),
          for (var i = 0; i < circulars.length; i++) ...[
            if (i > 0) Divider(height: 1, color: colors.glassBorder),
            _CircularTableRow(
              circular: circulars[i],
              index: i,
              locale: locale,
              useBanglaDigits: useBanglaDigits,
              onTap: onTapCircular != null
                  ? () => onTapCircular!(circulars[i])
                  : null,
            ),
          ],
        ],
      ),
    );
  }
}

class _CircularTableRow extends StatelessWidget {
  const _CircularTableRow({
    required this.circular,
    required this.index,
    required this.locale,
    required this.useBanglaDigits,
    this.onTap,
  });

  final Circular circular;
  final int index;
  final Locale locale;
  final bool useBanglaDigits;
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

    final rowContent = FadeSlideIn(
      index: index.clamp(0, 8),
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: spacing.lg,
          vertical: spacing.md,
        ),
        child: Row(
          children: [
            Expanded(
              flex: 4,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    circular.title,
                    style: textStyles.titleMedium,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: spacing.xs),
                  Text(
                    organizationText,
                    style: textStyles.bodyMedium,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            SizedBox(width: spacing.md),
            Expanded(
              flex: 2,
              child: Align(
                alignment: Alignment.centerLeft,
                child: CircularSectorChip(sector: circular.sector),
              ),
            ),
            SizedBox(width: spacing.md),
            Expanded(
              flex: 3,
              child: CircularDeadlineCountdownBadge(
                deadline: circular.deadline,
              ),
            ),
            SizedBox(width: spacing.md),
            Expanded(
              flex: 2,
              child: Text(
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
            ),
            SizedBox(width: spacing.md),
            Expanded(
              flex: 3,
              child: CircularStatusBadge(
                workflowStatus: circular.workflowStatus,
                applicationStatus: circular.applicationStatus,
                priority: circular.priority,
              ),
            ),
          ],
        ),
      ),
    );

    return Material(
      key: ValueKey('circular-row-${circular.id}'),
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap ?? () {},
        hoverColor: colors.goldAccentSubtle.withValues(alpha: 0.35),
        child: rowContent,
      ),
    );
  }
}
