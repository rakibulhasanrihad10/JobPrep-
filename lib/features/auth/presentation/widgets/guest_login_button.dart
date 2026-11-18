import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:job_prep/core/data/app_mode.dart';
import 'package:job_prep/core/localization/app_localizations_extension.dart';
import 'package:job_prep/core/theme/app_theme_tokens.dart';
import 'package:job_prep/core/widgets/glass_button.dart';
import 'package:job_prep/features/auth/presentation/navigation/auth_redirect.dart';
import 'package:job_prep/features/auth/presentation/widgets/guest_confirmation_sheet.dart';
import 'package:job_prep/features/onboarding/presentation/providers/onboarding_status_provider.dart';

/// "Continue without account" button with disclaimer and confirmation sheet
/// flow.
class GuestLoginButton extends ConsumerWidget {
  /// Creates a [GuestLoginButton].
  const GuestLoginButton({
    required this.isDisabled,
    super.key,
  });

  /// Whether button is disabled while auth actions are pending.
  final bool isDisabled;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tokens = context.tokens;
    final colors = tokens.colors;
    final spacing = tokens.spacing;
    final textStyles = tokens.textStyles;
    final l10n = context.l10n;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        GlassButton(
          key: const ValueKey('auth_continue_without_account_button'),
          onPressed: isDisabled
              ? null
              : () async {
                  final confirmed = await showGuestConfirmationSheet(context);
                  if (confirmed && context.mounted) {
                    await ref.read(appModeProvider.notifier).enterGuestMode();
                    if (context.mounted) {
                      final status =
                          await ref.read(onboardingStatusProvider.future);
                      final needs = status.needsOnboarding;
                      if (context.mounted) {
                        context.go(
                          needs
                              ? AppRoutePaths.onboarding
                              : AppRoutePaths.today,
                        );
                      }
                    }
                  }
                },
          child: Text(l10n.authContinueWithoutAccount),
        ),
        SizedBox(height: spacing.xs),
        Text(
          l10n.authDataStaysOnDevice,
          key: const ValueKey('auth_guest_device_disclaimer'),
          style: textStyles.bodySmall.copyWith(
            color: colors.textSecondary,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
