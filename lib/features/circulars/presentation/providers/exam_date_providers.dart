import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show FutureProviderFamily;
import 'package:job_prep/core/supabase/supabase_provider.dart';
import 'package:job_prep/features/auth/presentation/providers/auth_providers.dart';
import 'package:job_prep/features/circulars/data/repositories/supabase_exam_date_repository.dart';
import 'package:job_prep/features/circulars/data/repositories/unconfigured_exam_date_repository.dart';
import 'package:job_prep/features/circulars/domain/entities/circular_exam_date.dart';
import 'package:job_prep/features/circulars/domain/errors/circular_failure.dart';
import 'package:job_prep/features/circulars/domain/repositories/exam_date_repository.dart';
import 'package:job_prep/features/circulars/presentation/providers/circulars_providers.dart';

Duration? _noRetry(int retryCount, Object error) => null;

/// Dependency-injected [ExamDateRepository] provider.
///
/// Override this provider in tests with an in-memory fake repository.
final Provider<ExamDateRepository> examDateRepositoryProvider =
    Provider<ExamDateRepository>((ref) {
  final client = ref.watch(optionalSupabaseClientProvider);
  if (client == null) {
    return const UnconfiguredExamDateRepository();
  }
  return SupabaseExamDateRepository(client);
});

/// Fetches all exam dates for `circularId` ordered earliest first.
final FutureProviderFamily<List<CircularExamDate>, String>
    circularExamDatesProvider =
    FutureProvider.family<List<CircularExamDate>, String>(
  (ref, circularId) {
    ref.watch(currentUserProvider.select((user) => user?.id));
    if (circularId.trim().isEmpty) {
      return Future<List<CircularExamDate>>.value(const []);
    }
    return ref.watch(examDateRepositoryProvider).getExamDatesForCircular(
          circularId,
        );
  },
  retry: _noRetry,
);

/// Notifier handling create, update, and delete operations against
/// [ExamDateRepository] and refreshing circular/exam-date caches.
class ExamDateMutationNotifier extends Notifier<AsyncValue<void>> {
  @override
  AsyncValue<void> build() => const AsyncData<void>(null);

  /// Inserts [examDate] via [ExamDateRepository] and invalidates caches.
  Future<CircularExamDate?> createExamDate(CircularExamDate examDate) async {
    state = const AsyncLoading<void>();
    try {
      final created =
          await ref.read(examDateRepositoryProvider).createExamDate(examDate);
      if (!ref.mounted) return created;
      state = const AsyncData<void>(null);
      _invalidateCaches(created.circularId);
      return created;
    } on CircularFailure catch (failure, stackTrace) {
      if (ref.mounted) {
        state = AsyncError<void>(failure, stackTrace);
      }
      return null;
    } on Object catch (error, stackTrace) {
      if (ref.mounted) {
        state = AsyncError<void>(
          UnknownCircularFailure(message: error.toString()),
          stackTrace,
        );
      }
      return null;
    }
  }

  /// Updates [examDate] via [ExamDateRepository] and invalidates caches.
  Future<CircularExamDate?> updateExamDate(CircularExamDate examDate) async {
    state = const AsyncLoading<void>();
    try {
      final updated =
          await ref.read(examDateRepositoryProvider).updateExamDate(examDate);
      if (!ref.mounted) return updated;
      state = const AsyncData<void>(null);
      _invalidateCaches(updated.circularId);
      return updated;
    } on CircularFailure catch (failure, stackTrace) {
      if (ref.mounted) {
        state = AsyncError<void>(failure, stackTrace);
      }
      return null;
    } on Object catch (error, stackTrace) {
      if (ref.mounted) {
        state = AsyncError<void>(
          UnknownCircularFailure(message: error.toString()),
          stackTrace,
        );
      }
      return null;
    }
  }

  /// Deletes exam date [examDateId] belonging to [circularId].
  Future<bool> deleteExamDate({
    required String examDateId,
    required String circularId,
  }) async {
    state = const AsyncLoading<void>();
    try {
      await ref.read(examDateRepositoryProvider).deleteExamDate(examDateId);
      if (!ref.mounted) return true;
      state = const AsyncData<void>(null);
      _invalidateCaches(circularId);
      return true;
    } on CircularFailure catch (failure, stackTrace) {
      if (ref.mounted) {
        state = AsyncError<void>(failure, stackTrace);
      }
      return false;
    } on Object catch (error, stackTrace) {
      if (ref.mounted) {
        state = AsyncError<void>(
          UnknownCircularFailure(message: error.toString()),
          stackTrace,
        );
      }
      return false;
    }
  }

  /// Clears any previous mutation failure state.
  void clearError() {
    if (state.hasError) {
      state = const AsyncData<void>(null);
    }
  }

  void _invalidateCaches(String circularId) {
    ref
      ..invalidate(circularExamDatesProvider(circularId))
      ..invalidate(circularByIdProvider(circularId))
      ..invalidate(circularsListProvider);
  }
}

/// Provides exam date add, edit, and delete mutation actions.
final NotifierProvider<ExamDateMutationNotifier, AsyncValue<void>>
    examDateMutationProvider =
    NotifierProvider<ExamDateMutationNotifier, AsyncValue<void>>(
  ExamDateMutationNotifier.new,
);
