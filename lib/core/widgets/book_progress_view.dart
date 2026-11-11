import 'dart:async' show unawaited;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:job_prep/core/localization/app_localizations_extension.dart';
import 'package:job_prep/core/localization/formatters.dart';
import 'package:job_prep/core/theme/app_theme_tokens.dart';
import 'package:job_prep/core/widgets/book_position_controls.dart';
import 'package:job_prep/core/widgets/book_progress_3d_canvas.dart';
import 'package:job_prep/core/widgets/glass_card.dart';

/// Interactive glassmorphic book progress view displaying a 3D cover with
/// page-stack thickness, draggable ribbon bookmark, `"I am at page ___ of ___"`
/// quick position input, and backward correction confirmation.
class BookProgressView extends ConsumerStatefulWidget {
  /// Creates a [BookProgressView].
  const BookProgressView({
    required this.title,
    required this.completedUnits,
    required this.totalUnits,
    required this.unitLabel,
    required this.accentColor,
    required this.onCommitPosition,
    super.key,
    this.cover,
    this.lastUpdatedAt,
    this.replayKey,
    this.isSaving = false,
    this.errorText,
    this.trailingAction,
  });

  /// Book title shown beside the 3D cover (and used for glass placeholder).
  final String title;

  /// Current completed page count (`0 .. totalUnits`).
  final int completedUnits;

  /// Total page count of the book.
  final int totalUnits;

  /// Localized or configured unit label (typically `"pages"`).
  final String unitLabel;

  /// Accent color derived from the parent subject token.
  final Color accentColor;

  /// Optional Phase 4C front cover widget; falls back to glass initial cover.
  final Widget? cover;

  /// Optional timestamp of the latest book position update.
  final DateTime? lastUpdatedAt;

  /// Key whose change replays the open-book & progress bar animations.
  final Object? replayKey;

  /// Disables position submission controls while persistence is in flight.
  final bool isSaving;

  /// Optional repository/controller error rendered below the form.
  final String? errorText;

  /// Optional action rendered alongside the position save controls.
  final Widget? trailingAction;

  /// Saves the requested `targetPage`; `isCorrection` is `true` only after the
  /// user confirmed moving backward below [completedUnits].
  final Future<bool> Function(int targetPage, {required bool isCorrection})
      onCommitPosition;

  @override
  ConsumerState<BookProgressView> createState() => _BookProgressViewState();
}

class _BookProgressViewState extends ConsumerState<BookProgressView> {
  late final TextEditingController _pageController;
  int? _dragPreviewPage;
  String? _validationError;
  String? _statusMessage;
  bool _localBusy = false;

  int get _safeTotal => widget.totalUnits < 0 ? 0 : widget.totalUnits;
  int get _safeCompleted => widget.completedUnits.clamp(0, _safeTotal);

  @override
  void initState() {
    super.initState();
    _pageController = TextEditingController(text: _safeCompleted.toString());
  }

  @override
  void didUpdateWidget(BookProgressView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.completedUnits != widget.completedUnits ||
        oldWidget.totalUnits != widget.totalUnits ||
        oldWidget.replayKey != widget.replayKey) {
      _dragPreviewPage = null;
      _validationError = null;
      if (oldWidget.replayKey != widget.replayKey) {
        _statusMessage = null;
      }
      _syncFieldTo(_safeCompleted);
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _syncFieldTo(int page) {
    final text = page.toString();
    _pageController.value = TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
  }

  double get _effectiveFraction {
    if (_safeTotal <= 0) return 0;
    final page = _dragPreviewPage ?? _safeCompleted;
    return (page / _safeTotal).clamp(0.0, 1.0);
  }

  int _pageFromFraction(double fraction) {
    if (_safeTotal <= 0 || fraction.isNaN) return 0;
    return (fraction.clamp(0.0, 1.0) * _safeTotal).round();
  }

  Future<void> _submitTargetPage(int targetPage) async {
    if (_localBusy || widget.isSaving) return;
    final l10n = context.l10n;
    final locale = Localizations.localeOf(context);
    final current = _safeCompleted;
    final delta = targetPage - current;

    if (delta == 0) {
      setState(() {
        _dragPreviewPage = null;
        _validationError = null;
        _syncFieldTo(current);
      });
      return;
    }

    var isCorrection = false;
    if (delta < 0) {
      isCorrection = true;
      final confirmed = await showBookPositionCorrectionConfirmDialog(
        context,
        currentPage: current,
        targetPage: targetPage,
        unitLabel: widget.unitLabel,
      );
      if (!confirmed || !mounted) {
        setState(() {
          _dragPreviewPage = null;
          _validationError = null;
          _syncFieldTo(current);
        });
        return;
      }
    }

    setState(() {
      _localBusy = true;
      _validationError = null;
      _statusMessage = null;
    });

    final ok = await widget.onCommitPosition(
      targetPage,
      isCorrection: isCorrection,
    );
    if (!mounted) return;

    setState(() {
      _localBusy = false;
      _dragPreviewPage = null;
      if (ok) {
        _syncFieldTo(targetPage);
        _statusMessage = isCorrection
            ? l10n.bookProgressCorrectionSaved(
                AppFormatters.formatNumber(targetPage, locale: locale),
              )
            : l10n.bookProgressStudySaved(
                AppFormatters.formatNumber(delta, locale: locale),
                widget.unitLabel,
              );
      } else {
        _syncFieldTo(current);
      }
    });
  }

  void _handleTextSubmit() {
    final result = validateBookPageInput(
      raw: _pageController.text,
      totalUnits: _safeTotal,
      l10n: context.l10n,
      locale: Localizations.localeOf(context),
    );
    if (result.error != null || result.page == null) {
      setState(() {
        _validationError = result.error;
        _statusMessage = null;
      });
      return;
    }
    unawaited(_submitTargetPage(result.page!));
  }

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final spacing = tokens.spacing;
    final l10n = context.l10n;
    final locale = Localizations.localeOf(context);

    final shownPage = _dragPreviewPage ?? _safeCompleted;
    final fraction = _effectiveFraction;
    final percentText = l10n.bookProgressPercentLabel(
      AppFormatters.formatNumber((fraction * 100).round(), locale: locale),
    );
    final isBusy = _localBusy || widget.isSaving;

    return GlassCard(
      key: const ValueKey('book-progress-view-card'),
      padding: spacing.insetsAllLg,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth >= 520;
          final bookCanvas = BookProgress3dCanvas(
            title: widget.title,
            accentColor: widget.accentColor,
            progressFraction: fraction,
            cover: widget.cover,
            percentLabel: percentText,
            width: isWide ? 200.0 : 176.0,
            height: isWide ? 276.0 : 244.0,
            replayKey: widget.replayKey,
            interactiveBookmark: !isBusy,
            bookmarkSemanticLabel: l10n.bookProgressBookmarkSemantics,
            onBookmarkDragUpdate: (nextFraction) {
              final nextPage = _pageFromFraction(nextFraction);
              setState(() {
                _dragPreviewPage = nextPage;
                _validationError = null;
                _statusMessage = null;
                _syncFieldTo(nextPage);
              });
            },
            onBookmarkDragEnd: (finalFraction) {
              final targetPage = _pageFromFraction(finalFraction);
              setState(() => _syncFieldTo(targetPage));
              unawaited(_submitTargetPage(targetPage));
            },
          );

          final controlsColumn = BookPositionControlsPanel(
            title: widget.title,
            shownPage: shownPage,
            totalUnits: _safeTotal,
            unitLabel: widget.unitLabel,
            fraction: fraction,
            pageController: _pageController,
            isBusy: isBusy,
            lastUpdatedAt: widget.lastUpdatedAt,
            replayKey: widget.replayKey,
            errorMessage: _validationError ?? widget.errorText,
            statusMessage: _statusMessage,
            trailingAction: widget.trailingAction,
            onInputChanged: () {
              if (_validationError != null || _statusMessage != null) {
                setState(() {
                  _validationError = null;
                  _statusMessage = null;
                });
              }
            },
            onSubmit: _handleTextSubmit,
          );

          if (isWide) {
            return Row(
              children: [
                bookCanvas,
                SizedBox(width: spacing.xl),
                Expanded(child: controlsColumn),
              ],
            );
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              Center(child: bookCanvas),
              SizedBox(height: spacing.lg),
              controlsColumn,
            ],
          );
        },
      ),
    );
  }
}
