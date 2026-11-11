import 'dart:async' show unawaited;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:job_prep/features/onboarding/domain/entities/onboarding_draft.dart';
import 'package:job_prep/features/onboarding/domain/entities/onboarding_track.dart';
import 'package:job_prep/features/onboarding/domain/utils/onboarding_planner.dart';
import 'package:job_prep/features/onboarding/presentation/providers/onboarding_apply_executor.dart';
import 'package:job_prep/features/onboarding/presentation/providers/onboarding_status_provider.dart';
import 'package:job_prep/features/onboarding/presentation/providers/onboarding_wizard_mutations.dart';
import 'package:job_prep/features/onboarding/presentation/providers/onboarding_wizard_state.dart';
import 'package:job_prep/features/prep/domain/entities/prep_enums.dart';
import 'package:job_prep/features/prep/domain/entities/prep_template.dart';
import 'package:job_prep/features/prep/presentation/providers/prep_template_providers.dart';

/// Controls onboarding wizard state transitions, validation, resumable
/// mid-flow persistence, skipping, and Step 6 idempotent workspace setup.
class OnboardingWizardController extends Notifier<OnboardingWizardState> {
  int _nextCustomSeq = 1;

  @override
  OnboardingWizardState build() {
    ref.watch(onboardingStatusProvider.select((async) => async.hasValue));
    ref.watch(
      onboardingStatusProvider.select((async) => async.asData?.value.userId),
    );
    ref.watch(
      onboardingStatusProvider.select(
        (async) => async.asData?.value.onboardingCompletedAt == null,
      ),
    );
    ref.watch(prepTemplatesProvider.select((async) => async.hasValue));

    final status = ref.read(onboardingStatusProvider).asData?.value;
    final templates = _templates();
    final draft = OnboardingWizardMutations.seedSubjectsIfUnmodified(
      status?.draft ?? const OnboardingDraft(),
      templates,
    );

    return OnboardingWizardState(
      step: (status?.onboardingStep ?? 1).clamp(
        1,
        OnboardingWizardState.totalSteps,
      ),
      draft: draft,
      maxDailyPaceInput:
          draft.maxDailyPace != null ? '${draft.maxDailyPace}' : '',
    );
  }

  /// Selects preparation track on Step 2 and seeds Step 3 from Phase 4E packs.
  void selectTrack(OnboardingTrack track) {
    _setDraftAndPersist(
      OnboardingWizardMutations.applyTrackSelection(
        state.draft,
        track,
        _templates(),
      ),
      clearErrors: true,
    );
  }

  /// Enables or disables a subject card in Step 3.
  void toggleSubject(String localId, {required bool enabled}) {
    _applySubjectDraft(
      OnboardingWizardMutations.updateSubject(
        state.draft,
        localId,
        (sub) => sub.copyWith(enabled: enabled),
      ),
    );
  }

  /// Renames a subject inline during Step 3.
  void renameSubject(String localId, String name) {
    _applySubjectDraft(
      OnboardingWizardMutations.updateSubject(
        state.draft,
        localId,
        (sub) => sub.copyWith(name: name),
      ),
    );
  }

  /// Adds a custom subject to Step 3 so any career track is supported.
  void addCustomSubject({
    required String name,
    String firstMaterialTitle = '',
    int firstMaterialUnits = 100,
  }) {
    _setDraftAndPersist(
      OnboardingWizardMutations.appendCustomSubject(
        state.draft,
        subjectId: _nextId('custom_sub'),
        materialId: _nextId('custom_mat'),
        name: name,
        firstMaterialTitle: firstMaterialTitle,
        firstMaterialUnits: firstMaterialUnits,
      ),
      clearErrors: true,
    );
  }

  /// Updates an existing material's title inside Step 3.
  void updateMaterialTitle(String subjectId, String matId, String title) {
    _applySubjectDraft(
      OnboardingWizardMutations.updateMaterialTitle(
        state.draft,
        subjectLocalId: subjectId,
        materialLocalId: matId,
        title: title,
      ),
    );
  }

  /// Updates a material's total units from user text input in Step 3.
  void updateMaterialUnits(String subjectId, String matId, String rawUnits) {
    _applySubjectDraft(
      OnboardingWizardMutations.updateMaterialUnits(
        state.draft,
        subjectLocalId: subjectId,
        materialLocalId: matId,
        rawUnits: rawUnits,
      ),
    );
  }

  /// Appends a new material to [subjectLocalId] inside Step 3.
  void addMaterial(
    String subjectLocalId, {
    required String title,
    required int totalUnits,
    MaterialKind kind = MaterialKind.book,
  }) {
    _setDraftAndPersist(
      OnboardingWizardMutations.appendMaterial(
        state.draft,
        subjectLocalId: subjectLocalId,
        materialId: _nextId('mat'),
        title: title,
        totalUnits: totalUnits,
        kind: kind,
      ),
      clearErrors: true,
    );
  }

  /// Removes a material from [subjectLocalId] inside Step 3.
  void removeMaterial(String subjectLocalId, String materialLocalId) {
    _setDraftAndPersist(
      OnboardingWizardMutations.removeMaterial(
        state.draft,
        subjectLocalId: subjectLocalId,
        materialLocalId: materialLocalId,
      ),
      clearErrors: true,
    );
  }

  /// Toggles `"I don't know yet"` vs explicit exam date on Step 4.
  void setDontKnowExamDate({required bool dontKnow}) {
    _setDraftAndPersist(
      state.draft.copyWith(
        dontKnowExamDate: dontKnow,
        examDate: dontKnow ? null : state.draft.examDate,
      ),
      clearErrors: true,
    );
  }

  /// Sets the target exam date on Step 4.
  void setExamDate(DateTime date) {
    _setDraftAndPersist(
      state.draft.copyWith(
        dontKnowExamDate: false,
        examDate: DateTime.utc(date.year, date.month, date.day),
      ),
      clearErrors: true,
    );
  }

  /// Updates study days per week (`1..7`) and syncs rest weekdays cleanly.
  void setStudyDaysPerWeek(int days) {
    final nextRest = OnboardingPlanner.syncRestWeekdaysForStudyCount(
      studyDaysPerWeek: days,
      currentRestDays: state.draft.restWeekdays,
    );
    _setDraftAndPersist(
      state.draft.copyWith(restWeekdays: nextRest),
      clearErrors: true,
    );
  }

  /// Toggles an individual rest weekday (`0` Sunday .. `6` Saturday) on Step 4.
  void toggleRestWeekday(int weekday) {
    _setDraftAndPersist(
      state.draft.copyWith(
        restWeekdays: OnboardingWizardMutations.toggleRestWeekday(
          state.draft.restWeekdays,
          weekday,
        ),
      ),
      clearErrors: true,
    );
  }

  /// Updates the optional max daily pace text input on Step 4.
  void setMaxDailyPaceInput(String raw) {
    state = state.copyWith(
      maxDailyPaceInput: raw,
      draft: state.draft.copyWith(
        maxDailyPace: OnboardingWizardMutations.parseMaxDailyPaceOrNull(raw),
      ),
      scheduleError: null,
    );
  }

  /// Updates the optional Step 5 circular URL.
  void setCircularLink(String link) {
    state = state.copyWith(
      draft: state.draft.copyWith(circularLink: link),
      circularLinkError: null,
    );
  }

  /// Updates the optional Step 5 circular title.
  void setCircularTitle(String title) {
    state = state.copyWith(draft: state.draft.copyWith(circularTitle: title));
  }

  /// Updates or clears the optional Step 5 deadline.
  void setCircularDeadline(DateTime? deadline) {
    _setDraftAndPersist(
      state.draft.copyWith(circularDeadline: deadline),
      clearErrors: true,
    );
  }

  /// Validates the current step, advances forward, and persists resume state.
  Future<bool> goNext() async {
    if (state.isApplying) return false;
    final validationErrorState = OnboardingWizardMutations.validateStep(
      state: state,
      today: ref.read(onboardingNowProvider)(),
    );
    if (validationErrorState != null) {
      state = validationErrorState;
      return false;
    }

    if (state.step >= OnboardingWizardState.totalSteps) {
      return await finishOnboarding();
    }

    final nextDraft = state.step == 2
        ? OnboardingWizardMutations.seedSubjectsIfUnmodified(
            state.draft,
            _templates(),
          )
        : state.draft;
    final nextStep = state.step + 1;

    state = state.copyWith(
      step: nextStep,
      draft: nextDraft,
      subjectsError: null,
      scheduleError: null,
      circularLinkError: null,
      applyFailed: false,
    );
    await ref.read(onboardingStatusProvider.notifier).saveProgress(
          step: nextStep,
          draft: nextDraft,
        );
    return true;
  }

  /// Moves back one step and persists resume progress cleanly.
  Future<void> goBack() async {
    if (state.isApplying || state.step <= 1) return;
    final prevStep = state.step - 1;
    state = state.copyWith(
      step: prevStep,
      subjectsError: null,
      scheduleError: null,
      circularLinkError: null,
      applyFailed: false,
    );
    await ref.read(onboardingStatusProvider.notifier).saveProgress(
          step: prevStep,
          draft: state.draft,
        );
  }

  /// Skips onboarding cleanly from any step without adding partial data.
  Future<bool> skipOnboarding() async {
    if (state.isApplying) return false;
    state = state.copyWith(isApplying: true, applyFailed: false);
    final ok =
        await ref.read(onboardingStatusProvider.notifier).complete(state.draft);
    state =
        state.copyWith(isApplying: false, applyFailed: !ok, didComplete: ok);
    return ok;
  }

  /// Applies subjects, materials, study plan, and optional circular safely and
  /// marks onboarding complete so Today opens with welcome tips.
  Future<bool> finishOnboarding() async {
    if (state.isApplying) return false;
    state = state.copyWith(isApplying: true, applyFailed: false);

    try {
      await applyOnboardingDraftSafely(
        ref: ref,
        draft: state.draft,
        today: ref.read(onboardingNowProvider)(),
      );
      final ok = await ref
          .read(onboardingStatusProvider.notifier)
          .complete(state.draft);
      state = state.copyWith(
        isApplying: false,
        applyFailed: !ok,
        didComplete: ok,
      );
      return ok;
    } on Object {
      state = state.copyWith(isApplying: false, applyFailed: true);
      return false;
    }
  }

  List<PrepTemplate> _templates() =>
      ref.read(prepTemplatesProvider).asData?.value ?? const <PrepTemplate>[];

  void _applySubjectDraft(OnboardingDraft nextDraft) {
    state = state.copyWith(draft: nextDraft, subjectsError: null);
  }

  void _setDraftAndPersist(OnboardingDraft draft, {bool clearErrors = false}) {
    state = state.copyWith(
      draft: draft,
      subjectsError: clearErrors ? null : state.subjectsError,
      scheduleError: clearErrors ? null : state.scheduleError,
      circularLinkError: clearErrors ? null : state.circularLinkError,
    );
    unawaited(
      ref.read(onboardingStatusProvider.notifier).saveProgress(
            step: state.step,
            draft: draft,
          ),
    );
  }

  String _nextId(String prefix) => '${prefix}_${_nextCustomSeq++}';
}

/// Provides [OnboardingWizardController] for the onboarding flow.
final NotifierProvider<OnboardingWizardController, OnboardingWizardState>
    onboardingWizardControllerProvider =
    NotifierProvider<OnboardingWizardController, OnboardingWizardState>(
  OnboardingWizardController.new,
);
