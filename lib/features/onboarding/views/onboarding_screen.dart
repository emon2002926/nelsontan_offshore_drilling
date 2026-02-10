// onboarding_screen.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/util/screen_size.dart';
import '../../../core/widgets/buttons/app_button.dart';
import '../../../core/widgets/text/app_text.dart';
import '../controllers/onboarding_controller.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(OnboardingController());

    return Scaffold(
      backgroundColor: const Color(0xFF1E3A5F), // Dark blue background
      body: SafeArea(
        child: Column(
          children: [
            // Skip Button
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: context.responsiveSize(24),
                vertical: context.responsiveSize(16),
              ),
              child: Align(
                alignment: Alignment.centerRight,
                child: GestureDetector(
                  onTap: () => controller.skipOnboarding(context),
                  child: AppText(
                    data: 'Skip',
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                    useResponsiveFontSize: true,
                  ),
                ),
              ),
            ),

            // PageView Content
            Expanded(
              child: PageView.builder(
                controller: controller.pageController,
                onPageChanged: (index) {
                  controller.currentPage.value = index;
                },
                itemCount: controller.pages.length,
                itemBuilder: (context, index) {
                  return _buildPage(
                    context,
                    controller.pages[index],
                  );
                },
              ),
            ),

            // Page Indicator Dots
            Obx(
                  () => Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  controller.pages.length,
                      (index) => _buildDot(
                    context,
                    index,
                    controller.currentPage.value,
                  ),
                ),
              ),
            ),

            SizedBox(height: context.responsiveSize(24)),

            // Continue/Get Started Button
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: context.responsiveSize(24),
              ),
              child: Obx(
                    () => AppButton(
                  buttonText: controller.currentPage.value ==
                      controller.pages.length - 1
                      ? 'Get Started'
                      : 'Continue',
                  onPressed: () => controller.nextPage(context),
                  fillColor: const Color(0xFF0047AB),
                  textColor: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  buttonHeight: 56,
                ),
              ),
            ),

            SizedBox(height: context.responsiveSize(40)),
          ],
        ),
      ),
    );
  }

  Widget _buildPage(BuildContext context, OnboardingPage page) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: context.responsiveSize(24),
      ),
      child: Column(
        children: [
          SizedBox(height: context.responsiveSize(20)),

          // Title
          AppText(
            data: page.title,
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            useResponsiveFontSize: true,
            textAlign: TextAlign.center,
          ),

          SizedBox(height: context.responsiveSize(8)),

          // Subtitle
          AppText(
            data: page.subtitle,
            fontSize: 16,
            fontWeight: FontWeight.w400,
            color: Colors.white.withOpacity(0.8),
            useResponsiveFontSize: true,
            textAlign: TextAlign.center,
          ),

          SizedBox(height: context.responsiveSize(40)),

          // Image Container
          Container(
            width: double.infinity,
            height: context.responsiveSize(280),
            decoration: BoxDecoration(
              color: const Color(0xFF2B4A6F),
              borderRadius: BorderRadius.circular(context.responsiveSize(20)),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(context.responsiveSize(20)),
              child: Image.asset(
                page.image,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  // Placeholder when image is not found
                  return Center(
                    child: Icon(
                      Icons.image,
                      size: context.responsiveSize(80),
                      color: Colors.white.withOpacity(0.3),
                    ),
                  );
                },
              ),
            ),
          ),

          SizedBox(height: context.responsiveSize(40)),

          // Bottom Title
          AppText(
            data: page.bottomTitle,
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            useResponsiveFontSize: true,
            textAlign: TextAlign.center,
          ),

          SizedBox(height: context.responsiveSize(12)),

          // Bottom Subtitle
          AppText(
            data: page.bottomSubtitle,
            fontSize: 15,
            fontWeight: FontWeight.w400,
            color: Colors.white.withOpacity(0.8),
            useResponsiveFontSize: true,
            textAlign: TextAlign.center,
          ),

          const Spacer(),
        ],
      ),
    );
  }

  Widget _buildDot(BuildContext context, int index, int currentPage) {
    final isActive = index == currentPage;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: EdgeInsets.symmetric(
        horizontal: context.responsiveSize(4),
      ),
      width: isActive
          ? context.responsiveSize(24)
          : context.responsiveSize(8),
      height: context.responsiveSize(8),
      decoration: BoxDecoration(
        color: isActive
            ? const Color(0xFF0047AB)
            : Colors.white.withOpacity(0.3),
        borderRadius: BorderRadius.circular(context.responsiveSize(4)),
      ),
    );
  }
}