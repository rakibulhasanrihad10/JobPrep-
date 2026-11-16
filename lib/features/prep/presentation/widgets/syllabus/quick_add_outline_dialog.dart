import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:job_prep/core/localization/app_localizations_extension.dart';
import 'package:job_prep/core/theme/app_theme_tokens.dart';
import 'package:job_prep/core/widgets/glass_button.dart';
import 'package:job_prep/core/widgets/glass_dialog.dart';
import 'package:job_prep/core/widgets/glass_text_field.dart';
import 'package:job_prep/features/prep/domain/utils/syllabus_outline_parser.dart';
import 'package:job_prep/features/prep/presentation/providers/syllabus_providers.dart';

/// Modal dialog to paste a multi-line outline and import chapters and topics.
class QuickAddOutlineDialog extends ConsumerStatefulWidget {
  const QuickAddOutlineDialog({
    required this.subjectId,
    this.initialText,
    super.key,
  });

  final String subjectId;
  final String? initialText;

  static Future<void> show(
    BuildContext context, {
    required String subjectId,
    String? initialText,
  }) {
    return showDialog<void>(
      context: context,
      builder: (_) => QuickAddOutlineDialog(
        subjectId: subjectId,
        initialText: initialText,
      ),
    );
  }

  @override
  ConsumerState<QuickAddOutlineDialog> createState() =>
      _QuickAddOutlineDialogState();
}

class _QuickAddOutlineDialogState extends ConsumerState<QuickAddOutlineDialog> {
  late final TextEditingController _controller;
  ParsedSyllabusOutline _preview = const ParsedSyllabusOutline();
  bool _isImporting = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialText ?? '')
      ..addListener(_updatePreview);
    _updatePreview();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _updatePreview() {
    setState(() {
      _preview = SyllabusOutlineParser.parse(_controller.text);
    });
  }

  Future<void> _handleImport() async {
    if (_preview.isEmpty || _isImporting) return;
    setState(() => _isImporting = true);

    try {
      await ref.read(syllabusControllerProvider).importPastedOutline(
            subjectId: widget.subjectId,
            outline: _preview,
          );
      if (mounted) Navigator.of(context).pop();
    } finally {
      if (mounted) setState(() => _isImporting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final spacing = tokens.spacing;
    final textStyles = tokens.textStyles;
    final colors = tokens.colors;
    final l10n = context.l10n;

    return GlassDialog(
      maxWidth: 520,
      title: Row(
        children: [
          Icon(
            Icons.playlist_add_rounded,
            color: colors.goldAccent,
            size: 20,
          ),
          SizedBox(width: spacing.sm),
          Expanded(
            child: Text(
              l10n.syllabusQuickAdd,
              style: textStyles.titleMedium.copyWith(
                color: colors.textPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            l10n.syllabusQuickAddSubtitle,
            style: textStyles.bodySmall.copyWith(
              color: colors.textSecondary,
            ),
          ),
          SizedBox(height: spacing.md),
          GlassTextField(
            controller: _controller,
            hintText: l10n.syllabusQuickAddHint,
            maxLines: 8,
          ),
          SizedBox(height: spacing.sm),
          Container(
            padding: spacing.insetsAllSm,
            decoration: BoxDecoration(
              color: colors.surfaceElevated.withValues(alpha: 0.5),
              borderRadius: tokens.radii.smRadius,
              border: Border.all(color: colors.glassBorder),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.preview_rounded,
                  color: colors.goldAccent,
                  size: 16,
                ),
                SizedBox(width: spacing.xs),
                Expanded(
                  child: Text(
                    l10n.syllabusQuickAddPreview(
                      _preview.chapters.length,
                      _preview.totalTopics,
                    ),
                    style: textStyles.bodySmall.copyWith(
                      color: colors.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      actions: [
        GlassButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(
            MaterialLocalizations.of(context).cancelButtonLabel,
          ),
        ),
        GlassButton(
          onPressed: _preview.isEmpty || _isImporting ? null : _handleImport,
          variant: GlassButtonVariant.primary,
          child: Text(l10n.syllabusQuickAddImportButton),
        ),
      ],
    );
  }
}
