import 'dart:async' show unawaited;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:job_prep/core/localization/app_localizations_extension.dart';
import 'package:job_prep/core/widgets/app_scaffold.dart';
import 'package:job_prep/features/circulars/domain/utils/quick_capture_helpers.dart';
import 'package:job_prep/features/circulars/presentation/providers/circulars_providers.dart';
import 'package:job_prep/features/circulars/presentation/widgets/quick_capture_dialog.dart';

/// Connects [AppScaffold] with the live Inbox count, global Quick Capture
/// trigger, and incoming `?capture=` URL query parameters.
class QuickCaptureShell extends ConsumerStatefulWidget {
  /// Creates a [QuickCaptureShell].
  const QuickCaptureShell({
    required this.currentUri,
    required this.child,
    super.key,
  });

  /// Current URI reported by `GoRouterState`.
  final Uri currentUri;

  /// Active child route inside `ShellRoute`.
  final Widget child;

  @override
  ConsumerState<QuickCaptureShell> createState() => _QuickCaptureShellState();
}

class _QuickCaptureShellState extends ConsumerState<QuickCaptureShell> {
  bool _isDialogOpen = false;
  String? _pendingHandledUri;

  @override
  void initState() {
    super.initState();
    _scheduleIncomingCaptureIfNeeded(widget.currentUri);
  }

  @override
  void didUpdateWidget(QuickCaptureShell oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.currentUri != oldWidget.currentUri) {
      _scheduleIncomingCaptureIfNeeded(widget.currentUri);
    }
  }

  void _scheduleIncomingCaptureIfNeeded(Uri uri) {
    final captureLink = extractCaptureLinkFromUri(uri);
    final rawUri = uri.toString();
    if (captureLink == null || _isDialogOpen || _pendingHandledUri == rawUri) {
      return;
    }

    _pendingHandledUri = rawUri;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      unawaited(
        _openQuickCapture(
          initialUrl: captureLink,
          stripCaptureFromUri: uri,
        ),
      );
    });
  }

  Future<void> _openQuickCapture({
    String? initialUrl,
    Uri? stripCaptureFromUri,
  }) async {
    if (_isDialogOpen || !mounted) return;
    _isDialogOpen = true;

    final l10n = context.l10n;
    final messenger = ScaffoldMessenger.maybeOf(context);
    final router = GoRouter.maybeOf(context);

    final saved = await showQuickCaptureDialog(
      context,
      initialUrl: initialUrl,
    );

    _isDialogOpen = false;
    if (!mounted) return;

    if (stripCaptureFromUri != null) {
      _pendingHandledUri = null;
      final cleaned = stripCaptureQueryParams(stripCaptureFromUri).toString();
      if (cleaned != stripCaptureFromUri.toString()) {
        unawaited(
          router?.replace<Object?>(cleaned) ?? Future<Object?>.value(),
        );
      }
    }

    if (saved != null && messenger != null) {
      messenger.showSnackBar(
        SnackBar(
          content: Text(l10n.quickCaptureSavedSnackbar(saved.title)),
          action: SnackBarAction(
            label: l10n.quickCaptureViewInboxAction,
            onPressed: () => router?.go('/inbox'),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final inboxCount = ref.watch(inboxCountProvider);

    return AppScaffold(
      currentPath: widget.currentUri.path,
      inboxCount: inboxCount,
      onQuickCapture: () => unawaited(_openQuickCapture()),
      child: widget.child,
    );
  }
}
