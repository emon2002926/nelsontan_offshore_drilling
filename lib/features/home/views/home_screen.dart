import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nelsontan_offshore_drilling/core/constants/app_assert_image.dart';
import 'package:nelsontan_offshore_drilling/core/widgets/text/app_text.dart';

import '../../../core/util/app_navigation.dart';
import '../../../core/util/screen_size.dart';
import '../../../home_page.dart';
import '../../notification/views/notifications_screen.dart';
import '../../video_player/models/video_source.dart';
import '../../video_player/widgets/app_video_player.dart';
import '../controllers/home_controller.dart';
import '../widgets/submit_safety_card_button.dart';
import '../widgets/training_game_card.dart';
import '../../weekly_safety_focus/widget/weekly_safety_focus_card.dart';

class HomeScreen extends StatelessWidget {
  HomeScreen({super.key});
  final appAssets = AppAssertImage.instance;

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(HomeController());

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: SingleChildScrollView(
            child: Column(
              children: [
                SizedBox(height: context.heightPercentage(1)),

                topHeader(context, appAssets.topHeaderIcon, appAssets.topHeaderNotificationIcon),
                SizedBox(height: context.responsiveSize(10)),

                // Reactive video — switches to network URL once API data loads
                Obx(() {
                  final video = controller.appHome.value?.videos;
                  return AppVideoPlayer(
                    key: ValueKey(video?.videoUrl ?? 'local'),
                    videoSource: video?.videoUrl != null
                        ? VideoSource.network(
                      video!.videoUrl,
                      // thumbnailNetworkPath: video.thumbnail,
                    )
                        : VideoSource.asset(
                      'assets/videos/demo.mp4',
                      thumbnailAssetPath: appAssets.thumbnailImage,
                    ),
                    width: context.widthPercentage(100),
                    height: context.heightPercentage(23),
                    borderRadius: 16,
                    autoPlay: false,
                  );
                }),

                SizedBox(height: context.responsiveSize(8)),

                Obx(
                      () => WeeklySafetyFocusCard(
                    data: controller.weeklySafetyFocus.value,
                    isLoading: controller.isLoadingSafetyFocus.value,
                    onReadMore: () => controller.onReadMoreSafetyFocus(context),
                  ),
                ),

                SizedBox(height: context.responsiveSize(8)),

                Obx(
                      () => TrainingGameCard(
                    data: controller.trainingGame.value,
                    isLoading: controller.isLoadingTrainingGame.value,
                    onPlay: () => controller.onPlayGame(context),
                    onSettings: () => controller.onGameSettings(context),
                  ),
                ),

                SizedBox(height: context.responsiveSize(20)),

                Obx(
                      () => SubmitSafetyCardButton(
                    onPressed: () {
                      context.findAncestorStateOfType<HomePageState>()?.onTabSelected(1);
                    },
                    isLoading: controller.isSubmittingSafetyCard.value,
                  ),
                ),

                SizedBox(height: context.responsiveSize(20)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget topHeader(BuildContext context, String headerSaveIcon, String headerNotificationIcon) {
    return SizedBox(
      width: MediaQuery.of(context).size.width,
      height: context.heightPercentage(5),
      child: Row(
        children: [
          Image.asset(
            headerSaveIcon,
            height: context.responsiveSize(24),
          ),
          SizedBox(width: context.responsiveSize(12)),
          AppText(
            data: "Homepage",
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
          const Spacer(),
          GestureDetector(
            onTap: () {
              AppNavigation.push(NotificationsScreen(), context: context);
            },
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Image.asset(
                headerNotificationIcon,
                height: context.responsiveSize(24),
              ),
            ),
          ),
        ],
      ),
    );
  }
}