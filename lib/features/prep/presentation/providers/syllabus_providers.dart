import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart'
    show FutureProviderFamily, ProviderFamily;
import 'package:job_prep/features/auth/presentation/providers/auth_providers.dart';
import 'package:job_prep/features/prep/domain/entities/chapter.dart';
import 'package:job_prep/features/prep/domain/entities/prep_enums.dart';
import 'package:job_prep/features/prep/domain/entities/topic.dart';
import 'package:job_prep/features/prep/domain/utils/syllabus_progress_calculator.dart';
import 'package:job_prep/features/prep/presentation/controllers/syllabus_controller.dart';
import 'package:job_prep/features/prep/presentation/providers/prep_providers.dart';

export 'package:job_prep/features/prep/presentation/controllers/syllabus_controller.dart';

Duration? _noRetry(int retryCount, Object error) => null;

/// Notifier tracking the selected subject id in the Syllabus tab.
class SelectedSyllabusSubjectNotifier extends Notifier<String?> {
  @override
  String? build() => null;

  /// The currently selected subject identifier.
  String? get currentId => state;
  set currentId(String? id) => state = id;
}

/// Currently selected subject in the Syllabus tab.
final NotifierProvider<SelectedSyllabusSubjectNotifier, String?>
    selectedSyllabusSubjectIdProvider =
    NotifierProvider<SelectedSyllabusSubjectNotifier, String?>(
  SelectedSyllabusSubjectNotifier.new,
);

/// Fetches syllabus chapters belonging to `subjectId`, ordered by `sortOrder`.
final FutureProviderFamily<List<Chapter>, String> chaptersForSubjectProvider =
    FutureProvider.family<List<Chapter>, String>(
  (ref, subjectId) {
    ref.watch(currentUserProvider.select((user) => user?.id));
    if (subjectId.trim().isEmpty) {
      return Future<List<Chapter>>.value(const []);
    }
    return ref
        .watch(chapterRepositoryProvider)
        .getChaptersForSubject(subjectId);
  },
  retry: _noRetry,
);

/// Filters topics for a specific chapter within a subject.
final ProviderFamily<List<Topic>, ({String subjectId, String chapterId})>
    topicsForChapterProvider =
    Provider.family<List<Topic>, ({String subjectId, String chapterId})>(
        (ref, arg) {
  final allTopics =
      ref.watch(topicsForSubjectProvider(arg.subjectId)).asData?.value ??
          const [];
  final filtered = allTopics.where((t) => t.chapterId == arg.chapterId).toList()
    ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
  return filtered;
});

/// Filters topics not assigned to any chapter within a subject.
final ProviderFamily<List<Topic>, String> unassignedTopicsForSubjectProvider =
    Provider.family<List<Topic>, String>((ref, subjectId) {
  final allTopics =
      ref.watch(topicsForSubjectProvider(subjectId)).asData?.value ?? const [];
  final filtered = allTopics
      .where((t) => t.chapterId == null || t.chapterId!.trim().isEmpty)
      .toList()
    ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
  return filtered;
});

/// Derives weighted syllabus progress `[0.0 .. 1.0]` for a subject.
final ProviderFamily<double, String> subjectSyllabusProgressProvider =
    Provider.family<double, String>((ref, subjectId) {
  final topics =
      ref.watch(topicsForSubjectProvider(subjectId)).asData?.value ?? const [];
  final subjects = ref.watch(subjectsProvider).asData?.value ?? const [];
  final subject = subjects.where((s) => s.id == subjectId).firstOrNull;
  final enabledCheckpoints =
      subject?.enabledCheckpoints ?? SyllabusCheckpoint.defaultEnabledValues;

  return SyllabusProgressCalculator.calculateSubjectSyllabusProgress(
    topics: topics,
    enabledCheckpoints: enabledCheckpoints,
  );
});

/// Derives weighted syllabus progress `[0.0 .. 1.0]` for a single chapter.
final ProviderFamily<double, ({String subjectId, String chapterId})>
    chapterProgressProvider =
    Provider.family<double, ({String subjectId, String chapterId})>((ref, arg) {
  final topics = ref.watch(topicsForChapterProvider(arg));
  final subjects = ref.watch(subjectsProvider).asData?.value ?? const [];
  final subject = subjects.where((s) => s.id == arg.subjectId).firstOrNull;
  final enabledCheckpoints =
      subject?.enabledCheckpoints ?? SyllabusCheckpoint.defaultEnabledValues;

  return SyllabusProgressCalculator.calculateChapterProgress(
    topics: topics,
    enabledCheckpoints: enabledCheckpoints,
  );
});

/// Provider for [SyllabusController].
final Provider<SyllabusController> syllabusControllerProvider =
    Provider<SyllabusController>(SyllabusController.new);

/// Display mode for the syllabus tab (tree hierarchy vs visual map).
enum SyllabusViewMode { tree, map }

/// Notifier coordinating syllabus view mode.
class SyllabusViewModeNotifier extends Notifier<SyllabusViewMode> {
  @override
  SyllabusViewMode build() => SyllabusViewMode.tree;

  /// Changes the current view mode.
  void setMode(SyllabusViewMode mode) {
    if (state != mode) {
      state = mode;
    }
  }
}

/// Provider managing active [SyllabusViewMode].
final NotifierProvider<SyllabusViewModeNotifier, SyllabusViewMode>
    syllabusViewModeProvider =
    NotifierProvider<SyllabusViewModeNotifier, SyllabusViewMode>(
  SyllabusViewModeNotifier.new,
);

/// Fetches all syllabus topics across all subjects.
final FutureProvider<List<Topic>> allTopicsProvider =
    FutureProvider<List<Topic>>((ref) async {
  final subjects = await ref.watch(subjectsProvider.future);
  final allTopics = <Topic>[];
  for (final s in subjects) {
    final topics = await ref.watch(topicsForSubjectProvider(s.id).future);
    allTopics.addAll(topics);
  }
  return allTopics;
});
