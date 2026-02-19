import 'package:get/get.dart';
import 'package:nelsontan_offshore_drilling/core/widgets/snakbar/custom_snackbar.dart';

class GamePageController extends GetxController {
  final RxBool showInstructions = false.obs;
  final RxInt score = 0.obs;
  final RxInt timeRemaining = 30.obs;
  final RxBool isGameActive = false.obs;

  void startGame() {
    // Navigate to actual game screen
    // Get.to(() => const GameplayScreen());
    CustomSnackBar.info("Games Coming Soon");
  }
}