class VideoModel {
  final int id;
  final String title;
  final String description;
  final String position;
  final String? videoUrl;
  final String? thumbnail;
  final String status;

  VideoModel({
    required this.id,
    required this.title,
    required this.description,
    required this.position,
    this.videoUrl,
    this.thumbnail,
    required this.status,
  });

  factory VideoModel.fromJson(Map<String, dynamic> json) => VideoModel(
    id: json['id'] as int,
    title: json['title'] as String,
    description: json['description'] as String,
    position: json['position'] as String,
    videoUrl: json['videoUrl'] as String?,
    thumbnail: json['thumbnail'] as String?,
    status: json['status'] as String,
  );
}