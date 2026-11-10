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
/// (> 1024 px), and a full-screen scrollable materials manager on mobile/tablet.
class PrepSubjectDetailScreen extends ConsumerWidget {
  /// Creates a [PrepSubjectDetailScreen].
  const PrepSubjectDetailScreen({
    required this.subjectId,
    super.key,
  });

  /// Selected subject identifier.
  final String subjectId;

  void _navigateBack(BuildContext context) {
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
  Widget build(BuildContext context, WidgetRef ref) {
    final tokens = context.tokens;
    final breakpoints = tokens.breakpoints;
    final spacing = tokens.spacing;
    final viewportWidth = MediaQuery.sizeOf(context).width;

    if (breakpoints.isExpanded(viewportWidth)) {
      return PrepScreen(selectedSubjectId: subjectId);
    }

    final subjectsAsync = ref.watch(subjectsProvider);
    final subjects = subjectsAsync.asData?.value ?? const [];
    final subject = subjects.where((item) => item.id == subjectId).firstOrNull;

    return SingleChildScrollView(
      key: const ValueKey('prep-subject-detail-fullscreen-scroll'),
      padding: EdgeInsets.fromLTRB(
        spacing.xl,
        spacing.xl,
        spacing.xl,
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
                    onPressed: () => _navigateBack(context),
                    child: Text(context.l10n.prepBackToSubjects),
                  ),
                ],
              ),
            )
          : PrepSubjectDetailView(
              subject: subject,
              replayKey: 'detail-$subjectId',
              onBack: () => _navigateBack(context),
              onSubjectDeleted: () => _navigateBack(context),
            ),
    );
  }
}
