// features/home/presentation/controllers/home_controller.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nelsontan_offshore_drilling/core/util/app_navigation.dart';

import '../../../core/services/api_services.dart';
import '../../../core/util/storage_service.dart';
import '../../../core/widgets/snakbar/custom_snackbar.dart';
import '../../../base_page.dart';
import '../../auth/views/signin_screen.dart';
import '../../safety_card/views/safety_card_screen.dart';
import '../../weekly_safety_focus/views/safety_focus_details_screen.dart';
import '../models/app_home_model.dart';
import '../models/training_game_model.dart';
import '../../weekly_safety_focus/models/weekly_safety_focus_model.dart';

class HomeController extends GetxController {
  final ApiServices _api = Get.find<ApiServices>();


  final Rx<AppHomeModel?> appHome = Rx<AppHomeModel?>(null);
  final RxBool isLoadingHome = false.obs;


  final Rx<TrainingGameModel?> trainingGame = Rx<TrainingGameModel?>(null);
  final RxBool isLoadingTrainingGame = false.obs;

  final RxBool isSubmittingSafetyCard = false.obs;


  final Rx<WeeklySafetyFocusModel?> weeklySafetyFocus =
  Rx<WeeklySafetyFocusModel?>(null);

  RxBool get isLoadingSafetyFocus => isLoadingHome;

  @override
  void onInit() {
    super.onInit();
    fetchAppHome();
  }



  Future<void> fetchAppHome() async {
    final token = StorageService.accessToken;
    if (token == null || token.isEmpty) {
      CustomSnackBar.error('Session expired. Please sign in again.');
      AppNavigation.pushAndClear(const SignInScreen());
      return;
    }

    print("asfdg: $token");
    isLoadingHome.value = true;
    try {
      final raw = await _api.get(
        '/app/home',
        headers: {"Authorization": "Bearer $token"},
      );

      appHome.value = AppHomeModel.fromJson(raw["data"]);

      print("video title: ${appHome.value?.videos?.thumbnail}");

      final alert = appHome.value?.messages;
      weeklySafetyFocus.value = alert == null
          ? null
          : WeeklySafetyFocusModel(
        id: alert.id.toString(),
        title: alert.title,
        description: alert.description,
        imageUrl: alert.file,
      );
    } on HttpException catch (e) {
      CustomSnackBar.error(e.message);
    } catch (e) {
      CustomSnackBar.error('Failed to load home data. Please try again.');
    } finally {
      isLoadingHome.value = false;
    }
  }

  void onReadMoreSafetyFocus(BuildContext context) {
    final data = weeklySafetyFocus.value;
    if (data == null) return;
    AppNavigation.push(
      SafetyFocusDetailsScreen(data: data),
      context: context,
    );
  }

  Future<void> fetchTrainingGame() async {
    isLoadingTrainingGame.value = true;
    try {
      // TODO: Replace with actual API call when endpoint is available
      trainingGame.value = TrainingGameModel.dummy();
    } on HttpException catch (e) {
      CustomSnackBar.error(e.message);
    } catch (e) {
      CustomSnackBar.error('Failed to load training game. Please try again.');
    } finally {
      isLoadingTrainingGame.value = false;
    }
  }

  void onPlayGame(BuildContext context) {
    context.findAncestorStateOfType<BasePageState>()?.onTabSelected(2);
  }

  void onGameSettings(BuildContext context) {
    CustomSnackBar.info('Opening game settings...');
  }

  Future<void> submitSafetyCard(BuildContext context) async {
    AppNavigation.push(SafetyCardScreen());
  }

  Future<void> refreshHome() async {
    await fetchAppHome();
  }
}