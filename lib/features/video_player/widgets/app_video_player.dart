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
          if (autoPlay) {
            controller.togglePlayPause();
          }
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
          // Show thumbnail if video hasn't started playing and thumbnail is available
          if (showThumbnail &&
              !controller.hasStartedPlaying.value &&
              videoSource.thumbnailPath != null) {
            return _buildThumbnail(controller);
          }

          // Loading state
          if (controller.isLoading.value) {
            return const Center(
              child: CircularProgressIndicator(
                color: Colors.white,
              ),
            );
          }

          // Video player
          if (controller.isInitialized.value &&
              controller.videoController != null) {
            return GestureDetector(
              onTap: controller.toggleControls,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  // Video
                  Center(
                    child: AspectRatio(
                      aspectRatio:
                      controller.videoController!.value.aspectRatio,
                      child: VideoPlayer(controller.videoController!),
                    ),
                  ),

                  // Play button overlay (when paused)
                  if (!controller.isPlaying.value)
                    Center(
                      child: GestureDetector(
                        onTap: controller.togglePlayPause,
                        child: Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.9),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.play_arrow,
                            size: 50,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ),

                  // Controls
                  if (controller.showControls.value && controller.isPlaying.value)
                    _buildControls(controller),
                ],
              ),
            );
          }

          return const SizedBox();
        }),
      ),
    );
  }

  Widget _buildThumbnail(AppVideoPlayerController controller) {
    return Stack(
      fit: StackFit.expand,
      children: [
        // Thumbnail image based on type
        _buildThumbnailImage(),

        // Play button overlay on thumbnail
        Center(
          child: GestureDetector(
            onTap: () {
              controller.hasStartedPlaying.value = true;
              controller.togglePlayPause();
            },
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.9),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.play_arrow,
                size: 50,
                color: Colors.black,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildThumbnailImage() {
    if (videoSource.thumbnailPath == null) {
      return const Center(
        child: Icon(
          Icons.video_library,
          color: Colors.white,
          size: 50,
        ),
      );
    }

    switch (videoSource.thumbnailType) {
      case VideoSourceType.asset:
        return Image.asset(
          videoSource.thumbnailPath!,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return const Center(
              child: Icon(
                Icons.broken_image,
                color: Colors.white,
                size: 50,
              ),
            );
          },
        );

      case VideoSourceType.network:
        return Image.network(
          videoSource.thumbnailPath!,
          fit: BoxFit.cover,
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return Center(
              child: CircularProgressIndicator(
                color: Colors.white,
                value: loadingProgress.expectedTotalBytes != null
                    ? loadingProgress.cumulativeBytesLoaded /
                    loadingProgress.expectedTotalBytes!
                    : null,
              ),
            );
          },
          errorBuilder: (context, error, stackTrace) {
            return const Center(
              child: Icon(
                Icons.broken_image,
                color: Colors.white,
                size: 50,
              ),
            );
          },
        );

      case VideoSourceType.file:
        return Image.file(
          File(videoSource.thumbnailPath!),
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return const Center(
              child: Icon(
                Icons.broken_image,
                color: Colors.white,
                size: 50,
              ),
            );
          },
        );

      default:
        return const Center(
          child: Icon(
            Icons.video_library,
            color: Colors.white,
            size: 50,
          ),
        );
    }
  }

  Widget _buildControls(AppVideoPlayerController controller) {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 8,
        ),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.transparent,
              Colors.black.withOpacity(0.7),
            ],
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Progress bar
            Obx(() {
              final position = controller.currentPosition.value;
              final duration = controller.totalDuration.value;
              final progress = duration.inMilliseconds > 0
                  ? position.inMilliseconds / duration.inMilliseconds
                  : 0.0;

              return SliderTheme(
                data: SliderThemeData(
                  trackHeight: 3,
                  thumbShape: const RoundSliderThumbShape(
                    enabledThumbRadius: 6,
                  ),
                  overlayShape: const RoundSliderOverlayShape(
                    overlayRadius: 12,
                  ),
                ),
                child: Slider(
                  value: progress.clamp(0.0, 1.0),
                  onChanged: (value) {
                    final newPosition = duration * value;
                    controller.seekTo(newPosition);
                  },
                  activeColor: Colors.white,
                  inactiveColor: Colors.white.withOpacity(0.3),
                ),
              );
            }),

            const SizedBox(height: 4),

            // Time and controls
            Obx(() {
              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Time
                  Text(
                    '${controller.formatDuration(controller.currentPosition.value)} / ${controller.formatDuration(controller.totalDuration.value)}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                    ),
                  ),

                  // Play/Pause button
                  IconButton(
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    icon: Icon(
                      controller.isPlaying.value
                          ? Icons.pause
                          : Icons.play_arrow,
                      color: Colors.white,
                      size: 24,
                    ),
                    onPressed: controller.togglePlayPause,
                  ),
                ],
              );
            }),
          ],
        ),
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