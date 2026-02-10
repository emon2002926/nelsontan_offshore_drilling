// forget_password_controller.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/util/app_navigation.dart';
import '../../../core/widgets/snakbar/custom_snackbar.dart';
import '../views/otp_verification_screen.dart';

class ForgetPasswordController extends GetxController {
  // Text Controller
  final emailController = TextEditingController();

  // Focus Node
  final emailFocus = FocusNode();

  // Observable states
  final isLoading = false.obs;

  // Form key
  final formKey = GlobalKey<FormState>();

  // Validator
  String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your email';
    }
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value)) {
      return 'Please enter a valid email';
    }
    return null;
  }

  // Reset Password Action
// In forget_password_controller.dart
  Future<void> resetPassword(BuildContext context) async {
    if (formKey.currentState!.validate()) {
      isLoading.value = true;

      try {
        await Future.delayed(const Duration(seconds: 2));

        print('Reset password email sent to: ${emailController.text}');

        isLoading.value = false;

        // Show success message
        CustomSnackBar.success('Verification code sent to your email!');

        // Navigate to OTP verification screen
        await Future.delayed(const Duration(milliseconds: 500));
        AppNavigation.push(
          context,
          OtpVerificationScreen(email: emailController.text,isFromSignUp: false,),
        );

      } catch (e) {
        isLoading.value = false;
        CustomSnackBar.error('Failed to send reset link. Please try again.');
        print('Error: $e');
      }
    }
  }
  @override
  void onClose() {
    // Dispose controller
    emailController.dispose();

    // Dispose focus node
    emailFocus.dispose();

    super.onClose();
  }
}