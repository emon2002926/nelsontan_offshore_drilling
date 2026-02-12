// lib/features/video_player/models/video_source.dart

enum VideoSourceType { asset, network }

class VideoSource {
  final String path;
  final VideoSourceType type;

  const VideoSource({
    required this.path,
    required this.type,
  });

  factory VideoSource.asset(String assetPath) {
    return VideoSource(
      path: assetPath,
      type: VideoSourceType.asset,
    );
  }

  factory VideoSource.network(String url) {
    return VideoSource(
      path: url,
      type: VideoSourceType.network,
    );
  }
}