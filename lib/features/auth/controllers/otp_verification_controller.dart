// otp_verification_controller.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/util/app_navigation.dart';
import '../../../core/widgets/snakbar/custom_snackbar.dart';
import '../views/account_created_success_screen.dart';
import '../views/reset_password_screen.dart';

class OtpVerificationController extends GetxController {
  // Text Controllers for each OTP box
  final otp1Controller = TextEditingController();
  final otp2Controller = TextEditingController();
  final otp3Controller = TextEditingController();
  final otp4Controller = TextEditingController();
  final otp5Controller = TextEditingController();
  final otp6Controller = TextEditingController();

  // Focus Nodes for each OTP box
  final otp1Focus = FocusNode();
  final otp2Focus = FocusNode();
  final otp3Focus = FocusNode();
  final otp4Focus = FocusNode();
  final otp5Focus = FocusNode();
  final otp6Focus = FocusNode();

  // Observable states
  final isLoading = false.obs;
  final isResending = false.obs;

  // Email passed from previous screen
  final String email;
  final bool isFromSignUp;


  OtpVerificationController({required this.email,required this.isFromSignUp});

  // Get complete OTP code
  String get otpCode =>
      '${otp1Controller.text}${otp2Controller.text}${otp3Controller.text}'
          '${otp4Controller.text}${otp5Controller.text}${otp6Controller.text}';

  // Check if OTP is complete
  bool get isOtpComplete => otpCode.length == 6;

  // Verify OTP Action

// In otp_verification_controller.dart
// Verify OTP Action
  Future<void> verifyOtp(BuildContext context) async {
    if (!isOtpComplete) {
      CustomSnackBar.warning('Please enter complete 6-digit code');
      return;
    }

    isLoading.value = true;

    try {
      // Simulate API call
      await Future.delayed(const Duration(seconds: 2));

      print('Verifying OTP: $otpCode for email: $email');

      isLoading.value = false;

      // Show success message
      CustomSnackBar.success('Email verified successfully!');

      // Navigate to Reset Password screen
      await Future.delayed(const Duration(milliseconds: 500));
      if(isFromSignUp){
        AppNavigation.push(
          context,
          ResetPasswordScreen(
            email: email,
            otp: otpCode,
          ),
        );
      }else{

        AppNavigation.push(
          context,
            AccountCreatedSuccessScreen()
        );

      }


    } catch (e) {
      isLoading.value = false;
      CustomSnackBar.error('Invalid code. Please try again.');
      _clearOtp();
      print('Error: $e');
    }
  }

  // Resend OTP Action
  Future<void> resendOtp(BuildContext context) async {
    isResending.value = true;

    try {
      // Simulate API call
      await Future.delayed(const Duration(seconds: 2));

      // TODO: Implement actual resend OTP API call
      // Example:
      // final response = await AuthService.resendOtp(email: email);

      print('Resending OTP to: $email');

      isResending.value = false;

      // Clear previous OTP
      _clearOtp();

      // Show success message
      CustomSnackBar.success('Verification code sent to your email!');

    } catch (e) {
      isResending.value = false;
      CustomSnackBar.error('Failed to resend code. Please try again.');
      print('Error: $e');
    }
  }

  // Clear all OTP fields
  void _clearOtp() {
    otp1Controller.clear();
    otp2Controller.clear();
    otp3Controller.clear();
    otp4Controller.clear();
    otp5Controller.clear();
    otp6Controller.clear();
    otp1Focus.requestFocus();
  }

  // Handle backspace
  void handleBackspace(
      TextEditingController current,
      FocusNode? previous,
      ) {
    if (current.text.isEmpty && previous != null) {
      previous.requestFocus();
    }
  }

  @override
  void onClose() {
    // Dispose controllers
    otp1Controller.dispose();
    otp2Controller.dispose();
    otp3Controller.dispose();
    otp4Controller.dispose();
    otp5Controller.dispose();
    otp6Controller.dispose();

    // Dispose focus nodes
    otp1Focus.dispose();
    otp2Focus.dispose();
    otp3Focus.dispose();
    otp4Focus.dispose();
    otp5Focus.dispose();
    otp6Focus.dispose();

    super.onClose();
  }
}