// reset_password_controller.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/services/api_services.dart';
import '../../../core/util/app_navigation.dart';
import '../../../core/util/form_validator.dart';
import '../../../core/util/storage_service.dart';
import '../../../core/widgets/snakbar/custom_snackbar.dart';
import '../views/signin_screen.dart';

class ResetPasswordController extends GetxController {
  final ApiServices _api = Get.find<ApiServices>();

  final newPasswordController     = TextEditingController();
  final confirmPasswordController = TextEditingController();

  final newPasswordFocus     = FocusNode();
  final confirmPasswordFocus = FocusNode();

  final isNewPasswordVisible     = false.obs;
  final isConfirmPasswordVisible = false.obs;
  final isLoading                = false.obs;

  final formKey = GlobalKey<FormState>();

  final String email;
  final String? otp;

  ResetPasswordController({required this.email, this.otp});

  void toggleNewPasswordVisibility()     => isNewPasswordVisible.value = !isNewPasswordVisible.value;
  void toggleConfirmPasswordVisibility() => isConfirmPasswordVisible.value = !isConfirmPasswordVisible.value;

  String? validateNewPassword(String? value) {
    if (value == null || value.isEmpty) return 'Please enter a new password';
    if (!FormValidator.isValidPassword(value)) {
      return value.length < 8
          ? 'Password must be at least 8 characters'
          : 'Password must contain at least one uppercase letter';
    }
    if (!value.contains(RegExp(r'[a-z]'))) return 'Password must contain at least one lowercase letter';
    if (!value.contains(RegExp(r'[0-9]'))) return 'Password must contain at least one number';
    return null;
  }

  String? validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) return 'Please re-enter your password';
    if (value != newPasswordController.text) return 'Passwords do not match';
    return null;
  }

  Future<void> updatePassword(BuildContext context) async {
    if (!formKey.currentState!.validate()) return;

    final password        = newPasswordController.text.trim();
    final confirmPassword = confirmPasswordController.text.trim();

    // Sequential snackbar guards
    final isValid = FormValidator.validateAll([
      FormFieldEntry(value: password,        errorMessage: 'Please enter a new password',   focusNode: newPasswordFocus),
      FormFieldEntry(value: confirmPassword, errorMessage: 'Please re-enter your password', focusNode: confirmPasswordFocus),
    ]);
    if (!isValid) return;

    if (!FormValidator.isValidPassword(password)) {
      final msg = password.length < 8
          ? 'Password must be at least 8 characters'
          : 'Password must contain at least one uppercase letter';
      CustomSnackBar.error(msg);
      newPasswordFocus.requestFocus();
      return;
    }

    if (password != confirmPassword) {
      CustomSnackBar.error('Passwords do not match');
      confirmPasswordFocus.requestFocus();
      return;
    }

    isLoading.value = true;
    try {
      // POST /auth/user/set-password  body: { email, otp: int, password }
      // Response: { success: true, data: "<JWT token>" }
      final data = await _api.post(
        '/auth/user/set-password',
        body: {
          "email":    email,
          "otp":      int.parse(otp ?? '0'), // ✅ API expects integer
          "password": password,
        },
      );

      // API returns a fresh token after password reset — save it
      final token = data?["data"];
      if (token != null) {
        StorageService.saveToken(token);
      }

      CustomSnackBar.success('Password updated successfully!',
          duration: const Duration(seconds: 3));

      await Future.delayed(const Duration(milliseconds: 500));
      AppNavigation.pushAndClear(const SignInScreen());

    } on HttpException catch (e) {
      CustomSnackBar.error(e.message);
    } catch (e) {
      CustomSnackBar.error('Failed to update password. Please try again.');
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    newPasswordController.dispose();
    confirmPasswordController.dispose();
    newPasswordFocus.dispose();
    confirmPasswordFocus.dispose();
    super.onClose();
  }
}