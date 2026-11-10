import 'package:flutter/material.dart';
import 'package:job_prep/core/theme/app_theme_tokens.dart';
import 'package:job_prep/features/circulars/domain/entities/circular.dart';
import 'package:job_prep/features/circulars/presentation/screens/circulars_screen.dart';
import 'package:job_prep/features/circulars/presentation/widgets/circular_detail_view.dart';

/// Responsive route widget for `/circulars/:id`.
///
/// Renders [CircularsScreen] in a desktop master-detail split view on expanded
/// viewports (> 1024 px), and renders [CircularDetailView] as a full-screen
/// scrollable page on compact/mobile and tablet viewports.
class CircularDetailScreen extends StatelessWidget {
  /// Creates a [CircularDetailScreen].
  const CircularDetailScreen({
    required this.circularId,
    super.key,
    this.initialCircular,
    this.onBack,
    this.onEdit,
  });

  /// Selected circular identifier.
  final String circularId;

  /// Optional preloaded circular passed via route extra.
  final Circular? initialCircular;

  /// Optional callback fired when closing or navigating back.
  final VoidCallback? onBack;

  /// Optional callback fired when pressing Edit.
  final ValueChanged<Circular>? onEdit;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final breakpoints = tokens.breakpoints;
    final spacing = tokens.spacing;
    final viewportWidth = MediaQuery.sizeOf(context).width;

    if (breakpoints.isExpanded(viewportWidth)) {
      return CircularsScreen(
        selectedCircularId: circularId,
        initialSelectedCircular: initialCircular,
      );
    }

    return SingleChildScrollView(
      key: const ValueKey('circular-detail-fullscreen-scroll'),
      padding: EdgeInsets.fromLTRB(
        spacing.xl,
        spacing.xl,
        spacing.xl,
        spacing.xl + spacing.xxxl,
      ),
      child: CircularDetailView(
        circularId: circularId,
        initialCircular: initialCircular,
        onCloseOrBack: onBack,
        onEdit: onEdit,
      ),
    );
  }
}
