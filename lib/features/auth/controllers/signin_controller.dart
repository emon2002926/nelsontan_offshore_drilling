// sign_in_controller.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nelsontan_offshore_drilling/core/util/app_navigation.dart';
import 'package:nelsontan_offshore_drilling/core/widgets/snakbar/custom_snackbar.dart';
import 'package:nelsontan_offshore_drilling/features/auth/views/signup_screen.dart';
import 'package:nelsontan_offshore_drilling/home_page.dart';

import '../views/forget_password_screen.dart';

class SignInController extends GetxController {
  // Text Controllers
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  // Focus Nodes
  final emailFocus = FocusNode();
  final passwordFocus = FocusNode();

  // Observable states
  final isPasswordVisible = false.obs;
  final isLoading = false.obs;

  // Form key
  final formKey = GlobalKey<FormState>();

  // Toggle password visibility
  void togglePasswordVisibility() {
    isPasswordVisible.value = !isPasswordVisible.value;
  }

  // Validators
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

  String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your password';
    }
    if (value.length < 6) {
      return 'Password must be at least 6 characters';
    }
    return null;
  }

  // Sign In Action
  Future<void> signIn(BuildContext context) async {
    if (formKey.currentState!.validate()) {
      isLoading.value = true;

      // Simulate API call
      await Future.delayed(const Duration(seconds: 2));

      // TODO: Implement actual sign in API call
      print('Email: ${emailController.text}');
      print('Password: ${passwordController.text}');

      isLoading.value = false;

      // Navigate to home screen or show success message
      CustomSnackBar.success("Sign In Successful");

      AppNavigation.pushAndClear(context, HomePage());
    }
  }

  // Navigate to Sign Up
  void navigateToSignUp() {
    AppNavigation.push(Get.context!, SignUpScreen());
  }

  // Navigate to Forget Password
  void navigateToForgetPassword(BuildContext context) {

    AppNavigation.push(context, ForgetPasswordScreen());
  }

  @override
  void onClose() {
    // Dispose controllers
    emailController.dispose();
    passwordController.dispose();

    // Dispose focus nodes
    emailFocus.dispose();
    passwordFocus.dispose();

    super.onClose();
  }
}