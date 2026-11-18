import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:job_prep/core/theme/app_theme_tokens.dart';
import 'package:job_prep/core/theme/reduce_effects_controller.dart';
import 'package:job_prep/features/prep/domain/utils/material_cover_validator.dart';
import 'package:job_prep/features/prep/presentation/providers/prep_cover_providers.dart';

/// Displays a study material cover from memory preview bytes, a signed private
/// Supabase Storage path, an external URL, or a tinted glass initial badge.
///
/// Lazy-loads remote images: defers signed-URL/network fetches while an ancestor
/// scrollable is flinging rapidly and bounds bitmap decoding with `cacheWidth`
/// / `cacheHeight` to keep scrolling smooth on low-memory devices.
class MaterialCoverThumbnail extends ConsumerWidget {
  /// Creates a [MaterialCoverThumbnail].
  const MaterialCoverThumbnail({
    required this.title,
    required this.subjectColor,
    super.key,
    this.coverImagePath,
    this.coverImageUrl,
    this.previewBytes,
    this.width,
    this.height,
    this.expand = false,
    this.deferDuringFastScroll = true,
  });

  /// Material title used to derive the glass placeholder's first letter.
  final String title;

  /// Subject accent color used for the glass placeholder background/border.
  final Color subjectColor;

  /// Private Storage object path inside `material-covers`.
  final String? coverImagePath;

  /// Optional external cover URL pasted by the user.
  final String? coverImageUrl;

  /// Optional in-memory bytes shown immediately after picking/resizing a photo.
  final Uint8List? previewBytes;

  /// Optional fixed thumbnail width when [expand] is false (`56 dp` default).
  final double? width;

  /// Optional fixed thumbnail height when [expand] is false (`72 dp` default).
  final double? height;

  /// When true, fills parent constraints (such as an [AspectRatio] cover box).
  final bool expand;

  /// Keeps the glass placeholder until rapid fling scrolling settles.
  final bool deferDuringFastScroll;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tokens = context.tokens;
    final colors = tokens.colors;
    final spacing = tokens.spacing;
    final radii = tokens.radii;
    final reduceEffects = ref.watch(reduceEffectsProvider);
    final dpr = MediaQuery.maybeDevicePixelRatioOf(context) ?? 1.0;

    final effectiveWidth =
        expand ? double.infinity : (width ?? (spacing.xxxl + spacing.sm));
    final effectiveHeight =
        expand ? double.infinity : (height ?? (spacing.xxxl + spacing.xl));
    final borderRadius = radii.buttonRadius;

    final decodeWidth = expand
        ? (180 * dpr).round().clamp(96, 480)
        : (effectiveWidth * dpr).round().clamp(64, 480);
    final decodeHeight = expand
        ? (225 * dpr).round().clamp(120, 600)
        : (effectiveHeight * dpr).round().clamp(64, 600);

    Widget buildPlaceholder() {
      final initial = MaterialCoverValidator.materialPlaceholderInitial(title);
      return Container(
        key: const ValueKey('material-cover-placeholder'),
        width: effectiveWidth,
        height: effectiveHeight,
        decoration: BoxDecoration(
          color: Color.alphaBlend(
            subjectColor.withValues(alpha: 0.24),
            colors.surfaceElevated,
          ),
          borderRadius: borderRadius,
          border: Border.all(
            color: subjectColor.withValues(alpha: 0.55),
          ),
        ),
        alignment: Alignment.center,
        child: Text(
          initial,
          style: (expand
                  ? tokens.textStyles.headlineMedium
                  : tokens.textStyles.titleLarge)
              .copyWith(color: colors.textPrimary),
        ),
      );
    }

    Widget wrapImage(Widget image) {
      return ClipRRect(
        borderRadius: borderRadius,
        child: Container(
          width: effectiveWidth,
          height: effectiveHeight,
          decoration: BoxDecoration(
            color: colors.surfaceElevated,
            borderRadius: borderRadius,
            border: Border.all(color: colors.glassBorder),
          ),
          child: image,
        ),
      );
    }

    final memoryBytes = previewBytes;
    if (memoryBytes != null && memoryBytes.isNotEmpty) {
      return wrapImage(
        Image.memory(
          memoryBytes,
          fit: BoxFit.cover,
          cacheWidth: decodeWidth,
          cacheHeight: decodeHeight,
          gaplessPlayback: true,
          errorBuilder: (_, __, ___) => buildPlaceholder(),
        ),
      );
    }

    if (deferDuringFastScroll &&
        Scrollable.recommendDeferredLoadingForContext(context)) {
      return buildPlaceholder();
    }

    final trimmedPath = coverImagePath?.trim() ?? '';
    if (trimmedPath.isNotEmpty) {
      final signedAsync =
          ref.watch(materialCoverSignedUrlProvider(trimmedPath));
      return signedAsync.when(
        loading: buildPlaceholder,
        error: (_, __) => buildPlaceholder(),
        data: (uri) {
          if (uri == null) return buildPlaceholder();
          return wrapImage(
            _buildNetworkImage(
              context: context,
              ref: ref,
              uri: uri,
              decodeWidth: decodeWidth,
              decodeHeight: decodeHeight,
              reduceEffects: reduceEffects,
              fadeDuration: tokens.durations.fast,
              fallbackBuilder: buildPlaceholder,
            ),
          );
        },
      );
    }

    final trimmedUrl = coverImageUrl?.trim() ?? '';
    if (trimmedUrl.isNotEmpty &&
        MaterialCoverValidator.validateCoverUrl(trimmedUrl) == null) {
      final uri = Uri.tryParse(trimmedUrl);
      if (uri != null) {
        return wrapImage(
          _buildNetworkImage(
            context: context,
            ref: ref,
            uri: uri,
            decodeWidth: decodeWidth,
            decodeHeight: decodeHeight,
            reduceEffects: reduceEffects,
            fadeDuration: tokens.durations.fast,
            fallbackBuilder: buildPlaceholder,
          ),
        );
      }
    }

    return buildPlaceholder();
  }

  Widget _buildNetworkImage({
    required BuildContext context,
    required WidgetRef ref,
    required Uri uri,
    required int decodeWidth,
    required int decodeHeight,
    required bool reduceEffects,
    required Duration fadeDuration,
    required Widget Function() fallbackBuilder,
  }) {
    final overrideBuilder = ref.watch(materialCoverPreviewImageBuilderProvider);
    if (overrideBuilder != null) {
      return overrideBuilder(context, uri);
    }
    return Image.network(
      uri.toString(),
      fit: BoxFit.cover,
      cacheWidth: decodeWidth,
      cacheHeight: decodeHeight,
      gaplessPlayback: true,
      frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
        if (wasSynchronouslyLoaded) return child;
        final loaded = frame != null;
        return Stack(
          fit: StackFit.expand,
          children: [
            if (!loaded) fallbackBuilder(),
            AnimatedOpacity(
              opacity: loaded ? 1.0 : 0.0,
              duration: reduceEffects ? Duration.zero : fadeDuration,
              child: child,
            ),
          ],
        );
      },
      errorBuilder: (_, __, ___) => fallbackBuilder(),
    );
  }
}
