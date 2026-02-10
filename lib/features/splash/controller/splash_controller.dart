import 'dart:async';
import 'package:get/get.dart';
import 'package:nelsontan_offshore_drilling/features/auth/views/signin_screen.dart';
import 'package:nelsontan_offshore_drilling/features/onboarding/views/onboarding_screen.dart';
import '../../../../core/util/storage_service.dart';
import 'package:get_storage/get_storage.dart';
import '../../../core/util/app_navigation.dart';

class SplashController extends GetxController {
  final box = GetStorage();

  @override
  void onInit() {
    super.onInit();
    _startTimer();
  }

  void _startTimer() {
    Timer(const Duration(seconds: 3), () {
      String? accessToken = StorageService.accessToken;

      if (accessToken != null && accessToken.isNotEmpty) {
        AppNavigation.pushAndClear(Get.context!, SignInScreen());

      } else {

        AppNavigation.pushAndClear(Get.context!, OnboardingScreen());

      }
    });
  }

}