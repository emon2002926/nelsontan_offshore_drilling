// lib/features/video_player/models/video_source.dart

enum VideoSourceType { asset, network }

class VideoSource {
  final String path;
  final VideoSourceType type;
  final String? thumbnailPath; // Added thumbnail support
  final VideoSourceType? thumbnailType; // Type for thumbnail (asset or network)

  const VideoSource({
    required this.path,
    required this.type,
    this.thumbnailPath,
    this.thumbnailType,
  });

  factory VideoSource.asset(String assetPath, {String? thumbnailAssetPath}) {
    return VideoSource(
      path: assetPath,
      type: VideoSourceType.asset,
      thumbnailPath: thumbnailAssetPath,
      thumbnailType: thumbnailAssetPath != null ? VideoSourceType.asset : null,
    );
  }

  factory VideoSource.network(String url, {String? thumbnailUrl}) {
    return VideoSource(
      path: url,
      type: VideoSourceType.network,
      thumbnailPath: thumbnailUrl,
      thumbnailType: thumbnailUrl != null ? VideoSourceType.network : null,
    );
  }
}