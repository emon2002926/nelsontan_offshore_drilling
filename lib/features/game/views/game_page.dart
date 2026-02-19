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
    final controller = Get.put(GamePageController());

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

  // Game Start Screen (Left side of screenshot)
  Widget _buildGameStartScreen(BuildContext context, GamePageController controller) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: context.responsiveSize(24)),
      child: Column(
        children: [
          SizedBox(height: context.responsiveSize(20)),

          // Leaderboard button
          leaderboardButton(context),

          const Spacer(),

          // Play icon
          Container(
            width: context.responsiveSize(85),
            height: context.responsiveSize(85),
            decoration: BoxDecoration(
              color: const Color(0xFFDBEAFE),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.play_arrow_outlined,
              color: const Color(0xFF2563EB),
              size: context.responsiveSize(55),
            ),
          ),

          SizedBox(height: context.responsiveSize(20)),

          // Title
          AppText(
            data: 'Spot the Hazards',
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF003E9A),
            useResponsiveFontSize: true,
            textAlign: TextAlign.center,
          ),

          SizedBox(height: context.responsiveSize(16)),

          // Description
          AppText(
            data: 'You have 30 seconds to identify as many unsafe conditions as possible in the rig scene. Tap on hazards to mark them.',
            fontSize: 14,
            fontWeight: FontWeight.w400,
            color: const Color(0xFF003E9A),
            useResponsiveFontSize: true,
            textAlign: TextAlign.center,
            maxLines: 4,
          ),

          SizedBox(height: context.responsiveSize(48)),

          // Play button with custom image
          GestureDetector(
            onTap: () {
              controller.startGame();
            },
            child: Image.asset(
              appAssets.playButton,
              width: context.responsiveSize(160),
              height: context.responsiveSize(56),
              fit: BoxFit.contain,
            ),
          ),

          const Spacer(),

          // How to Play link
          GestureDetector(
            onTap: () {
              controller.showInstructions.value = true;
            },
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

  // Instructions Screen (Right side of screenshot)
  Widget _buildInstructionsScreen(BuildContext context, GamePageController controller) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: context.responsiveSize(24)),
      child: Column(
        children: [
          SizedBox(height: context.responsiveSize(20)),

          // Leaderboard button

          leaderboardButton(context),

          const Spacer(),

          // Game controller icon
          Container(
            width: context.responsiveSize(85),
            height: context.responsiveSize(85),
            decoration: BoxDecoration(
              color: const Color(0xFFE6F0FF),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Image.asset(appAssets.game,
                width: context.responsiveSize(45),
                height: context.responsiveSize(45),
                fit: BoxFit.contain,
              ),
            ),
            // child: Icon(
            //   Icons.sports_esports,
            //   color: const Color(0xFF0047AB),
            //   size: context.responsiveSize(50),
            // ),
          ),

          SizedBox(height: context.responsiveSize(32)),

          // Title
          AppText(
            data: 'How to Play:',
            fontSize: 24,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF003E9A),
            useResponsiveFontSize: true,
            textAlign: TextAlign.center,
          ),

          SizedBox(height: context.responsiveSize(16)),

          // Instructions
          AppText(
            data: '"Tap on all unsafe conditions in the scene before time runs out. Each correct tap increases your score. Find them all to win!"',
            fontSize: 14,
            fontWeight: FontWeight.w400,
            color: const Color(0xFF003E9A),
            useResponsiveFontSize: true,
            textAlign: TextAlign.center,
            maxLines: 5,
          ),

          SizedBox(height: context.responsiveSize(48)),

          // Navigation buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Back button
              GestureDetector(
                onTap: () {
                  controller.showInstructions.value = false;
                },
                child: Container(
                  width: context.responsiveSize(60),
                  height: context.responsiveSize(60),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(context.responsiveSize(15)),
                  ),
                  child: Center(
                    child: Image.asset(
                      appAssets.arrowBackIcon,
                      width: context.responsiveSize(60),
                    ),
                  ),
                ),
              ),

              SizedBox(width: context.responsiveSize(24)),

              // Next/Start button
              GestureDetector(
                onTap: () {
                  controller.startGame();
                },
                child: Container(
                  width: context.responsiveSize(60),
                  height: context.responsiveSize(60),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(context.responsiveSize(15)),
                  ),
                  child: Center(
                    child: Image.asset(
                      appAssets.arrowBackIcon,
                      width: context.responsiveSize(60),
                    ),
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
    return  Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        GestureDetector(
          onTap: () {
            // Navigate to leaderboard
            AppNavigation.push(context, LeaderboardView());
          },
          child: Column(
            children: [
              Container(
                padding: EdgeInsets.symmetric(vertical: context.responsiveSize(12),
                    horizontal: context.responsiveSize(16)),
                decoration: BoxDecoration(
                  color: const Color(0xFF0047AB),
                  borderRadius: BorderRadius.circular(context.responsiveSize(12)),

                  boxShadow: [
                    BoxShadow(
                      color: Colors.blue.withOpacity(0.05),
                      blurRadius: 8,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child:
                Image.asset(appAssets.trophyIcon,

                  width: context.responsiveSize(24),),

              ),
              SizedBox(height: context.responsiveSize(3),),
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


