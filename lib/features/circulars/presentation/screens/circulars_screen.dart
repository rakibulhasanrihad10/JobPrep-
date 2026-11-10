import 'dart:async' show unawaited;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:job_prep/core/theme/app_theme_tokens.dart';
import 'package:job_prep/features/circulars/domain/entities/circular.dart';
import 'package:job_prep/features/circulars/presentation/providers/circulars_providers.dart';
import 'package:job_prep/features/circulars/presentation/widgets/circulars_card_list.dart';
import 'package:job_prep/features/circulars/presentation/widgets/circulars_states.dart';
import 'package:job_prep/features/circulars/presentation/widgets/circulars_table_view.dart';
import 'package:job_prep/features/circulars/presentation/widgets/circulars_toolbar.dart';

/// Main job circulars directory screen with responsive desktop table vs mobile
/// card list, search, multi-criteria filtering, and sorting.
class CircularsScreen extends ConsumerStatefulWidget {
  /// Creates a [CircularsScreen].
  const CircularsScreen({
    super.key,
    this.onTapCircular,
    this.onAddCircular,
  });

  /// Optional callback invoked when a circular row or card is tapped.
  final ValueChanged<Circular>? onTapCircular;

  /// Optional callback invoked when the add-circular action is pressed.
  final VoidCallback? onAddCircular;

  @override
  ConsumerState<CircularsScreen> createState() => _CircularsScreenState();
}

class _CircularsScreenState extends ConsumerState<CircularsScreen> {
  late final TextEditingController _searchController;
  late final AppLifecycleListener _lifecycleListener;
  bool _filtersExpanded = false;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController(
      text: ref.read(circularSearchQueryProvider),
    );
    _lifecycleListener = AppLifecycleListener(
      onResume: () {
        if (mounted) {
          setState(() {});
        }
      },
    );
  }

  @override
  void dispose() {
    _lifecycleListener.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _clearAllFilters() {
    _searchController.clear();
    ref.read(circularSearchQueryProvider.notifier).clear();
    ref.read(circularFilterProvider.notifier).reset();
  }

  void _refresh() {
    unawaited(ref.read(circularsListProvider.notifier).refresh());
  }

  void _openAddForm() {
    if (widget.onAddCircular != null) {
      widget.onAddCircular!();
      return;
    }
    GoRouter.maybeOf(context)?.go('/circulars/new');
  }

  void _openEditForm(Circular circular) {
    if (widget.onTapCircular != null) {
      widget.onTapCircular!(circular);
      return;
    }
    GoRouter.maybeOf(context)?.go(
      '/circulars/${circular.id}/edit',
      extra: circular,
    );
  }

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final spacing = tokens.spacing;
    final breakpoints = tokens.breakpoints;

    final rawListAsync = ref.watch(circularsListProvider);
    final filteredAsync = ref.watch(filteredCircularsProvider);
    final effectiveFilter = ref.watch(effectiveCircularFilterProvider);
    final viewportWidth = MediaQuery.sizeOf(context).width;

    final visibleCount = filteredAsync.asData?.value.length ?? 0;

    return SingleChildScrollView(
      padding: spacing.insetsAllXl,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final useDesktopTable = breakpoints.isExpanded(viewportWidth) &&
              !breakpoints.isCompact(constraints.maxWidth);

          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              CircularsToolbar(
                searchController: _searchController,
                visibleCount: visibleCount,
                filter: effectiveFilter,
                filtersExpanded: _filtersExpanded,
                onToggleFilters: () {
                  setState(() => _filtersExpanded = !_filtersExpanded);
                },
                onClearAllFilters: _clearAllFilters,
                onRefresh: _refresh,
                onAddCircular: _openAddForm,
              ),
              SizedBox(height: spacing.lg),
              filteredAsync.when(
                loading: () => const CircularsLoadingState(),
                error: (error, _) => CircularsErrorState(
                  error: error,
                  onRetry: _refresh,
                ),
                data: (circulars) {
                  if (circulars.isEmpty) {
                    final hasRawItems =
                        rawListAsync.asData?.value.isNotEmpty ?? false;
                    return CircularsEmptyState(
                      isFiltered:
                          hasRawItems || effectiveFilter.hasActiveFilters,
                      onClearFilters: _clearAllFilters,
                    );
                  }

                  if (useDesktopTable) {
                    return CircularsTableView(
                      circulars: circulars,
                      onTapCircular: _openEditForm,
                    );
                  }

                  return CircularsCardList(
                    circulars: circulars,
                    onTapCircular: _openEditForm,
                  );
                },
              ),
            ],
          );
        },
      ),
    );
  }
}
