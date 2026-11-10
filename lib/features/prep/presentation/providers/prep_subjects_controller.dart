import 'dart:async' show unawaited;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:job_prep/features/prep/domain/entities/prep_material.dart';
import 'package:job_prep/features/prep/domain/entities/subject.dart';
import 'package:job_prep/features/prep/presentation/providers/prep_cover_providers.dart';
import 'package:job_prep/features/prep/presentation/providers/prep_mutation_state.dart';
import 'package:job_prep/features/prep/presentation/providers/prep_providers.dart';
import 'package:job_prep/features/prep/presentation/utils/prep_templates.dart';

/// Controller managing subject creation, editing, drag/button reordering,
/// and cascading deletion (with best-effort cover storage cleanup).
class PrepSubjectsNotifier extends Notifier<PrepMutationState> {
  @override
  PrepMutationState build() => const PrepMutationState();

  /// Clears transient error state.
  void clearError() {
    state = state.copyWith(error: null);
  }

  /// Creates a new [Subject] or updates [existing].
  Future<Subject?> saveSubject({
    required String name,
    required String color,
    required String icon,
    required String examType,
    Subject? existing,
  }) async {
    state = state.copyWith(
      isSubmitting: true,
      activeId: existing?.id,
      error: null,
    );

    try {
      final repo = ref.read(subjectRepositoryProvider);
      final trimmedName = name.trim();
      final trimmedExam = examType.trim().isEmpty ? 'general' : examType.trim();

      final Subject saved;
      if (existing == null) {
        final current = ref.read(subjectsProvider).asData?.value ??
            await repo.getSubjects();
        var nextSort = 0;
        for (final item in current) {
          if (item.sortOrder >= nextSort) {
            nextSort = item.sortOrder + 1;
          }
        }
        saved = await repo.createSubject(
          Subject(
            name: trimmedName,
            color: color,
            icon: icon,
            examType: trimmedExam,
            sortOrder: nextSort,
          ),
        );
      } else {
        saved = await repo.updateSubject(
          existing.copyWith(
            name: trimmedName,
            color: color,
            icon: icon,
            examType: trimmedExam,
          ),
        );
      }

      ref.invalidate(subjectsProvider);
      state = state.copyWith(isSubmitting: false, activeId: null);
      return saved;
    } on Object catch (error) {
      state = state.copyWith(
        isSubmitting: false,
        activeId: null,
        error: error,
      );
      return null;
    }
  }

  /// Persists sequential `sortOrder` indices for [reordered].
  Future<bool> reorderSubjects(List<Subject> reordered) async {
    if (reordered.isEmpty) return true;
    state = state.copyWith(isReordering: true, error: null);
    try {
      final repo = ref.read(subjectRepositoryProvider);
      for (var i = 0; i < reordered.length; i++) {
        final subject = reordered[i];
        if (subject.sortOrder != i) {
          await repo.updateSubject(subject.copyWith(sortOrder: i));
        }
      }
      ref.invalidate(subjectsProvider);
      state = state.copyWith(isReordering: false);
      return true;
    } on Object catch (error) {
      state = state.copyWith(isReordering: false, error: error);
      return false;
    }
  }

  /// Moves the subject at [index] by [offset] (`-1` up, `+1` down).
  Future<bool> moveSubjectByOffset({
    required List<Subject> subjects,
    required int index,
    required int offset,
  }) {
    final target = index + offset;
    if (index < 0 ||
        index >= subjects.length ||
        target < 0 ||
        target >= subjects.length) {
      return Future<bool>.value(false);
    }
    final updated = List<Subject>.of(subjects);
    final moved = updated.removeAt(index);
    updated.insert(target, moved);
    return reorderSubjects(updated);
  }

  /// Deletes [subject] and best-effort removes stored covers of cascaded
  /// materials.
  Future<bool> deleteSubject(Subject subject) async {
    state = state.copyWith(
      isSubmitting: true,
      activeId: subject.id,
      error: null,
    );
    try {
      final allMaterials = ref.read(allMaterialsProvider).asData?.value ??
          await ref
              .read(materialRepositoryProvider)
              .getMaterialsForSubject(subject.id);
      final coverPaths = allMaterials
          .where(
            (m) =>
                m.subjectId == subject.id &&
                (m.coverImagePath?.trim().isNotEmpty ?? false),
          )
          .map((m) => m.coverImagePath!.trim())
          .toList(growable: false);

      await ref.read(subjectRepositoryProvider).deleteSubject(subject.id);

      final coverRepo = ref.read(materialCoverRepositoryProvider);
      for (final path in coverPaths) {
        unawaited(coverRepo.deleteCover(path).catchError((_) {}));
        ref.invalidate(materialCoverSignedUrlProvider(path));
      }

      ref
        ..invalidate(subjectsProvider)
        ..invalidate(allMaterialsProvider)
        ..invalidate(materialsForSubjectProvider(subject.id));
      state = state.copyWith(isSubmitting: false, activeId: null);
      return true;
    } on Object catch (error) {
      state = state.copyWith(
        isSubmitting: false,
        activeId: null,
        error: error,
      );
      return false;
    }
  }

  /// Creates all starter subjects and materials defined by [template].
  Future<bool> applyTemplate(PrepStarterTemplate template) async {
    state = state.copyWith(
      isSubmitting: true,
      activeId: template.id.name,
      error: null,
    );
    try {
      final subjectRepo = ref.read(subjectRepositoryProvider);
      final materialRepo = ref.read(materialRepositoryProvider);
      final existing = ref.read(subjectsProvider).asData?.value ??
          await subjectRepo.getSubjects();
      var nextSort = 0;
      for (final item in existing) {
        if (item.sortOrder >= nextSort) {
          nextSort = item.sortOrder + 1;
        }
      }

      for (final subjectSpec in template.subjects) {
        final createdSubject = await subjectRepo.createSubject(
          Subject(
            name: subjectSpec.name,
            color: subjectSpec.color,
            icon: subjectSpec.icon,
            examType: subjectSpec.examType,
            sortOrder: nextSort++,
          ),
        );
        for (final matSpec in subjectSpec.materials) {
          await materialRepo.createMaterial(
            PrepMaterial(
              subjectId: createdSubject.id,
              title: matSpec.title,
              kind: matSpec.kind,
              unitLabel: matSpec.unitLabel,
              totalUnits: matSpec.totalUnits,
            ),
          );
        }
      }

      await Future.wait(<Future<Object?>>[
        ref.refresh(subjectsProvider.future),
        ref.refresh(allMaterialsProvider.future),
      ]);
      state = state.copyWith(isSubmitting: false, activeId: null);
      return true;
    } on Object catch (error) {
      state = state.copyWith(
        isSubmitting: false,
        activeId: null,
        error: error,
      );
      return false;
    }
  }
}

/// Provides [PrepSubjectsNotifier] for subject CRUD and ordering mutations.
final NotifierProvider<PrepSubjectsNotifier, PrepMutationState>
    prepSubjectsControllerProvider =
    NotifierProvider<PrepSubjectsNotifier, PrepMutationState>(
  PrepSubjectsNotifier.new,
);
