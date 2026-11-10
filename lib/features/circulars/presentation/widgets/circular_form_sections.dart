import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:job_prep/core/localization/app_localizations_extension.dart';
import 'package:job_prep/core/localization/formatters.dart';
import 'package:job_prep/core/localization/locale_controller.dart';
import 'package:job_prep/core/theme/app_theme_tokens.dart';
import 'package:job_prep/core/widgets/glass_button.dart';
import 'package:job_prep/core/widgets/glass_text_field.dart';
import 'package:job_prep/features/circulars/domain/entities/circular_enums.dart';
import 'package:job_prep/features/circulars/presentation/providers/circular_form_controller.dart';
import 'package:job_prep/features/circulars/presentation/providers/circular_form_state.dart';
import 'package:job_prep/features/circulars/presentation/providers/circulars_providers.dart';
import 'package:job_prep/features/circulars/presentation/utils/circular_l10n.dart';
import 'package:job_prep/features/circulars/presentation/widgets/circular_form_status_and_text_sections.dart';
import 'package:job_prep/features/circulars/presentation/widgets/circular_form_widgets.dart';

/// Groups the 5 form sections (basics, links, dates & numbers, status, text)
/// rendered by `CircularFormScreen`.
class CircularFormSections extends ConsumerWidget {
  /// Creates [CircularFormSections].
  const CircularFormSections({
    required this.formState,
    required this.controller,
    required this.titleController,
    required this.orgNameController,
    required this.orgWebsiteController,
    required this.circularUrlController,
    required this.applicationUrlController,
    required this.vacanciesController,
    required this.salaryMinController,
    required this.salaryMaxController,
    required this.salaryNoteController,
    required this.feeController,
    required this.feeNoteController,
    required this.instructionsController,
    required this.notesController,
    required this.syllabusController,
    super.key,
  });

  final CircularFormState formState;
  final CircularFormController controller;
  final TextEditingController titleController;
  final TextEditingController orgNameController;
  final TextEditingController orgWebsiteController;
  final TextEditingController circularUrlController;
  final TextEditingController applicationUrlController;
  final TextEditingController vacanciesController;
  final TextEditingController salaryMinController;
  final TextEditingController salaryMaxController;
  final TextEditingController salaryNoteController;
  final TextEditingController feeController;
  final TextEditingController feeNoteController;
  final TextEditingController instructionsController;
  final TextEditingController notesController;
  final TextEditingController syllabusController;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tokens = context.tokens;
    final colors = tokens.colors;
    final spacing = tokens.spacing;
    final textStyles = tokens.textStyles;
    final l10n = context.l10n;
    final locale = ref.watch(localeProvider);
    final useBanglaDigits = ref.watch(useBanglaDigitsProvider);
    final now = ref.watch(circularNowProvider)();

    final salaryMaxErrorText = CircularL10n.numberValidationMessage(
          formState.salaryMaxError,
          l10n,
        ) ??
        CircularL10n.salaryRangeValidationMessage(
          formState.salaryRangeError,
          l10n,
        );

    final deadlineDisplay = formState.deadline != null
        ? AppFormatters.formatDate(
            formState.deadline!,
            locale: locale,
            useBanglaDigits: useBanglaDigits,
          )
        : l10n.circularFieldDeadlineNone;

    Future<void> pickDeadline() async {
      final picked = await showDatePicker(
        context: context,
        initialDate: formState.deadline ?? now,
        firstDate: DateTime(2020),
        lastDate: DateTime(2040),
      );
      if (picked != null) {
        controller.updateDeadline(picked);
      }
    }

    final enabled = !formState.isSubmitting;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // 1. Basics
        CircularFormSectionCard(
          title: l10n.circularFormSectionBasics,
          icon: Icons.info_outline_rounded,
          children: [
            CircularFormResponsivePair(
              first: GlassTextField(
                key: const ValueKey('circular-form-title'),
                controller: titleController,
                enabled: enabled,
                labelText: l10n.circularFieldTitleLabel,
                hintText: l10n.circularFieldTitleHint,
                errorText: CircularL10n.titleValidationMessage(
                  formState.titleError,
                  l10n,
                ),
                onChanged: controller.updateTitle,
              ),
              second: CircularEnumDropdown<CircularSector>(
                key: const ValueKey('circular-form-sector'),
                label: l10n.circularFieldSectorLabel,
                value: formState.sector,
                items: CircularSector.values,
                enabled: enabled,
                labelBuilder: (item) => CircularL10n.sectorLabel(item, l10n),
                onChanged: controller.updateSector,
              ),
            ),
            CircularFormResponsivePair(
              first: GlassTextField(
                key: const ValueKey('circular-form-org-name'),
                controller: orgNameController,
                enabled: enabled,
                labelText: l10n.circularFieldOrgNameLabel,
                hintText: l10n.circularFieldOrgNameHint,
                onChanged: controller.updateOrganizationName,
              ),
              second: GlassTextField(
                key: const ValueKey('circular-form-org-website'),
                controller: orgWebsiteController,
                enabled: enabled,
                keyboardType: TextInputType.url,
                labelText: l10n.circularFieldOrgWebsiteLabel,
                hintText: l10n.circularFieldOrgWebsiteHint,
                errorText: CircularL10n.urlValidationMessage(
                  formState.organizationWebsiteError,
                  l10n,
                ),
                onChanged: controller.updateOrganizationWebsite,
              ),
            ),
          ],
        ),
        SizedBox(height: spacing.lg),

        // 2. Links
        CircularFormSectionCard(
          index: 1,
          title: l10n.circularFormSectionLinks,
          icon: Icons.link_rounded,
          children: [
            CircularFormResponsivePair(
              first: GlassTextField(
                key: const ValueKey('circular-form-circular-url'),
                controller: circularUrlController,
                enabled: enabled,
                keyboardType: TextInputType.url,
                labelText: l10n.circularFieldCircularUrlLabel,
                hintText: l10n.circularFieldCircularUrlHint,
                errorText: CircularL10n.urlValidationMessage(
                  formState.circularUrlError,
                  l10n,
                ),
                onChanged: controller.updateCircularUrl,
              ),
              second: GlassTextField(
                key: const ValueKey('circular-form-application-url'),
                controller: applicationUrlController,
                enabled: enabled,
                keyboardType: TextInputType.url,
                labelText: l10n.circularFieldApplicationUrlLabel,
                hintText: l10n.circularFieldApplicationUrlHint,
                errorText: CircularL10n.urlValidationMessage(
                  formState.applicationUrlError,
                  l10n,
                ),
                onChanged: controller.updateApplicationUrl,
              ),
            ),
            if (formState.duplicateCircular != null)
              CircularDuplicateWarningBanner(
                duplicate: formState.duplicateCircular!,
              ),
          ],
        ),
        SizedBox(height: spacing.lg),

        // 3. Dates & Numbers
        CircularFormSectionCard(
          index: 2,
          title: l10n.circularFormSectionDatesAndNumbers,
          icon: Icons.payments_outlined,
          children: [
            CircularFormResponsivePair(
              first: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.circularFieldDeadlineLabel,
                    style: textStyles.labelLarge.copyWith(
                      color: colors.textSecondary,
                    ),
                  ),
                  SizedBox(height: spacing.sm),
                  Row(
                    children: [
                      Expanded(
                        child: GlassButton(
                          key: const ValueKey('circular-form-deadline-btn'),
                          onPressed: enabled ? pickDeadline : null,
                          leading: Icon(
                            Icons.calendar_today_outlined,
                            size: spacing.lg,
                            color: colors.goldAccent,
                          ),
                          child: Text(deadlineDisplay),
                        ),
                      ),
                      if (formState.deadline != null) ...[
                        SizedBox(width: spacing.xs),
                        IconButton(
                          key: const ValueKey('circular-form-clear-deadline'),
                          tooltip: l10n.circularFieldClearDeadlineTooltip,
                          onPressed: enabled
                              ? () => controller.updateDeadline(null)
                              : null,
                          icon: Icon(
                            Icons.close_rounded,
                            color: colors.textSecondary,
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
              second: GlassTextField(
                key: const ValueKey('circular-form-vacancies'),
                controller: vacanciesController,
                enabled: enabled,
                keyboardType: TextInputType.number,
                labelText: l10n.circularFieldVacanciesLabel,
                hintText: l10n.circularFieldVacanciesHint,
                errorText: CircularL10n.numberValidationMessage(
                  formState.vacanciesError,
                  l10n,
                ),
                onChanged: controller.updateVacancies,
              ),
            ),
            CircularFormResponsivePair(
              first: GlassTextField(
                key: const ValueKey('circular-form-salary-min'),
                controller: salaryMinController,
                enabled: enabled,
                keyboardType: TextInputType.number,
                labelText: l10n.circularFieldSalaryMinLabel,
                hintText: l10n.circularFieldSalaryMinHint,
                errorText: CircularL10n.numberValidationMessage(
                  formState.salaryMinError,
                  l10n,
                ),
                onChanged: controller.updateSalaryMin,
              ),
              second: GlassTextField(
                key: const ValueKey('circular-form-salary-max'),
                controller: salaryMaxController,
                enabled: enabled,
                keyboardType: TextInputType.number,
                labelText: l10n.circularFieldSalaryMaxLabel,
                hintText: l10n.circularFieldSalaryMaxHint,
                errorText: salaryMaxErrorText,
                onChanged: controller.updateSalaryMax,
              ),
            ),
            GlassTextField(
              key: const ValueKey('circular-form-salary-note'),
              controller: salaryNoteController,
              enabled: enabled,
              labelText: l10n.circularFieldSalaryNoteLabel,
              hintText: l10n.circularFieldSalaryNoteHint,
              onChanged: controller.updateSalaryNote,
            ),
            CircularFormResponsivePair(
              first: GlassTextField(
                key: const ValueKey('circular-form-fee'),
                controller: feeController,
                enabled: enabled,
                keyboardType: TextInputType.number,
                labelText: l10n.circularFieldFeeLabel,
                hintText: l10n.circularFieldFeeHint,
                errorText: CircularL10n.numberValidationMessage(
                  formState.applicationFeeError,
                  l10n,
                ),
                onChanged: controller.updateApplicationFee,
              ),
              second: GlassTextField(
                key: const ValueKey('circular-form-fee-note'),
                controller: feeNoteController,
                enabled: enabled,
                labelText: l10n.circularFieldFeeNoteLabel,
                hintText: l10n.circularFieldFeeNoteHint,
                onChanged: controller.updateFeeNote,
              ),
            ),
          ],
        ),
        SizedBox(height: spacing.lg),

        // 4. Status
        CircularStatusSection(
          formState: formState,
          controller: controller,
          enabled: enabled,
        ),
        SizedBox(height: spacing.lg),

        // 5. Text (Instructions, Personal notes, Syllabus)
        CircularTextDetailsSection(
          controller: controller,
          instructionsController: instructionsController,
          notesController: notesController,
          syllabusController: syllabusController,
          enabled: enabled,
        ),
      ],
    );
  }
}
