import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nelsontan_offshore_drilling/core/constants/app_assert_image.dart';
import 'package:nelsontan_offshore_drilling/core/widgets/text/app_text.dart';

import '../../../core/util/app_navigation.dart';
import '../../../core/util/screen_size.dart';
import '../../../core/widgets/snakbar/custom_snackbar.dart';
import '../../notification/views/notifications_screen.dart';
import '../../video_player/models/video_source.dart';
import '../../video_player/widgets/app_video_player.dart';
import '../controllers/home_controller.dart';
import '../widgets/submit_safety_card_button.dart';
import '../widgets/training_game_card.dart';
import '../../weekly_safety_focus/widget/weekly_safety_focus_card.dart';

class HomeScreen extends StatelessWidget {
   HomeScreen({super.key});
  final assetsIcon = AppAssertImage.instance;

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(HomeController());

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: SingleChildScrollView(
            child: Column(
              children: [
                topHeader(context,assetsIcon.topHeaderIcon,assetsIcon.topHeaderNotificationIcon),
                SizedBox(height: context.responsiveSize(12)),

                AppVideoPlayer(
                  videoSource: VideoSource.asset('assets/videos/demo.mp4'),
                  // videoSource: VideoSource.network('https://api.example.com/video.mp4'),
                  showThumbnail: true,

                  width: context.widthPercentage(100),
                  height: context.heightPercentage(28),
                  borderRadius: 16,
                  autoPlay: false,
                ),
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
                    onPressed: () => controller.submitSafetyCard(context),
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
     return Container(
       width: MediaQuery.of(context).size.width,
       height: context.heightPercentage(5),
       child: Row(
         children: [
           // Left icon
           Padding(
             padding: const EdgeInsets.all(8),
             child: Image.asset(
               headerSaveIcon,
               height: context.responsiveSize(24),
             ),
           ),
           // Title
           AppText(
             data: "Homepage",
             fontSize: 18,
             fontWeight: FontWeight.w900,
           ),
           const Spacer(), // Pushes notification icon to the right
           // Right notification icon
           GestureDetector(
             onTap: () {
               AppNavigation.push(context, const NotificationsScreen());
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
