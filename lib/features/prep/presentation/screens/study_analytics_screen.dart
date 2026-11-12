import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:job_prep/core/theme/app_theme_tokens.dart';
import 'package:job_prep/features/prep/presentation/widgets/study_analytics_tab_view.dart';

/// Standalone route screen hosting [StudyAnalyticsTabView] when opened via
/// `/prep/analytics`.
class StudyAnalyticsScreen extends StatefulWidget {
  /// Creates a [StudyAnalyticsScreen].
  const StudyAnalyticsScreen({super.key});

  @override
  State<StudyAnalyticsScreen> createState() => _StudyAnalyticsScreenState();
}

class _StudyAnalyticsScreenState extends State<StudyAnalyticsScreen> {
  static int _nextVisitId = 0;
  late final int _visitId;

  @override
  void initState() {
    super.initState();
    _visitId = ++_nextVisitId;
  }

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final spacing = tokens.spacing;
    final breakpoints = tokens.breakpoints;
    final viewportWidth = MediaQuery.sizeOf(context).width;
    final horizontalPad =
        breakpoints.isCompact(viewportWidth) ? spacing.lg : spacing.xl;

    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(
        horizontalPad,
        spacing.xl,
        horizontalPad,
        spacing.xl + spacing.xxxl,
      ),
      child: StudyAnalyticsTabView(
        visitId: _visitId,
        onOpenSubjects: () => GoRouter.maybeOf(context)?.go('/prep'),
      ),
    );
  }
}
