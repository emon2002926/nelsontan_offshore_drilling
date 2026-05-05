import 'package:flutter/cupertino.dart';

import '../../../core/util/app_navigation.dart';
import '../../notification/views/notifications_screen.dart';
import '../../video_player/controllers/video_player_controller.dart';
import '../../video_player/models/video_source.dart';
import 'package:get/get.dart';
class VideoPlayerScreenController extends GetxController {
  final VideoSource videoSource;
  final String title;
  final String? description;

  VideoPlayerScreenController({
    required this.videoSource,
    required this.title,
    this.description,
  });

  late final AppVideoPlayerController playerController;

  @override
  void onInit() {
    super.onInit();
    playerController = Get.find<AppVideoPlayerController>(
      tag: 'main_${videoSource.path}',
    );
  }

  String get playerTag => 'main_${videoSource.path}';

  double get progress {
    final position = playerController.currentPosition.value;
    final duration = playerController.totalDuration.value;
    return duration.inMilliseconds > 0
        ? (position.inMilliseconds / duration.inMilliseconds).clamp(0.0, 1.0)
        : 0.0;
  }

  void seekTo(double value) {
    final newPosition = playerController.totalDuration.value * value;
    playerController.seekTo(newPosition);
  }

  void togglePlayPause() => playerController.togglePlayPause();

  void goToNotifications(BuildContext context) =>
      AppNavigation.push(const NotificationsScreen(), context: context);
}