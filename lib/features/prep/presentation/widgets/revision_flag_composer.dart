import 'dart:async' show unawaited;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:job_prep/core/localization/app_localizations_extension.dart';
import 'package:job_prep/core/localization/formatters.dart';
import 'package:job_prep/core/localization/locale_controller.dart';
import 'package:job_prep/core/theme/app_theme_tokens.dart';
import 'package:job_prep/core/widgets/glass_text_field.dart';
import 'package:job_prep/features/prep/domain/entities/prep_enums.dart';
import 'package:job_prep/features/prep/domain/entities/revision_item.dart';
import 'package:job_prep/features/prep/presentation/providers/revision_providers.dart';
import 'package:job_prep/features/prep/presentation/utils/prep_l10n.dart';
import 'package:job_prep/features/prep/presentation/widgets/revision_composer_sections.dart';

/// Inline multi-flag composer letting users add one or more revision flags
/// (reference, optional page number, reason, and optional note) right after
/// saving study progress or inside the standalone Revision dialog.
class RevisionFlagComposer extends ConsumerStatefulWidget {
  /// Creates a [RevisionFlagComposer].
  const RevisionFlagComposer({
    required this.subjectId,
    required this.source,
    super.key,
    this.materialId,
    this.topicId,
    this.progressLogId,
    this.mockTestId,
    this.initialReference = '',
    this.initialPageNumber,
    this.initialReason = RevisionReason.tricky,
    this.showPageField = true,
    this.quickFillSuggestions = const <String>[],
    this.onClose,
    this.onFlagAdded,
  });

  /// Owning subject identifier.
  final String subjectId;

  /// Origin surface creating flags (`log`, `mock_test`, or `manual`).
  final RevisionSource source;

  /// Optional linked material identifier.
  final String? materialId;

  /// Optional linked syllabus topic identifier.
  final String? topicId;

  /// Optional triggering progress log identifier.
  final String? progressLogId;

  /// Optional triggering mock test identifier.
  final String? mockTestId;

  /// Initial text seeded into the reference field (for example `"p. 128"`).
  final String initialReference;

  /// Optional initial numeric page count seeded into the page field.
  final int? initialPageNumber;

  /// Initial selected reason pill.
  final RevisionReason initialReason;

  /// Whether to render the optional numeric page input field.
  final bool showPageField;

  /// Optional quick-fill topic chips (used when flagging mock weak topics).
  final List<String> quickFillSuggestions;

  /// Optional callback collapsing the inline composer.
  final VoidCallback? onClose;

  /// Optional callback invoked after adding a flag.
  final ValueChanged<RevisionItem>? onFlagAdded;

  @override
  ConsumerState<RevisionFlagComposer> createState() =>
      _RevisionFlagComposerState();
}

class _RevisionFlagComposerState extends ConsumerState<RevisionFlagComposer> {
  late final TextEditingController _refController;
  late final TextEditingController _pageController;
  late final TextEditingController _noteController;
  late RevisionReason _selectedReason;
  String? _referenceError;
  final List<RevisionItem> _addedThisSession = <RevisionItem>[];

  @override
  void initState() {
    super.initState();
    _refController = TextEditingController(text: widget.initialReference);
    _pageController = TextEditingController(
      text: widget.initialPageNumber != null && widget.initialPageNumber! >= 0
          ? widget.initialPageNumber.toString()
          : '',
    );
    _noteController = TextEditingController();
    _selectedReason = widget.initialReason;
  }

  @override
  void didUpdateWidget(RevisionFlagComposer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialReference != widget.initialReference &&
        _refController.text.trim().isEmpty) {
      _refController.text = widget.initialReference;
    }
    if (oldWidget.initialPageNumber != widget.initialPageNumber &&
        _pageController.text.trim().isEmpty &&
        widget.initialPageNumber != null &&
        widget.initialPageNumber! >= 0) {
      _pageController.text = widget.initialPageNumber.toString();
    }
  }

  @override
  void dispose() {
    _refController.dispose();
    _pageController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  int? _parsePage() {
    final normalized =
        AppFormatters.toEnglishDigits(_pageController.text.trim());
    if (normalized.isEmpty) return null;
    final parsed = int.tryParse(normalized);
    if (parsed == null || parsed < 0) return null;
    return parsed;
  }

  Future<void> _submitSingle() async {
    final refText = _refController.text.trim();
    if (refText.isEmpty) {
      setState(() => _referenceError = context.l10n.prepRevisionRefError);
      return;
    }
    setState(() => _referenceError = null);

    final created = await ref.read(revisionControllerProvider.notifier).addFlag(
          subjectId: widget.subjectId,
          materialId: widget.materialId,
          topicId: widget.topicId,
          referenceLabel: refText,
          pageNumber: _parsePage(),
          note: _noteController.text,
          reason: _selectedReason,
          source: widget.source,
          progressLogId: widget.progressLogId,
          mockTestId: widget.mockTestId,
        );
    if (!mounted || created == null) return;

    setState(() {
      _addedThisSession.add(created);
      _refController.clear();
      _noteController.clear();
    });
    widget.onFlagAdded?.call(created);
  }

  Future<void> _addAllWeakTopics() async {
    if (widget.quickFillSuggestions.isEmpty) return;
    final noteTrimmed = _noteController.text.trim();
    final drafts = [
      for (final topic in widget.quickFillSuggestions)
        RevisionFlagDraft(
          subjectId: widget.subjectId,
          materialId: widget.materialId,
          topicId: widget.topicId,
          referenceLabel: topic,
          note: noteTrimmed.isEmpty ? null : noteTrimmed,
          reason: _selectedReason,
          source: widget.source,
          mockTestId: widget.mockTestId,
        ),
    ];

    final createdList = await ref
        .read(revisionControllerProvider.notifier)
        .addMultipleFlags(drafts);
    if (!mounted || createdList.isEmpty) return;

    setState(() {
      _addedThisSession.addAll(createdList);
      _refController.clear();
      _noteController.clear();
    });
    final onFlagAdded = widget.onFlagAdded;
    if (onFlagAdded != null) {
      createdList.forEach(onFlagAdded);
    }
  }

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final colors = tokens.colors;
    final spacing = tokens.spacing;
    final radii = tokens.radii;
    final l10n = context.l10n;
    final locale = ref.watch(localeProvider);
    final useBanglaDigits = ref.watch(useBanglaDigitsProvider);
    final mutationState = ref.watch(revisionControllerProvider);
    final isBusy = mutationState.isSaving;

    return Container(
      key: const ValueKey('revision-inline-composer'),
      padding: spacing.insetsAllMd,
      decoration: BoxDecoration(
        color: colors.surfaceElevated,
        borderRadius: radii.cardRadius,
        border: Border.all(
          color: colors.goldAccent.withValues(alpha: 0.45),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          RevisionComposerHeader(
            isBusy: isBusy,
            onClose: widget.onClose,
          ),
          if (widget.quickFillSuggestions.isNotEmpty) ...[
            SizedBox(height: spacing.sm),
            RevisionWeakTopicSuggestionsRow(
              suggestions: widget.quickFillSuggestions,
              currentText: _refController.text.trim(),
              isBusy: isBusy,
              locale: locale,
              useBanglaDigits: useBanglaDigits,
              onSelectSuggestion: (suggestion) => setState(() {
                _refController.text = suggestion;
                _referenceError = null;
              }),
              onAddAll: () => unawaited(_addAllWeakTopics()),
            ),
          ],
          SizedBox(height: spacing.sm),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 3,
                child: GlassTextField(
                  key: const ValueKey('revision-ref-field'),
                  controller: _refController,
                  enabled: !isBusy,
                  labelText: l10n.prepRevisionRefLabel,
                  hintText: l10n.prepRevisionRefHint,
                  errorText: _referenceError,
                  onChanged: (_) {
                    if (_referenceError != null) {
                      setState(() => _referenceError = null);
                    }
                  },
                ),
              ),
              if (widget.showPageField) ...[
                SizedBox(width: spacing.sm),
                Expanded(
                  child: GlassTextField(
                    key: const ValueKey('revision-page-field'),
                    controller: _pageController,
                    enabled: !isBusy,
                    labelText: l10n.prepRevisionPageLabel,
                    hintText: l10n.prepRevisionPageHint,
                    keyboardType: TextInputType.number,
                  ),
                ),
              ],
            ],
          ),
          SizedBox(height: spacing.sm),
          RevisionReasonSelector(
            selectedReason: _selectedReason,
            isBusy: isBusy,
            onSelectReason: (reason) =>
                setState(() => _selectedReason = reason),
          ),
          SizedBox(height: spacing.sm),
          GlassTextField(
            key: const ValueKey('revision-note-field'),
            controller: _noteController,
            enabled: !isBusy,
            labelText: l10n.prepRevisionNoteLabel,
            hintText: l10n.prepRevisionNoteHint,
            onSubmitted: (_) => unawaited(_submitSingle()),
          ),
          if (mutationState.error != null) ...[
            SizedBox(height: spacing.xs),
            Text(
              PrepL10n.failureMessage(mutationState.error!, l10n),
              style: tokens.textStyles.bodySmall.copyWith(color: colors.danger),
            ),
          ],
          SizedBox(height: spacing.sm),
          RevisionComposerSubmitBar(
            addedItems: _addedThisSession,
            isBusy: isBusy,
            locale: locale,
            useBanglaDigits: useBanglaDigits,
            onSubmit: () => unawaited(_submitSingle()),
          ),
        ],
      ),
    );
  }
}
