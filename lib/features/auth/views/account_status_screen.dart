import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_assert_image.dart';
import '../../../core/util/screen_size.dart';
import '../../../core/widgets/app_bar/build_app_bar.dart';
import '../../../core/widgets/text/app_text.dart';
import '../controllers/account_status_controller.dart';


class AccountStatusScreen extends StatelessWidget {
  final AccountStatus status;

  const AccountStatusScreen({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(AccountStatusController(status: status));
    final config = controller.config;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: BuildAppBar(
        useCircularBackButton: true,
        showBackButton: false,
      ),
      body: SafeArea(
        child: Padding(
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

              const Spacer(),

              // Status Icon
              Container(
                width: context.responsiveSize(100),
                height: context.responsiveSize(100),
                decoration: BoxDecoration(
                  color: config.iconColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  config.icon,
                  size: context.responsiveSize(48),
                  color: config.iconColor,
                ),
              ),

              SizedBox(height: context.responsiveSize(32)),

              // Title
              AppText(
                data: config.title,
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF333333),
                useResponsiveFontSize: true,
                textAlign: TextAlign.center,
              ),

              SizedBox(height: context.responsiveSize(16)),

              // Message
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: context.responsiveSize(12),
                ),
                child: AppText(
                  data: config.message,
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                  color: const Color(0xFF666666),
                  useResponsiveFontSize: true,
                  textAlign: TextAlign.center,
                ),
              ),

              const Spacer(),

              SizedBox(height: context.responsiveSize(40)),
            ],
          ),
        ),
      ),
    );
  }
}

