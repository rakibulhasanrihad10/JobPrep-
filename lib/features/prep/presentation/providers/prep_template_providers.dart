import 'package:flutter/foundation.dart' show immutable;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:job_prep/core/supabase/supabase_provider.dart';
import 'package:job_prep/features/auth/presentation/providers/auth_providers.dart';
import 'package:job_prep/features/prep/data/repositories/supabase_prep_template_repository.dart';
import 'package:job_prep/features/prep/data/repositories/unconfigured_prep_template_repository.dart';
import 'package:job_prep/features/prep/domain/entities/prep_material.dart';
import 'package:job_prep/features/prep/domain/entities/prep_template.dart';
import 'package:job_prep/features/prep/domain/entities/subject.dart';
import 'package:job_prep/features/prep/domain/errors/prep_failure.dart';
import 'package:job_prep/features/prep/domain/repositories/prep_template_repository.dart';
import 'package:job_prep/features/prep/domain/utils/prep_template_planner.dart';
import 'package:job_prep/features/prep/presentation/providers/prep_providers.dart';

Duration? _noRetry(int retryCount, Object error) => null;

/// Dependency-injected [PrepTemplateRepository] provider.
final Provider<PrepTemplateRepository> prepTemplateRepositoryProvider =
    Provider<PrepTemplateRepository>((ref) {
  final client = ref.watch(optionalSupabaseClientProvider);
  if (client == null) {
    return const UnconfiguredPrepTemplateRepository();
  }
  return SupabasePrepTemplateRepository(client);
});

/// Async notifier loading seeded read-only starter packs plus the user's
/// saved personal templates.
class PrepTemplatesNotifier extends AsyncNotifier<List<PrepTemplate>> {
  @override
  Future<List<PrepTemplate>> build() {
    ref.watch(currentUserProvider.select((user) => user?.id));
    return ref.watch(prepTemplateRepositoryProvider).getTemplates();
  }

  /// Reloads available starter and personal templates.
  Future<List<PrepTemplate>> refresh() {
    ref.invalidateSelf();
    return future;
  }
}

/// Provides ordered system packs and user-saved personal templates.
final AsyncNotifierProvider<PrepTemplatesNotifier, List<PrepTemplate>>
    prepTemplatesProvider =
    AsyncNotifierProvider<PrepTemplatesNotifier, List<PrepTemplate>>(
  PrepTemplatesNotifier.new,
  retry: _noRetry,
);

/// Immutable mutation state for applying, saving, or deleting templates.
@immutable
class PrepTemplateActionState {
  /// Creates a [PrepTemplateActionState].
  const PrepTemplateActionState({
    this.isBusy = false,
    this.activeTemplateId,
    this.lastApplyResult,
    this.error,
  });

  static const Object _unset = Object();

  /// Whether a template apply, save, or delete call is currently running.
  final bool isBusy;

  /// Identifier/slug of the template actively mutating, if any.
  final String? activeTemplateId;

  /// Last summary returned by `PrepTemplateActionController.applyTemplate`.
  final PrepTemplateApplyResult? lastApplyResult;

  /// Latest failure thrown while applying or managing a template.
  final Object? error;

  /// Returns a copy with specified fields replaced.
  PrepTemplateActionState copyWith({
    bool? isBusy,
    Object? activeTemplateId = _unset,
    Object? lastApplyResult = _unset,
    Object? error = _unset,
  }) {
    return PrepTemplateActionState(
      isBusy: isBusy ?? this.isBusy,
      activeTemplateId: identical(activeTemplateId, _unset)
          ? this.activeTemplateId
          : activeTemplateId as String?,
      lastApplyResult: identical(lastApplyResult, _unset)
          ? this.lastApplyResult
          : lastApplyResult as PrepTemplateApplyResult?,
      error: identical(error, _unset) ? this.error : error,
    );
  }
}

/// Coordinates idempotent template application (with concurrency + double-apply
/// deduplication), saving user subjects as personal templates, and deletion.
class PrepTemplateActionController extends Notifier<PrepTemplateActionState> {
  final Set<String> _inFlightTemplateKeys = <String>{};

  @override
  PrepTemplateActionState build() {
    _inFlightTemplateKeys.clear();
    return const PrepTemplateActionState();
  }

  /// Clears any surfaced error.
  void clearError() {
    state = state.copyWith(error: null);
  }

  /// Copies [template] subjects and example materials into the user's own
  /// prep workspace without duplicating already-present subjects or materials.
  Future<PrepTemplateApplyResult?> applyTemplate(
    PrepTemplate template, {
    Map<String, int> unitOverrides = const {},
  }) async {
    final activeKey = template.stableKey.isNotEmpty
        ? template.stableKey
        : template.title.trim().toLowerCase();
    if (_inFlightTemplateKeys.contains(activeKey)) {
      return null;
    }

    _inFlightTemplateKeys.add(activeKey);
    state = state.copyWith(
      isBusy: true,
      activeTemplateId: activeKey,
      error: null,
    );

    try {
      final subjectRepo = ref.read(subjectRepositoryProvider);
      final materialRepo = ref.read(materialRepositoryProvider);
      final existingSubjects = await subjectRepo.getSubjects();
      final existingMaterials = await materialRepo.getAllMaterials();

      final plan = PrepTemplatePlanner.buildPlan(
        template: template,
        existingSubjects: existingSubjects,
        existingMaterials: existingMaterials,
        unitOverrides: unitOverrides,
      );

      if (!plan.hasChanges) {
        state = state.copyWith(
          isBusy: false,
          activeTemplateId: null,
          lastApplyResult: plan.summary,
        );
        return plan.summary;
      }

      final touchedSubjectIds = <String>{};
      for (final op in plan.operations) {
        String resolvedSubjectId;
        if (op.subjectToCreate != null) {
          final createdSubject =
              await subjectRepo.createSubject(op.subjectToCreate!);
          resolvedSubjectId = createdSubject.id;
        } else {
          resolvedSubjectId = op.existingSubjectId!;
        }
        touchedSubjectIds.add(resolvedSubjectId);

        for (final mat in op.materialsToCreate) {
          await materialRepo.createMaterial(
            mat.copyWith(subjectId: resolvedSubjectId),
          );
        }
      }

      for (final subjectId in touchedSubjectIds) {
        ref.invalidate(materialsForSubjectProvider(subjectId));
      }
      await Future.wait(<Future<Object?>>[
        ref.refresh(subjectsProvider.future),
        ref.refresh(allMaterialsProvider.future),
      ]);

      state = state.copyWith(
        isBusy: false,
        activeTemplateId: null,
        lastApplyResult: plan.summary,
      );
      return plan.summary;
    } on Object catch (error) {
      state = state.copyWith(
        isBusy: false,
        activeTemplateId: null,
        error: error,
      );
      return null;
    } finally {
      _inFlightTemplateKeys.remove(activeKey);
    }
  }

  /// Saves a snapshot of [subjects] and [materials] as a personal template.
  Future<PrepTemplate?> savePersonalTemplate({
    required String title,
    required List<Subject> subjects,
    required List<PrepMaterial> materials,
    String? description,
    String examType = 'general',
  }) async {
    final trimmedTitle = title.trim();
    if (trimmedTitle.isEmpty) {
      state = state.copyWith(
        error: const PrepValidationFailure(
          code: 'missing_template_title',
          message: 'Template title must not be empty.',
        ),
      );
      return null;
    }
    if (subjects.isEmpty) {
      state = state.copyWith(
        error: const PrepValidationFailure(
          code: 'empty_template_subjects',
          message: 'At least one subject is required to save a template.',
        ),
      );
      return null;
    }

    state = state.copyWith(
      isBusy: true,
      activeTemplateId: 'save-personal',
      error: null,
    );

    try {
      final created =
          await ref.read(prepTemplateRepositoryProvider).savePersonalTemplate(
                title: trimmedTitle,
                subjects: subjects,
                materials: materials,
                description: description,
                examType: examType,
              );
      ref.invalidate(prepTemplatesProvider);
      await ref.read(prepTemplatesProvider.future);
      state = state.copyWith(isBusy: false, activeTemplateId: null);
      return created;
    } on Object catch (error) {
      state = state.copyWith(
        isBusy: false,
        activeTemplateId: null,
        error: error,
      );
      return null;
    }
  }

  /// Deletes a user-owned personal [template]; rejects seeded system packs.
  Future<bool> deletePersonalTemplate(PrepTemplate template) async {
    if (template.isSystem) {
      state = state.copyWith(
        error: const PrepPermissionFailure(
          code: 'system_template_readonly',
          message: 'Built-in starter packs cannot be deleted.',
        ),
      );
      return false;
    }

    final key = template.stableKey;
    state = state.copyWith(
      isBusy: true,
      activeTemplateId: key,
      error: null,
    );

    try {
      await ref
          .read(prepTemplateRepositoryProvider)
          .deletePersonalTemplate(template.id);
      ref.invalidate(prepTemplatesProvider);
      await ref.read(prepTemplatesProvider.future);
      state = state.copyWith(isBusy: false, activeTemplateId: null);
      return true;
    } on Object catch (error) {
      state = state.copyWith(
        isBusy: false,
        activeTemplateId: null,
        error: error,
      );
      return false;
    }
  }
}

/// Provides [PrepTemplateActionController] for template copy and CRUD.
final NotifierProvider<PrepTemplateActionController, PrepTemplateActionState>
    prepTemplateActionControllerProvider =
    NotifierProvider<PrepTemplateActionController, PrepTemplateActionState>(
  PrepTemplateActionController.new,
);
