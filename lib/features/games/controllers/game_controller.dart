import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/services/api_services.dart';
import '../../../core/util/app_navigation.dart';
import '../../../core/util/storage_service.dart';
import '../../../core/widgets/snakbar/custom_snackbar.dart';
import '../../auth/views/signin_screen.dart';
import '../views/gameplay_screen.dart';
import '../views/puzzle_game_screen.dart';

class GamePageController extends GetxController {
  final ApiServices _api = Get.find<ApiServices>();

  final RxBool showInstructions = false.obs;
  final RxBool isStartingGame   = false.obs;

  Future<void> startGame(BuildContext context) async {
    final token = StorageService.accessToken;
    if (token == null || token.isEmpty) {
      CustomSnackBar.error('Session expired. Please sign in again.');
      AppNavigation.pushAndClear(const SignInScreen());
      return;
    }

    isStartingGame.value = true;
    try {
      final raw = await _api.get(
        '/game',
        headers: {'Authorization': 'Bearer $token'},
      );

      final gameType = raw['data']['gameType'] as String?;

      if (gameType == 'QUESTION') {
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const GameplayScreen()),
        );
      } else if (gameType == 'PUZZLE') {
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const PuzzleGameScreen()),
        );
      } else {
        CustomSnackBar.info('No game available for today.');
      }
    } on HttpException catch (e) {
      CustomSnackBar.error(e.message);
    } catch (e) {
      CustomSnackBar.error('Failed to start game. Please try again.');
    } finally {
      isStartingGame.value = false;
    }
  }
}