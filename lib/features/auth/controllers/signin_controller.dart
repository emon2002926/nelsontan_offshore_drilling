// sign_in_controller.dart
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nelsontan_offshore_drilling/core/util/app_navigation.dart';
import 'package:nelsontan_offshore_drilling/core/widgets/snakbar/custom_snackbar.dart';
import 'package:nelsontan_offshore_drilling/features/auth/views/signup_screen.dart';
import 'package:nelsontan_offshore_drilling/home_page.dart';

import '../../../core/services/api_services.dart';
import '../../../core/util/storage_service.dart';
import '../views/forget_password_screen.dart';

class SignInController extends GetxController {
  // Text Controllers
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final ApiServices _api = Get.find<ApiServices>();


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


  Future<void> login() async {
    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    if (!formKey.currentState!.validate()) return; // use your form validator

    isLoading.value = true;
    try {
      final data = await _api.post(
        '/auth/user/signin',
        body: {"email": email, "password": password},
      );

      final accessToken = data?["data"]; // ✅ fixed — token is directly in "data"
      if (accessToken != null) {
        StorageService.saveToken(accessToken);
        CustomSnackBar.success('Login Successful');
        Get.offAll(() => HomePage());
      } else {
        CustomSnackBar.error('Token not received. Please try again.');
      }

    } on HttpException catch (e) {
      // ✅ never leave this empty
      CustomSnackBar.error(e.message);
    } catch (e) {
      CustomSnackBar.error('Something went wrong. Please try again.');
    } finally {
      isLoading.value = false;
    }
  }

  void navigateToSignUp() {
    AppNavigation.push( SignUpScreen());
  }

  // Navigate to Forget Password
  void navigateToForgetPassword(BuildContext context) {

    AppNavigation.push( ForgetPasswordScreen());
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