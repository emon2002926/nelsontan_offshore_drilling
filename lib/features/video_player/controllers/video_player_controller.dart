// lib/features/video_player/controllers/video_player_controller.dart

import 'dart:io';

import 'package:get/get.dart';
import 'package:nelsontan_offshore_drilling/core/widgets/snakbar/custom_snackbar.dart';
import 'package:video_player/video_player.dart';
import '../models/video_source.dart';

class AppVideoPlayerController extends GetxController {
  VideoPlayerController? videoController;

  final RxBool isInitialized     = false.obs;
  final RxBool isPlaying         = false.obs;
  final RxBool isLoading         = true.obs;
  final RxBool showControls      = false.obs;
  final RxBool hasStartedPlaying = false.obs;
  final RxBool isMuted           = false.obs;

  final Rx<Duration> currentPosition = Duration.zero.obs;
  final Rx<Duration> totalDuration   = Duration.zero.obs;

  Future<void> initializeVideo(VideoSource source) async {
    try {
      isLoading.value = true;

      await videoController?.dispose();
      videoController = null;

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

      // Read duration immediately after initialize — works for most formats
      final initialDuration = videoController!.value.duration;
      if (initialDuration > Duration.zero) {
        totalDuration.value = initialDuration;
      }

      // Listener keeps updating duration in case it arrives late
      // (common with some HTTP servers / containers)
      videoController!.addListener(_videoListener);

      isInitialized.value = true;
      isLoading.value     = false;
    } catch (e) {
      isLoading.value = false;
      CustomSnackBar.error('Failed to load video: ${e.toString()}');
    }
  }

  void _videoListener() {
    if (videoController == null) return;
    final value = videoController!.value;

    currentPosition.value = value.position;
    isPlaying.value       = value.isPlaying;

    // Always update duration from listener — some servers report it late
    if (value.duration > Duration.zero &&
        value.duration != totalDuration.value) {
      totalDuration.value = value.duration;
    }
  }

  void togglePlayPause() {
    if (videoController == null) return;
    if (videoController!.value.isPlaying) {
      videoController!.pause();
    } else {
      hasStartedPlaying.value = true;
      videoController!.play();
    }
  }

  void seekTo(Duration position) {
    final clamped = position.isNegative
        ? Duration.zero
        : position > totalDuration.value
        ? totalDuration.value
        : position;
    videoController?.seekTo(clamped);
  }

  void skipForward() {
    seekTo(currentPosition.value + const Duration(seconds: 5));
  }

  void skipBackward() {
    seekTo(currentPosition.value - const Duration(seconds: 5));
  }

  void toggleMute() {
    isMuted.value = !isMuted.value;
    videoController?.setVolume(isMuted.value ? 0.0 : 1.0);
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