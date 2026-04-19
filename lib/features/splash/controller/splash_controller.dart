import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:nelsontan_offshore_drilling/features/auth/views/signin_screen.dart';
import '../../../../core/util/storage_service.dart';
import 'package:get_storage/get_storage.dart';
import '../../../core/util/app_navigation.dart';
import '../../../home_page.dart';
import '../../auth/views/account_status_screen.dart';
import '../../auth/views/client_rig_select_screen.dart';
import '../../onboarding/views/onboarding_screen.dart';

class SplashController extends GetxController {
  @override
  void onInit() {
    super.onInit();
    _startTimer();
  }

  void _startTimer() {
    Timer(const Duration(seconds: 3), _navigate);
  }

  void _navigate() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!StorageService.hasToken || !StorageService.hasUser) {
        Get.offAll(() => OnboardingScreen());
        return;
      }

      final u = StorageService.user!;

      if (u.isNotSubmitted) { Get.offAll(() => const ClientRigSelectScreen());                               return; }
      if (u.isPending)      { Get.offAll(() => const AccountStatusScreen(status: AccountStatus.pending));    return; }
      if (u.isSuspended)    { Get.offAll(() => const AccountStatusScreen(status: AccountStatus.suspended));  return; }
      if (u.isInactive)     { Get.offAll(() => const AccountStatusScreen(status: AccountStatus.inactive));   return; }
      if (u.isDeleted)      { Get.offAll(() => const AccountStatusScreen(status: AccountStatus.deleted));    return; }
      if (u.isApproved)     { Get.offAll(() => HomePage());                                                  return; }

      Get.offAll(() => OnboardingScreen());
    });
  }
}