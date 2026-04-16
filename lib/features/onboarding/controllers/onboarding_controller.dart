// onboarding_controller.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nelsontan_offshore_drilling/core/constants/app_assert_image.dart';

import '../../../core/util/app_navigation.dart';
import '../../auth/views/signin_screen.dart';

class OnboardingController extends GetxController {
  final PageController pageController = PageController();
  final RxInt currentPage = 0.obs;
  final appImage = AppAssertImage.instance;

  late final List<OnboardingPage> pages = [
    OnboardingPage(
      title: 'Welcome to SafeRig360.',
      subtitle: 'Safety Awareness in Real Time.',
      image: appImage.onboardingImage1, // Add your onboarding images
      bottomTitle: 'Your Safety, Your Voice',
      bottomSubtitle: 'Report Hazards and observations in seconds',
    ),
    OnboardingPage(
      title: 'Spot the Hazards',
      subtitle: 'Play the Safety Challenge',
      image: appImage.onboardingImage2,
      bottomTitle: 'Unlock Your Hazard Identification Superpower',
      bottomSubtitle: 'Find risks in quick, timed games',
    ),
    OnboardingPage(
      title: 'Stay Informed & Alert',
      subtitle: 'Learn From HSE Videos',
      image: appImage.onboardingImage3,
      bottomTitle: 'Watch & Learn',
      bottomSubtitle: 'Get safety tips and updates from your HSE team',
    ),
  ];

  void nextPage(BuildContext context) {
    if (currentPage.value < pages.length - 1) {
      pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      // Last page - navigate to main app
      completeOnboarding(context);
    }
  }

  void skipOnboarding(BuildContext context) {
    completeOnboarding(context);
  }

  void completeOnboarding(BuildContext context) {
    // Save onboarding completion status
    // StorageService.saveOnboardingCompleted();

    // Navigate to Sign In or Home
    AppNavigation.pushAndClear( const SignInScreen());
  }

  @override
  void onClose() {
    pageController.dispose();
    super.onClose();
  }
}

class OnboardingPage {
  final String title;
  final String subtitle;
  final String image;
  final String bottomTitle;
  final String bottomSubtitle;

  OnboardingPage({
    required this.title,
    required this.subtitle,
    required this.image,
    required this.bottomTitle,
    required this.bottomSubtitle,
  });
}