// reset_password_screen.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/constants/app_assert_image.dart';
import '../../../core/util/app_navigation.dart';
import '../../../core/util/screen_size.dart';
import '../../../core/widgets/app_bar/build_app_bar.dart';
import '../../../core/widgets/buttons/app_button.dart';
import '../../../core/widgets/text/app_text.dart';
import '../../../core/widgets/text/text_field/AppTextFiled.dart';
import '../controllers/reset_password_controller.dart';

class ResetPasswordScreen extends StatelessWidget {
  final String email;
  final String? otp;

  const ResetPasswordScreen({
    super.key,
    required this.email,
    this.otp,
  });

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(
      ResetPasswordController(
        email: email,
        otp: otp,
      ),
    );

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
                      data: 'Password reset',
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF333333),
                      useResponsiveFontSize: true,
                    ),

                    SizedBox(height: context.responsiveSize(80)),

                    // New Password Field
                    Obx(
                          () => AppTextField(
                        hintText: 'Enter your new password',
                        controller: controller.newPasswordController,
                        focusNode: controller.newPasswordFocus,
                        prefixIcon: Icons.lock_outline,
                        suffixIcon: controller.isNewPasswordVisible.value
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                        onSuffixIconTap: controller.toggleNewPasswordVisibility,
                        obscureText: !controller.isNewPasswordVisible.value,
                        validator: controller.validateNewPassword,
                        keyboardType: TextInputType.visiblePassword,
                        fillColor: Colors.white,
                        hintTextColor: const Color(0xFF9E9E9E),
                        inputTextColor: const Color(0xFF333333),
                        borderColor: Colors.transparent,
                        useResponsiveSize: true,
                      ),
                    ),

                    SizedBox(height: context.responsiveSize(20)),

                    // Confirm Password Field
                    Obx(
                          () => AppTextField(
                        hintText: 'Re- Enter new password',
                        controller: controller.confirmPasswordController,
                        focusNode: controller.confirmPasswordFocus,
                        prefixIcon: Icons.lock_outline,
                        suffixIcon: controller.isConfirmPasswordVisible.value
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                        onSuffixIconTap:
                        controller.toggleConfirmPasswordVisibility,
                        obscureText: !controller.isConfirmPasswordVisible.value,
                        validator: controller.validateConfirmPassword,
                        keyboardType: TextInputType.visiblePassword,
                        fillColor: Colors.white,
                        hintTextColor: const Color(0xFF9E9E9E),
                        inputTextColor: const Color(0xFF333333),
                        borderColor: Colors.transparent,
                        useResponsiveSize: true,
                      ),
                    ),

                    SizedBox(height: context.responsiveSize(40)),

                    // Update Password Button
                    Obx(
                          () => AppButton(
                        buttonText: 'Update Password',
                        onPressed: () => controller.updatePassword(context),
                        fillColor: const Color(0xFF0047AB),
                        textColor: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        buttonHeight: 56,
                        isLoading: controller.isLoading.value,
                        loadingText: 'Updating...',
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
              loadingMessage: 'Updating your password...',
              backgroundColor: Colors.black,
              cardColor: Colors.white,
            ),
          ],
        ),
      ),
    );
  }
}