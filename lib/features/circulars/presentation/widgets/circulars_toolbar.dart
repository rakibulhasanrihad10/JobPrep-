import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:job_prep/core/localization/app_localizations_extension.dart';
import 'package:job_prep/core/localization/formatters.dart';
import 'package:job_prep/core/localization/locale_controller.dart';
import 'package:job_prep/core/theme/app_theme_tokens.dart';
import 'package:job_prep/core/widgets/fade_slide_in.dart';
import 'package:job_prep/core/widgets/glass_button.dart';
import 'package:job_prep/core/widgets/glass_card.dart';
import 'package:job_prep/core/widgets/glass_text_field.dart';
import 'package:job_prep/features/circulars/domain/entities/circular_enums.dart';
import 'package:job_prep/features/circulars/domain/entities/circular_filter.dart';
import 'package:job_prep/features/circulars/presentation/providers/circulars_providers.dart';
import 'package:job_prep/features/circulars/presentation/utils/circular_l10n.dart';
import 'package:job_prep/features/circulars/presentation/widgets/circulars_filter_panel.dart';

/// Top glass toolbar providing title, count summary, search, sorting, and
/// expandable filters for the Circulars screen.
class CircularsToolbar extends ConsumerWidget {
  /// Creates a [CircularsToolbar].
  const CircularsToolbar({
    required this.searchController,
    required this.visibleCount,
    required this.filter,
    required this.filtersExpanded,
    required this.onToggleFilters,
    required this.onClearAllFilters,
    required this.onRefresh,
    this.onAddCircular,
    super.key,
  });

  /// Text controller driving the search input.
  final TextEditingController searchController;

  /// Count of currently visible circulars after filtering.
  final int visibleCount;

  /// Effective active filter configuration.
  final CircularFilter filter;

  /// Whether the advanced filter panel is currently expanded.
  final bool filtersExpanded;

  /// Callback toggling expansion of [CircularsFilterPanel].
  final VoidCallback onToggleFilters;

  /// Callback clearing search query and structured filters.
  final VoidCallback onClearAllFilters;

  /// Callback triggering a manual list reload.
  final VoidCallback onRefresh;

  /// Optional callback opening the add-circular form.
  final VoidCallback? onAddCircular;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tokens = context.tokens;
    final colors = tokens.colors;
    final spacing = tokens.spacing;
    final textStyles = tokens.textStyles;
    final l10n = context.l10n;
    final locale = ref.watch(localeProvider);
    final useBanglaDigits = ref.watch(useBanglaDigitsProvider);
    final query = ref.watch(circularSearchQueryProvider);

    final formattedCount = AppFormatters.formatNumber(
      visibleCount,
      locale: locale,
      useBanglaDigits: useBanglaDigits,
    );

    final sortWidget = Container(
      padding: EdgeInsets.symmetric(horizontal: spacing.md),
      decoration: BoxDecoration(
        color: colors.surfaceElevated,
        borderRadius: tokens.radii.buttonRadius,
        border: Border.all(color: colors.glassBorder),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<CircularSortOption>(
          key: const ValueKey('circulars-sort-dropdown'),
          value: filter.sortBy,
          isExpanded: true,
          dropdownColor: colors.surfaceElevated,
          iconEnabledColor: colors.goldAccent,
          style: textStyles.bodyMedium.copyWith(color: colors.textPrimary),
          onChanged: (option) {
            if (option != null) {
              ref.read(circularFilterProvider.notifier).setSortBy(option);
            }
          },
          items: [
            for (final option in const [
              CircularSortOption.deadlineAsc,
              CircularSortOption.priorityDesc,
              CircularSortOption.createdDesc,
              CircularSortOption.updatedDesc,
              CircularSortOption.titleAsc,
            ])
              DropdownMenuItem<CircularSortOption>(
                value: option,
                child: Text(
                  CircularL10n.sortOptionLabel(option, l10n),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
          ],
        ),
      ),
    );

    final searchField = GlassTextField(
      key: const ValueKey('circulars-search-field'),
      controller: searchController,
      hintText: l10n.circularsSearchHint,
      prefixIcon: const Icon(Icons.search_rounded),
      suffixIcon: query.isEmpty
          ? null
          : IconButton(
              key: const ValueKey('circulars-clear-search-btn'),
              tooltip: l10n.circularsClearSearchTooltip,
              onPressed: () {
                searchController.clear();
                ref.read(circularSearchQueryProvider.notifier).clear();
              },
              icon: Icon(Icons.close_rounded, color: colors.textSecondary),
            ),
      onChanged: (value) {
        ref.read(circularSearchQueryProvider.notifier).setQuery(value);
      },
    );

    return GlassCard(
      padding: spacing.insetsAllLg,
      child: FadeSlideIn(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Wrap(
              spacing: spacing.md,
              runSpacing: spacing.sm,
              alignment: WrapAlignment.spaceBetween,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.circularsTitle,
                      style: textStyles.headlineMedium,
                    ),
                    SizedBox(height: spacing.xs),
                    Text(
                      l10n.circularsCount(visibleCount, formattedCount),
                      style: textStyles.bodyMedium,
                    ),
                  ],
                ),
                Wrap(
                  spacing: spacing.sm,
                  runSpacing: spacing.sm,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    IconButton(
                      key: const ValueKey('circulars-refresh-btn'),
                      tooltip: l10n.circularsRefreshTooltip,
                      onPressed: onRefresh,
                      icon: Icon(
                        Icons.refresh_rounded,
                        color: colors.goldAccent,
                      ),
                    ),
                    if (filter.hasActiveFilters)
                      GlassButton(
                        key: const ValueKey('circulars-clear-filters-btn'),
                        onPressed: onClearAllFilters,
                        child: Text(l10n.circularsClearFilters),
                      ),
                    GlassButton(
                      key: const ValueKey('circulars-filter-toggle-btn'),
                      variant: filtersExpanded || filter.hasActiveFilters
                          ? GlassButtonVariant.primary
                          : GlassButtonVariant.standard,
                      onPressed: onToggleFilters,
                      leading: Icon(
                        Icons.tune_rounded,
                        size: spacing.lg,
                      ),
                      child: Text(l10n.circularsFilterToggle),
                    ),
                    if (onAddCircular != null)
                      GlassButton(
                        key: const ValueKey('circulars-add-btn'),
                        variant: GlassButtonVariant.primary,
                        onPressed: onAddCircular,
                        leading: Icon(
                          Icons.add_rounded,
                          size: spacing.lg,
                        ),
                        child: Text(l10n.circularsAddButton),
                      ),
                  ],
                ),
              ],
            ),
            SizedBox(height: spacing.lg),
            LayoutBuilder(
              builder: (context, constraints) {
                final isNarrow =
                    tokens.breakpoints.isCompact(constraints.maxWidth);
                if (isNarrow) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      searchField,
                      SizedBox(height: spacing.sm),
                      sortWidget,
                    ],
                  );
                }
                return Row(
                  children: [
                    Expanded(flex: 3, child: searchField),
                    SizedBox(width: spacing.md),
                    Expanded(child: sortWidget),
                  ],
                );
              },
            ),
            if (filtersExpanded) CircularsFilterPanel(filter: filter),
          ],
        ),
      ),
    );
  }
}
