// features/home/presentation/controllers/home_controller.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nelsontan_offshore_drilling/core/util/app_navigation.dart';

import '../../../core/widgets/snakbar/custom_snackbar.dart';
import '../../../home_page.dart';
import '../../safety_card/views/safety_card_screen.dart';
import '../../weekly_safety_focus/views/safety_focus_details_screen.dart';
import '../models/training_game_model.dart';
import '../../weekly_safety_focus/models/weekly_safety_focus_model.dart';

class HomeController extends GetxController {
  // Observable for weekly safety focus
  final Rx<WeeklySafetyFocusModel?> weeklySafetyFocus = Rx<WeeklySafetyFocusModel?>(null);
  final RxBool isLoadingSafetyFocus = false.obs;

  // Training & Game
  final Rx<TrainingGameModel?> trainingGame = Rx<TrainingGameModel?>(null);
  final RxBool isLoadingTrainingGame = false.obs;

  final RxBool isSubmittingSafetyCard = false.obs;





  @override
  void onInit() {
    super.onInit();
    fetchWeeklySafetyFocus();
  }

  // Fetch weekly safety focus
  Future<void> fetchWeeklySafetyFocus() async {
    isLoadingSafetyFocus.value = true;

    try {
      // Simulate API call delay
      await Future.delayed(const Duration(seconds: 1));

      // TODO: Replace with actual API call
      // final response = await ApiService.getWeeklySafetyFocus();
      // weeklySafetyFocus.value = WeeklySafetyFocusModel.fromJson(response.data);

      // Using dummy data for now
      weeklySafetyFocus.value = WeeklySafetyFocusModel.dummy();

    } catch (e) {
      CustomSnackBar.error('Failed to load safety focus');
      print('Error fetching weekly safety focus: $e');
    } finally {
      isLoadingSafetyFocus.value = false;
    }
  }

  // Handle read more action
  void onReadMoreSafetyFocus(BuildContext context) {
    if (weeklySafetyFocus.value == null) return;

    AppNavigation.push(

      SafetyFocusDetailsScreen(data: weeklySafetyFocus.value!),context: context
    );
  }
  Future<void> fetchTrainingGame() async {
    isLoadingTrainingGame.value = true;

    try {
      await Future.delayed(const Duration(seconds: 1));

      // TODO: Replace with actual API call
      trainingGame.value = TrainingGameModel.dummy();

    } catch (e) {
      CustomSnackBar.error('Failed to load training game');
      print('Error fetching training game: $e');
    } finally {
      isLoadingTrainingGame.value = false;
    }
  }

  // Handle play game
  void onPlayGame(BuildContext context) {
    context.findAncestorStateOfType<HomePageState>()?.onTabSelected(2);

  }

  // Handle game settings
  void onGameSettings(BuildContext context) {
    CustomSnackBar.info('Opening game settings...');
  }



  // Submit safety card
  Future<void> submitSafetyCard(BuildContext context) async {
    AppNavigation.push(  SafetyCardScreen());
  }


  // Refresh safety focus
  Future<void> refreshSafetyFocus() async {
    await fetchWeeklySafetyFocus();
  }
}