// reset_password_controller.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/util/app_navigation.dart';
import '../../../core/widgets/snakbar/custom_snackbar.dart';
import '../views/signin_screen.dart';

class ResetPasswordController extends GetxController {
  // Text Controllers
  final newPasswordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  // Focus Nodes
  final newPasswordFocus = FocusNode();
  final confirmPasswordFocus = FocusNode();

  // Observable states
  final isNewPasswordVisible = false.obs;
  final isConfirmPasswordVisible = false.obs;
  final isLoading = false.obs;

  // Form key
  final formKey = GlobalKey<FormState>();

  // Email and OTP passed from previous screen
  final String email;
  final String? otp;

  ResetPasswordController({
    required this.email,
    this.otp,
  });

  // Toggle password visibility
  void toggleNewPasswordVisibility() {
    isNewPasswordVisible.value = !isNewPasswordVisible.value;
  }

  void toggleConfirmPasswordVisibility() {
    isConfirmPasswordVisible.value = !isConfirmPasswordVisible.value;
  }

  // Validators
  String? validateNewPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter a new password';
    }
    if (value.length < 8) {
      return 'Password must be at least 8 characters';
    }
    // Optional: Add more password strength validations
    if (!value.contains(RegExp(r'[A-Z]'))) {
      return 'Password must contain at least one uppercase letter';
    }
    if (!value.contains(RegExp(r'[a-z]'))) {
      return 'Password must contain at least one lowercase letter';
    }
    if (!value.contains(RegExp(r'[0-9]'))) {
      return 'Password must contain at least one number';
    }
    return null;
  }

  String? validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please re-enter your password';
    }
    if (value != newPasswordController.text) {
      return 'Passwords do not match';
    }
    return null;
  }

  // Update Password Action
  Future<void> updatePassword(BuildContext context) async {
    if (formKey.currentState!.validate()) {
      isLoading.value = true;

      try {
        // Simulate API call
        await Future.delayed(const Duration(seconds: 2));

        // TODO: Implement actual reset password API call
        // Example:
        // final response = await AuthService.resetPassword(
        //   email: email,
        //   otp: otp,
        //   newPassword: newPasswordController.text,
        // );

        print('Email: $email');
        print('OTP: $otp');
        print('New Password: ${newPasswordController.text}');

        isLoading.value = false;

        // Show success message
        CustomSnackBar.success(
          'Password updated successfully!',
          duration: const Duration(seconds: 3),
        );

        // Navigate to sign in screen
        await Future.delayed(const Duration(milliseconds: 500));
        AppNavigation.pushAndClear( const SignInScreen());

      } catch (e) {
        isLoading.value = false;
        CustomSnackBar.error('Failed to update password. Please try again.');
        print('Error: $e');
      }
    }
  }

  @override
  void onClose() {
    // Dispose controllers
    newPasswordController.dispose();
    confirmPasswordController.dispose();

    // Dispose focus nodes
    newPasswordFocus.dispose();
    confirmPasswordFocus.dispose();

    super.onClose();
  }
}