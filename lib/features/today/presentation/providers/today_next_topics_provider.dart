import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:job_prep/features/prep/domain/entities/subject.dart';
import 'package:job_prep/features/prep/domain/entities/topic.dart';
import 'package:job_prep/features/prep/domain/utils/syllabus_progress_calculator.dart';
import 'package:job_prep/features/prep/presentation/providers/prep_providers.dart';
import 'package:job_prep/features/prep/presentation/providers/study_plan_providers.dart';
import 'package:job_prep/features/prep/presentation/providers/syllabus_providers.dart';

/// Single item representing an upcoming incomplete syllabus topic for Today.
class NextTopicItem {
  /// Creates a [NextTopicItem].
  const NextTopicItem({
    required this.topic,
    required this.subject,
    required this.progress,
    required this.enabledCheckpoints,
  });

  /// The syllabus topic entity.
  final Topic topic;

  /// The parent subject entity.
  final Subject subject;

  /// Weighted completion progress `[0.0 .. 1.0]`.
  final double progress;

  /// Checkpoints configured for the parent subject.
  final List<String> enabledCheckpoints;
}

/// Computes first 3 incomplete topics from subjects that have an active plan.
final Provider<AsyncValue<List<NextTopicItem>>> todayNextTopicsProvider =
    Provider<AsyncValue<List<NextTopicItem>>>((ref) {
  final snapshotsAsync = ref.watch(studyPlanSnapshotsProvider);
  final subjectsAsync = ref.watch(subjectsProvider);

  if (snapshotsAsync.isLoading || subjectsAsync.isLoading) {
    return const AsyncLoading<List<NextTopicItem>>();
  }

  final snapshots = snapshotsAsync.asData?.value ?? const [];
  final subjects = subjectsAsync.asData?.value ?? const [];
  if (snapshots.isEmpty || subjects.isEmpty) {
    return const AsyncData<List<NextTopicItem>>([]);
  }

  final subjectMap = <String, Subject>{for (final s in subjects) s.id: s};

  // Find subject IDs with an active study plan
  final activeSubjectIds = <String>{};
  for (final s in snapshots) {
    if (s.remainingUnits > 0 && !s.isPastBufferOrTarget) {
      if (s.plan.isAllSubjects) {
        activeSubjectIds.addAll(subjectMap.keys);
      } else if (s.plan.subjectId != null) {
        activeSubjectIds.add(s.plan.subjectId!);
      }
    }
  }

  if (activeSubjectIds.isEmpty) {
    return const AsyncData<List<NextTopicItem>>([]);
  }

  final allTopics = ref.watch(allTopicsProvider).asData?.value ?? const [];
  if (allTopics.isEmpty) {
    return const AsyncData<List<NextTopicItem>>([]);
  }

  final result = <NextTopicItem>[];

  for (final subjectId in activeSubjectIds) {
    final subject = subjectMap[subjectId];
    if (subject == null) continue;

    final subjectTopics = allTopics
        .where((t) => t.subjectId == subjectId)
        .toList()
      ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));

    for (final topic in subjectTopics) {
      final progress = SyllabusProgressCalculator.calculateTopicProgress(
        topic: topic,
        enabledCheckpoints: subject.enabledCheckpoints,
      );
      if (progress < 1.0) {
        result.add(
          NextTopicItem(
            topic: topic,
            subject: subject,
            progress: progress,
            enabledCheckpoints: subject.enabledCheckpoints,
          ),
        );
        if (result.length >= 3) {
          return AsyncData<List<NextTopicItem>>(result);
        }
      }
    }
  }

  return AsyncData<List<NextTopicItem>>(result);
});
