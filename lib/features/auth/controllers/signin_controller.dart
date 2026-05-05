
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


      // print("sadkfjgsag: ${user.approveStatus}");
      //
      // String status = user.approveStatus;
      // if(status=="PENDING"){
      //   AppNavigation.pushAndClear(AccountStatusScreen(status: AccountStatus.pending));
      // } else if(status=="APPROVED"){
      //   AppNavigation.pushAndClear(HomePage());
      // } else if(status=="REJECTED"){
      //   AppNavigation.pushAndClear(AccountStatusScreen(status: AccountStatus.suspended));
      // }else if(status=="INACTIVE"){
      //   AppNavigation.pushAndClear(AccountStatusScreen(status: AccountStatus.inactive));
      // }else if(status=="DELETED"){
      //   AppNavigation.pushAndClear(AccountStatusScreen(status: AccountStatus.deleted));
      // }else if(status=="NOT_SUBMITTED"){
      //   AppNavigation.pushAndClear(ClientRigSelectScreen());
      // }
      //



      if (!user.isApproved) {
        final screen = switch (true) {
          _ when user.isActive   =>  const BasePage( ),
          _ when user.isPending   => const AccountStatusScreen(status: AccountStatus.pending),
          _ when user.isInactive  => const AccountStatusScreen(status: AccountStatus.inactive),
          _ when user.isSuspended => const AccountStatusScreen(status: AccountStatus.suspended),
          _ when user.isDeleted   => const AccountStatusScreen(status: AccountStatus.deleted),
          _ when user.isNotSubmitted   => const ClientRigSelectScreen( ),
          _                       => const AccountStatusScreen(status: AccountStatus.pending),
        };
        AppNavigation.push(screen);
        return;
      }


      // ✅ Approved — go home
      CustomSnackBar.success('Welcome back, ${user.name}!');
      Get.offAll(() => BasePage());

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