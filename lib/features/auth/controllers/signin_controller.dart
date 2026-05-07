
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nelsontan_offshore_drilling/core/util/app_navigation.dart';
import 'package:nelsontan_offshore_drilling/core/widgets/snakbar/custom_snackbar.dart';
import 'package:nelsontan_offshore_drilling/features/auth/views/signup_screen.dart';
import 'package:nelsontan_offshore_drilling/home_page.dart';

import '../../../core/services/api_services.dart';
import '../../../core/util/storage_service.dart';
import '../models/sign_in_response_model.dart';
import '../views/account_status_screen.dart';
import '../views/client_rig_select_screen.dart';
import '../views/forget_password_screen.dart';
import '../views/otp_verification_screen.dart';

class SignInController extends GetxController {
  // Text Controllers
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final ApiServices _api = Get.find<ApiServices>();


  final emailFocus = FocusNode();
  final passwordFocus = FocusNode();

  final isPasswordVisible = false.obs;
  final isLoading = false.obs;

  final formKey = GlobalKey<FormState>();

  void togglePasswordVisibility() {
    isPasswordVisible.value = !isPasswordVisible.value;
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
    final email    = emailController.text.trim();
    final password = passwordController.text.trim();

    if (!formKey.currentState!.validate()) return;

    isLoading.value = true;
    try {
      final raw = await _api.post(
        '/auth/user/signin',
        body: {"email": email, "password": password},
      );

      final response = SignInResponseModel.fromJson(raw);

      if (response.data == null) {
        CustomSnackBar.error('Login failed. Please try again.');
        return;
      }

      final token = response.data!.token;
      final user  = response.data!.user;


      StorageService.saveToken(token);
      await StorageService.saveUser(user);



      switch (user.approveStatus){
        case "PENDING":
          AppNavigation.pushAndClear(AccountStatusScreen(status: AccountStatus.pending));
          break;
        case "APPROVED":
          AppNavigation.pushAndClear(BasePage());
          break;
        case "REJECTED":
          AppNavigation.pushAndClear(AccountStatusScreen(status: AccountStatus.suspended));
          break;
        case "INACTIVE":
          AppNavigation.pushAndClear(AccountStatusScreen(status: AccountStatus.inactive));
          break;
        case "DELETED":
          AppNavigation.pushAndClear(AccountStatusScreen(status: AccountStatus.deleted));
          break;
        case "NOT_SUBMITTED":
          AppNavigation.pushAndClear(ClientRigSelectScreen());
          break;
      }

      CustomSnackBar.success('Welcome back, ${user.name}!');

    } on HttpException catch (e) {
      if (e.body != null && e.body!.contains('not verified')) {
        CustomSnackBar.warning('Please verify your email to continue.');
        await Future.delayed(const Duration(milliseconds: 500));
        AppNavigation.push(OtpVerificationScreen(email: email, isFromSignUp: true));
      } else {
        CustomSnackBar.error(e.message);
      }
    }finally {
      isLoading.value = false;
    }
  }

  void navigateToSignUp() {
    AppNavigation.push( SignUpScreen());
  }

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