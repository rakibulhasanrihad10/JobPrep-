import 'package:job_prep/features/circulars/domain/entities/circular.dart';
import 'package:job_prep/features/circulars/domain/entities/circular_enums.dart';
import 'package:job_prep/features/circulars/domain/utils/quick_capture_helpers.dart';
import 'package:job_prep/features/circulars/domain/validators/circular_form_validators.dart';
import 'package:job_prep/features/onboarding/domain/entities/onboarding_draft.dart';
import 'package:job_prep/features/onboarding/domain/entities/onboarding_track.dart';
import 'package:job_prep/features/prep/domain/entities/prep_template.dart';
import 'package:job_prep/features/prep/domain/entities/prep_template_item.dart';
import 'package:job_prep/features/prep/domain/entities/study_plan.dart';
import 'package:job_prep/features/prep/domain/utils/prep_seeded_templates.dart';

/// Validation error keys for Step 3 subject & material customization.
enum OnboardingSubjectsValidationError {
  emptySubjectName,
  duplicateSubjectName,
  emptyMaterialTitle,
  invalidMaterialUnits,
}

/// Validation error keys for Step 4 exam date & weekly study schedule inputs.
enum OnboardingScheduleValidationError {
  missingExamDate,
  pastExamDate,
  noStudyDaysSelected,
  invalidMaxDailyPace,
}

/// Pure planners, template adapters, and validators powering the onboarding
/// wizard without UI or database dependencies.
abstract final class OnboardingPlanner {
  /// Default rest weekday preference fallback order (`Fri`, `Sat`, `Sun`, ...).
  static const List<int> preferredRestDayOrder = [5, 6, 0, 4, 1, 2, 3];

  /// Picks the matching starting [PrepTemplate] for [track] from [available].
  static PrepTemplate? resolveTemplateForTrack({
    required OnboardingTrack track,
    required List<PrepTemplate> available,
  }) {
    final targetSlug = track.templateSlug;
    if (targetSlug == null) return null;

    for (final template in available) {
      if (template.slug == targetSlug) return template;
    }
    return switch (track) {
      OnboardingTrack.government => PrepSeededTemplates.governmentJob,
      OnboardingTrack.software => PrepSeededTemplates.softwareEngineer,
      OnboardingTrack.blank => null,
    };
  }

  /// Converts a [PrepTemplate] into editable [OnboardingSubjectDraft] items.
  static List<OnboardingSubjectDraft> draftSubjectsFromTemplate(
    PrepTemplate? template,
  ) {
    if (template == null) return const <OnboardingSubjectDraft>[];
    final groups = template.groupedSubjects;
    final drafts = <OnboardingSubjectDraft>[];

    for (var sIdx = 0; sIdx < groups.length; sIdx++) {
      final group = groups[sIdx];
      final matDrafts = <OnboardingMaterialDraft>[];
      for (var mIdx = 0; mIdx < group.materials.length; mIdx++) {
        final item = group.materials[mIdx];
        final title = item.materialTitle?.trim() ?? '';
        if (title.isEmpty) continue;
        matDrafts.add(
          OnboardingMaterialDraft(
            localId: 'mat_${sIdx}_$mIdx',
            title: title,
            kind: item.materialKind,
            unitLabel: item.unitLabel,
            totalUnits: item.totalUnits < 1 ? 100 : item.totalUnits,
          ),
        );
      }

      drafts.add(
        OnboardingSubjectDraft(
          localId: 'sub_$sIdx',
          name: group.subjectName,
          color: group.subjectColor,
          icon: group.subjectIcon,
          examType: group.examType,
          materials: List<OnboardingMaterialDraft>.unmodifiable(matDrafts),
        ),
      );
    }

    return List<OnboardingSubjectDraft>.unmodifiable(drafts);
  }

  /// Packs enabled [OnboardingSubjectDraft] entries into a [PrepTemplate] so
  /// `PrepTemplatePlanner` applies them idempotently without duplicates.
  static PrepTemplate buildTemplateFromDraft(
    List<OnboardingSubjectDraft> subjects, {
    String title = 'Onboarding Setup',
  }) {
    final items = <PrepTemplateItem>[];
    var subjectOrder = 0;
    var itemOrder = 0;

    for (final subject in subjects) {
      if (!subject.enabled) continue;
      final trimmedName = subject.name.trim();
      if (trimmedName.isEmpty) continue;

      if (subject.materials.isEmpty) {
        items.add(
          PrepTemplateItem(
            subjectName: trimmedName,
            subjectColor: subject.color,
            subjectIcon: subject.icon,
            examType: subject.examType,
            subjectSortOrder: subjectOrder++,
            itemSortOrder: itemOrder++,
          ),
        );
        continue;
      }

      for (final material in subject.materials) {
        final trimmedMat = material.title.trim();
        if (trimmedMat.isEmpty) continue;
        items.add(
          PrepTemplateItem(
            subjectName: trimmedName,
            subjectColor: subject.color,
            subjectIcon: subject.icon,
            examType: subject.examType,
            subjectSortOrder: subjectOrder,
            materialTitle: trimmedMat,
            materialKind: material.kind,
            unitLabel: material.unitLabel,
            totalUnits: material.totalUnits < 1 ? 1 : material.totalUnits,
            itemSortOrder: itemOrder++,
          ),
        );
      }
      subjectOrder++;
    }

    return PrepTemplate(
      slug: 'onboarding_custom',
      title: title,
      items: List<PrepTemplateItem>.unmodifiable(items),
    );
  }

  /// Keeps [currentRestDays] aligned when the user selects [studyDaysPerWeek]
  /// (`1..7`), ensuring `restDays.length == 7 - studyDaysPerWeek`.
  static Set<int> syncRestWeekdaysForStudyCount({
    required int studyDaysPerWeek,
    required Set<int> currentRestDays,
  }) {
    final targetRestCount = (7 - studyDaysPerWeek.clamp(1, 7)).clamp(0, 6);
    final result = <int>{};
    for (final day in currentRestDays) {
      if (day >= 0 && day <= 6 && result.length < targetRestCount) {
        result.add(day);
      }
    }
    for (final fallback in preferredRestDayOrder) {
      if (result.length >= targetRestCount) break;
      result.add(fallback);
    }
    return Set<int>.unmodifiable(result);
  }

  /// Validates Step 3 customized subjects & materials before continuing.
  static OnboardingSubjectsValidationError? validateSubjectsAndMaterials(
    List<OnboardingSubjectDraft> subjects,
  ) {
    final seenNames = <String>{};
    for (final subject in subjects) {
      if (!subject.enabled) continue;
      final normalizedName = PrepTemplate.normalizeNameKey(subject.name);
      if (normalizedName.isEmpty) {
        return OnboardingSubjectsValidationError.emptySubjectName;
      }
      if (!seenNames.add(normalizedName)) {
        return OnboardingSubjectsValidationError.duplicateSubjectName;
      }
      for (final material in subject.materials) {
        if (material.title.trim().isEmpty) {
          return OnboardingSubjectsValidationError.emptyMaterialTitle;
        }
        if (material.totalUnits < 1) {
          return OnboardingSubjectsValidationError.invalidMaterialUnits;
        }
      }
    }
    return null;
  }

  /// Validates Step 4 exam date, weekly study/rest days, and optional max pace.
  static OnboardingScheduleValidationError? validateSchedule({
    required bool dontKnowExamDate,
    required DateTime? examDate,
    required DateTime today,
    required Set<int> restWeekdays,
    required String maxDailyPaceText,
    int? parsedMaxDailyPace,
  }) {
    if (!dontKnowExamDate) {
      if (examDate == null) {
        return OnboardingScheduleValidationError.missingExamDate;
      }
      final todayCal = DateTime.utc(today.year, today.month, today.day);
      final targetCal = DateTime.utc(
        examDate.year,
        examDate.month,
        examDate.day,
      );
      if (targetCal.isBefore(todayCal)) {
        return OnboardingScheduleValidationError.pastExamDate;
      }
    }
    if (restWeekdays.length >= 7) {
      return OnboardingScheduleValidationError.noStudyDaysSelected;
    }
    if (maxDailyPaceText.trim().isNotEmpty &&
        (parsedMaxDailyPace == null || parsedMaxDailyPace <= 0)) {
      return OnboardingScheduleValidationError.invalidMaxDailyPace;
    }
    return null;
  }

  /// Builds the initial combined [StudyPlan] from [draft] when an exam date
  /// was specified, or returns `null` if the user does not know it yet.
  static StudyPlan? buildStudyPlanFromDraft({
    required OnboardingDraft draft,
    required DateTime today,
  }) {
    if (draft.dontKnowExamDate || draft.examDate == null) return null;
    final start = DateTime.utc(today.year, today.month, today.day);
    final target = DateTime.utc(
      draft.examDate!.year,
      draft.examDate!.month,
      draft.examDate!.day,
    );
    return StudyPlan(
      startDate: start,
      targetDate: target,
      restDaysPerWeek: draft.restWeekdays.length.clamp(0, 6),
      maxDailyPace: draft.maxDailyPace,
    );
  }

  /// Builds an Inbox quick-capture [Circular] when Step 5 contains a link, or
  /// returns `null` when Step 5 was left blank/skipped or already exists.
  static Circular? buildFirstCircularFromDraft({
    required OnboardingDraft draft,
    required Iterable<Circular> existingCirculars,
  }) {
    final trimmedLink = draft.circularLink.trim();
    if (trimmedLink.isEmpty) return null;

    final normalizedNew = CircularFormValidators.normalizeCircularUrl(
      trimmedLink,
    );
    if (normalizedNew != null) {
      for (final existing in existingCirculars) {
        if (CircularFormValidators.normalizeCircularUrl(existing.circularUrl) ==
                normalizedNew ||
            CircularFormValidators.normalizeCircularUrl(
                  existing.applicationUrl,
                ) ==
                normalizedNew) {
          return null;
        }
      }
    }

    final customTitle = draft.circularTitle.trim();
    final resolvedTitle = customTitle.isNotEmpty
        ? customTitle
        : deriveTitleFromCircularUrl(trimmedLink);
    return Circular(
      title: resolvedTitle,
      circularUrl: trimmedLink,
      deadline: draft.circularDeadline,
      workflowStatus: CircularWorkflowStatus.inbox,
      isQuickCapture: true,
    );
  }

  /// Parses user-entered ASCII or Bangla digits into a non-negative integer.
  static int? parseNonNegativeInt(String raw) =>
      CircularFormValidators.parseOptionalInt(raw);
}
