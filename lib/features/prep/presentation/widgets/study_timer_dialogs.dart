import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:job_prep/core/localization/app_localizations_extension.dart';
import 'package:job_prep/core/localization/formatters.dart';
import 'package:job_prep/core/theme/app_theme_tokens.dart';
import 'package:job_prep/core/widgets/glass_button.dart';
import 'package:job_prep/core/widgets/glass_dialog.dart';
import 'package:job_prep/core/widgets/glass_text_field.dart';
import 'package:job_prep/features/prep/domain/entities/study_session.dart';
import 'package:job_prep/features/prep/presentation/providers/study_session_providers.dart';

/// Opens a glass dialog to configure Focus, Short Break, and Long Break (after
/// 4 rounds) durations persisted to `SharedPreferences`.
Future<void> showPomodoroConfigDialog(
  BuildContext context,
  WidgetRef ref,
) {
  final current = ref.read(pomodoroConfigProvider);
  return showGlassDialog<void>(
    context: context,
    builder: (_) => _PomodoroConfigDialog(initialConfig: current),
  );
}

/// Confirms discarding an open active timer session before deleting it.
Future<bool> showDiscardSessionDialog(BuildContext context) async {
  final confirmed = await showGlassDialog<bool>(
    context: context,
    builder: (ctx) {
      final l10n = ctx.l10n;
      final tokens = ctx.tokens;
      return GlassDialog(
        title: Text(l10n.prepTimerDiscardConfirmTitle),
        content: Text(
          l10n.prepTimerDiscardConfirmBody,
          style: tokens.textStyles.bodyMedium,
        ),
        actions: [
          GlassButton(
            key: const ValueKey('timer-discard-cancel-btn'),
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(l10n.prepCancelButton),
          ),
          GlassButton(
            key: const ValueKey('timer-discard-confirm-btn'),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(
              l10n.prepTimerDiscardButton,
              style: tokens.textStyles.labelLarge.copyWith(
                color: tokens.colors.danger,
              ),
            ),
          ),
        ],
      );
    },
  );
  return confirmed ?? false;
}

class _PomodoroConfigDialog extends ConsumerStatefulWidget {
  const _PomodoroConfigDialog({required this.initialConfig});

  final PomodoroConfig initialConfig;

  @override
  ConsumerState<_PomodoroConfigDialog> createState() =>
      _PomodoroConfigDialogState();
}

class _PomodoroConfigDialogState extends ConsumerState<_PomodoroConfigDialog> {
  late final TextEditingController _focusController;
  late final TextEditingController _shortController;
  late final TextEditingController _longController;
  String? _focusError;
  String? _shortError;
  String? _longError;

  @override
  void initState() {
    super.initState();
    _focusController =
        TextEditingController(text: '${widget.initialConfig.focusMinutes}');
    _shortController = TextEditingController(
      text: '${widget.initialConfig.shortBreakMinutes}',
    );
    _longController =
        TextEditingController(text: '${widget.initialConfig.longBreakMinutes}');
  }

  @override
  void dispose() {
    _focusController.dispose();
    _shortController.dispose();
    _longController.dispose();
    super.dispose();
  }

  int? _parsePositive(String raw) {
    final normalized = AppFormatters.toEnglishDigits(raw.trim());
    final value = int.tryParse(normalized);
    if (value == null || value < 1) return null;
    return value;
  }

  Future<void> _save() async {
    final l10n = context.l10n;
    final focus = _parsePositive(_focusController.text);
    final shortBreak = _parsePositive(_shortController.text);
    final longBreak = _parsePositive(_longController.text);

    setState(() {
      _focusError = focus == null ? l10n.prepTimerConfigPositiveError : null;
      _shortError =
          shortBreak == null ? l10n.prepTimerConfigPositiveError : null;
      _longError = longBreak == null ? l10n.prepTimerConfigPositiveError : null;
    });
    if (focus == null || shortBreak == null || longBreak == null) return;

    await ref.read(pomodoroConfigProvider.notifier).updateConfig(
          widget.initialConfig.copyWith(
            focusMinutes: focus,
            shortBreakMinutes: shortBreak,
            longBreakMinutes: longBreak,
          ),
        );
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final spacing = context.tokens.spacing;

    return GlassDialog(
      title: Text(l10n.prepTimerConfigDialogTitle),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          GlassTextField(
            key: const ValueKey('timer-config-focus-field'),
            controller: _focusController,
            labelText: l10n.prepTimerConfigFocusLabel,
            errorText: _focusError,
            keyboardType: TextInputType.number,
          ),
          SizedBox(height: spacing.md),
          GlassTextField(
            key: const ValueKey('timer-config-short-field'),
            controller: _shortController,
            labelText: l10n.prepTimerConfigShortBreakLabel,
            errorText: _shortError,
            keyboardType: TextInputType.number,
          ),
          SizedBox(height: spacing.md),
          GlassTextField(
            key: const ValueKey('timer-config-long-field'),
            controller: _longController,
            labelText: l10n.prepTimerConfigLongBreakLabel,
            errorText: _longError,
            keyboardType: TextInputType.number,
          ),
        ],
      ),
      actions: [
        GlassButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n.prepCancelButton),
        ),
        GlassButton(
          key: const ValueKey('timer-config-save-btn'),
          variant: GlassButtonVariant.primary,
          onPressed: _save,
          child: Text(l10n.prepSaveButton),
        ),
      ],
    );
  }
}
