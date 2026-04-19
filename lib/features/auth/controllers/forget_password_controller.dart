// forget_password_controller.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/services/api_services.dart';
import '../../../core/util/app_navigation.dart';
import '../../../core/util/form_validator.dart';
import '../../../core/widgets/snakbar/custom_snackbar.dart';
import '../views/otp_verification_screen.dart';

class ForgetPasswordController extends GetxController {
  final ApiServices _api = Get.find<ApiServices>();

  final emailController = TextEditingController();
  final emailFocus      = FocusNode();
  final isLoading       = false.obs;
  final formKey         = GlobalKey<FormState>();

  String? validateEmail(String? value) {
    if (value == null || value.isEmpty) return 'Please enter your email';
    if (!FormValidator.isValidEmail(value)) return 'Please enter a valid email';
    return null;
  }

  Future<void> resetPassword(BuildContext context) async {


    if (!formKey.currentState!.validate()) return;

    final email = emailController.text.trim();

    // Extra snackbar + focus guard (same pattern as SignUp)
    if (!FormValidator.isValidEmail(email)) {
      CustomSnackBar.error('Please enter a valid email');
      emailFocus.requestFocus();
      return;
    }

    isLoading.value = true;
    try {
      // POST /auth/user/forgot-password  body: { "email": "..." }
      await _api.post('/auth/user/forgot-password', body: {"email": email});

      CustomSnackBar.success('Verification code sent to your email!');
      await Future.delayed(const Duration(milliseconds: 500));

      AppNavigation.push(
        OtpVerificationScreen(email: email, isFromSignUp: false),
      );

    } on HttpException catch (e) {
      CustomSnackBar.error(e.message);
    } catch (e) {
      CustomSnackBar.error('Failed to send reset link. Please try again.');
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    emailController.dispose();
    emailFocus.dispose();
    super.onClose();
  }
}