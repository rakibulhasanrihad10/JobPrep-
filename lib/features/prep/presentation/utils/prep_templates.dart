import 'package:flutter/foundation.dart' show immutable;
import 'package:job_prep/features/prep/domain/entities/prep_enums.dart';
import 'package:job_prep/l10n/app_localizations.dart';

/// Identifiers for starter preparation templates offered in the empty state.
enum PrepTemplateId { bcsCore, bankOfficer, techEngineering }

/// Blueprint for a starter study material created when applying a template.
@immutable
class PrepTemplateMaterialSpec {
  /// Creates a [PrepTemplateMaterialSpec].
  const PrepTemplateMaterialSpec({
    required this.title,
    required this.kind,
    required this.unitLabel,
    required this.totalUnits,
  });

  /// Localized starter material title.
  final String title;

  /// Category of resource.
  final MaterialKind kind;

  /// Localized unit label (`pages`, `questions`, `chapters`, etc.).
  final String unitLabel;

  /// Planned target units (`>= 0`).
  final int totalUnits;
}

/// Blueprint for a starter subject and its initial materials.
@immutable
class PrepTemplateSubjectSpec {
  /// Creates a [PrepTemplateSubjectSpec].
  const PrepTemplateSubjectSpec({
    required this.name,
    required this.color,
    required this.icon,
    required this.examType,
    required this.materials,
  });

  /// Localized subject title.
  final String name;

  /// Semantic `PrepStyleTokens` color key.
  final String color;

  /// Semantic `PrepStyleTokens` icon key.
  final String icon;

  /// Localized exam or career track badge.
  final String examType;

  /// Starter materials populated under this subject.
  final List<PrepTemplateMaterialSpec> materials;
}

/// Localized starter template bundle selectable from the empty prep state.
@immutable
class PrepStarterTemplate {
  /// Creates a [PrepStarterTemplate].
  const PrepStarterTemplate({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.subjects,
  });

  /// Unique preset identifier.
  final PrepTemplateId id;

  /// Display title of the template.
  final String title;

  /// Concise summary explaining included subjects/materials.
  final String subtitle;

  /// Starter subjects created when applying this template.
  final List<PrepTemplateSubjectSpec> subjects;
}

/// Localized career-agnostic and BCS/Bank starter preparation templates.
abstract final class PrepTemplates {
  /// Builds localized starter templates for the active locale's [l10n].
  static List<PrepStarterTemplate> all(AppLocalizations l10n) {
    final pages = l10n.prepUnitPresetPages;
    final questions = l10n.prepUnitPresetQuestions;
    final chapters = l10n.prepUnitPresetChapters;
    final notes = l10n.prepMaterialKindNotes;

    return <PrepStarterTemplate>[
      PrepStarterTemplate(
        id: PrepTemplateId.bcsCore,
        title: l10n.prepTemplateBcsTitle,
        subtitle: l10n.prepTemplateBcsSubtitle,
        subjects: [
          PrepTemplateSubjectSpec(
            name: l10n.prepTplSubBcsBangla,
            color: 'gold',
            icon: 'language',
            examType: l10n.prepExamTrackBcs,
            materials: [
              PrepTemplateMaterialSpec(
                title: l10n.prepTplMatBanglaOne,
                kind: MaterialKind.book,
                unitLabel: pages,
                totalUnits: 300,
              ),
              PrepTemplateMaterialSpec(
                title: l10n.prepTplMatBanglaTwo,
                kind: MaterialKind.book,
                unitLabel: pages,
                totalUnits: 300,
              ),
              PrepTemplateMaterialSpec(
                title: l10n.prepTplMatBanglaThree,
                kind: MaterialKind.book,
                unitLabel: pages,
                totalUnits: 400,
              ),
            ],
          ),
          PrepTemplateSubjectSpec(
            name: l10n.prepTplSubBcsEnglish,
            color: 'info',
            icon: 'menu_book',
            examType: l10n.prepExamTrackBcs,
            materials: [
              PrepTemplateMaterialSpec(
                title: l10n.prepTplMatEnglishCore,
                kind: MaterialKind.book,
                unitLabel: pages,
                totalUnits: 250,
              ),
            ],
          ),
          PrepTemplateSubjectSpec(
            name: l10n.prepTplSubBcsGk,
            color: 'success',
            icon: 'public',
            examType: l10n.prepExamTrackBcs,
            materials: [
              PrepTemplateMaterialSpec(
                title: l10n.prepTplMatGkDigest,
                kind: MaterialKind.notes,
                unitLabel: pages,
                totalUnits: 200,
              ),
            ],
          ),
        ],
      ),
      PrepStarterTemplate(
        id: PrepTemplateId.bankOfficer,
        title: l10n.prepTemplateBankTitle,
        subtitle: l10n.prepTemplateBankSubtitle,
        subjects: [
          PrepTemplateSubjectSpec(
            name: l10n.prepTplSubBankMath,
            color: 'warning',
            icon: 'calculate',
            examType: l10n.prepExamTrackBank,
            materials: [
              PrepTemplateMaterialSpec(
                title: l10n.prepTplMatBankMathBook,
                kind: MaterialKind.questionBank,
                unitLabel: questions,
                totalUnits: 300,
              ),
            ],
          ),
          PrepTemplateSubjectSpec(
            name: l10n.prepTplSubBankEnglish,
            color: 'info',
            icon: 'language',
            examType: l10n.prepExamTrackBank,
            materials: [
              PrepTemplateMaterialSpec(
                title: l10n.prepTplMatBankFocus,
                kind: MaterialKind.book,
                unitLabel: pages,
                totalUnits: 180,
              ),
            ],
          ),
        ],
      ),
      PrepStarterTemplate(
        id: PrepTemplateId.techEngineering,
        title: l10n.prepTemplateTechTitle,
        subtitle: l10n.prepTemplateTechSubtitle,
        subjects: [
          PrepTemplateSubjectSpec(
            name: l10n.prepTplSubTechDsa,
            color: 'accent_secondary',
            icon: 'computer',
            examType: l10n.prepExamTrackEngineering,
            materials: [
              PrepTemplateMaterialSpec(
                title: l10n.prepTplMatDsaSet,
                kind: MaterialKind.questionBank,
                unitLabel: questions,
                totalUnits: 150,
              ),
            ],
          ),
          PrepTemplateSubjectSpec(
            name: l10n.prepTplSubTechSysDesign,
            color: 'info',
            icon: 'science',
            examType: l10n.prepExamTrackEngineering,
            materials: [
              PrepTemplateMaterialSpec(
                title: l10n.prepTplMatSysDesignGuide,
                kind: MaterialKind.notes,
                unitLabel: chapters.isNotEmpty ? chapters : notes,
                totalUnits: 24,
              ),
            ],
          ),
        ],
      ),
    ];
  }
}
