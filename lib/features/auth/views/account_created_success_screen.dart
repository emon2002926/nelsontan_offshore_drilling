// account_created_success_screen.dart
import 'package:flutter/material.dart';
import 'package:nelsontan_offshore_drilling/features/auth/views/signin_screen.dart';

import '../../../core/constants/app_assert_image.dart';
import '../../../core/util/app_navigation.dart';
import '../../../core/util/screen_size.dart';
import '../../../core/widgets/app_bar/build_app_bar.dart';
import '../../../core/widgets/buttons/app_button.dart';
import '../../../core/widgets/text/app_text.dart';

class AccountCreatedSuccessScreen extends StatelessWidget {
  const AccountCreatedSuccessScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: BuildAppBar(
        useCircularBackButton: true,
        showBackButton: true,
        onBackButtonPressed: () => _handleBackPress(context),
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: context.responsiveSize(24),
          ),
          child: Column(
            children: [
              // Spacer to center content
              SizedBox(height: context.responsiveSize(60)),

              // Logo
              Image.asset(
                AppAssertImage.instance.appLogo,
                width: context.responsiveSize(280),
                height: context.responsiveSize(100),
                fit: BoxFit.contain,
              ),

              SizedBox(height: context.responsiveSize(60)),

              // Success Title
              AppText(
                data: 'Account Created Successfully',
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF333333),
                useResponsiveFontSize: true,
                textAlign: TextAlign.center,
              ),

              SizedBox(height: context.responsiveSize(16)),

              // Success Message
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: context.responsiveSize(20),
                ),
                child: AppText(
                  data: 'Your account has been created. You can now log in and start exploring your account.',
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                  color: const Color(0xFF666666),
                  useResponsiveFontSize: true,
                  textAlign: TextAlign.center,
                  height: 1.5,
                ),
              ),

              const Spacer(),

              // Sign In Button
              AppButton(
                buttonText: 'Sign In',
                onPressed: () => _navigateToSignIn(context),
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

  // Handle back button press
  void _handleBackPress(BuildContext context) {
    // Navigate to sign in instead of going back
    _navigateToSignIn(context);
  }

  // Navigate to Sign In screen
  void _navigateToSignIn(BuildContext context) {
    // Clear all previous screens and go to sign in
    AppNavigation.pushAndClear(context, const SignInScreen());
  }
}