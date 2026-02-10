// sign_up_controller.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nelsontan_offshore_drilling/core/util/app_navigation.dart';

import '../../../core/widgets/snakbar/custom_snackbar.dart';
import '../views/otp_verification_screen.dart';

class SignUpController extends GetxController {
  // Text Controllers
  final fullNameController = TextEditingController();
  final emailController = TextEditingController();
  final companyNameController = TextEditingController();
  final positionController = TextEditingController();
  final mobileNumberController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  // Focus Nodes
  final fullNameFocus = FocusNode();
  final emailFocus = FocusNode();
  final companyNameFocus = FocusNode();
  final positionFocus = FocusNode();
  final mobileNumberFocus = FocusNode();
  final passwordFocus = FocusNode();
  final confirmPasswordFocus = FocusNode();

  // Observable states
  final isPasswordVisible = false.obs;
  final isConfirmPasswordVisible = false.obs;
  final isLoading = false.obs;

  // Form key
  final formKey = GlobalKey<FormState>();

  // Toggle password visibility
  void togglePasswordVisibility() {
    isPasswordVisible.value = !isPasswordVisible.value;
  }

  void toggleConfirmPasswordVisibility() {
    isConfirmPasswordVisible.value = !isConfirmPasswordVisible.value;
  }

  // Validators
  String? validateFullName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your full name';
    }
    if (value.length < 3) {
      return 'Name must be at least 3 characters';
    }
    return null;
  }

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

  String? validateCompanyName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your company name';
    }
    return null;
  }

  String? validatePosition(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your position';
    }
    return null;
  }

  String? validateMobileNumber(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your mobile number';
    }
    if (value.length < 10) {
      return 'Please enter a valid mobile number';
    }
    return null;
  }

  String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter a password';
    }
    if (value.length < 8) {
      return 'Password must be at least 8 characters';
    }
    return null;
  }

  String? validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please re-enter your password';
    }
    if (value != passwordController.text) {
      return 'Passwords do not match';
    }
    return null;
  }

  // Sign Up Action
  Future<void> signUp(BuildContext context) async {
    if (formKey.currentState!.validate()) {
      isLoading.value = true;

      // Simulate API call
      await Future.delayed(const Duration(seconds: 2));

      // TODO: Implement actual sign up API call
      print('Full Name: ${fullNameController.text}');
      print('Email: ${emailController.text}');
      print('Company: ${companyNameController.text}');
      print('Position: ${positionController.text}');
      print('Mobile: ${mobileNumberController.text}');

      isLoading.value = false;

      // Navigate to next screen or show success message

      CustomSnackBar.success('Account created successfully!');
      AppNavigation.push(context, OtpVerificationScreen( email: emailController.text,isFromSignUp: true,));


    }
  }

  // Navigate to Sign In
  void navigateToSignIn() {
    // TODO: Navigate to sign in screen
    AppNavigation.pop(Get.context!);

  }

  @override
  void onClose() {
    // Dispose controllers
    fullNameController.dispose();
    emailController.dispose();
    companyNameController.dispose();
    positionController.dispose();
    mobileNumberController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();

    // Dispose focus nodes
    fullNameFocus.dispose();
    emailFocus.dispose();
    companyNameFocus.dispose();
    positionFocus.dispose();
    mobileNumberFocus.dispose();
    passwordFocus.dispose();
    confirmPasswordFocus.dispose();

    super.onClose();
  }
}