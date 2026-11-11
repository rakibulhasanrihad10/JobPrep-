import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:job_prep/core/localization/app_localizations_extension.dart';
import 'package:job_prep/core/localization/formatters.dart';
import 'package:job_prep/core/localization/locale_controller.dart';
import 'package:job_prep/core/theme/app_theme_tokens.dart';
import 'package:job_prep/core/widgets/glass_card.dart';
import 'package:job_prep/features/prep/domain/entities/mock_test.dart';
import 'package:job_prep/features/prep/domain/utils/mock_test_analytics.dart';
import 'package:job_prep/l10n/app_localizations.dart';

/// Card displaying a single logged [MockTest] entry with net score, metadata
/// chips, optional linked circular/material/topic tags, and edit/delete actions.
class MockTestListTile extends ConsumerWidget {
  /// Creates a [MockTestListTile].
  const MockTestListTile({
    required this.test,
    required this.accentColor,
    required this.isBusy,
    required this.onEdit,
    required this.onDelete,
    super.key,
    this.subjectName,
    this.circularTitle,
    this.materialTitle,
    this.topicTitle,
  });

  /// Mock test record being rendered.
  final MockTest test;

  /// Semantic accent color associated with this test's subject.
  final Color accentColor;

  /// Whether a mock test mutation is currently in progress.
  final bool isBusy;

  /// Opens edit dialog for [test].
  final VoidCallback onEdit;

  /// Opens delete confirmation for [test].
  final VoidCallback onDelete;

  /// Optional subject display name shown when viewing across all subjects.
  final String? subjectName;

  /// Optional linked circular title.
  final String? circularTitle;

  /// Optional linked study material title.
  final String? materialTitle;

  /// Optional linked syllabus topic name.
  final String? topicTitle;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tokens = context.tokens;
    final colors = tokens.colors;
    final spacing = tokens.spacing;
    final radii = tokens.radii;
    final l10n = context.l10n;
    final locale = ref.watch(localeProvider);
    final useBanglaDigits = ref.watch(useBanglaDigitsProvider);

    final netMarks = MockTestAnalytics.calculateNetMarks(test);
    final percent = MockTestAnalytics.calculateScorePercentage(test);

    final Color scoreColor;
    if (percent >= 75) {
      scoreColor = colors.success;
    } else if (percent >= 50) {
      scoreColor = colors.goldAccent;
    } else {
      scoreColor = colors.danger;
    }

    final percentText = l10n.prepMockStatPercentValue(
      AppFormatters.formatNumber(
        percent,
        locale: locale,
        useBanglaDigits: useBanglaDigits,
        decimalDigits: 1,
      ),
    );
    final ratioText = l10n.prepMockScoreRatio(
      AppFormatters.formatNumber(
        netMarks,
        locale: locale,
        useBanglaDigits: useBanglaDigits,
        decimalDigits: netMarks % 1 == 0 ? 0 : 2,
      ),
      AppFormatters.formatNumber(
        test.totalMarks,
        locale: locale,
        useBanglaDigits: useBanglaDigits,
        decimalDigits: test.totalMarks % 1 == 0 ? 0 : 2,
      ),
    );
    final dateText = AppFormatters.formatDate(
      test.takenOn,
      locale: locale,
      pattern: 'd MMM yyyy',
      useBanglaDigits: useBanglaDigits,
    );

    final chips = <Widget>[
      if (subjectName != null && subjectName!.trim().isNotEmpty)
        _MetaChip(
          label: subjectName!.trim(),
          color: accentColor,
          background: accentColor.withValues(alpha: 0.14),
        ),
      if (test.negativeMarks != null && test.negativeMarks! > 0)
        _MetaChip(
          label: l10n.prepMockNegativeMarksBadge(
            AppFormatters.formatNumber(
              test.negativeMarks!,
              locale: locale,
              useBanglaDigits: useBanglaDigits,
              decimalDigits: test.negativeMarks! % 1 == 0 ? 0 : 2,
            ),
          ),
          color: colors.danger,
          background: colors.danger.withValues(alpha: 0.12),
        ),
      if (test.timeTakenMinutes != null)
        _MetaChip(
          label: _formatDuration(
            l10n: l10n,
            locale: locale,
            useBanglaDigits: useBanglaDigits,
            taken: test.timeTakenMinutes!,
            limit: test.timeLimitMinutes,
          ),
          color: colors.info,
          background: colors.info.withValues(alpha: 0.12),
        ),
      if (circularTitle != null && circularTitle!.trim().isNotEmpty)
        _MetaChip(
          label: l10n.prepMockLinkedCircularLabel(circularTitle!.trim()),
          color: colors.textSecondary,
          background: colors.surfaceElevated,
        ),
      if (materialTitle != null && materialTitle!.trim().isNotEmpty)
        _MetaChip(
          label: l10n.prepMockLinkedMaterialLabel(materialTitle!.trim()),
          color: colors.textSecondary,
          background: colors.surfaceElevated,
        ),
      if (topicTitle != null && topicTitle!.trim().isNotEmpty)
        _MetaChip(
          label: l10n.prepMockLinkedTopicLabel(topicTitle!.trim()),
          color: colors.textSecondary,
          background: colors.surfaceElevated,
        ),
    ];

    return GlassCard(
      key: ValueKey('mock-test-tile-${test.id}'),
      padding: spacing.insetsAllLg,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      test.title,
                      style: tokens.textStyles.titleMedium,
                    ),
                    SizedBox(height: spacing.xxs),
                    Wrap(
                      spacing: spacing.sm,
                      runSpacing: spacing.xxs,
                      children: [
                        Text(
                          dateText,
                          style: tokens.textStyles.bodySmall.copyWith(
                            color: colors.textSecondary,
                          ),
                        ),
                        if (test.source != null &&
                            test.source!.trim().isNotEmpty)
                          Text(
                            test.source!.trim(),
                            style: tokens.textStyles.bodySmall.copyWith(
                              color: colors.textMuted,
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(width: spacing.sm),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: spacing.sm,
                  vertical: spacing.xs,
                ),
                decoration: BoxDecoration(
                  color: scoreColor.withValues(alpha: 0.14),
                  borderRadius: radii.mdRadius,
                  border: Border.all(
                    color: scoreColor.withValues(alpha: 0.35),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      percentText,
                      style: tokens.textStyles.labelLarge.copyWith(
                        color: scoreColor,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      ratioText,
                      style: tokens.textStyles.bodySmall.copyWith(
                        color: colors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                key: ValueKey('mock-test-edit-${test.id}'),
                tooltip: l10n.prepMockEditTooltip,
                visualDensity: VisualDensity.compact,
                padding: spacing.insetsAllXs,
                constraints: const BoxConstraints(),
                onPressed: isBusy ? null : onEdit,
                icon: const Icon(Icons.edit_outlined),
              ),
              SizedBox(width: spacing.xs),
              IconButton(
                key: ValueKey('mock-test-delete-${test.id}'),
                tooltip: l10n.prepMockDeleteTooltip,
                visualDensity: VisualDensity.compact,
                padding: spacing.insetsAllXs,
                constraints: const BoxConstraints(),
                onPressed: isBusy ? null : onDelete,
                icon: Icon(Icons.delete_outline, color: colors.danger),
              ),
            ],
          ),
          if (chips.isNotEmpty) ...[
            SizedBox(height: spacing.sm),
            Wrap(
              spacing: spacing.xs,
              runSpacing: spacing.xs,
              children: chips,
            ),
          ],
          if (test.weakTopics != null &&
              test.weakTopics!.trim().isNotEmpty) ...[
            SizedBox(height: spacing.sm),
            Text(
              l10n.prepMockWeakTopicsLabel(test.weakTopics!.trim()),
              style: tokens.textStyles.bodySmall.copyWith(
                color: colors.warning,
              ),
            ),
          ],
          if (test.notes != null && test.notes!.trim().isNotEmpty) ...[
            SizedBox(height: spacing.xs),
            Text(
              test.notes!.trim(),
              style: tokens.textStyles.bodySmall.copyWith(
                color: colors.textSecondary,
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _formatDuration({
    required AppLocalizations l10n,
    required Locale locale,
    required bool useBanglaDigits,
    required int taken,
    required int? limit,
  }) {
    final takenFormatted = AppFormatters.formatNumber(
      taken,
      locale: locale,
      useBanglaDigits: useBanglaDigits,
    );
    if (limit == null) {
      return l10n.prepMockDurationBadge(takenFormatted);
    }
    final limitFormatted = AppFormatters.formatNumber(
      limit,
      locale: locale,
      useBanglaDigits: useBanglaDigits,
    );
    return l10n.prepMockDurationWithLimitBadge(
      takenFormatted,
      limitFormatted,
    );
  }
}

class _MetaChip extends StatelessWidget {
  const _MetaChip({
    required this.label,
    required this.color,
    required this.background,
  });

  final String label;
  final Color color;
  final Color background;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final spacing = tokens.spacing;
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: spacing.sm,
        vertical: spacing.xxs,
      ),
      decoration: BoxDecoration(
        color: background,
        borderRadius: tokens.radii.smRadius,
      ),
      child: Text(
        label,
        style: tokens.textStyles.labelSmall.copyWith(color: color),
      ),
    );
  }
}
