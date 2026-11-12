import 'dart:async' show unawaited;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:job_prep/core/localization/app_localizations_extension.dart';
import 'package:job_prep/core/localization/formatters.dart';
import 'package:job_prep/core/localization/locale_controller.dart';
import 'package:job_prep/core/theme/app_theme_tokens.dart';
import 'package:job_prep/core/widgets/glass_button.dart';
import 'package:job_prep/core/widgets/glass_card.dart';
import 'package:job_prep/features/circulars/domain/entities/circular.dart';
import 'package:job_prep/features/circulars/presentation/providers/circulars_providers.dart';
import 'package:job_prep/features/prep/domain/entities/prep_material.dart';
import 'package:job_prep/features/prep/domain/entities/subject.dart';
import 'package:job_prep/features/prep/domain/entities/topic.dart';
import 'package:job_prep/features/prep/presentation/providers/mock_test_providers.dart';
import 'package:job_prep/features/prep/presentation/providers/prep_providers.dart';
import 'package:job_prep/features/prep/presentation/utils/mock_test_ui_helpers.dart';
import 'package:job_prep/features/prep/presentation/widgets/mock_test_form_dialog.dart';
import 'package:job_prep/features/prep/presentation/widgets/mock_test_list_tile.dart';
import 'package:job_prep/features/prep/presentation/widgets/mock_test_state_cards.dart';
import 'package:job_prep/features/prep/presentation/widgets/mock_test_stats_grid.dart';
import 'package:job_prep/features/prep/presentation/widgets/mock_test_trend_chart.dart';
import 'package:job_prep/features/prep/presentation/widgets/revision_flag_dialog.dart';

/// Displays Latest / Best / Average / Improvement cards, trend line chart with
/// average reference line, and logged mock tests for a single [subject].
class SubjectMockTestsSection extends ConsumerWidget {
  /// Creates a [SubjectMockTestsSection].
  const SubjectMockTestsSection({
    required this.subject,
    required this.subjectColor,
    super.key,
    this.replayKey,
  });

  /// Subject currently displayed in the detail view.
  final Subject subject;

  /// Resolved semantic color for [subject].
  final Color subjectColor;

  /// Optional animation replay key bumped on tab or subject transitions.
  final Object? replayKey;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tokens = context.tokens;
    final colors = tokens.colors;
    final spacing = tokens.spacing;
    final l10n = context.l10n;
    final locale = ref.watch(localeProvider);
    final useBanglaDigits = ref.watch(useBanglaDigitsProvider);

    final testsAsync = ref.watch(subjectMockTestsProvider(subject.id));
    final summary = ref.watch(subjectMockTestSummaryProvider(subject.id));
    final isBusy = ref.watch(mockTestControllerProvider).isBusy;

    final circulars =
        ref.watch(circularsListProvider).asData?.value ?? const <Circular>[];
    final materials =
        ref.watch(allMaterialsProvider).asData?.value ?? const <PrepMaterial>[];
    final topics =
        ref.watch(topicsForSubjectProvider(subject.id)).asData?.value ??
            const <Topic>[];
    final lookup = MockTestLookupMaps.fromEntities(
      subjects: [subject],
      circulars: circulars,
      materials: materials,
      topics: topics,
      colors: colors,
    );

    final count = testsAsync.asData?.value.length ?? 0;
    final countFormatted = AppFormatters.formatNumber(
      count,
      locale: locale,
      useBanglaDigits: useBanglaDigits,
    );

    return Column(
      key: const ValueKey('subject-mock-tests-section'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        GlassCard(
          padding: spacing.insetsAllLg,
          child: Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: spacing.sm,
            runSpacing: spacing.sm,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.analytics_outlined,
                    color: subjectColor,
                    size: spacing.xl,
                  ),
                  SizedBox(width: spacing.sm),
                  Flexible(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.prepMockTestSubjectSectionTitle,
                          style: tokens.textStyles.titleMedium,
                        ),
                        Text(
                          l10n.prepMockTestSubjectCount(count, countFormatted),
                          style: tokens.textStyles.bodySmall.copyWith(
                            color: colors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              GlassButton(
                key: const ValueKey('subject-add-mock-test-button'),
                variant: GlassButtonVariant.primary,
                onPressed: isBusy
                    ? null
                    : () => unawaited(
                          showMockTestFormDialog(
                            context,
                            initialSubjectId: subject.id,
                          ),
                        ),
                child: Text(l10n.prepMockTestAddButton),
              ),
            ],
          ),
        ),
        SizedBox(height: spacing.md),
        testsAsync.when(
          loading: () => const MockTestLoadingCard(
            key: ValueKey('subject-mock-loading'),
          ),
          error: (error, _) => MockTestErrorCard(
            key: const ValueKey('subject-mock-error'),
            retryButtonKey: const ValueKey('subject-mock-retry-button'),
            error: error,
            onRetry: () =>
                unawaited(ref.read(mockTestsProvider.notifier).refresh()),
          ),
          data: (tests) {
            if (tests.isEmpty) {
              return MockTestEmptyCard(
                key: const ValueKey('subject-mock-empty'),
                actionKey: const ValueKey('subject-mock-empty-add-button'),
                icon: Icons.quiz_outlined,
                iconColor: subjectColor,
                title: l10n.prepMockEmptyTitle,
                body: l10n.prepMockEmptyBody,
                actionLabel: l10n.prepMockTestAddButton,
                onAction: isBusy
                    ? null
                    : () => unawaited(
                          showMockTestFormDialog(
                            context,
                            initialSubjectId: subject.id,
                          ),
                        ),
              );
            }

            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                MockTestStatsGrid(
                  summary: summary,
                  accentColor: subjectColor,
                  replayKey: replayKey,
                ),
                SizedBox(height: spacing.md),
                MockTestTrendChart(
                  summary: summary,
                  accentColor: subjectColor,
                  replayKey: replayKey,
                ),
                SizedBox(height: spacing.md),
                for (var i = 0; i < tests.length; i++) ...[
                  if (i > 0) SizedBox(height: spacing.sm),
                  MockTestListTile(
                    test: tests[i],
                    accentColor: subjectColor,
                    isBusy: isBusy,
                    circularTitle:
                        lookup.circularTitlesById[tests[i].circularId],
                    materialTitle:
                        lookup.materialTitlesById[tests[i].materialId],
                    topicTitle: lookup.topicNamesById[tests[i].topicId],
                    onEdit: () => unawaited(
                      showMockTestFormDialog(context, existing: tests[i]),
                    ),
                    onDelete: () => unawaited(
                      confirmAndDeleteMockTest(context, ref, tests[i]),
                    ),
                    onAddWeakTopicsToRevision: () => unawaited(
                      showRevisionFlagDialog(context, fromMockTest: tests[i]),
                    ),
                  ),
                ],
              ],
            );
          },
        ),
      ],
    );
  }
}
