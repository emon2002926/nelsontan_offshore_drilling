import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../../core/constants/app_assert_image.dart';
import '../../../core/util/app_navigation.dart';
import '../../../core/util/screen_size.dart';
import '../../../core/widgets/app_bar/build_app_bar.dart';
import '../../../core/widgets/buttons/app_button.dart';
import '../../../core/widgets/text/app_text.dart';
import '../controllers/otp_verification_controller.dart';

class OtpVerificationScreen extends StatelessWidget {
  final String email;
  final bool isFromSignUp;
  const OtpVerificationScreen({
    super.key,
    required this.email, required this.isFromSignUp,
  });

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<OtpVerificationController>() ;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: BuildAppBar(
        useCircularBackButton: true,
        showBackButton: true,
        onBackButtonPressed: () => AppNavigation.pop(context),
      ),
      body: SafeArea(
        child: Stack(
          children: [
            SingleChildScrollView(
              padding: EdgeInsets.symmetric(
                horizontal: context.responsiveSize(24),
              ),
              child: Column(
                children: [
                  SizedBox(height: context.responsiveSize(10)),

                  // Logo
                  Image.asset(
                    AppAssertImage.instance.appLogo,
                    width: context.responsiveSize(280),
                    height: context.responsiveSize(100),
                    fit: BoxFit.contain,
                  ),

                  SizedBox(height: context.responsiveSize(40)),

                  // Title
                  AppText(
                    data: 'Check your email',
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF333333),
                    useResponsiveFontSize: true,
                  ),

                  SizedBox(height: context.responsiveSize(12)),

                  // Subtitle with email
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: context.responsiveSize(20),
                    ),
                    child: RichText(
                      textAlign: TextAlign.center,
                      text: TextSpan(
                        style: TextStyle(
                          fontSize: context.responsiveFontSize(16),
                          fontWeight: FontWeight.w400,
                          color: const Color(0xFF666666),
                          height: 1.4,
                        ),
                        children: [
                          const TextSpan(text: 'We sent a code to '),
                          TextSpan(
                            text: _maskEmail(email),
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF0047AB),
                            ),
                          ),
                          const TextSpan(
                            text: '. Enter 6 digit code that mentioned in the email',
                          ),
                        ],
                      ),
                    ),
                  ),

                  SizedBox(height: context.responsiveSize(60)),

                  // OTP Input Boxes
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildOtpBox(
                        context,
                        controller.otp1Controller,
                        controller.otp1Focus,
                        controller.otp2Focus,
                        null,
                        controller,
                      ),
                      _buildOtpBox(
                        context,
                        controller.otp2Controller,
                        controller.otp2Focus,
                        controller.otp3Focus,
                        controller.otp1Focus,
                        controller,
                      ),
                      _buildOtpBox(
                        context,
                        controller.otp3Controller,
                        controller.otp3Focus,
                        controller.otp4Focus,
                        controller.otp2Focus,
                        controller,
                      ),
                      _buildOtpBox(
                        context,
                        controller.otp4Controller,
                        controller.otp4Focus,
                        controller.otp5Focus,
                        controller.otp3Focus,
                        controller,
                      ),
                      _buildOtpBox(
                        context,
                        controller.otp5Controller,
                        controller.otp5Focus,
                        controller.otp6Focus,
                        controller.otp4Focus,
                        controller,
                      ),
                      _buildOtpBox(
                        context,
                        controller.otp6Controller,
                        controller.otp6Focus,
                        null,
                        controller.otp5Focus,
                        controller,
                      ),
                    ],
                  ),

                  SizedBox(height: context.responsiveSize(40)),

                  // Verify Code Button
                  Obx(
                        () => AppButton(
                      buttonText: 'Verify Code',
                      onPressed: () => controller.verifyOtp(context,email,isFromSignUp),
                      fillColor: const Color(0xFF0047AB),
                      textColor: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      buttonHeight: 56,
                      isLoading: controller.isLoading.value,
                      loadingText: 'Verifying...',
                    ),
                  ),

                  SizedBox(height: context.responsiveSize(30)),

                  // Resend Email Link
                  Obx(
                        () => controller.isResending.value
                        ? Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: context.responsiveSize(16),
                          height: context.responsiveSize(16),
                          child: const CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation(
                              Color(0xFF0047AB),
                            ),
                          ),
                        ),
                        SizedBox(width: context.responsiveSize(12)),
                        AppText(
                          data: 'Sending...',
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: const Color(0xFF666666),
                          useResponsiveFontSize: true,
                        ),
                      ],
                    )
                        : GestureDetector(
                      onTap: () => controller.resendOtp(context,email,isFromSignUp),
                      child: RichText(
                        text: TextSpan(
                          style: TextStyle(
                            fontSize: context.responsiveFontSize(16),
                            fontWeight: FontWeight.w400,
                            color: const Color(0xFF666666),
                          ),
                          children: const [
                            TextSpan(
                              text: "Haven't got the email yet? ",
                            ),
                            TextSpan(
                              text: 'Resend email',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF0047AB),
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  SizedBox(height: context.responsiveSize(40)),
                ],
              ),
            ),

            // Loading Overlay
            AppButton.buildLoadingOverlay(
              isLoading: controller.isLoading,
              loadingMessage: 'Verifying your code...',
              backgroundColor: Colors.black,
              cardColor: Colors.white,
            ),
          ],
        ),
      ),
    );
  }

  // Build individual OTP box
  Widget _buildOtpBox(
      BuildContext context,
      TextEditingController controller,
      FocusNode currentFocus,
      FocusNode? nextFocus,
      FocusNode? previousFocus,
      OtpVerificationController otpController,
      ) {
    return Container(
      width: context.responsiveSize(50),
      height: context.responsiveSize(60),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(context.responsiveSize(12)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        focusNode: currentFocus,
        textAlign: TextAlign.center,
        keyboardType: TextInputType.number,
        maxLength: 1,
        style: TextStyle(
          fontSize: context.responsiveFontSize(24),
          fontWeight: FontWeight.w600,
          color: const Color(0xFF333333),
        ),
        inputFormatters: [
          FilteringTextInputFormatter.digitsOnly,
        ],
        decoration: InputDecoration(
          counterText: '',
          border: InputBorder.none,
          contentPadding: EdgeInsets.zero,
        ),
        onChanged: (value) {
          if (value.isNotEmpty && nextFocus != null) {
            nextFocus.requestFocus();
          }
          if (value.isEmpty) {
            otpController.handleBackspace(controller, previousFocus);
          }
        },
      ),
    );
  }

  // Mask email for privacy
  String _maskEmail(String email) {
    final parts = email.split('@');
    if (parts.length != 2) return email;

    final username = parts[0];
    final domain = parts[1];

    if (username.length <= 3) return email;

    final visibleStart = username.substring(0, 2);
    final visibleEnd = username.substring(username.length - 1);

    return '$visibleStart***$visibleEnd@$domain';
  }
}