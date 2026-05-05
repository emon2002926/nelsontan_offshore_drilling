import 'package:flutter/material.dart';

import '../../../core/constants/app_assert_image.dart';
import '../../../core/util/app_navigation.dart';
import '../../../core/util/screen_size.dart';
import '../../../core/widgets/text/app_text.dart';
import '../../notification/views/notifications_screen.dart';
import '../../video_player/models/video_source.dart';
import '../../video_player/widgets/app_video_player.dart';

// lib/features/video_player/views/video_player_screen.dart

import 'package:get/get.dart';
import '../../video_player/controllers/video_player_controller.dart';

class VideoPlayerScreen extends StatelessWidget {
  final VideoSource videoSource;
  final String title;
  final String? description;

  final appAssets = AppAssertImage.instance;

   VideoPlayerScreen({
    super.key,
    required this.videoSource,
    required this.title,
    this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: context.heightPercentage(1),),

            _buildHeader(context),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(18),
                child: AspectRatio(
                  aspectRatio: 16 / 10,
                  child: AppVideoPlayer(
                    videoSource: videoSource,
                    width: double.infinity,
                    borderRadius: 0,
                    showThumbnail: true,
                    autoPlay: false,
                    tag: 'main_${videoSource.path}',
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppText(
                    data: title,
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF111827),
                  ),
                  const SizedBox(height: 6),
                  AppText(
                    data:description ??
                        'Learn to identify and prevent hazards on the WIP Oil Machine and follow best practices for safe operation.',
                      fontSize: 14,
                      color: Color(0xFF6B7280),
                      height: 1.5,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            _InlinePlayerControls(videoSource: videoSource),
          ],
        ),
      ),
    );
  }
  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(context.responsiveSize(16)),
      color: Colors.white,
      child: Row(
        children: [
          // Icon
          Container(
            child: Image.asset(
              appAssets.bxsVideos,
              width: context.responsiveSize(40),
              height: context.responsiveSize(40),
              colorBlendMode: BlendMode.srcIn,
            ),
          ),
          SizedBox(width: context.responsiveSize(12)),

          // Title and subtitle
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppText(
                  data: 'Safety Training Library',
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF1A1A1A),
                  useResponsiveFontSize: true,
                ),
                SizedBox(height: context.responsiveSize(4)),
                AppText(
                  data: 'Complete required training modules',
                  fontSize: 13,
                  fontWeight: FontWeight.w400,
                  color: const Color(0xFF6B6B6B),
                  useResponsiveFontSize: true,
                ),
              ],
            ),
          ),

          // Notification icon
          IconButton(
            onPressed: () {
              // Handle notification tap
              AppNavigation.push( const NotificationsScreen(),context: context);

            },
            icon: const Icon(
              Icons.notifications_outlined,
              color: Color(0xFF1A1A1A),
            ),
            iconSize: context.responsiveSize(28),
          ),
        ],
      ),
    );
  }

}
class _InlinePlayerControls extends StatelessWidget {
  final VideoSource videoSource;

  const _InlinePlayerControls({required this.videoSource});

  @override
  Widget build(BuildContext context) {
    // Reuse the same controller that AppVideoPlayer already registered
    final controller = Get.find<AppVideoPlayerController>(
      tag: 'main_${videoSource.path}',
    );

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Obx(() {
        final position = controller.currentPosition.value;
        final duration = controller.totalDuration.value;
        final progress = duration.inMilliseconds > 0
            ? (position.inMilliseconds / duration.inMilliseconds).clamp(0.0, 1.0)
            : 0.0;

        return Row(
          children: [
            // Play / Pause button
            GestureDetector(
              onTap: controller.togglePlayPause,
              child: Icon(
                controller.isPlaying.value
                    ? Icons.pause_rounded
                    : Icons.play_arrow_rounded,
                color: const Color(0xFF0057B8),
                size: 32,
              ),
            ),

            const SizedBox(width: 8),

            // Slider
            Expanded(
              child: SliderTheme(
                data: SliderThemeData(
                  trackHeight: 3,
                  activeTrackColor: const Color(0xFF0057B8),
                  inactiveTrackColor: const Color(0xFFE5E7EB),
                  thumbColor: const Color(0xFF0057B8),
                  thumbShape:
                  const RoundSliderThumbShape(enabledThumbRadius: 6),
                  overlayShape:
                  const RoundSliderOverlayShape(overlayRadius: 12),
                ),
                child: Slider(
                  value: progress,
                  onChanged: (value) {
                    final newPosition = duration * value;
                    controller.seekTo(newPosition);
                  },
                ),
              ),
            ),

            const SizedBox(width: 4),

            // Duration label
            AppText(
              data: controller.formatDuration(duration),
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Color(0xFF0057B8),
            ),
          ],
        );
      }),
    );
  }
}