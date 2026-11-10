import 'package:flutter/material.dart';
import 'package:job_prep/core/localization/app_localizations_extension.dart';
import 'package:job_prep/core/theme/app_theme_tokens.dart';
import 'package:job_prep/features/auth/presentation/providers/auth_form_state.dart';

/// Bottom mode-switcher footer between sign-in, account creation, and
/// returning from forgot-password mode.
class AuthModeToggleFooter extends StatelessWidget {
  /// Creates an [AuthModeToggleFooter].
  const AuthModeToggleFooter({
    required this.mode,
    required this.isDisabled,
    required this.onSwitchMode,
    super.key,
  });

  /// Active authentication screen mode.
  final AuthScreenMode mode;

  /// Disables mode switching while an async action is in flight.
  final bool isDisabled;

  /// Invoked when the user switches to a different [AuthScreenMode].
  final ValueChanged<AuthScreenMode> onSwitchMode;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final colors = tokens.colors;
    final radii = tokens.radii;
    final textStyles = tokens.textStyles;
    final l10n = context.l10n;

    if (mode == AuthScreenMode.forgotPassword) {
      return Center(
        child: TextButton(
          key: const ValueKey('auth_back_to_sign_in_button'),
          style: TextButton.styleFrom(
            foregroundColor: colors.goldAccent,
            shape: RoundedRectangleBorder(borderRadius: radii.buttonRadius),
          ),
          onPressed:
              isDisabled ? null : () => onSwitchMode(AuthScreenMode.signIn),
          child: Text(l10n.authBackToSignIn),
        ),
      );
    }

    final isSignIn = mode == AuthScreenMode.signIn;
    final promptText =
        isSignIn ? l10n.authNoAccountPrompt : l10n.authAlreadyHaveAccountPrompt;
    final actionText =
        isSignIn ? l10n.authSwitchToSignUp : l10n.authSwitchToSignIn;
    final targetMode = isSignIn ? AuthScreenMode.signUp : AuthScreenMode.signIn;

    return Wrap(
      alignment: WrapAlignment.center,
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: tokens.spacing.xs,
      children: [
        Text(promptText, style: textStyles.bodySmall),
        TextButton(
          key: const ValueKey('auth_mode_toggle_button'),
          style: TextButton.styleFrom(
            foregroundColor: colors.goldAccent,
            padding: tokens.spacing.insetsHorizontalSm,
            shape: RoundedRectangleBorder(borderRadius: radii.buttonRadius),
          ),
          onPressed: isDisabled ? null : () => onSwitchMode(targetMode),
          child: Text(actionText),
        ),
      ],
    );
  }
}
