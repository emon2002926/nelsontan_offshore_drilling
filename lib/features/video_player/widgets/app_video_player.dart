import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:video_player/video_player.dart';
import '../controllers/video_player_controller.dart';
import '../models/video_source.dart';

class AppVideoPlayer extends StatelessWidget {
  final VideoSource videoSource;
  final double? width;
  final double? height;
  final double borderRadius;
  final bool autoPlay;
  final bool showThumbnail;
  final String? tag;

  const AppVideoPlayer({
    super.key,
    required this.videoSource,
    this.width,
    this.height,
    this.borderRadius = 16,
    this.autoPlay = false,
    this.showThumbnail = true,
    this.tag,
  });

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(
      AppVideoPlayerController(),
      tag: tag ?? videoSource.path,
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!controller.isInitialized.value) {
        controller.initializeVideo(videoSource).then((_) {
          if (autoPlay) controller.togglePlayPause();
        });
      }
    });

    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: Container(
        width: width,
        height: height,
        color: Colors.black,
        child: Obx(() {
          // ── Thumbnail ──────────────────────────────────────────────────
          if (showThumbnail &&
              !controller.hasStartedPlaying.value &&
              videoSource.thumbnailPath != null) {
            return _buildThumbnail(controller);
          }

          // ── Loading ────────────────────────────────────────────────────
          if (controller.isLoading.value) {
            return const Center(
              child: CircularProgressIndicator(color: Colors.white),
            );
          }

          // ── Player ─────────────────────────────────────────────────────
          if (controller.isInitialized.value &&
              controller.videoController != null) {
            return GestureDetector(
              onTap: controller.toggleControls,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  // Video frame
                  Center(
                    child: AspectRatio(
                      aspectRatio:
                      controller.videoController!.value.aspectRatio,
                      child: VideoPlayer(controller.videoController!),
                    ),
                  ),

                  // Controls — visible when paused OR showControls is true
                  Obx(() {
                    final visible = controller.showControls.value ||
                        !controller.isPlaying.value;
                    return AnimatedOpacity(
                      opacity: visible ? 1.0 : 0.0,
                      duration: const Duration(milliseconds: 250),
                      child: _buildControls(controller),
                    );
                  }),
                ],
              ),
            );
          }

          return const SizedBox();
        }),
      ),
    );
  }

  // ── Thumbnail ─────────────────────────────────────────────────────────────

  Widget _buildThumbnail(AppVideoPlayerController controller) {
    return Stack(
      fit: StackFit.expand,
      children: [
        _buildThumbnailImage(),
        Center(
          child: GestureDetector(
            onTap: () {
              controller.hasStartedPlaying.value = true;
              controller.togglePlayPause();
            },
            child: _circleButton(icon: Icons.play_arrow, size: 36),
          ),
        ),
      ],
    );
  }

  Widget _buildThumbnailImage() {
    if (videoSource.thumbnailPath == null) {
      return const Center(
        child: Icon(Icons.video_library, color: Colors.white, size: 50),
      );
    }
    switch (videoSource.thumbnailType) {
      case VideoSourceType.asset:
        return Image.asset(
          videoSource.thumbnailPath!,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => const Center(
            child: Icon(Icons.broken_image, color: Colors.white, size: 50),
          ),
        );
      case VideoSourceType.network:
        return Image.network(
          videoSource.thumbnailPath!,
          fit: BoxFit.cover,
          loadingBuilder: (_, child, progress) {
            if (progress == null) return child;
            return Center(
              child: CircularProgressIndicator(
                color: Colors.white,
                value: progress.expectedTotalBytes != null
                    ? progress.cumulativeBytesLoaded /
                    progress.expectedTotalBytes!
                    : null,
              ),
            );
          },
          errorBuilder: (_, __, ___) => const Center(
            child: Icon(Icons.broken_image, color: Colors.white, size: 50),
          ),
        );
      case VideoSourceType.file:
        return Image.file(
          File(videoSource.thumbnailPath!),
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => const Center(
            child: Icon(Icons.broken_image, color: Colors.white, size: 50),
          ),
        );
      default:
        return const Center(
          child: Icon(Icons.video_library, color: Colors.white, size: 50),
        );
    }
  }

  // ── Controls overlay ──────────────────────────────────────────────────────

  Widget _buildControls(AppVideoPlayerController controller) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.black.withOpacity(0.35),
            Colors.transparent,
            Colors.transparent,
            Colors.black.withOpacity(0.75),
          ],
          stops: const [0.0, 0.2, 0.65, 1.0],
        ),
      ),
      child: Column(
        children: [
          // ── Top: mute button ───────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.only(top: 8, right: 10),
            child: Align(
              alignment: Alignment.topRight,
              child: Obx(
                    () => _iconButton(
                  icon: controller.isMuted.value
                      ? Icons.volume_off
                      : Icons.volume_up,
                  onTap: controller.toggleMute,
                ),
              ),
            ),
          ),

          const Spacer(),

          // ── Centre: skip−5 | play/pause | skip+5 ──────────────────────
          Obx(
                () => Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _iconButton(
                  icon: Icons.replay_5,
                  onTap: controller.skipBackward,
                  size: 28,
                ),
                const SizedBox(width: 28),
                GestureDetector(
                  onTap: controller.togglePlayPause,
                  child: _circleButton(
                    icon: controller.isPlaying.value
                        ? Icons.pause
                        : Icons.play_arrow,
                    size: 36,
                  ),
                ),
                const SizedBox(width: 28),
                _iconButton(
                  icon: Icons.forward_5,
                  onTap: controller.skipForward,
                  size: 28,
                ),
              ],
            ),
          ),

          const SizedBox(height: 8),

          // ── Bottom: slider + time labels ───────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Obx(() {
              final position = controller.currentPosition.value;
              final duration = controller.totalDuration.value;
              final progress = duration.inMilliseconds > 0
                  ? position.inMilliseconds / duration.inMilliseconds
                  : 0.0;

              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SliderTheme(
                    data: SliderThemeData(
                      trackHeight: 3,
                      thumbShape: const RoundSliderThumbShape(
                          enabledThumbRadius: 6),
                      overlayShape: const RoundSliderOverlayShape(
                          overlayRadius: 12),
                    ),
                    child: Slider(
                      value: progress.clamp(0.0, 1.0),
                      onChanged: (v) => controller.seekTo(duration * v),
                      activeColor: Colors.white,
                      inactiveColor: Colors.white.withOpacity(0.3),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        controller.formatDuration(position),
                        style: const TextStyle(
                            color: Colors.white, fontSize: 11),
                      ),
                      Text(
                        controller.formatDuration(duration),
                        style: const TextStyle(
                            color: Colors.white, fontSize: 11),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                ],
              );
            }),
          ),
        ],
      ),
    );
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  /// White circle button (play/pause centre)
  Widget _circleButton({required IconData icon, double size = 36}) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        shape: BoxShape.circle,
      ),
      child: Icon(icon, size: size, color: Colors.black),
    );
  }

  /// Translucent circle icon button (skip, mute)
  Widget _iconButton({
    required IconData icon,
    required VoidCallback onTap,
    double size = 22,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(7),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.35),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, size: size, color: Colors.white),
      ),
    );
  }
}




/*


// Example 1: Single videos player
import 'package:flutter/material.dart';
import 'features/video_player/widgets/app_video_player.dart';
import 'features/video_player/models/video_source.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Video Player')),
      body: Center(
        child: AppVideoPlayer(
          // For assets (current)
          videoSource: VideoSource.asset('assets/videos/sample.mp4'),

          // For API (later)
          // videoSource: VideoSource.network('https://api.example.com/video.mp4'),

          width: MediaQuery.of(context).size.width * 0.9,
          height: 250,
          borderRadius: 16,
          autoPlay: false,
        ),
      ),
    );
  }
}



// Example 2: Multiple videos players in a list
class VideoListScreen extends StatelessWidget {
  const VideoListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final videos = [
      'assets/videos/video1.mp4',
      'assets/videos/video2.mp4',
      'assets/videos/video3.mp4',
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Video List')),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: videos.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: AppVideoPlayer(
              videoSource: VideoSource.asset(videos[index]),
              tag: 'video_$index', // Important: unique tag for each player
              width: double.infinity,
              height: 250,
              borderRadius: 16,
              autoPlay: false,
            ),
          );
        },
      ),
    );
  }
}

// Example 3: With API call (future implementation)
class ApiVideoScreen extends StatelessWidget {
  const ApiVideoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('API Video')),
      body: FutureBuilder<String>(
        future: _fetchVideoUrl(), // Your API call
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return Center(
              child: AppVideoPlayer(
                videoSource: VideoSource.network(snapshot.data!),
                width: MediaQuery.of(context).size.width * 0.9,
                height: 250,
                borderRadius: 16,
                autoPlay: true,
              ),
            );
          }
          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }

  Future<String> _fetchVideoUrl() async {
    // Your API call here
    await Future.delayed(const Duration(seconds: 2));
    return 'https://example.com/video.mp4';
  }
}

 */