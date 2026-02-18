// lib/features/video_player/models/video_source.dart

enum VideoSourceType { asset, network, file }

class VideoSource {
  final String path;
  final VideoSourceType type;
  final String? thumbnailPath;
  final VideoSourceType? thumbnailType;

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

  factory VideoSource.file(String filePath, {String? thumbnailFilePath}) {
    return VideoSource(
      path: filePath,
      type: VideoSourceType.file,
      thumbnailPath: thumbnailFilePath,
      thumbnailType: thumbnailFilePath != null ? VideoSourceType.file : null,
    );
  }

  // Convert to/from JSON
  Map<String, dynamic> toJson() {
    return {
      'path': path,
      'type': type.name,
      'thumbnailPath': thumbnailPath,
      'thumbnailType': thumbnailType?.name,
    };
  }

  factory VideoSource.fromJson(Map<String, dynamic> json) {
    return VideoSource(
      path: json['path'] as String,
      type: VideoSourceType.values.firstWhere(
            (e) => e.name == json['type'],
      ),
      thumbnailPath: json['thumbnailPath'] as String?,
      thumbnailType: json['thumbnailType'] != null
          ? VideoSourceType.values.firstWhere(
            (e) => e.name == json['thumbnailType'],
      )
          : null,
    );
  }
}