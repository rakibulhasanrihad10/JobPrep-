import 'package:flutter/material.dart';
import 'package:job_prep/core/theme/app_theme_tokens.dart';
import 'package:job_prep/core/widgets/fade_slide_in.dart';
import 'package:job_prep/features/prep/domain/entities/subject.dart';
import 'package:job_prep/features/prep/presentation/widgets/prep_subject_detail_view.dart';

/// Responsive Subjects tab body inside `PrepScreen` supporting both expanded
/// desktop master-detail split and stacked compact layouts.
class PrepSubjectsBody extends StatelessWidget {
  /// Creates a [PrepSubjectsBody].
  const PrepSubjectsBody({
    required this.isExpanded,
    required this.hasStudyPlans,
    required this.subjects,
    required this.selectedSubject,
    required this.routeSubjectId,
    required this.initialMaterialId,
    required this.tabVisitId,
    required this.headerCard,
    required this.plansSection,
    required this.subjectsSection,
    required this.onSubjectDeleted,
    super.key,
  });

  /// Whether expanded master-detail layout is active.
  final bool isExpanded;

  /// Whether study plans section should be displayed.
  final bool hasStudyPlans;

  /// Sorted list of subjects.
  final List<Subject> subjects;

  /// Currently selected subject on desktop split layout.
  final Subject? selectedSubject;

  /// Optional route-selected subject ID matching [initialMaterialId].
  final String? routeSubjectId;

  /// Optional initial material ID to focus.
  final String? initialMaterialId;

  /// Monotonic tab visit counter controlling animation replay.
  final int tabVisitId;

  /// Overview header card widget.
  final Widget headerCard;

  /// Active study plans section widget.
  final Widget plansSection;

  /// Subjects & templates list widget.
  final Widget subjectsSection;

  /// Callback triggered when the inspected subject is deleted.
  final VoidCallback onSubjectDeleted;

  @override
  Widget build(BuildContext context) {
    final spacing = context.tokens.spacing;
    final detailSubject = selectedSubject;

    return FadeSlideIn(
      child: isExpanded && subjects.isNotEmpty && detailSubject != null
          ? Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 4,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      headerCard,
                      if (hasStudyPlans) ...[
                        SizedBox(height: spacing.lg),
                        plansSection,
                      ],
                      SizedBox(height: spacing.lg),
                      subjectsSection,
                    ],
                  ),
                ),
                SizedBox(width: spacing.xl),
                Expanded(
                  flex: 8,
                  child: PrepSubjectDetailView(
                    subject: detailSubject,
                    initialMaterialId: detailSubject.id == routeSubjectId
                        ? initialMaterialId
                        : null,
                    replayKey: 'detail-visit-$tabVisitId-${detailSubject.id}',
                    onSubjectDeleted: onSubjectDeleted,
                  ),
                ),
              ],
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                headerCard,
                if (hasStudyPlans) ...[
                  SizedBox(height: spacing.lg),
                  plansSection,
                ],
                SizedBox(height: spacing.lg),
                subjectsSection,
              ],
            ),
    );
  }
}
