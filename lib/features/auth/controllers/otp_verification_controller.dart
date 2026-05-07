import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/services/api_services.dart';
import '../../../core/util/app_navigation.dart';
import '../../../core/util/storage_service.dart';
import '../../../core/widgets/snakbar/custom_snackbar.dart';
import '../../../home_page.dart';
import '../models/sign_in_response_model.dart';
import '../views/account_status_screen.dart';
import '../views/client_rig_select_screen.dart';
import '../views/reset_password_screen.dart';
import '../views/signin_screen.dart';
import 'account_status_controller.dart';

class OtpVerificationController extends GetxController {
  final ApiServices _api = Get.find<ApiServices>();

  // OTP Controllers & Focus Nodes
  final otp1Controller = TextEditingController();
  final otp2Controller = TextEditingController();
  final otp3Controller = TextEditingController();
  final otp4Controller = TextEditingController();
  final otp5Controller = TextEditingController();
  final otp6Controller = TextEditingController();

  final otp1Focus = FocusNode();
  final otp2Focus = FocusNode();
  final otp3Focus = FocusNode();
  final otp4Focus = FocusNode();
  final otp5Focus = FocusNode();
  final otp6Focus = FocusNode();


  final isLoading   = false.obs;
  final isResending = false.obs;

  String get otpCode =>
      '${otp1Controller.text}${otp2Controller.text}${otp3Controller.text}'
          '${otp4Controller.text}${otp5Controller.text}${otp6Controller.text}';

  bool get isOtpComplete => otpCode.length == 6;


  Future<void> verifyOtp(BuildContext context, String email, bool isFromSignUp) async {
    if (!isOtpComplete) {
      CustomSnackBar.warning('Please enter complete 6-digit code');
      return;
    }

    isLoading.value = true;
    try {
      if (isFromSignUp) {
        final raw = await _api.post(
          '/auth/user/verify-email',
          body: {"email": email, "otp": int.parse(otpCode)},
        );
        final response = SignInResponseModel.fromJson(raw);
        final token    = response.data?.token;
        final user     = response.data?.user;

        if (token != null && token.isNotEmpty) {
          StorageService.saveToken(token);
        }

        CustomSnackBar.success('Email verified successfully!');
        await Future.delayed(const Duration(milliseconds: 500));

        if (user == null || user.isNotSubmitted) {
          AppNavigation.pushAndClear(const ClientRigSelectScreen());
          return;
        }

        if (user.isPending) {
          AppNavigation.pushAndClear(
            const AccountStatusScreen(status: AccountStatus.pending),
          );
          return;
        }

        if (user.isApproved && user.isActive) {
          AppNavigation.pushAndClear(BasePage());
          return;
        }

        AppNavigation.pushAndClear(const SignInScreen());

      } else {
        // This one for Forgot Password
        await _api.post(
          '/auth/user/verify-otp',
          body: {"email": email, "otp": int.parse(otpCode)},
        );

        CustomSnackBar.success('OTP verified successfully!');
        await Future.delayed(const Duration(milliseconds: 500));
        AppNavigation.push(ResetPasswordScreen(email: email, otp: otpCode));
      }

    } on HttpException catch (e) {
      CustomSnackBar.error(e.message);
      _clearOtp();
    } catch (e) {
      CustomSnackBar.error('Invalid code. Please try again.');
      _clearOtp();
    } finally {
      isLoading.value = false;
    }
  }
  Future<void> resendOtp(BuildContext context, String email, bool isFromSignUp) async {
    isResending.value = true;
    try {
      if (isFromSignUp) {
        // Sign Up resend → dedicated endpoint
        await _api.post('/auth/user/resend-code', body: {"email": email});
      } else {
        // Forgot Password resend → hit forgot-password again
        await _api.post('/auth/user/forgot-password', body: {"email": email});
      }

      _clearOtp();
      CustomSnackBar.success('Verification code sent to your email!');

    } on HttpException catch (e) {
      CustomSnackBar.error(e.message);
    } catch (e) {
      CustomSnackBar.error('Failed to resend code. Please try again.');
    } finally {
      isResending.value = false;
    }
  }

  void _clearOtp() {
    for (final c in [otp1Controller, otp2Controller, otp3Controller,
      otp4Controller, otp5Controller, otp6Controller]) {
      c.clear();
    }
    otp1Focus.requestFocus();
  }

  void handleBackspace(TextEditingController current, FocusNode? previous) {
    if (current.text.isEmpty && previous != null) {
      previous.requestFocus();
    }
  }

  @override
  void onClose() {
    for (final c in [otp1Controller, otp2Controller, otp3Controller,
      otp4Controller, otp5Controller, otp6Controller]) {
      c.dispose();
    }
    for (final f in [otp1Focus, otp2Focus, otp3Focus,
      otp4Focus, otp5Focus, otp6Focus]) {
      f.dispose();
    }
    super.onClose();
  }
}