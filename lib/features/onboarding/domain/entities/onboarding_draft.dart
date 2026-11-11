import 'package:flutter/foundation.dart' show immutable, listEquals, setEquals;
import 'package:job_prep/features/onboarding/domain/entities/onboarding_subject_draft.dart';
import 'package:job_prep/features/onboarding/domain/entities/onboarding_track.dart';

export 'package:job_prep/features/onboarding/domain/entities/onboarding_subject_draft.dart';

/// Resumable draft selections held across the 6 onboarding wizard steps.
///
/// Stores strictly non-PII study preferences and syllabus customizations.
@immutable
class OnboardingDraft {
  /// Creates an [OnboardingDraft].
  const OnboardingDraft({
    this.track = OnboardingTrack.government,
    this.subjects = const <OnboardingSubjectDraft>[],
    this.hasCustomizedSubjects = false,
    this.dontKnowExamDate = false,
    this.examDate,
    this.restWeekdays = const <int>{5},
    this.maxDailyPace,
    this.circularLink = '',
    this.circularTitle = '',
    this.circularDeadline,
  });

  /// Restores an [OnboardingDraft] from persisted JSON.
  factory OnboardingDraft.fromJson(Map<String, dynamic> json) {
    final rawSubjects = json['subjects'];
    final subjects = rawSubjects is List
        ? rawSubjects
            .whereType<Map<Object?, Object?>>()
            .map(
              (entry) => OnboardingSubjectDraft.fromJson(
                Map<String, dynamic>.from(entry),
              ),
            )
            .toList(growable: false)
        : const <OnboardingSubjectDraft>[];

    final rawRest = json['restWeekdays'];
    final restWeekdays = rawRest is List
        ? rawRest.whereType<num>().map((n) => n.toInt().clamp(0, 6)).toSet()
        : const <int>{5};

    final rawExamDate = json['examDate'] as String?;
    final rawDeadline = json['circularDeadline'] as String?;
    final rawMaxPace = json['maxDailyPace'];

    return OnboardingDraft(
      track: OnboardingTrack.tryParse(json['track'] as String?) ??
          OnboardingTrack.government,
      subjects: subjects,
      hasCustomizedSubjects: (json['hasCustomizedSubjects'] as bool?) ?? false,
      dontKnowExamDate: (json['dontKnowExamDate'] as bool?) ?? false,
      examDate: rawExamDate == null ? null : DateTime.tryParse(rawExamDate),
      restWeekdays: Set<int>.unmodifiable(restWeekdays),
      maxDailyPace: rawMaxPace is num ? rawMaxPace.toInt() : null,
      circularLink: (json['circularLink'] as String?) ?? '',
      circularTitle: (json['circularTitle'] as String?) ?? '',
      circularDeadline:
          rawDeadline == null ? null : DateTime.tryParse(rawDeadline),
    );
  }

  static const Object _unset = Object();

  /// Chosen track (`government`, `software`, or `blank`).
  final OnboardingTrack track;

  /// Editable subjects and materials drafted from the template or scratch.
  final List<OnboardingSubjectDraft> subjects;

  /// Tracks whether the user opened/edited Step 3 so Back/Resume keeps edits.
  final bool hasCustomizedSubjects;

  /// True when the user chose "I don't know yet" instead of an exam date.
  final bool dontKnowExamDate;

  /// Target exam calendar date for creating the initial StudyPlan.
  final DateTime? examDate;

  /// Chosen weekly rest weekdays (`0` = Sunday .. `6` = Saturday).
  final Set<int> restWeekdays;

  /// Optional maximum units/day limit on the created study plan.
  final int? maxDailyPace;

  /// Optional first circular URL from Step 5.
  final String circularLink;

  /// Optional first circular title override from Step 5.
  final String circularTitle;

  /// Optional first circular application deadline from Step 5.
  final DateTime? circularDeadline;

  /// Number of study days per week (`7 - restWeekdays.length`).
  int get studyDaysPerWeek => (7 - restWeekdays.length).clamp(1, 7);

  /// Serializes draft selections to JSON.
  Map<String, dynamic> toJson() => <String, dynamic>{
        'track': track.value,
        'subjects': subjects.map((s) => s.toJson()).toList(growable: false),
        'hasCustomizedSubjects': hasCustomizedSubjects,
        'dontKnowExamDate': dontKnowExamDate,
        'examDate': examDate?.toIso8601String(),
        'restWeekdays': (restWeekdays.toList()..sort()),
        'maxDailyPace': maxDailyPace,
        'circularLink': circularLink,
        'circularTitle': circularTitle,
        'circularDeadline': circularDeadline?.toIso8601String(),
      };

  /// Returns a copy with overridden properties.
  OnboardingDraft copyWith({
    OnboardingTrack? track,
    List<OnboardingSubjectDraft>? subjects,
    bool? hasCustomizedSubjects,
    bool? dontKnowExamDate,
    Object? examDate = _unset,
    Set<int>? restWeekdays,
    Object? maxDailyPace = _unset,
    String? circularLink,
    String? circularTitle,
    Object? circularDeadline = _unset,
  }) {
    return OnboardingDraft(
      track: track ?? this.track,
      subjects: subjects ?? this.subjects,
      hasCustomizedSubjects:
          hasCustomizedSubjects ?? this.hasCustomizedSubjects,
      dontKnowExamDate: dontKnowExamDate ?? this.dontKnowExamDate,
      examDate:
          identical(examDate, _unset) ? this.examDate : examDate as DateTime?,
      restWeekdays: restWeekdays ?? this.restWeekdays,
      maxDailyPace: identical(maxDailyPace, _unset)
          ? this.maxDailyPace
          : maxDailyPace as int?,
      circularLink: circularLink ?? this.circularLink,
      circularTitle: circularTitle ?? this.circularTitle,
      circularDeadline: identical(circularDeadline, _unset)
          ? this.circularDeadline
          : circularDeadline as DateTime?,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is OnboardingDraft &&
        other.track == track &&
        listEquals(other.subjects, subjects) &&
        other.hasCustomizedSubjects == hasCustomizedSubjects &&
        other.dontKnowExamDate == dontKnowExamDate &&
        other.examDate == examDate &&
        setEquals(other.restWeekdays, restWeekdays) &&
        other.maxDailyPace == maxDailyPace &&
        other.circularLink == circularLink &&
        other.circularTitle == circularTitle &&
        other.circularDeadline == circularDeadline;
  }

  @override
  int get hashCode => Object.hash(
        track,
        Object.hashAll(subjects),
        hasCustomizedSubjects,
        dontKnowExamDate,
        examDate,
        Object.hashAllUnordered(restWeekdays),
        maxDailyPace,
        circularLink,
        circularTitle,
        circularDeadline,
      );
}
