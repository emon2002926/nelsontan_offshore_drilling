import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nelsontan_offshore_drilling/core/util/app_navigation.dart';
import '../../../core/constants/app_assert_image.dart';
import '../../../core/util/screen_size.dart';
import '../../../core/widgets/text/app_text.dart';
import '../controllers/game_controller.dart';
import 'leader_board_page.dart';

class GamePage extends StatelessWidget {
  GamePage({super.key});

  final appAssets = AppAssertImage.instance;

  @override
  Widget build(BuildContext context) {
    // final controller = Get.put(GamePageController());
    final controller = Get.find<GamePageController>();


    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Obx(() {
          if (controller.showInstructions.value) {
            return _buildInstructionsScreen(context, controller);
          } else {
            return _buildGameStartScreen(context, controller);
          }
        }),
      ),
    );
  }

  Widget _buildGameStartScreen(
      BuildContext context, GamePageController controller) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: context.responsiveSize(24)),
      child: Column(
        children: [
          SizedBox(height: context.responsiveSize(20)),
          leaderboardButton(context),
          const Spacer(),

          Container(
            width: context.responsiveSize(85),
            height: context.responsiveSize(85),
            decoration: const BoxDecoration(
              color: Color(0xFFDBEAFE),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.play_arrow_outlined,
              color: const Color(0xFF2563EB),
              size: context.responsiveSize(55),
            ),
          ),

          SizedBox(height: context.responsiveSize(20)),

          AppText(
            data: 'Spot the Hazards',
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF003E9A),
            useResponsiveFontSize: true,
            textAlign: TextAlign.center,
          ),

          SizedBox(height: context.responsiveSize(16)),

          AppText(
            data: 'Find hazards in the rig scene and answer safety questions. Each round gives you 20 seconds. Score as high as you can!',
            fontSize: 14,
            fontWeight: FontWeight.w400,
            color: const Color(0xFF003E9A),
            useResponsiveFontSize: true,
            textAlign: TextAlign.center,
            maxLines: 4,
          ),

          SizedBox(height: context.responsiveSize(48)),

          // Play button — shows spinner while checking game type
          Obx(() => GestureDetector(
            onTap: controller.isStartingGame.value
                ? null
                : () => controller.startGame(context),
            child: controller.isStartingGame.value
                ? const SizedBox(
              width: 40,
              height: 40,
              child: CircularProgressIndicator(
                color: Color(0xFF0047AB),
                strokeWidth: 3,
              ),
            )
                : Image.asset(
              appAssets.playButton,
              width: context.responsiveSize(160),
              height: context.responsiveSize(56),
              fit: BoxFit.contain,
            ),
          )),

          const Spacer(),

          GestureDetector(
            onTap: () => controller.showInstructions.value = true,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AppText(
                  data: 'How to Play',
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF0047AB),
                  useResponsiveFontSize: true,
                ),
                SizedBox(width: context.responsiveSize(8)),
                Icon(
                  Icons.arrow_forward,
                  color: const Color(0xFF0047AB),
                  size: context.responsiveSize(18),
                ),
              ],
            ),
          ),

          SizedBox(height: context.responsiveSize(40)),
        ],
      ),
    );
  }

  Widget _buildInstructionsScreen(
      BuildContext context, GamePageController controller) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: context.responsiveSize(24)),
      child: Column(
        children: [
          SizedBox(height: context.responsiveSize(20)),
          leaderboardButton(context),
          const Spacer(),

          Container(
            width: context.responsiveSize(85),
            height: context.responsiveSize(85),
            decoration: const BoxDecoration(color: Color(0xFFE6F0FF), shape: BoxShape.circle),
            child: Center(
              child: Image.asset(
                appAssets.game,
                width: context.responsiveSize(45),
                height: context.responsiveSize(45),
                fit: BoxFit.contain,
              ),
            ),
          ),

          SizedBox(height: context.responsiveSize(32)),

          AppText(
            data: 'How to Play:',
            fontSize: 24,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF003E9A),
            useResponsiveFontSize: true,
            textAlign: TextAlign.center,
          ),

          SizedBox(height: context.responsiveSize(16)),

          AppText(
            data: '"The game has two types of rounds:\n\n🔍 Hazard Spot — Tap on unsafe conditions in the rig scene.\n\n📝 Quiz — Pick the correct answer about safety.\n\nYou get 20 seconds per round. Score points for every correct action!"',
            fontSize: 14,
            fontWeight: FontWeight.w400,
            color: const Color(0xFF003E9A),
            useResponsiveFontSize: true,
            textAlign: TextAlign.center,
            maxLines: 12,
          ),

          SizedBox(height: context.responsiveSize(48)),

          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              GestureDetector(
                onTap: () => controller.showInstructions.value = false,
                child: Container(
                  width: context.responsiveSize(60),
                  height: context.responsiveSize(60),
                  decoration: BoxDecoration(
                      borderRadius:
                      BorderRadius.circular(context.responsiveSize(15))),
                  child: Center(
                    child: Image.asset(appAssets.arrowBackIcon,
                        width: context.responsiveSize(60)),
                  ),
                ),
              ),
              SizedBox(width: context.responsiveSize(24)),
              GestureDetector(
                onTap: () => controller.startGame(context),
                child: Container(
                  width: context.responsiveSize(60),
                  height: context.responsiveSize(60),
                  decoration: BoxDecoration(
                      borderRadius:
                      BorderRadius.circular(context.responsiveSize(15))),
                  child: Center(
                    child: Image.asset(appAssets.arrowForwardIcon,
                        width: context.responsiveSize(60)),
                  ),
                ),
              ),
            ],
          ),

          const Spacer(),
          SizedBox(height: context.responsiveSize(40)),
        ],
      ),
    );
  }

  Widget leaderboardButton(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        GestureDetector(
          onTap: () =>
              AppNavigation.push(const LeaderboardView(), context: context),
          child: Column(
            children: [
              Container(
                padding: EdgeInsets.symmetric(
                    vertical: context.responsiveSize(12),
                    horizontal: context.responsiveSize(16)),
                decoration: BoxDecoration(
                  color: const Color(0xFF0047AB),
                  borderRadius:
                  BorderRadius.circular(context.responsiveSize(12)),
                  boxShadow: [
                    BoxShadow(
                        color: Colors.blue.withOpacity(0.05),
                        blurRadius: 8,
                        offset: const Offset(0, 5)),
                  ],
                ),
                child: Image.asset(appAssets.trophyIcon,
                    width: context.responsiveSize(24)),
              ),
              SizedBox(height: context.responsiveSize(3)),
              AppText(
                data: 'Leaderboard',
                fontSize: 10,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF003E9A),
                useResponsiveFontSize: true,
              ),
            ],
          ),
        ),
      ],
    );
  }
}