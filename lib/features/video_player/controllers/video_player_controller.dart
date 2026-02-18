// lib/features/video_player/controllers/video_player_controller.dart

import 'dart:io';

import 'package:get/get.dart';
import 'package:nelsontan_offshore_drilling/core/widgets/snakbar/custom_snackbar.dart';
import 'package:video_player/video_player.dart';
import '../models/video_source.dart';

class AppVideoPlayerController extends GetxController {
  VideoPlayerController? videoController;

  final RxBool isInitialized = false.obs;
  final RxBool isPlaying = false.obs;
  final RxBool isLoading = true.obs;
  final RxBool showControls = false.obs;
  final RxBool hasStartedPlaying = false.obs;
  final Rx<Duration> currentPosition = Duration.zero.obs;
  final Rx<Duration> totalDuration = Duration.zero.obs;

  Future<void> initializeVideo(VideoSource source) async {
    try {
      isLoading.value = true;

      // Dispose previous controller if exists
      await videoController?.dispose();

      // Create controller based on source type
      switch (source.type) {
        case VideoSourceType.asset:
          videoController = VideoPlayerController.asset(source.path);
          break;
        case VideoSourceType.network:
          videoController = VideoPlayerController.networkUrl(
            Uri.parse(source.path),
          );
          break;
        case VideoSourceType.file:
          videoController = VideoPlayerController.file(File(source.path));
          break;
      }

      await videoController!.initialize();

      // Add listener for position updates
      videoController!.addListener(_videoListener);

      totalDuration.value = videoController!.value.duration;
      isInitialized.value = true;
      isLoading.value = false;
    } catch (e) {
      isLoading.value = false;
      CustomSnackBar.error('Failed to load video: ${e.toString()}');
    }
  }

  void _videoListener() {
    if (videoController != null) {
      currentPosition.value = videoController!.value.position;
      isPlaying.value = videoController!.value.isPlaying;
    }
  }

  void togglePlayPause() {
    if (videoController != null) {
      if (videoController!.value.isPlaying) {
        videoController!.pause();
      } else {
        hasStartedPlaying.value = true;
        videoController!.play();
      }
    }
  }

  void seekTo(Duration position) {
    videoController?.seekTo(position);
  }

  void toggleControls() {
    showControls.value = !showControls.value;
  }

  String formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);
    return '${twoDigits(minutes)}:${twoDigits(seconds)}';
  }

  @override
  void onClose() {
    videoController?.removeListener(_videoListener);
    videoController?.dispose();
    super.onClose();
  }
}