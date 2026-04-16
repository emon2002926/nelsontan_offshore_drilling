import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nelsontan_offshore_drilling/core/constants/app_assert_image.dart';
import '../../../core/util/screen_size.dart';
import '../../../core/widgets/app_bar/build_app_bar.dart';
import '../../../core/widgets/buttons/app_button.dart';
import '../../../core/widgets/text/text_field/AppTextFiled.dart';
import '../controllers/signup_controller.dart';

class SignUpScreen extends StatelessWidget {
  const SignUpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<SignUpController>();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: BuildAppBar(
        useCircularBackButton: true,
        showBackButton: true,
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
                    Image.asset(
                      AppAssertImage.instance.appLogo, // Add your logo asset
                      width: context.responsiveSize(280),
                      height: context.responsiveSize(100),
                      fit: BoxFit.contain,
                    ),

                    SizedBox(height: context.responsiveSize(40)),

                    // Full Name Field
                    AppTextField(
                      hintText: 'Enter Full Name',
                      controller: controller.fullNameController,
                      focusNode: controller.fullNameFocus,
                      prefixIcon: Icons.person_outline,
                      validator: controller.validateFullName,
                      keyboardType: TextInputType.name,
                      fillColor: Colors.white,
                      hintTextColor: const Color(0xFF9E9E9E),
                      inputTextColor: const Color(0xFF333333),
                      borderColor: Colors.transparent,
                      useResponsiveSize: true,
                    ),

                    SizedBox(height: context.responsiveSize(20)),

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

                    SizedBox(height: context.responsiveSize(20)),

                    // Company Name Field
                    AppTextField(
                      hintText: 'Enter Company Name',
                      controller: controller.companyNameController,
                      focusNode: controller.companyNameFocus,
                      prefixIcon: Icons.business_outlined,
                      validator: controller.validateCompanyName,
                      keyboardType: TextInputType.text,
                      fillColor: Colors.white,
                      hintTextColor: const Color(0xFF9E9E9E),
                      inputTextColor: const Color(0xFF333333),
                      borderColor: Colors.transparent,
                      useResponsiveSize: true,
                    ),

                    SizedBox(height: context.responsiveSize(20)),

                    // Position Field
                    AppTextField(
                      hintText: 'Enter Position',
                      controller: controller.positionController,
                      focusNode: controller.positionFocus,
                      prefixIcon: Icons.work_outline,
                      validator: controller.validatePosition,
                      keyboardType: TextInputType.text,
                      fillColor: Colors.white,
                      hintTextColor: const Color(0xFF9E9E9E),
                      inputTextColor: const Color(0xFF333333),
                      borderColor: Colors.transparent,
                      useResponsiveSize: true,
                    ),

                    SizedBox(height: context.responsiveSize(20)),

                    // Mobile Number Field
                    AppTextField(
                      hintText: 'Enter Mobile Number',
                      controller: controller.mobileNumberController,
                      focusNode: controller.mobileNumberFocus,
                      prefixIcon: Icons.phone_outlined,
                      validator: controller.validateMobileNumber,
                      keyboardType: TextInputType.phone,
                      fillColor: Colors.white,
                      hintTextColor: const Color(0xFF9E9E9E),
                      inputTextColor: const Color(0xFF333333),
                      borderColor: Colors.transparent,
                      useResponsiveSize: true,
                    ),

                    SizedBox(height: context.responsiveSize(20)),

                    // Password Field
                    Obx(
                          () => AppTextField(
                        hintText: 'Enter Password',
                        controller: controller.passwordController,
                        focusNode: controller.passwordFocus,
                        prefixIcon: Icons.lock_outline,
                        suffixIcon: controller.isPasswordVisible.value
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                        onSuffixIconTap: controller.togglePasswordVisibility,
                        obscureText: !controller.isPasswordVisible.value,
                        validator: controller.validatePassword,
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
                        hintText: 'Re Enter Password',
                        controller: controller.confirmPasswordController,
                        focusNode: controller.confirmPasswordFocus,
                        prefixIcon: Icons.lock_outline,
                        suffixIcon: controller.isConfirmPasswordVisible.value
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                        onSuffixIconTap: controller.toggleConfirmPasswordVisibility,
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

                    SizedBox(height: context.responsiveSize(36)),

                    // Sign Up Button
                    Obx(
                          () => AppButton(
                        buttonText: 'Sign Up',
                        onPressed: ()=> controller.signUp(context),
                        fillColor: const Color(0xFF0047AB),
                        textColor: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        buttonHeight: 56,
                        isLoading: controller.isLoading.value,
                        loadingText: 'Creating Account...',
                      ),
                    ),

                    SizedBox(height: context.responsiveSize(20)),

                    // Sign In Button
                    AppButton(
                      buttonText: 'Sign In',
                      onPressed: controller.navigateToSignIn,
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

            // Loading Overlay
            AppButton.buildLoadingOverlay(
              isLoading: controller.isLoading,
              loadingMessage: 'Creating your account...',
              backgroundColor: Colors.black,
              cardColor: Colors.white,
            ),
          ],
        ),
      ),
    );
  }
}