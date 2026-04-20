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
  final box = GetStorage();

  @override
  void onInit() {
    super.onInit();
    _startTimer();
  }

  void _startTimer() {
    Timer(const Duration(seconds: 3), () {
      String? accessToken = StorageService.accessToken;


      final u = StorageService.user!;

      if (accessToken != null && accessToken.isNotEmpty) {
        if(u.isActive){
          AppNavigation.pushAndClear( HomePage());
        }else if(u.isPending){
          AppNavigation.pushAndClear( const AccountStatusScreen(status: AccountStatus.pending));
        }else if(u.isSuspended){
          AppNavigation.pushAndClear( const AccountStatusScreen(status: AccountStatus.suspended));
        }else if(u.isInactive){
          AppNavigation.pushAndClear( const AccountStatusScreen(status: AccountStatus.inactive));
        }else if(u.isDeleted){
          AppNavigation.pushAndClear( const AccountStatusScreen(status: AccountStatus.deleted));
        }else if(u.isApproved){
          AppNavigation.pushAndClear( HomePage());
        }

      } else{
        AppNavigation.pushAndClear( OnboardingScreen());
      }
    });
  }

}

