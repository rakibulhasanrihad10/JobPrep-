import 'dart:async' show unawaited;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:job_prep/core/localization/app_localizations_extension.dart';
import 'package:job_prep/core/localization/formatters.dart';
import 'package:job_prep/core/theme/app_theme_tokens.dart';
import 'package:job_prep/core/widgets/glass_button.dart';
import 'package:job_prep/core/widgets/glass_dialog.dart';
import 'package:job_prep/core/widgets/glass_text_field.dart';
import 'package:job_prep/features/prep/domain/entities/study_plan_snapshot.dart';
import 'package:job_prep/features/prep/presentation/providers/study_plan_providers.dart';
import 'package:job_prep/features/prep/presentation/utils/study_plan_ui_helpers.dart';

/// Warning banner displayed inside a study plan card whenever its recalculated
/// daily target exceeds the user's configured maximum daily pace cap.
class StudyPlanPaceWarningBox extends ConsumerWidget {
  /// Creates a [StudyPlanPaceWarningBox].
  const StudyPlanPaceWarningBox({
    required this.cardKeySlug,
    required this.snapshot,
    required this.locale,
    required this.useBanglaDigits,
    required this.isBusy,
    super.key,
  });

  /// Identifier suffix used in widget keys for testability.
  final String cardKeySlug;

  /// Live snapshot driving the displayed target, limit, and options.
  final StudyPlanSnapshot snapshot;

  /// Active UI locale.
  final Locale locale;

  /// Whether Bangla numerals are enabled.
  final bool useBanglaDigits;

  /// Whether another mutation is currently in progress.
  final bool isBusy;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tokens = context.tokens;
    final colors = tokens.colors;
    final spacing = tokens.spacing;
    final radii = tokens.radii;
    final l10n = context.l10n;

    final formattedTarget = AppFormatters.formatNumber(
      snapshot.todayTarget,
      locale: locale,
      useBanglaDigits: useBanglaDigits,
    );
    final formattedLimit = AppFormatters.formatNumber(
      snapshot.plan.maxDailyPace!,
      locale: locale,
      useBanglaDigits: useBanglaDigits,
    );

    return Container(
      key: ValueKey('study-plan-pace-warning-$cardKeySlug'),
      padding: spacing.insetsAllMd,
      decoration: BoxDecoration(
        color: colors.warning.withValues(alpha: 0.14),
        borderRadius: radii.mdRadius,
        border: Border.all(color: colors.warning.withValues(alpha: 0.55)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                Icons.warning_amber_rounded,
                color: colors.warning,
                size: spacing.lg,
              ),
              SizedBox(width: spacing.sm),
              Expanded(
                child: Text(
                  l10n.prepStudyPlanPaceWarning(
                    formattedTarget,
                    formattedLimit,
                  ),
                  style: tokens.textStyles.bodySmall.copyWith(
                    color: colors.textPrimary,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: spacing.sm),
          Wrap(
            spacing: spacing.xs,
            runSpacing: spacing.xs,
            children: [
              if (snapshot.hasConvertibleRestDays)
                GlassButton(
                  key: ValueKey('pace-action-convert-rest-$cardKeySlug'),
                  onPressed: isBusy
                      ? null
                      : () => unawaited(
                            ref
                                .read(studyPlanControllerProvider.notifier)
                                .convertRestDayToStudyDay(snapshot),
                          ),
                  child: Text(l10n.prepStudyPlanActionConvertRest),
                ),
              GlassButton(
                key: ValueKey('pace-action-raise-limit-$cardKeySlug'),
                onPressed: isBusy
                    ? null
                    : () => unawaited(
                          StudyPlanUiHelpers.promptRaisePaceLimit(
                            context,
                            ref,
                            snapshot,
                          ),
                        ),
                child: Text(l10n.prepStudyPlanActionRaisePace),
              ),
              if (snapshot.postponableMaterials.isNotEmpty)
                GlassButton(
                  key: ValueKey('pace-action-postpone-$cardKeySlug'),
                  onPressed: isBusy
                      ? null
                      : () => unawaited(
                            StudyPlanUiHelpers.promptPostponeMaterial(
                              context,
                              ref,
                              snapshot,
                            ),
                          ),
                  child: Text(l10n.prepStudyPlanActionPostponeMaterial),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Stateful modal dialog letting users raise the daily pace limit while
/// safely owning its [TextEditingController] across dialog exit animations.
class RaisePaceLimitDialog extends StatefulWidget {
  /// Creates a [RaisePaceLimitDialog].
  const RaisePaceLimitDialog({
    required this.planId,
    required this.suggestedLimit,
    super.key,
  });

  /// Owning plan identifier used in widget keys.
  final String planId;

  /// Pre-filled suggested new daily pace cap.
  final int suggestedLimit;

  @override
  State<RaisePaceLimitDialog> createState() => _RaisePaceLimitDialogState();
}

class _RaisePaceLimitDialogState extends State<RaisePaceLimitDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: '${widget.suggestedLimit}');
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final l10n = context.l10n;
    return GlassDialog(
      key: ValueKey('raise-pace-dialog-${widget.planId}'),
      title: Text(
        l10n.prepStudyPlanRaisePaceTitle,
        style: tokens.textStyles.titleLarge,
      ),
      content: Form(
        key: _formKey,
        child: GlassTextField(
          key: const ValueKey('raise-pace-input-field'),
          controller: _controller,
          labelText: l10n.prepStudyPlanMaxPaceLabel,
          keyboardType: TextInputType.number,
          validator: (value) {
            final ascii = AppFormatters.toEnglishDigits((value ?? '').trim());
            final parsed = int.tryParse(ascii);
            if (parsed == null || parsed <= 0) {
              return l10n.prepStudyPlanValidationPace;
            }
            return null;
          },
        ),
      ),
      actions: [
        GlassButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n.circularFormCancelButton),
        ),
        GlassButton(
          key: const ValueKey('raise-pace-confirm-button'),
          variant: GlassButtonVariant.primary,
          onPressed: () {
            if (!(_formKey.currentState?.validate() ?? false)) return;
            final ascii = AppFormatters.toEnglishDigits(
              _controller.text.trim(),
            );
            Navigator.of(context).pop(int.parse(ascii));
          },
          child: Text(l10n.prepStudyPlanSaveButton),
        ),
      ],
    );
  }
}
