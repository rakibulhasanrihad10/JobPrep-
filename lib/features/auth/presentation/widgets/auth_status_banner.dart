import 'package:flutter/material.dart';
import 'package:job_prep/core/theme/app_theme_tokens.dart';

/// Visual tone for [AuthStatusBanner].
enum AuthBannerTone {
  /// Error / failure alert banner.
  error,

  /// Success / confirmation banner.
  success,
}

/// Tokenized alert banner displaying authentication errors or confirmations.
class AuthStatusBanner extends StatelessWidget {
  /// Creates an [AuthStatusBanner].
  const AuthStatusBanner({
    required this.message,
    required this.tone,
    super.key,
    this.title,
  });

  /// Optional heading shown above [message].
  final String? title;

  /// Body text describing the outcome or failure.
  final String message;

  /// Visual severity tone.
  final AuthBannerTone tone;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final colors = tokens.colors;
    final spacing = tokens.spacing;
    final radii = tokens.radii;
    final textStyles = tokens.textStyles;

    final accentColor =
        tone == AuthBannerTone.error ? colors.danger : colors.success;
    final iconData = tone == AuthBannerTone.error
        ? Icons.error_outline_rounded
        : Icons.check_circle_outline_rounded;

    return Semantics(
      liveRegion: true,
      child: Container(
        padding: spacing.insetsAllMd,
        decoration: BoxDecoration(
          color: accentColor.withValues(alpha: 0.12),
          borderRadius: radii.buttonRadius,
          border: Border.all(
            color: accentColor.withValues(alpha: 0.45),
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              iconData,
              color: accentColor,
              size: spacing.lg + spacing.xs,
            ),
            SizedBox(width: spacing.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (title != null) ...[
                    Text(
                      title!,
                      style: textStyles.labelLarge.copyWith(
                        color: colors.textPrimary,
                      ),
                    ),
                    SizedBox(height: spacing.xxs),
                  ],
                  Text(
                    message,
                    style: textStyles.bodySmall.copyWith(
                      color: colors.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
