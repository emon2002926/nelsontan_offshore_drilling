import 'dart:async';
import 'package:get/get.dart';
import '../../../../core/util/storage_service.dart';
import 'package:get_storage/get_storage.dart';
import '../../../core/util/app_navigation.dart';
import '../../../base_page.dart';
import '../../auth/controllers/account_status_controller.dart';
import '../../auth/utils/status_check.dart';
import '../../auth/views/account_status_screen.dart';
import '../../auth/views/client_rig_select_screen.dart';
import '../../onboarding/views/onboarding_screen.dart';
class SplashController extends GetxController {
  final box = GetStorage();

  @override
  void onInit() {
    super.onInit();
    _startTimer();
  }

  void _startTimer() {
    Timer(const Duration(seconds: 3), () {
      final String? accessToken = StorageService.accessToken;

      if (accessToken != null && accessToken.isNotEmpty) {
        final user = StorageService.user;
        if (user == null) {
          AppNavigation.pushAndClear(OnboardingScreen());
          return;
        }
        StatusChecker.navigate(user.approveStatus);
        // AppNavigation.push(ClientRigSelectScreen());

      } else {
        AppNavigation.pushAndClear(OnboardingScreen());
      }
    });
  }
}
