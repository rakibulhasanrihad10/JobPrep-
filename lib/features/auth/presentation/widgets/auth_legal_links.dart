import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:job_prep/core/localization/app_localizations_extension.dart';
import 'package:job_prep/core/theme/app_theme_tokens.dart';
import 'package:job_prep/features/auth/presentation/navigation/auth_redirect.dart';

/// Footer links displaying Privacy Policy and Terms of Service.
class AuthLegalLinks extends StatelessWidget {
  /// Creates an [AuthLegalLinks].
  const AuthLegalLinks({super.key});

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final colors = tokens.colors;
    final spacing = tokens.spacing;
    final textStyles = tokens.textStyles;
    final l10n = context.l10n;

    return Wrap(
      alignment: WrapAlignment.center,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        TextButton(
          key: const ValueKey('login-privacy-link'),
          onPressed: () => context.go(AppRoutePaths.privacy),
          child: Text(
            l10n.legalPrivacyPolicyLink,
            style: textStyles.bodySmall.copyWith(
              color: colors.textSecondary,
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: spacing.xs),
          child: Text(
            '•',
            style: textStyles.bodySmall.copyWith(
              color: colors.textSecondary,
            ),
          ),
        ),
        TextButton(
          key: const ValueKey('login-terms-link'),
          onPressed: () => context.go(AppRoutePaths.terms),
          child: Text(
            l10n.legalTermsOfServiceLink,
            style: textStyles.bodySmall.copyWith(
              color: colors.textSecondary,
            ),
          ),
        ),
      ],
    );
  }
}
