import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_assert_image.dart';
import '../../../core/util/screen_size.dart';
import '../../../core/widgets/app_bar/build_app_bar.dart';
import '../../../core/widgets/buttons/app_button.dart';
import '../../../core/widgets/text/app_text.dart';
import '../../../core/widgets/text/text_field/AppTextFiled.dart';
import '../controllers/signin_controller.dart';

class SignInScreen extends StatelessWidget {
  const SignInScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<SignInController>();

    return Scaffold(
      backgroundColor: Colors.white,
      // appBar: BuildAppBar(
      //   useCircularBackButton: true,
      //   showBackButton: false,
      // ),
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

                    // Welcome Text
                    AppText(
                      data: 'Welcome Back!',
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF333333),
                      useResponsiveFontSize: true,
                    ),

                    SizedBox(height: context.responsiveSize(12)),

                    // Subtitle
                    AppText(
                      data: 'Log in to discover your perfect match',
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                      color: const Color(0xFF666666),
                      useResponsiveFontSize: true,
                    ),

                    SizedBox(height: context.responsiveSize(60)),

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

                    SizedBox(height: context.responsiveSize(12)),

                    // Forget Password
                    Align(
                      alignment: Alignment.centerRight,
                      child: GestureDetector(
                        onTap: ()=>controller.navigateToForgetPassword(context),
                        child: AppText(
                          data: 'Forget Password?',
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: const Color(0xFF666666),
                          useResponsiveFontSize: true,
                        ),
                      ),
                    ),

                    SizedBox(height: context.responsiveSize(60)),

                    // Sign In Button
                    Obx(
                          () => AppButton(
                        buttonText: 'Sign In',
                        onPressed: ()=> controller.login(),
                        fillColor: const Color(0xFF0047AB),
                        textColor: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        buttonHeight: 56,
                        isLoading: controller.isLoading.value,
                        loadingText: 'Signing In...',
                      ),
                    ),

                    SizedBox(height: context.responsiveSize(20)),

                    // Sign Up Button
                    AppButton(
                      buttonText: 'Sign Up',
                      onPressed: controller.navigateToSignUp,
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
              loadingMessage: 'Signing you in...',
              backgroundColor: Colors.black,
              cardColor: Colors.white,
            ),
          ],
        ),
      ),
    );
  }
}