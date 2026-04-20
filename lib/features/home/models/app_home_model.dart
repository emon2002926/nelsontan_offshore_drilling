class AppHomeModel {
  final AppHomeAlertModel? alerts;
  final AppHomeVideoModel? videos;

  AppHomeModel({
    this.alerts,
    this.videos,
  });

  factory AppHomeModel.fromJson(Map<String, dynamic> json) {
    return AppHomeModel(
      alerts: json['alerts'] != null
          ? AppHomeAlertModel.fromJson(json['alerts'] as Map<String, dynamic>)
          : null,
      videos: json['videos'] != null
          ? AppHomeVideoModel.fromJson(json['videos'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'alerts': alerts?.toJson(),
    'videos': videos?.toJson(),
  };
}

class AppHomeAlertModel {
  final int id;
  final String title;
  final String description;
  final String? file;
  final String status;
  final bool isDefault;
  final int? companyId;
  final bool isAllRigs;
  final List<dynamic> rigIds;
  final String createdAt;
  final String updatedAt;

  AppHomeAlertModel({
    required this.id,
    required this.title,
    required this.description,
    this.file,
    required this.status,
    required this.isDefault,
    this.companyId,
    required this.isAllRigs,
    required this.rigIds,
    required this.createdAt,
    required this.updatedAt,
  });

  factory AppHomeAlertModel.fromJson(Map<String, dynamic> json) {
    return AppHomeAlertModel(
      id: json['id'] as int,
      title: json['title'] as String,
      description: json['description'] as String,
      file: json['file'] as String?,
      status: json['status'] as String,
      isDefault: json['isDefault'] as bool,
      companyId: json['companyId'] as int?,
      isAllRigs: json['isAllRigs'] as bool,
      rigIds: json['rigIds'] as List<dynamic>? ?? [],
      createdAt: json['createdAt'] as String,
      updatedAt: json['updatedAt'] as String,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'description': description,
    'file': file,
    'status': status,
    'isDefault': isDefault,
    'companyId': companyId,
    'isAllRigs': isAllRigs,
    'rigIds': rigIds,
    'createdAt': createdAt,
    'updatedAt': updatedAt,
  };
}

class AppHomeVideoModel {
  final int id;
  final String title;
  final String description;
  final String position;
  final String videoUrl;
  final String? thumbnail;
  final String status;
  final bool isDefault;
  final int? companyId;
  final bool isAllRigs;
  final List<dynamic> rigIds;
  final String createdAt;
  final String updatedAt;

  AppHomeVideoModel({
    required this.id,
    required this.title,
    required this.description,
    required this.position,
    required this.videoUrl,
    this.thumbnail,
    required this.status,
    required this.isDefault,
    this.companyId,
    required this.isAllRigs,
    required this.rigIds,
    required this.createdAt,
    required this.updatedAt,
  });

  factory AppHomeVideoModel.fromJson(Map<String, dynamic> json) {
    return AppHomeVideoModel(
      id: json['id'] as int,
      title: json['title'] as String,
      description: json['description'] as String,
      position: json['position'] as String,
      videoUrl: json['videoUrl'] as String,
      thumbnail: json['thumbnail'] as String?,
      status: json['status'] as String,
      isDefault: json['isDefault'] as bool,
      companyId: json['companyId'] as int?,
      isAllRigs: json['isAllRigs'] as bool,
      rigIds: json['rigIds'] as List<dynamic>? ?? [],
      createdAt: json['createdAt'] as String,
      updatedAt: json['updatedAt'] as String,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'description': description,
    'position': position,
    'videoUrl': videoUrl,
    'thumbnail': thumbnail,
    'status': status,
    'isDefault': isDefault,
    'companyId': companyId,
    'isAllRigs': isAllRigs,
    'rigIds': rigIds,
    'createdAt': createdAt,
    'updatedAt': updatedAt,
  };
}