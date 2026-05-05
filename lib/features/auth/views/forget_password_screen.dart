// forget_password_screen.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/constants/app_assert_image.dart';
import '../../../core/util/app_navigation.dart';
import '../../../core/util/screen_size.dart';
import '../../../core/widgets/app_bar/build_app_bar.dart';
import '../../../core/widgets/buttons/app_button.dart';
import '../../../core/widgets/text/app_text.dart';
import '../../../core/widgets/text/text_field/AppTextFiled.dart';
import '../controllers/forget_password_controller.dart';

class ForgetPasswordScreen extends StatelessWidget {
  const ForgetPasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ForgetPasswordController>();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: BuildAppBar(
        useCircularBackButton: true,
        showBackButton: true,
        onBackButtonPressed: () => AppNavigation.pop(context),
      ),
      body: SafeArea(
        child: Stack(
          children: [
            SingleChildScrollView(
              padding: EdgeInsets.symmetric(
                horizontal: context.responsiveSize(24),
              ),
              child: Form(
                key: controller.formKey,
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

                    SizedBox(height: context.responsiveSize(40)),

                    // Title
                    AppText(
                      data: 'Forgot password',
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF333333),
                      useResponsiveFontSize: true,
                    ),

                    SizedBox(height: context.responsiveSize(12)),

                    // Subtitle
                    AppText(
                      data: 'Please enter your email to reset the password',
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                      color: const Color(0xFF666666),
                      useResponsiveFontSize: true,
                      textAlign: TextAlign.center,
                    ),

                    SizedBox(height: context.responsiveSize(80)),

                    // Email Field
                    AppTextField(
                      hintText: 'Enter Email Address',
                      controller: controller.emailController,
                      focusNode: controller.emailFocus,
                      prefixIcon: Icons.email_outlined,
                      validator: controller.validateEmail,
                      keyboardType: TextInputType.emailAddress,
                      fillColor: Colors.white,
                      hintTextColor: const Color(0xFF9E9E9E),
                      inputTextColor: const Color(0xFF333333),
                      borderColor: Colors.transparent,
                      useResponsiveSize: true,
                    ),

                    SizedBox(height: context.responsiveSize(40)),

                    // Reset Password Button
                    Obx(
                          () => AppButton(
                        buttonText: 'Reset Password',
                        onPressed: () => controller.resetPassword(context),
                        fillColor: const Color(0xFF0047AB),
                        textColor: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        buttonHeight: 56,
                        isLoading: controller.isLoading.value,
                        loadingText: 'Sending...',
                      ),
                    ),

                    SizedBox(height: context.responsiveSize(40)),
                  ],
                ),
              ),
            ),

            // Loading Overlay
            AppButton.buildLoadingOverlay(
              isLoading: controller.isLoading,
              loadingMessage: 'Sending reset link...',
              backgroundColor: Colors.black,
            ),
          ],
        ),
      ),
    );
  }
}