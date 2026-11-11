import 'dart:async' show unawaited;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:job_prep/core/localization/app_localizations_extension.dart';
import 'package:job_prep/core/localization/formatters.dart';
import 'package:job_prep/core/localization/locale_controller.dart';
import 'package:job_prep/core/theme/app_theme_tokens.dart';
import 'package:job_prep/core/widgets/fade_slide_in.dart';
import 'package:job_prep/core/widgets/glass_button.dart';
import 'package:job_prep/core/widgets/glass_card.dart';
import 'package:job_prep/features/circulars/domain/entities/circular.dart';
import 'package:job_prep/features/circulars/presentation/providers/circulars_providers.dart';
import 'package:job_prep/features/prep/domain/entities/mock_test.dart';
import 'package:job_prep/features/prep/domain/entities/prep_material.dart';
import 'package:job_prep/features/prep/domain/entities/subject.dart';
import 'package:job_prep/features/prep/presentation/providers/mock_test_providers.dart';
import 'package:job_prep/features/prep/presentation/providers/prep_providers.dart';
import 'package:job_prep/features/prep/presentation/utils/mock_test_ui_helpers.dart';
import 'package:job_prep/features/prep/presentation/widgets/mock_test_form_dialog.dart';
import 'package:job_prep/features/prep/presentation/widgets/mock_test_list_tile.dart';
import 'package:job_prep/features/prep/presentation/widgets/mock_test_state_cards.dart';
import 'package:job_prep/features/prep/presentation/widgets/mock_test_stats_grid.dart';
import 'package:job_prep/features/prep/presentation/widgets/mock_test_trend_chart.dart';
import 'package:job_prep/features/prep/presentation/widgets/mock_tests_filter_card.dart';

/// Filterable Mock Tests tab view inside `PrepScreen`, showing subject & date
/// filters, aggregate stats, score trend line chart, and logged test results.
class MockTestsTabView extends ConsumerWidget {
  /// Creates a [MockTestsTabView].
  const MockTestsTabView({
    required this.visitId,
    super.key,
  });

  /// Monotonically incremented counter triggering replay when switching tabs.
  final int visitId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tokens = context.tokens;
    final colors = tokens.colors;
    final spacing = tokens.spacing;
    final l10n = context.l10n;
    final locale = ref.watch(localeProvider);
    final useBanglaDigits = ref.watch(useBanglaDigitsProvider);

    final subjects = List<Subject>.of(
      ref.watch(subjectsProvider).asData?.value ?? const <Subject>[],
    )..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));

    final allTestsAsync = ref.watch(mockTestsProvider);
    final filteredAsync = ref.watch(filteredMockTestsProvider);
    final filter = ref.watch(mockTestFilterProvider);
    final summary = ref.watch(filteredMockTestSummaryProvider);
    final isBusy = ref.watch(mockTestControllerProvider).isBusy;

    final filteredList = filteredAsync.asData?.value ?? const <MockTest>[];
    final circulars =
        ref.watch(circularsListProvider).asData?.value ?? const <Circular>[];
    final materials =
        ref.watch(allMaterialsProvider).asData?.value ?? const <PrepMaterial>[];
    final topics = MockTestLookupMaps.collectTopicsForTests(ref, filteredList);
    final lookup = MockTestLookupMaps.fromEntities(
      subjects: subjects,
      circulars: circulars,
      materials: materials,
      topics: topics,
      colors: colors,
    );

    final selectedAccent = filter.subjectId != null
        ? (lookup.subjectColorsById[filter.subjectId!] ?? colors.goldAccent)
        : colors.goldAccent;
    final hasActiveFilters = filter.subjectId != null ||
        filter.datePreset != MockDateFilterPreset.all;
    final replayKey = 'mock-tab-$visitId-${filter.subjectId ?? "all"}'
        '-${filter.datePreset.name}';

    return FadeSlideIn(
      child: Column(
        key: const ValueKey('mock-tests-tab-view'),
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          GlassCard(
            padding: spacing.insetsAllXl,
            child: Wrap(
              alignment: WrapAlignment.spaceBetween,
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: spacing.md,
              runSpacing: spacing.md,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.prepMockTestsTitle,
                      style: tokens.textStyles.headlineMedium,
                    ),
                    SizedBox(height: spacing.xs),
                    Text(
                      l10n.prepMockTestsSubtitle,
                      style: tokens.textStyles.bodyMedium.copyWith(
                        color: colors.textSecondary,
                      ),
                    ),
                  ],
                ),
                Wrap(
                  spacing: spacing.xs,
                  runSpacing: spacing.xs,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    IconButton(
                      tooltip: l10n.prepRefreshTooltip,
                      onPressed: () => unawaited(
                        ref.read(mockTestsProvider.notifier).refresh(),
                      ),
                      icon: const Icon(Icons.refresh_rounded),
                    ),
                    GlassButton(
                      key: const ValueKey('mock-tab-add-button'),
                      variant: GlassButtonVariant.primary,
                      onPressed: isBusy
                          ? null
                          : () => unawaited(
                                showMockTestFormDialog(
                                  context,
                                  initialSubjectId: filter.subjectId,
                                ),
                              ),
                      child: Text(l10n.prepMockTestAddButton),
                    ),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(height: spacing.lg),
          MockTestsFilterCard(
            subjects: subjects,
            filter: filter,
            hasActiveFilters: hasActiveFilters,
            onSubjectChanged: (id) =>
                ref.read(mockTestFilterProvider.notifier).setSubject(id),
            onDatePresetChanged: (preset) =>
                ref.read(mockTestFilterProvider.notifier).setDatePreset(preset),
            onClear: () => ref.read(mockTestFilterProvider.notifier).clear(),
          ),
          SizedBox(height: spacing.lg),
          filteredAsync.when(
            loading: () => const MockTestLoadingCard(
              key: ValueKey('mock-tab-loading'),
            ),
            error: (error, _) => MockTestErrorCard(
              key: const ValueKey('mock-tab-error'),
              retryButtonKey: const ValueKey('mock-tab-retry-button'),
              error: error,
              onRetry: () =>
                  unawaited(ref.read(mockTestsProvider.notifier).refresh()),
            ),
            data: (tests) {
              final totalLogged = allTestsAsync.asData?.value.length ?? 0;
              if (totalLogged == 0) {
                return MockTestEmptyCard(
                  key: const ValueKey('mock-tab-empty'),
                  actionKey: const ValueKey('mock-tab-empty-add-button'),
                  icon: Icons.quiz_outlined,
                  iconColor: colors.goldAccent,
                  title: l10n.prepMockEmptyTitle,
                  body: l10n.prepMockEmptyBody,
                  actionLabel: l10n.prepMockTestAddButton,
                  onAction: isBusy
                      ? null
                      : () => unawaited(showMockTestFormDialog(context)),
                );
              }

              if (tests.isEmpty) {
                return MockTestEmptyCard(
                  key: const ValueKey('mock-tab-filtered-empty'),
                  actionKey: const ValueKey('mock-tab-empty-clear-button'),
                  icon: Icons.filter_alt_off_outlined,
                  iconColor: colors.textMuted,
                  title: l10n.prepMockFilteredEmptyTitle,
                  body: l10n.prepMockFilteredEmptyBody,
                  actionLabel: l10n.prepMockFilterClear,
                  primaryAction: false,
                  onAction: () =>
                      ref.read(mockTestFilterProvider.notifier).clear(),
                );
              }

              final countFormatted = AppFormatters.formatNumber(
                tests.length,
                locale: locale,
                useBanglaDigits: useBanglaDigits,
              );

              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  MockTestStatsGrid(
                    summary: summary,
                    accentColor: selectedAccent,
                    replayKey: replayKey,
                  ),
                  SizedBox(height: spacing.lg),
                  MockTestTrendChart(
                    summary: summary,
                    accentColor: selectedAccent,
                    replayKey: replayKey,
                  ),
                  SizedBox(height: spacing.md),
                  Text(
                    l10n.prepMockTestSubjectCount(
                      tests.length,
                      countFormatted,
                    ),
                    style: tokens.textStyles.labelLarge.copyWith(
                      color: colors.textSecondary,
                    ),
                  ),
                  SizedBox(height: spacing.sm),
                  for (var i = 0; i < tests.length; i++) ...[
                    if (i > 0) SizedBox(height: spacing.sm),
                    MockTestListTile(
                      test: tests[i],
                      subjectName:
                          lookup.subjectsById[tests[i].subjectId]?.name,
                      accentColor:
                          lookup.subjectColorsById[tests[i].subjectId] ??
                              colors.goldAccent,
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
                    ),
                  ],
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}
