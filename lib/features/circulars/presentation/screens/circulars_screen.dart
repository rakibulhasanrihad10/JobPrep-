import 'dart:async' show unawaited;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:job_prep/core/theme/app_theme_tokens.dart';
import 'package:job_prep/features/circulars/domain/entities/circular.dart';
import 'package:job_prep/features/circulars/presentation/providers/circulars_providers.dart';
import 'package:job_prep/features/circulars/presentation/screens/circular_detail_screen.dart';
import 'package:job_prep/features/circulars/presentation/widgets/circular_detail_view.dart';
import 'package:job_prep/features/circulars/presentation/widgets/circulars_card_list.dart';
import 'package:job_prep/features/circulars/presentation/widgets/circulars_states.dart';
import 'package:job_prep/features/circulars/presentation/widgets/circulars_table_view.dart';
import 'package:job_prep/features/circulars/presentation/widgets/circulars_toolbar.dart';

/// Main job circulars directory screen with responsive desktop table vs mobile
/// card list, master-detail right pane on desktop, search, filtering, and sort.
class CircularsScreen extends ConsumerStatefulWidget {
  /// Creates a [CircularsScreen].
  const CircularsScreen({
    super.key,
    this.selectedCircularId,
    this.initialSelectedCircular,
    this.onTapCircular,
    this.onAddCircular,
  });

  /// Initially selected circular shown in desktop master-detail right pane.
  final String? selectedCircularId;

  /// Optional preloaded instance matching [selectedCircularId].
  final Circular? initialSelectedCircular;

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
  String? _localSelectedId;
  Circular? _localSelectedCircular;

  @override
  void initState() {
    super.initState();
    _localSelectedId = widget.selectedCircularId;
    _localSelectedCircular = widget.initialSelectedCircular;
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
  void didUpdateWidget(CircularsScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selectedCircularId != oldWidget.selectedCircularId ||
        widget.initialSelectedCircular != oldWidget.initialSelectedCircular) {
      _localSelectedId = widget.selectedCircularId;
      _localSelectedCircular = widget.initialSelectedCircular;
    }
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

  void _openCircularDetail(Circular circular, {required bool isExpanded}) {
    if (widget.onTapCircular != null) {
      widget.onTapCircular!(circular);
      return;
    }

    final router = GoRouter.maybeOf(context);
    if (isExpanded) {
      if (router != null) {
        router.go('/circulars/${circular.id}', extra: circular);
        return;
      }
      setState(() {
        _localSelectedId = circular.id;
        _localSelectedCircular = circular;
      });
      return;
    }

    if (router != null) {
      router.go('/circulars/${circular.id}', extra: circular);
      return;
    }

    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => Scaffold(
          body: CircularDetailScreen(
            circularId: circular.id,
            initialCircular: circular,
          ),
        ),
      ),
    );
  }

  void _closeDetailPane() {
    final router = GoRouter.maybeOf(context);
    if (router != null) {
      router.go('/circulars');
      return;
    }
    setState(() {
      _localSelectedId = null;
      _localSelectedCircular = null;
    });
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
    final isExpandedViewport = breakpoints.isExpanded(viewportWidth);

    final visibleCount = filteredAsync.asData?.value.length ?? 0;
    final activeSelectedId = widget.selectedCircularId ?? _localSelectedId;
    final showMasterDetail = isExpandedViewport &&
        activeSelectedId != null &&
        widget.onTapCircular == null;

    Widget buildMasterColumn({required bool forceCards}) {
      return LayoutBuilder(
        builder: (context, constraints) {
          final useDesktopTable = !forceCards &&
              isExpandedViewport &&
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
                      onTapCircular: (c) => _openCircularDetail(
                        c,
                        isExpanded: isExpandedViewport,
                      ),
                    );
                  }

                  return CircularsCardList(
                    circulars: circulars,
                    selectedCircularId:
                        showMasterDetail ? activeSelectedId : null,
                    onTapCircular: (c) => _openCircularDetail(
                      c,
                      isExpanded: isExpandedViewport,
                    ),
                  );
                },
              ),
            ],
          );
        },
      );
    }

    if (!showMasterDetail) {
      return SingleChildScrollView(
        padding: spacing.insetsAllXl,
        child: buildMasterColumn(forceCards: false),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final masterPane = SingleChildScrollView(
          key: const ValueKey('circulars-master-pane-scroll'),
          padding: EdgeInsets.fromLTRB(
            spacing.xl,
            spacing.xl,
            spacing.sm,
            spacing.xl,
          ),
          child: buildMasterColumn(forceCards: true),
        );

        final detailPane = SingleChildScrollView(
          key: const ValueKey('circulars-detail-pane-scroll'),
          padding: EdgeInsets.fromLTRB(
            spacing.sm,
            spacing.xl,
            spacing.xl,
            spacing.xl,
          ),
          child: CircularDetailView(
            key: ValueKey('circular-detail-pane-$activeSelectedId'),
            circularId: activeSelectedId,
            initialCircular:
                widget.initialSelectedCircular ?? _localSelectedCircular,
            isPane: true,
            onCloseOrBack: _closeDetailPane,
            onDeleted: _closeDetailPane,
          ),
        );

        final splitRow = Row(
          key: const ValueKey('circulars-master-detail-layout'),
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(flex: 5, child: masterPane),
            Expanded(flex: 6, child: detailPane),
          ],
        );

        if (constraints.hasBoundedHeight) {
          return SizedBox(
            height: constraints.maxHeight,
            child: splitRow,
          );
        }
        return splitRow;
      },
    );
  }
}
