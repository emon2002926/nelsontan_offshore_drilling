class ProfileResponseModel {
  final bool success;
  final String message;
  final ProfileModel? data;

  ProfileResponseModel({
    required this.success,
    required this.message,
    this.data,
  });

  factory ProfileResponseModel.fromJson(Map<String, dynamic> json) {
    return ProfileResponseModel(
      success: json["success"] ?? false,
      message: json["message"] ?? '',
      data: json["data"] != null ? ProfileModel.fromJson(json["data"]) : null,
    );
  }
}

class ProfileModel {
  final int id;
  final String name;
  final String email;
  final String? profile;
  final String entryCompany;
  final String position;
  final String phone;
  final bool isVerified;
  final String approveStatus;
  final String status;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int? companyId;
  final int? rigId;

  const ProfileModel({
    required this.id,
    required this.name,
    required this.email,
    this.profile,
    required this.entryCompany,
    required this.position,
    required this.phone,
    required this.isVerified,
    required this.approveStatus,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    this.companyId,
    this.rigId,
  });

  factory ProfileModel.fromJson(Map<String, dynamic> json) {
    return ProfileModel(
      id:            json["id"],
      name:          json["name"]          ?? '',
      email:         json["email"]         ?? '',
      profile:       json["profile"],
      entryCompany:  json["entryCompany"]  ?? '',
      position:      json["position"]      ?? '',
      phone:         json["phone"]         ?? '',
      isVerified:    json["isVerified"]    ?? false,
      approveStatus: json["approveStatus"] ?? '',
      status:        json["status"]        ?? '',
      createdAt:     DateTime.parse(json["createdAt"]),
      updatedAt:     DateTime.parse(json["updatedAt"]),
      companyId:     json["companyId"],
      rigId:         json["rigId"],
    );
  }

  Map<String, String> toUpdateFields() => {
    "name":         name,
    "entryCompany": entryCompany,
    "position":     position,
    "phone":        phone,
  };
}