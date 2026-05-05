import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:video_player/video_player.dart';
import '../controllers/video_player_controller.dart';
import '../models/video_source.dart';

class AppVideoPlayer extends StatefulWidget {
  final VideoSource? videoSource;
  final double? width;
  final double? height;
  final double borderRadius;
  final bool autoPlay;
  final bool showThumbnail;
  final String? tag;
  final Widget? placeholder;

  const AppVideoPlayer({
    super.key,
    this.videoSource,
    this.width,
    this.height,
    this.borderRadius = 16,
    this.autoPlay = false,
    this.showThumbnail = true,
    this.tag,
    this.placeholder,
  });

  @override
  State<AppVideoPlayer> createState() => _AppVideoPlayerState();
}

class _AppVideoPlayerState extends State<AppVideoPlayer> {
  bool _showNoVideo = false;

  @override
  void initState() {
    super.initState();
    if (widget.videoSource == null) {
      // Wait a moment before revealing "no video" UI
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) setState(() => _showNoVideo = true);
      });
    }
  }

  @override
  void dispose() {
    final tag = widget.tag ?? widget.videoSource?.path;
    if (tag != null) {
      try {
        final controller = Get.find<AppVideoPlayerController>(tag: tag);
        if (controller.isPlaying.value) {
          controller.togglePlayPause(); // only toggle if actually playing
        }
      } catch (_) {}
      Get.delete<AppVideoPlayerController>(tag: tag);
    }
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    // ── No video source ─────────────────────────────────────────────────────
    if (widget.videoSource == null) {
      return _showNoVideo ? _buildPlaceholder() : _buildLoadingState();
    }

    final controller = Get.put(
      AppVideoPlayerController(),
      tag: widget.tag ?? widget.videoSource!.path,
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!controller.isInitialized.value) {
        controller.initializeVideo(widget.videoSource!).then((_) {
          if (widget.autoPlay) controller.togglePlayPause();
        });
      }
    });

    return ClipRRect(
      borderRadius: BorderRadius.circular(widget.borderRadius),
      child: Container(
        width: widget.width,
        height: widget.height,
        color: Colors.black,
        child: Obx(() {
          // ── Thumbnail ────────────────────────────────────────────────────
          if (widget.showThumbnail &&
              !controller.hasStartedPlaying.value &&
              widget.videoSource!.thumbnailPath != null) {
            return _buildThumbnail(controller);
          }

          // ── Loading ──────────────────────────────────────────────────────
          if (controller.isLoading.value) {
            return _buildLoadingState();
          }

          // ── Player ───────────────────────────────────────────────────────
          if (controller.isInitialized.value &&
              controller.videoController != null) {
            return GestureDetector(
              onTap: controller.toggleControls,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Center(
                    child: AspectRatio(
                      aspectRatio:
                      controller.videoController!.value.aspectRatio,
                      child: VideoPlayer(controller.videoController!),
                    ),
                  ),
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

  // ── Loading state ─────────────────────────────────────────────────────────

  Widget _buildLoadingState() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(widget.borderRadius),
      child: Container(
        width: widget.width,
        height: widget.height,
        color: Colors.grey.shade900,
        child: const Center(
          child: SizedBox(
            width: 120,
            child: LinearProgressIndicator(
              color: Colors.white,
              backgroundColor: Colors.white24,
              minHeight: 3,
            ),
          ),
        ),
      ),
    );
  }

  // ── Placeholder (no video) ────────────────────────────────────────────────

  Widget _buildPlaceholder() {
    if (widget.placeholder != null) return widget.placeholder!;

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 400),
      child: ClipRRect(
        key: const ValueKey('no_video'),
        borderRadius: BorderRadius.circular(widget.borderRadius),
        child: Container(
          width: widget.width,
          height: widget.height,
          color: Colors.grey.shade900,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.videocam_off_rounded,
                color: Colors.white.withOpacity(0.5),
                size: 40,
              ),
              const SizedBox(height: 10),
              Text(
                'No video available',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.6),
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Please check back later',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.35),
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
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
    if (widget.videoSource!.thumbnailPath == null) {
      return const Center(
        child: Icon(Icons.video_library, color: Colors.white, size: 50),
      );
    }
    switch (widget.videoSource!.thumbnailType) {
      case VideoSourceType.asset:
        return Image.asset(
          widget.videoSource!.thumbnailPath!,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => const Center(
            child: Icon(Icons.broken_image, color: Colors.white, size: 50),
          ),
        );
      case VideoSourceType.network:
        return Image.network(
          widget.videoSource!.thumbnailPath!,
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
          File(widget.videoSource!.thumbnailPath!),
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