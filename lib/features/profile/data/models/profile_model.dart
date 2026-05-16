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

// ── Nested models ─────────────────────────────────────────────────────────────

class ProfileCompanyModel {
  final int id;
  final String name;

  const ProfileCompanyModel({required this.id, required this.name});

  factory ProfileCompanyModel.fromJson(Map<String, dynamic> json) =>
      ProfileCompanyModel(
        id:   json["id"]   as int,
        name: json["name"] as String? ?? '',
      );
}

class ProfileRigModel {
  final int id;
  final String name;

  const ProfileRigModel({required this.id, required this.name});

  factory ProfileRigModel.fromJson(Map<String, dynamic> json) =>
      ProfileRigModel(
        id:   json["id"]   as int,
        name: json["name"] as String? ?? '',
      );
}

// ── Main model ────────────────────────────────────────────────────────────────

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
  final ProfileCompanyModel? company;  // new
  final ProfileRigModel? rig;          // new

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
    this.company,
    this.rig,
  });

  factory ProfileModel.fromJson(Map<String, dynamic> json) {
    return ProfileModel(
      id:            json["id"]            as int,
      name:          json["name"]          as String? ?? '',
      email:         json["email"]         as String? ?? '',
      profile:       json["profile"]       as String?,
      entryCompany:  json["entryCompany"]  as String? ?? '',
      position:      json["position"]      as String? ?? '',
      phone:         json["phone"]         as String? ?? '',
      isVerified:    json["isVerified"]    as bool?   ?? false,
      approveStatus: json["approveStatus"] as String? ?? '',
      status:        json["status"]        as String? ?? '',
      createdAt:     DateTime.parse(json["createdAt"] as String),
      updatedAt:     DateTime.parse(json["updatedAt"] as String),
      companyId:     json["companyId"]     as int?,
      rigId:         json["rigId"]         as int?,
      company:       json["company"] != null
          ? ProfileCompanyModel.fromJson(json["company"] as Map<String, dynamic>)
          : null,
      rig:           json["rig"] != null
          ? ProfileRigModel.fromJson(json["rig"] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, String> toUpdateFields() => {
    "name":         name,
    "entryCompany": entryCompany,
    "position":     position,
    "phone":        phone,
  };
}