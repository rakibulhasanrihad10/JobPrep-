import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart'
    show FutureProviderFamily, ProviderFamily;
import 'package:job_prep/core/supabase/supabase_provider.dart';
import 'package:job_prep/features/auth/presentation/providers/auth_providers.dart';
import 'package:job_prep/features/prep/data/repositories/supabase_material_repository.dart';
import 'package:job_prep/features/prep/data/repositories/supabase_progress_log_repository.dart';
import 'package:job_prep/features/prep/data/repositories/supabase_subject_repository.dart';
import 'package:job_prep/features/prep/data/repositories/supabase_topic_repository.dart';
import 'package:job_prep/features/prep/data/repositories/unconfigured_material_repository.dart';
import 'package:job_prep/features/prep/data/repositories/unconfigured_progress_log_repository.dart';
import 'package:job_prep/features/prep/data/repositories/unconfigured_subject_repository.dart';
import 'package:job_prep/features/prep/data/repositories/unconfigured_topic_repository.dart';
import 'package:job_prep/features/prep/domain/entities/prep_material.dart';
import 'package:job_prep/features/prep/domain/entities/progress_log.dart';
import 'package:job_prep/features/prep/domain/entities/subject.dart';
import 'package:job_prep/features/prep/domain/entities/topic.dart';
import 'package:job_prep/features/prep/domain/repositories/material_repository.dart';
import 'package:job_prep/features/prep/domain/repositories/progress_log_repository.dart';
import 'package:job_prep/features/prep/domain/repositories/subject_repository.dart';
import 'package:job_prep/features/prep/domain/repositories/topic_repository.dart';
import 'package:job_prep/features/prep/domain/utils/prep_progress.dart';

Duration? _noRetry(int retryCount, Object error) => null;

/// Dependency-injected [SubjectRepository] provider.
final Provider<SubjectRepository> subjectRepositoryProvider =
    Provider<SubjectRepository>((ref) {
  final client = ref.watch(optionalSupabaseClientProvider);
  if (client == null) {
    return const UnconfiguredSubjectRepository();
  }
  return SupabaseSubjectRepository(client);
});

/// Dependency-injected [MaterialRepository] provider.
final Provider<MaterialRepository> materialRepositoryProvider =
    Provider<MaterialRepository>((ref) {
  final client = ref.watch(optionalSupabaseClientProvider);
  if (client == null) {
    return const UnconfiguredMaterialRepository();
  }
  return SupabaseMaterialRepository(client);
});

/// Dependency-injected [ProgressLogRepository] provider.
final Provider<ProgressLogRepository> progressLogRepositoryProvider =
    Provider<ProgressLogRepository>((ref) {
  final client = ref.watch(optionalSupabaseClientProvider);
  if (client == null) {
    return const UnconfiguredProgressLogRepository();
  }
  return SupabaseProgressLogRepository(client);
});

/// Dependency-injected [TopicRepository] provider.
final Provider<TopicRepository> topicRepositoryProvider =
    Provider<TopicRepository>((ref) {
  final client = ref.watch(optionalSupabaseClientProvider);
  if (client == null) {
    return const UnconfiguredTopicRepository();
  }
  return SupabaseTopicRepository(client);
});

/// Async notifier loading all study subjects for the signed-in user.
class SubjectsNotifier extends AsyncNotifier<List<Subject>> {
  @override
  Future<List<Subject>> build() {
    ref.watch(currentUserProvider.select((user) => user?.id));
    return ref.watch(subjectRepositoryProvider).getSubjects();
  }

  /// Refreshes subjects from [SubjectRepository].
  Future<List<Subject>> refresh() {
    ref.invalidateSelf();
    return future;
  }
}

/// Provides all study subjects for the active user.
final AsyncNotifierProvider<SubjectsNotifier, List<Subject>> subjectsProvider =
    AsyncNotifierProvider<SubjectsNotifier, List<Subject>>(
  SubjectsNotifier.new,
  retry: _noRetry,
);

/// Async notifier loading all materials across all subjects for the user.
class AllMaterialsNotifier extends AsyncNotifier<List<PrepMaterial>> {
  @override
  Future<List<PrepMaterial>> build() {
    ref.watch(currentUserProvider.select((user) => user?.id));
    return ref.watch(materialRepositoryProvider).getAllMaterials();
  }

  /// Refreshes all materials from [MaterialRepository].
  Future<List<PrepMaterial>> refresh() {
    ref.invalidateSelf();
    return future;
  }
}

/// Provides all study materials across all subjects.
final AsyncNotifierProvider<AllMaterialsNotifier, List<PrepMaterial>>
    allMaterialsProvider =
    AsyncNotifierProvider<AllMaterialsNotifier, List<PrepMaterial>>(
  AllMaterialsNotifier.new,
  retry: _noRetry,
);

/// Fetches all study materials belonging to `subjectId`.
final FutureProviderFamily<List<PrepMaterial>, String>
    materialsForSubjectProvider =
    FutureProvider.family<List<PrepMaterial>, String>(
  (ref, subjectId) {
    ref.watch(currentUserProvider.select((user) => user?.id));
    if (subjectId.trim().isEmpty) {
      return Future<List<PrepMaterial>>.value(const []);
    }
    return ref.watch(materialRepositoryProvider).getMaterialsForSubject(
          subjectId,
        );
  },
  retry: _noRetry,
);

/// Fetches all progress logs recorded for `materialId`, newest first.
final FutureProviderFamily<List<ProgressLog>, String>
    progressLogsForMaterialProvider =
    FutureProvider.family<List<ProgressLog>, String>(
  (ref, materialId) {
    ref.watch(currentUserProvider.select((user) => user?.id));
    if (materialId.trim().isEmpty) {
      return Future<List<ProgressLog>>.value(const []);
    }
    return ref.watch(progressLogRepositoryProvider).getLogsForMaterial(
          materialId,
        );
  },
  retry: _noRetry,
);

/// Fetches recent progress logs across all materials.
final FutureProvider<List<ProgressLog>> recentProgressLogsProvider =
    FutureProvider<List<ProgressLog>>(
  (ref) {
    ref.watch(currentUserProvider.select((user) => user?.id));
    return ref.watch(progressLogRepositoryProvider).getRecentLogs();
  },
  retry: _noRetry,
);

/// Fetches extended recent progress logs (`limit: 2000`) for Study Analytics
/// date windows, streaks, and calendar heatmap calculations.
final FutureProvider<List<ProgressLog>> analyticsProgressLogsProvider =
    FutureProvider<List<ProgressLog>>(
  (ref) {
    ref.watch(currentUserProvider.select((user) => user?.id));
    return ref.watch(progressLogRepositoryProvider).getRecentLogs(limit: 2000);
  },
  retry: _noRetry,
);

/// Fetches syllabus topics belonging to `subjectId`.
final FutureProviderFamily<List<Topic>, String> topicsForSubjectProvider =
    FutureProvider.family<List<Topic>, String>(
  (ref, subjectId) {
    ref.watch(currentUserProvider.select((user) => user?.id));
    if (subjectId.trim().isEmpty) {
      return Future<List<Topic>>.value(const []);
    }
    return ref.watch(topicRepositoryProvider).getTopicsForSubject(subjectId);
  },
  retry: _noRetry,
);

/// Derives normalized progress (`0.0` to `1.0`) for `subjectId` using
/// `calculateSubjectProgress`.
final ProviderFamily<AsyncValue<double>, String> subjectProgressProvider =
    Provider.family<AsyncValue<double>, String>((ref, subjectId) {
  final materialsAsync = ref.watch(materialsForSubjectProvider(subjectId));
  return materialsAsync.whenData(calculateSubjectProgress);
});

/// Derives normalized overall progress (`0.0` to `1.0`) across all subjects
/// using `calculateOverallProgress`.
final Provider<AsyncValue<double>> overallPrepProgressProvider =
    Provider<AsyncValue<double>>((ref) {
  final subjectsAsync = ref.watch(subjectsProvider);
  final materialsAsync = ref.watch(allMaterialsProvider);

  return switch ((subjectsAsync, materialsAsync)) {
    (AsyncError(:final error, :final stackTrace), _) =>
      AsyncError<double>(error, stackTrace),
    (_, AsyncError(:final error, :final stackTrace)) =>
      AsyncError<double>(error, stackTrace),
    (AsyncLoading(), _) || (_, AsyncLoading()) => const AsyncLoading<double>(),
    (AsyncData(value: final subjects), AsyncData(value: final materials)) =>
      AsyncData<double>(
        calculateOverallProgress(subjects: subjects, materials: materials),
      ),
  };
});
