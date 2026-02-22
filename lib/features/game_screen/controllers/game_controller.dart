import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import '../../../core/util/app_navigation.dart';
import '../../games/views/gameplay_screen.dart';

class GamePageController extends GetxController {
  final RxBool showInstructions = false.obs;
  final RxInt score = 0.obs;
  final RxInt timeRemaining = 30.obs;
  final RxBool isGameActive = false.obs;



  final RxInt selectedGameMode = 0.obs;

  void startGame(BuildContext context) {
    AppNavigation.push(context, const GameplayScreen());
  }

  void selectGameMode(int index) {
    selectedGameMode.value = index;
  }
}