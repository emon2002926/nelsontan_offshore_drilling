// account_status_screen.dart
import 'package:flutter/material.dart';
import 'package:nelsontan_offshore_drilling/features/auth/views/signin_screen.dart';

import '../../../core/constants/app_assert_image.dart';
import '../../../core/util/app_navigation.dart';
import '../../../core/util/screen_size.dart';
import '../../../core/widgets/app_bar/build_app_bar.dart';
import '../../../core/widgets/buttons/app_button.dart';
import '../../../core/widgets/text/app_text.dart';
enum AccountStatus { pending, inactive, suspended, deleted }

class AccountStatusScreen extends StatelessWidget {
  final AccountStatus status;

  const AccountStatusScreen({super.key, required this.status});

  // ── Status config ─────────────────────────────────────────────────────────
  _StatusConfig get _config => switch (status) {
    AccountStatus.pending => _StatusConfig(
        icon: Icons.hourglass_top_rounded,
        iconColor: const Color(0xFFF59E0B),
        title: 'Account Pending',
        message:
        'Your account is under review. Our team will approve it shortly. You will be notified once the process is complete.',
    ),
    AccountStatus.inactive => _StatusConfig(
      icon: Icons.block_rounded,
      iconColor: const Color(0xFF6B7280),
      title: 'Account Inactive',
      message:
      'Your account is currently inactive. '
          'Please contact support to reactivate your account.',
    ),
    AccountStatus.suspended => _StatusConfig(
      icon: Icons.gpp_bad_rounded,
      iconColor: const Color(0xFFEF4444),
      title: 'Account Suspended',
      message:
      'Your account has been suspended due to a policy violation. '
          'Please contact support for further assistance.',
    ),
    AccountStatus.deleted => _StatusConfig(
      icon: Icons.delete_forever_rounded,
      iconColor: const Color(0xFFEF4444),
      title: 'Account Deleted',
      message:
      'This account no longer exists. '
          'If you believe this is a mistake, please contact support.',
    ),
  };

  @override
  Widget build(BuildContext context) {
    final config = _config;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: BuildAppBar(
        useCircularBackButton: true,
        showBackButton: false, // no back — user must use the button below
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: context.responsiveSize(24),
          ),
          child: Column(
            children: [
              SizedBox(height: context.responsiveSize(10)),

              // Logo
              Image.asset(
                AppAssertImage.instance.appLogo,
                width: context.responsiveSize(280),
                height: context.responsiveSize(100),
                fit: BoxFit.contain,
              ),

              const Spacer(),

              // Status Icon
              Container(
                width: context.responsiveSize(100),
                height: context.responsiveSize(100),
                decoration: BoxDecoration(
                  color: config.iconColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  config.icon,
                  size: context.responsiveSize(48),
                  color: config.iconColor,
                ),
              ),

              SizedBox(height: context.responsiveSize(32)),

              // Title
              AppText(
                data: config.title,
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF333333),
                useResponsiveFontSize: true,
                textAlign: TextAlign.center,
              ),

              SizedBox(height: context.responsiveSize(16)),

              // Message
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: context.responsiveSize(12),
                ),
                child: AppText(
                  data: config.message,
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                  color: const Color(0xFF666666),
                  useResponsiveFontSize: true,
                  textAlign: TextAlign.center,
                ),
              ),

              const Spacer(),

              // Back to Sign In Button
              AppButton(
                buttonText: 'Back to previous page',
                onPressed: () => AppNavigation.pushAndClear(const SignInScreen()),
                fillColor: const Color(0xFF0047AB),
                textColor: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w600,
                buttonHeight: 56,
              ),

              SizedBox(height: context.responsiveSize(40)),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Internal config model ─────────────────────────────────────────────────────
class _StatusConfig {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String message;

  const _StatusConfig({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.message,
  });
}