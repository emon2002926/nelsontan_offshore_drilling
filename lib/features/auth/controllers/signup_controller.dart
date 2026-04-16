// sign_up_controller.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nelsontan_offshore_drilling/core/util/app_navigation.dart';

import '../../../core/services/api_services.dart';
import '../../../core/util/form_validator.dart';
import '../../../core/widgets/snakbar/custom_snackbar.dart';
import '../views/otp_verification_screen.dart';

class SignUpController extends GetxController {
  final ApiServices _api = Get.find<ApiServices>();

  // Text Controllers
  final fullNameController        = TextEditingController();
  final emailController           = TextEditingController();
  final companyNameController     = TextEditingController();
  final positionController        = TextEditingController();
  final mobileNumberController    = TextEditingController();
  final passwordController        = TextEditingController();
  final confirmPasswordController = TextEditingController();

  // Focus Nodes
  final fullNameFocus         = FocusNode();
  final emailFocus            = FocusNode();
  final companyNameFocus      = FocusNode();
  final positionFocus         = FocusNode();
  final mobileNumberFocus     = FocusNode();
  final passwordFocus         = FocusNode();
  final confirmPasswordFocus  = FocusNode();

  // Observable states
  final isPasswordVisible        = false.obs;
  final isConfirmPasswordVisible = false.obs;
  final isLoading                = false.obs;

  // Form key
  final formKey = GlobalKey<FormState>();

  void togglePasswordVisibility()        => isPasswordVisible.value = !isPasswordVisible.value;
  void toggleConfirmPasswordVisibility() => isConfirmPasswordVisible.value = !isConfirmPasswordVisible.value;

  // ── Validators (used by AppTextField) ────────────────────────────────────
  String? validateFullName(String? v) {
    if (v == null || v.isEmpty) return 'Please enter your full name';
    if (v.length < 3) return 'Name must be at least 3 characters';
    return null;
  }

  String? validateEmail(String? v) {
    if (v == null || v.isEmpty) return 'Please enter your email';
    if (!FormValidator.isValidEmail(v)) return 'Please enter a valid email';
    return null;
  }

  String? validateCompanyName(String? v) =>
      (v == null || v.isEmpty) ? 'Please enter your company name' : null;

  String? validatePosition(String? v) =>
      (v == null || v.isEmpty) ? 'Please enter your position' : null;

  String? validateMobileNumber(String? v) {
    if (v == null || v.isEmpty) return 'Please enter your mobile number';
    if (v.length < 10) return 'Please enter a valid mobile number';
    return null;
  }

  String? validatePassword(String? v) {
    if (v == null || v.isEmpty) return 'Please enter a password';
    if (v.length < 8) return 'Password must be at least 8 characters';
    if (!v.contains(RegExp(r'[A-Z]'))) return 'Password must contain at least one uppercase letter';
    return null;
  }

  String? validateConfirmPassword(String? v) {
    if (v == null || v.isEmpty) return 'Please re-enter your password';
    if (v != passwordController.text) return 'Passwords do not match';
    return null;
  }

  // ── Sign Up ───────────────────────────────────────────────────────────────
  Future<void> signUp(BuildContext context) async {
    // Step 1: Flutter form validators (inline field errors)
    if (!formKey.currentState!.validate()) return;

    // Step 2: FormValidator — sequential snackbar + focus on first failure
    final password        = passwordController.text.trim();
    final confirmPassword = confirmPasswordController.text.trim();

    final isValid = FormValidator.validateAll([
      FormFieldEntry(value: fullNameController.text.trim(),     errorMessage: 'Full name is required',      focusNode: fullNameFocus),
      FormFieldEntry(value: emailController.text.trim(),        errorMessage: 'Email is required',          focusNode: emailFocus),
      FormFieldEntry(value: companyNameController.text.trim(),  errorMessage: 'Company name is required',   focusNode: companyNameFocus),
      FormFieldEntry(value: positionController.text.trim(),     errorMessage: 'Position is required',       focusNode: positionFocus),
      FormFieldEntry(value: mobileNumberController.text.trim(), errorMessage: 'Mobile number is required',  focusNode: mobileNumberFocus),
      FormFieldEntry(value: password,                           errorMessage: 'Password is required',       focusNode: passwordFocus),
      FormFieldEntry(value: confirmPassword,                    errorMessage: 'Please confirm your password', focusNode: confirmPasswordFocus),
    ]);
    if (!isValid) return;

    // Step 3: Extra checks that validateAll can't handle
    if (!FormValidator.isValidEmail(emailController.text.trim())) {
      CustomSnackBar.error('Please enter a valid email');
      emailFocus.requestFocus();
      return;
    }

    if (!FormValidator.isValidPassword(password)) {
      final msg = password.length < 8
          ? 'Password must be at least 8 characters'
          : 'Password must contain at least one uppercase letter';
      CustomSnackBar.error(msg);
      passwordFocus.requestFocus();
      return;
    }

    if (password != confirmPassword) {
      CustomSnackBar.error('Passwords do not match');
      confirmPasswordFocus.requestFocus();
      return;
    }

    // ✅ All validation passed — ready for API call
    isLoading.value = true;
    try {
      // TODO: replace with real endpoint
      final data = await _api.post('/auth/user/signup', body: {
        "name":        fullNameController.text.trim(),
        "email":       emailController.text.trim(),
        "entryCompany":     companyNameController.text.trim(),
        "position":    positionController.text.trim(),
        "phone": mobileNumberController.text.trim(),
        "password":    password,
      });

      CustomSnackBar.success('Account created successfully!');
      AppNavigation.push(OtpVerificationScreen(
        email: emailController.text.trim(),
        isFromSignUp: true,
      ));

    } on HttpException catch (e) {
      CustomSnackBar.error(e.message);
    } catch (e) {
      CustomSnackBar.error('Something went wrong. Please try again.');
    } finally {
      isLoading.value = false;
    }
  }

  void navigateToSignIn() => AppNavigation.pop(Get.context!);

  @override
  void onClose() {
    for (final c in [fullNameController, emailController, companyNameController,
      positionController, mobileNumberController, passwordController,
      confirmPasswordController]) {
      c.dispose();
    }
    for (final f in [fullNameFocus, emailFocus, companyNameFocus, positionFocus,
      mobileNumberFocus, passwordFocus, confirmPasswordFocus]) {
      f.dispose();
    }
    super.onClose();
  }
}