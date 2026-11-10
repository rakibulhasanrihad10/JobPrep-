import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:job_prep/core/localization/app_localizations_extension.dart';
import 'package:job_prep/core/localization/formatters.dart';
import 'package:job_prep/core/localization/locale_controller.dart';
import 'package:job_prep/core/theme/app_theme_tokens.dart';
import 'package:job_prep/core/widgets/glass_button.dart';
import 'package:job_prep/core/widgets/glass_dialog.dart';
import 'package:job_prep/core/widgets/glass_text_field.dart';
import 'package:job_prep/features/circulars/domain/entities/circular.dart';
import 'package:job_prep/features/circulars/presentation/providers/circulars_providers.dart';
import 'package:job_prep/features/circulars/presentation/providers/quick_capture_controller.dart';
import 'package:job_prep/features/circulars/presentation/utils/circular_l10n.dart';
import 'package:job_prep/features/circulars/presentation/widgets/circular_form_widgets.dart';

/// Opens the Quick Capture frosted glass dialog, optionally pre-filling
/// [initialUrl] (for example from a `?capture=` deep link).
///
/// Returns the created Inbox [Circular] when saved, or `null` if cancelled.
Future<Circular?> showQuickCaptureDialog(
  BuildContext context, {
  String? initialUrl,
}) {
  return showGlassDialog<Circular?>(
    context: context,
    builder: (_) => QuickCaptureDialog(initialUrl: initialUrl),
  );
}

/// Compact frosted glass dialog for saving a circular link to Inbox in as few
/// taps as possible.
class QuickCaptureDialog extends ConsumerStatefulWidget {
  /// Creates a [QuickCaptureDialog].
  const QuickCaptureDialog({
    super.key,
    this.initialUrl,
  });

  /// Optional prefilled URL captured from browser query parameters.
  final String? initialUrl;

  @override
  ConsumerState<QuickCaptureDialog> createState() => _QuickCaptureDialogState();
}

class _QuickCaptureDialogState extends ConsumerState<QuickCaptureDialog> {
  late final TextEditingController _linkController;
  late final TextEditingController _titleController;

  @override
  void initState() {
    super.initState();
    final initial = ref.read(
      quickCaptureControllerProvider(widget.initialUrl),
    );
    _linkController = TextEditingController(text: initial.link);
    _titleController = TextEditingController(text: initial.title);
  }

  @override
  void dispose() {
    _linkController.dispose();
    _titleController.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    final controller = ref.read(
      quickCaptureControllerProvider(widget.initialUrl).notifier,
    );
    final saved = await controller.submit();
    if (!mounted || saved == null) return;
    Navigator.of(context).pop(saved);
  }

  Future<void> _pickDeadline(DateTime? current) async {
    final now = ref.read(circularNowProvider)();
    final picked = await showDatePicker(
      context: context,
      initialDate: current ?? now,
      firstDate: DateTime(2020),
      lastDate: DateTime(2040),
    );
    if (picked != null && mounted) {
      ref
          .read(quickCaptureControllerProvider(widget.initialUrl).notifier)
          .updateDeadline(picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = quickCaptureControllerProvider(widget.initialUrl);
    final state = ref.watch(provider);
    final controller = ref.read(provider.notifier);

    final tokens = context.tokens;
    final colors = tokens.colors;
    final spacing = tokens.spacing;
    final textStyles = tokens.textStyles;
    final l10n = context.l10n;
    final locale = ref.watch(localeProvider);
    final useBanglaDigits = ref.watch(useBanglaDigitsProvider);
    final enabled = !state.isSubmitting;

    final deadlineLabel = state.deadline != null
        ? AppFormatters.formatDate(
            state.deadline!,
            locale: locale,
            useBanglaDigits: useBanglaDigits,
          )
        : l10n.circularFieldDeadlineNone;

    return GlassDialog(
      key: const ValueKey('quick-capture-dialog'),
      maxWidth: 440,
      title: Row(
        children: [
          Icon(
            Icons.add_link_rounded,
            color: colors.goldAccent,
            size: spacing.xl,
          ),
          SizedBox(width: spacing.sm),
          Expanded(
            child: Text(l10n.quickCaptureDialogTitle),
          ),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              l10n.quickCaptureDialogSubtitle,
              style: textStyles.bodySmall.copyWith(color: colors.textSecondary),
            ),
            SizedBox(height: spacing.lg),
            GlassTextField(
              key: const ValueKey('quick-capture-link-field'),
              controller: _linkController,
              enabled: enabled,
              autofocus: true,
              keyboardType: TextInputType.url,
              textInputAction: TextInputAction.done,
              prefixIcon: const Icon(Icons.link_rounded),
              labelText: l10n.quickCaptureLinkLabel,
              hintText: l10n.quickCaptureLinkHint,
              errorText: CircularL10n.quickCaptureLinkValidationMessage(
                state.linkError,
                l10n,
              ),
              onChanged: controller.updateLink,
              onSubmitted: (_) => _handleSave(),
            ),
            if (state.duplicateCircular != null) ...[
              SizedBox(height: spacing.sm),
              CircularDuplicateWarningBanner(
                duplicate: state.duplicateCircular!,
              ),
            ],
            SizedBox(height: spacing.md),
            GlassTextField(
              key: const ValueKey('quick-capture-title-field'),
              controller: _titleController,
              enabled: enabled,
              textInputAction: TextInputAction.done,
              labelText: l10n.quickCaptureTitleLabel,
              hintText: l10n.quickCaptureTitleHint,
              onChanged: controller.updateTitle,
              onSubmitted: (_) => _handleSave(),
            ),
            SizedBox(height: spacing.md),
            Text(
              l10n.quickCaptureDeadlineLabel,
              style: textStyles.labelLarge.copyWith(
                color: colors.textSecondary,
              ),
            ),
            SizedBox(height: spacing.sm),
            Row(
              children: [
                Expanded(
                  child: GlassButton(
                    key: const ValueKey('quick-capture-deadline-btn'),
                    onPressed:
                        enabled ? () => _pickDeadline(state.deadline) : null,
                    leading: Icon(
                      Icons.calendar_today_outlined,
                      size: spacing.lg,
                      color: colors.goldAccent,
                    ),
                    child: Text(deadlineLabel),
                  ),
                ),
                if (state.deadline != null) ...[
                  SizedBox(width: spacing.xs),
                  IconButton(
                    key: const ValueKey('quick-capture-clear-deadline'),
                    tooltip: l10n.circularFieldClearDeadlineTooltip,
                    onPressed:
                        enabled ? () => controller.updateDeadline(null) : null,
                    icon: Icon(
                      Icons.close_rounded,
                      color: colors.textSecondary,
                    ),
                  ),
                ],
              ],
            ),
            if (state.submitFailure != null) ...[
              SizedBox(height: spacing.md),
              Container(
                key: const ValueKey('quick-capture-error-banner'),
                padding: spacing.insetsAllMd,
                decoration: BoxDecoration(
                  color: colors.danger.withValues(alpha: 0.14),
                  borderRadius: tokens.radii.buttonRadius,
                  border: Border.all(
                    color: colors.danger.withValues(alpha: 0.55),
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.error_outline_rounded,
                      color: colors.danger,
                      size: spacing.lg,
                    ),
                    SizedBox(width: spacing.sm),
                    Expanded(
                      child: Text(
                        CircularL10n.circularErrorMessage(
                          state.submitFailure!,
                          l10n,
                        ),
                        style: textStyles.bodySmall.copyWith(
                          color: colors.danger,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
      actions: [
        GlassButton(
          key: const ValueKey('quick-capture-cancel-btn'),
          onPressed: enabled ? () => Navigator.of(context).pop() : null,
          child: Text(l10n.circularFormCancelButton),
        ),
        GlassButton(
          key: const ValueKey('quick-capture-save-btn'),
          variant: GlassButtonVariant.primary,
          onPressed: enabled ? _handleSave : null,
          leading: state.isSubmitting
              ? SizedBox(
                  width: spacing.lg,
                  height: spacing.lg,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: colors.background,
                  ),
                )
              : Icon(Icons.inbox_rounded, size: spacing.lg),
          child: Text(
            state.isSubmitting
                ? l10n.quickCaptureSavingAction
                : l10n.quickCaptureSaveAction,
          ),
        ),
      ],
    );
  }
}
