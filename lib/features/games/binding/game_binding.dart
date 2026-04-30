import 'package:get/get.dart';

import '../controllers/game_controller.dart';
import '../controllers/game_play_controller.dart';
import '../controllers/leader_bord_controller.dart';
import '../controllers/puzzle_game_controller.dart';
class GameBinding {
  static void gameDependencies() {

    Get.lazyPut<GamePageController>(
          () => GamePageController(),
      fenix: true,
    );

    Get.lazyPut<GamePlayController>(
          () => GamePlayController(),
      fenix: true,
    );

    Get.lazyPut<LeaderboardController>(
          () => LeaderboardController(),
      fenix: true,
    );

    Get.lazyPut<PuzzleGameController>(
          () => PuzzleGameController(),
      fenix: true,
    );

  }

}