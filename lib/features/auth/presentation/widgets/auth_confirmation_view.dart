import 'package:flutter/material.dart';
import 'package:job_prep/core/theme/app_theme_tokens.dart';
import 'package:job_prep/features/auth/presentation/widgets/auth_action_button.dart';
import 'package:job_prep/features/auth/presentation/widgets/auth_status_banner.dart';

/// Success confirmation body used after registration, password reset email,
/// or password update.
class AuthConfirmationView extends StatelessWidget {
  /// Creates an [AuthConfirmationView].
  const AuthConfirmationView({
    required this.bannerTitle,
    required this.bannerMessage,
    required this.buttonLabel,
    required this.onContinue,
    super.key,
    this.buttonKey,
  });

  /// Title rendered inside the success banner.
  final String bannerTitle;

  /// Descriptive confirmation message.
  final String bannerMessage;

  /// Primary CTA button label.
  final String buttonLabel;

  /// Callback triggered when CTA is pressed.
  final VoidCallback onContinue;

  /// Optional test key for the CTA button.
  final Key? buttonKey;

  @override
  Widget build(BuildContext context) {
    final spacing = context.spacing;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AuthStatusBanner(
          tone: AuthBannerTone.success,
          title: bannerTitle,
          message: bannerMessage,
        ),
        SizedBox(height: spacing.xl),
        AuthActionButton(
          key: buttonKey,
          label: buttonLabel,
          onPressed: onContinue,
        ),
      ],
    );
  }
}
