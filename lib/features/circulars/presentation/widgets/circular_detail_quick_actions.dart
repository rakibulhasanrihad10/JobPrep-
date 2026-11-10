import 'dart:async' show unawaited;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:job_prep/core/localization/app_localizations_extension.dart';
import 'package:job_prep/core/localization/formatters.dart';
import 'package:job_prep/core/localization/locale_controller.dart';
import 'package:job_prep/core/theme/app_theme_tokens.dart';
import 'package:job_prep/core/widgets/animated_progress_bar.dart';
import 'package:job_prep/core/widgets/fade_slide_in.dart';
import 'package:job_prep/core/widgets/glass_card.dart';
import 'package:job_prep/features/circulars/domain/entities/application_checklist.dart';
import 'package:job_prep/features/circulars/domain/entities/circular.dart';
import 'package:job_prep/features/circulars/domain/entities/circular_enums.dart';
import 'package:job_prep/features/circulars/presentation/providers/circular_detail_controller.dart';
import 'package:job_prep/features/circulars/presentation/utils/circular_l10n.dart';
import 'package:job_prep/features/circulars/presentation/widgets/circular_form_widgets.dart';

/// Quick status controls (workflow, application, admit card) and interactive
/// 5-step application checklist for a [Circular].
class CircularDetailQuickActionsCard extends ConsumerWidget {
  /// Creates a [CircularDetailQuickActionsCard].
  const CircularDetailQuickActionsCard({
    required this.circular,
    super.key,
  });

  /// Active circular being managed.
  final Circular circular;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tokens = context.tokens;
    final colors = tokens.colors;
    final spacing = tokens.spacing;
    final textStyles = tokens.textStyles;
    final l10n = context.l10n;
    final locale = ref.watch(localeProvider);
    final useBanglaDigits = ref.watch(useBanglaDigitsProvider);

    final actionState = ref.watch(circularDetailControllerProvider);
    final controller = ref.read(circularDetailControllerProvider.notifier);
    final enabled = !actionState.isUpdating && !actionState.isDeleting;

    final checklist = circular.checklist;
    final formattedDone = AppFormatters.formatNumber(
      checklist.completedCount,
      locale: locale,
      useBanglaDigits: useBanglaDigits,
    );
    final formattedTotal = AppFormatters.formatNumber(
      ApplicationChecklist.totalSteps,
      locale: locale,
      useBanglaDigits: useBanglaDigits,
    );

    return GlassCard(
      key: const ValueKey('circular-detail-quick-actions-card'),
      padding: spacing.insetsAllLg,
      child: FadeSlideIn(
        index: 1,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Icon(
                  Icons.bolt_rounded,
                  color: colors.goldAccent,
                  size: spacing.lg,
                ),
                SizedBox(width: spacing.sm),
                Expanded(
                  child: Text(
                    l10n.circularDetailQuickActionsTitle,
                    style: textStyles.titleMedium,
                  ),
                ),
                if (actionState.isUpdating)
                  SizedBox(
                    width: spacing.lg,
                    height: spacing.lg,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: colors.goldAccent,
                    ),
                  ),
              ],
            ),
            Divider(color: colors.glassBorder, height: spacing.xl),
            CircularFormResponsivePair(
              first: CircularEnumDropdown<CircularWorkflowStatus>(
                key: const ValueKey('detail-quick-workflow-status'),
                label: l10n.circularFieldWorkflowStatusLabel,
                value: circular.workflowStatus,
                items: CircularWorkflowStatus.values,
                enabled: enabled,
                labelBuilder: (item) =>
                    CircularL10n.workflowStatusLabel(item, l10n),
                onChanged: (next) =>
                    unawaited(controller.updateWorkflowStatus(circular, next)),
              ),
              second: CircularEnumDropdown<ApplicationStatus>(
                key: const ValueKey('detail-quick-app-status'),
                label: l10n.circularFieldAppStatusLabel,
                value: circular.applicationStatus,
                items: ApplicationStatus.values,
                enabled: enabled,
                labelBuilder: (item) =>
                    CircularL10n.applicationStatusLabel(item, l10n),
                onChanged: (next) => unawaited(
                  controller.updateApplicationStatus(circular, next),
                ),
              ),
            ),
            SizedBox(height: spacing.md),
            CircularEnumDropdown<AdmitCardStatus>(
              key: const ValueKey('detail-quick-admit-status'),
              label: l10n.circularFieldAdmitStatusLabel,
              value: circular.admitCardStatus,
              items: AdmitCardStatus.values,
              enabled: enabled,
              labelBuilder: (item) =>
                  CircularL10n.admitCardStatusLabel(item, l10n),
              onChanged: (next) =>
                  unawaited(controller.updateAdmitCardStatus(circular, next)),
            ),
            SizedBox(height: spacing.xl),
            Row(
              children: [
                Expanded(
                  child: Text(
                    l10n.circularDetailChecklistTitle,
                    style: textStyles.titleMedium,
                  ),
                ),
                Text(
                  l10n.circularDetailChecklistProgress(
                    formattedDone,
                    formattedTotal,
                  ),
                  style: textStyles.labelMedium.copyWith(
                    color: colors.goldAccent,
                  ),
                ),
              ],
            ),
            SizedBox(height: spacing.sm),
            AnimatedProgressBar(
              value: checklist.progress,
              replayKey: circular.id,
            ),
            SizedBox(height: spacing.md),
            for (final item in ApplicationChecklistItem.values)
              _ChecklistRow(
                item: item,
                checked: checklist.isChecked(item),
                enabled: enabled,
                onToggle: () => unawaited(
                  controller.toggleChecklistItem(circular, item),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _ChecklistRow extends StatelessWidget {
  const _ChecklistRow({
    required this.item,
    required this.checked,
    required this.enabled,
    required this.onToggle,
  });

  final ApplicationChecklistItem item;
  final bool checked;
  final bool enabled;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final colors = tokens.colors;
    final spacing = tokens.spacing;
    final l10n = context.l10n;

    return Padding(
      padding: EdgeInsets.only(bottom: spacing.xs),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          key: ValueKey('checklist-item-${item.name}'),
          onTap: enabled ? onToggle : null,
          borderRadius: tokens.radii.buttonRadius,
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: spacing.sm,
              vertical: spacing.xs,
            ),
            child: Row(
              children: [
                Checkbox(
                  value: checked,
                  onChanged: enabled ? (_) => onToggle() : null,
                  activeColor: colors.goldAccent,
                  checkColor: colors.background,
                  side: BorderSide(color: colors.glassBorder),
                ),
                SizedBox(width: spacing.sm),
                Expanded(
                  child: Text(
                    CircularL10n.checklistItemLabel(item, l10n),
                    style: tokens.textStyles.bodyMedium.copyWith(
                      color:
                          checked ? colors.textSecondary : colors.textPrimary,
                      decoration: checked ? TextDecoration.lineThrough : null,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
