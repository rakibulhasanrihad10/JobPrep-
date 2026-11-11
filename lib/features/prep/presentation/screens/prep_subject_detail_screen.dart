import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:job_prep/core/localization/app_localizations_extension.dart';
import 'package:job_prep/core/theme/app_theme_tokens.dart';
import 'package:job_prep/core/widgets/glass_button.dart';
import 'package:job_prep/core/widgets/glass_card.dart';
import 'package:job_prep/features/prep/presentation/providers/prep_providers.dart';
import 'package:job_prep/features/prep/presentation/screens/prep_screen.dart';
import 'package:job_prep/features/prep/presentation/widgets/prep_subject_detail_view.dart';

/// Responsive route widget for `/prep/:subjectId`.
///
/// Renders [PrepScreen] in a desktop master-detail split on expanded viewports
/// (> 1024 px), and a full-screen scrollable materials showcase on mobile.
class PrepSubjectDetailScreen extends ConsumerStatefulWidget {
  /// Creates a [PrepSubjectDetailScreen].
  const PrepSubjectDetailScreen({
    required this.subjectId,
    this.initialMaterialId,
    super.key,
  });

  /// Selected subject identifier.
  final String subjectId;

  /// Optional study material identifier to open immediately in the logs sheet.
  final String? initialMaterialId;

  @override
  ConsumerState<PrepSubjectDetailScreen> createState() =>
      _PrepSubjectDetailScreenState();
}

class _PrepSubjectDetailScreenState
    extends ConsumerState<PrepSubjectDetailScreen> {
  static int _nextVisitId = 0;
  late final int _visitId;

  @override
  void initState() {
    super.initState();
    _visitId = ++_nextVisitId;
  }

  void _navigateBack() {
    final router = GoRouter.maybeOf(context);
    if (router != null) {
      if (router.canPop()) {
        router.pop();
      } else {
        router.go('/prep');
      }
      return;
    }
    Navigator.of(context).maybePop();
  }

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final breakpoints = tokens.breakpoints;
    final spacing = tokens.spacing;
    final viewportWidth = MediaQuery.sizeOf(context).width;

    if (breakpoints.isExpanded(viewportWidth)) {
      return PrepScreen(
        selectedSubjectId: widget.subjectId,
        initialMaterialId: widget.initialMaterialId,
      );
    }

    final horizontalPad =
        breakpoints.isCompact(viewportWidth) ? spacing.lg : spacing.xl;
    final subjectsAsync = ref.watch(subjectsProvider);
    final subjects = subjectsAsync.asData?.value ?? const [];
    final subject =
        subjects.where((item) => item.id == widget.subjectId).firstOrNull;

    return SingleChildScrollView(
      key: const ValueKey('prep-subject-detail-fullscreen-scroll'),
      padding: EdgeInsets.fromLTRB(
        horizontalPad,
        spacing.xl,
        horizontalPad,
        spacing.xl + spacing.xxxl,
      ),
      child: subject == null
          ? GlassCard(
              padding: spacing.insetsAllXl,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    context.l10n.prepErrorNotFound,
                    style: tokens.textStyles.titleMedium,
                  ),
                  SizedBox(height: spacing.md),
                  GlassButton(
                    onPressed: _navigateBack,
                    child: Text(context.l10n.prepBackToSubjects),
                  ),
                ],
              ),
            )
          : PrepSubjectDetailView(
              subject: subject,
              initialMaterialId: widget.initialMaterialId,
              replayKey: 'mobile-detail-$_visitId-${widget.subjectId}',
              onBack: _navigateBack,
              onSubjectDeleted: _navigateBack,
            ),
    );
  }
}
