import 'package:job_prep/features/circulars/domain/utils/quick_capture_helpers.dart';
import 'package:job_prep/features/onboarding/domain/entities/onboarding_draft.dart';
import 'package:job_prep/features/onboarding/domain/entities/onboarding_track.dart';
import 'package:job_prep/features/onboarding/domain/utils/onboarding_planner.dart';
import 'package:job_prep/features/onboarding/presentation/providers/onboarding_wizard_state.dart';
import 'package:job_prep/features/prep/domain/entities/prep_enums.dart';
import 'package:job_prep/features/prep/domain/entities/prep_template.dart';

/// Pure draft mutation & step-validation helpers used by the wizard controller.
abstract final class OnboardingWizardMutations {
  /// Populates default subjects from [templates] if untouched for non-blank.
  static OnboardingDraft seedSubjectsIfUnmodified(
    OnboardingDraft draft,
    List<PrepTemplate> templates,
  ) {
    if (draft.hasCustomizedSubjects ||
        draft.subjects.isNotEmpty ||
        draft.track == OnboardingTrack.blank) {
      return draft;
    }
    final template = OnboardingPlanner.resolveTemplateForTrack(
      track: draft.track,
      available: templates,
    );
    return draft.copyWith(
      subjects: OnboardingPlanner.draftSubjectsFromTemplate(template),
    );
  }

  /// Replaces draft subjects when choosing a new [track] on Step 2.
  static OnboardingDraft applyTrackSelection(
    OnboardingDraft draft,
    OnboardingTrack track,
    List<PrepTemplate> templates,
  ) {
    final template = OnboardingPlanner.resolveTemplateForTrack(
      track: track,
      available: templates,
    );
    return draft.copyWith(
      track: track,
      subjects: OnboardingPlanner.draftSubjectsFromTemplate(template),
      hasCustomizedSubjects: false,
    );
  }

  /// Updates one subject inside [draft] and marks Step 3 as customized.
  static OnboardingDraft updateSubject(
    OnboardingDraft draft,
    String localId,
    OnboardingSubjectDraft Function(OnboardingSubjectDraft current) updater,
  ) {
    final nextSubjects = [
      for (final sub in draft.subjects)
        if (sub.localId == localId) updater(sub) else sub,
    ];
    return draft.copyWith(
      subjects: List<OnboardingSubjectDraft>.unmodifiable(nextSubjects),
      hasCustomizedSubjects: true,
    );
  }

  /// Appends a custom subject (optionally with an initial material) to [draft].
  static OnboardingDraft appendCustomSubject(
    OnboardingDraft draft, {
    required String subjectId,
    required String materialId,
    required String name,
    required String firstMaterialTitle,
    required int firstMaterialUnits,
  }) {
    final trimmedTitle = firstMaterialTitle.trim();
    final materials = trimmedTitle.isEmpty
        ? const <OnboardingMaterialDraft>[]
        : <OnboardingMaterialDraft>[
            OnboardingMaterialDraft(
              localId: materialId,
              title: trimmedTitle,
              totalUnits: firstMaterialUnits < 1 ? 100 : firstMaterialUnits,
            ),
          ];
    final added = OnboardingSubjectDraft(
      localId: subjectId,
      name: name.trim(),
      examType: draft.track.value,
      materials: materials,
    );
    return draft.copyWith(
      subjects: List<OnboardingSubjectDraft>.unmodifiable([
        ...draft.subjects,
        added,
      ]),
      hasCustomizedSubjects: true,
    );
  }

  /// Updates an existing material's title inside [subjectLocalId].
  static OnboardingDraft updateMaterialTitle(
    OnboardingDraft draft, {
    required String subjectLocalId,
    required String materialLocalId,
    required String title,
  }) {
    return updateSubject(
      draft,
      subjectLocalId,
      (sub) => sub.copyWith(
        materials: List<OnboardingMaterialDraft>.unmodifiable([
          for (final mat in sub.materials)
            if (mat.localId == materialLocalId)
              mat.copyWith(title: title)
            else
              mat,
        ]),
      ),
    );
  }

  /// Updates a material's total units inside [subjectLocalId].
  static OnboardingDraft updateMaterialUnits(
    OnboardingDraft draft, {
    required String subjectLocalId,
    required String materialLocalId,
    required String rawUnits,
  }) {
    final parsed = OnboardingPlanner.parseNonNegativeInt(rawUnits);
    return updateSubject(
      draft,
      subjectLocalId,
      (sub) => sub.copyWith(
        materials: List<OnboardingMaterialDraft>.unmodifiable([
          for (final mat in sub.materials)
            if (mat.localId == materialLocalId)
              mat.copyWith(totalUnits: parsed ?? 0)
            else
              mat,
        ]),
      ),
    );
  }

  /// Appends a material to [subjectLocalId].
  static OnboardingDraft appendMaterial(
    OnboardingDraft draft, {
    required String subjectLocalId,
    required String materialId,
    required String title,
    required int totalUnits,
    MaterialKind kind = MaterialKind.book,
  }) {
    final mat = OnboardingMaterialDraft(
      localId: materialId,
      title: title.trim(),
      kind: kind,
      totalUnits: totalUnits < 1 ? 100 : totalUnits,
    );
    return updateSubject(
      draft,
      subjectLocalId,
      (sub) => sub.copyWith(
        materials: List<OnboardingMaterialDraft>.unmodifiable([
          ...sub.materials,
          mat,
        ]),
      ),
    );
  }

  /// Removes a material from [subjectLocalId].
  static OnboardingDraft removeMaterial(
    OnboardingDraft draft, {
    required String subjectLocalId,
    required String materialLocalId,
  }) {
    return updateSubject(
      draft,
      subjectLocalId,
      (sub) => sub.copyWith(
        materials: List<OnboardingMaterialDraft>.unmodifiable(
          sub.materials.where((m) => m.localId != materialLocalId),
        ),
      ),
    );
  }

  /// Toggles an individual rest weekday (`0`..`6`) while keeping >= 1 study
  /// day per week.
  static Set<int> toggleRestWeekday(Set<int> current, int weekday) {
    final normalized = weekday.clamp(0, 6);
    final next = Set<int>.of(current);
    if (next.contains(normalized)) {
      next.remove(normalized);
    } else if (next.length < 6) {
      next.add(normalized);
    }
    return Set<int>.unmodifiable(next);
  }

  /// Parses max daily pace text into `state.draft.maxDailyPace` cleanly.
  static int? parseMaxDailyPaceOrNull(String raw) {
    final parsed = OnboardingPlanner.parseNonNegativeInt(raw);
    return raw.trim().isEmpty
        ? null
        : (parsed != null && parsed > 0 ? parsed : null);
  }

  /// Validates [state] for the active wizard step; returns updated state on
  /// validation error, or `null` when the step is valid.
  static OnboardingWizardState? validateStep({
    required OnboardingWizardState state,
    required DateTime today,
  }) {
    if (state.step == 3) {
      final err = OnboardingPlanner.validateSubjectsAndMaterials(
        state.draft.subjects,
      );
      return err == null ? null : state.copyWith(subjectsError: err);
    }
    if (state.step == 4) {
      final parsedPace = OnboardingPlanner.parseNonNegativeInt(
        state.maxDailyPaceInput,
      );
      final err = OnboardingPlanner.validateSchedule(
        dontKnowExamDate: state.draft.dontKnowExamDate,
        examDate: state.draft.examDate,
        today: today,
        restWeekdays: state.draft.restWeekdays,
        maxDailyPaceText: state.maxDailyPaceInput,
        parsedMaxDailyPace: parsedPace,
      );
      return err == null ? null : state.copyWith(scheduleError: err);
    }
    if (state.step == 5) {
      final link = state.draft.circularLink.trim();
      if (link.isNotEmpty) {
        final err = validateRequiredCircularLink(link);
        return err == null ? null : state.copyWith(circularLinkError: err);
      }
    }
    return null;
  }
}
