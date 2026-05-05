
class SignInResponseModel {
  final bool success;
  final String message;
  final SignInData? data;

  SignInResponseModel({
    required this.success,
    required this.message,
    this.data,
  });

  factory SignInResponseModel.fromJson(Map<String, dynamic> json) {
    return SignInResponseModel(
      success: json["success"] ?? false,
      message: json["message"] ?? '',
      data: json["data"] != null ? SignInData.fromJson(json["data"]) : null,
    );
  }
}

class SignInData {
  final String token;
  final UserModel user;

  SignInData({required this.token, required this.user});

  factory SignInData.fromJson(Map<String, dynamic> json) {
    return SignInData(
      token: json["token"] ?? '',
      user: UserModel.fromJson(json["user"]),
    );
  }
}

class UserModel {
  final int id;
  final String name;
  final String email;
  final String? profile;
  final String entryCompany;
  final String position;
  final String phone;
  final bool isVerified;
  final String approveStatus; // "PENDING" | "APPROVED" | "REJECTED"
  final String status;        // "ACTIVE" | "INACTIVE"
  final DateTime createdAt;
  final DateTime updatedAt;
  final int? companyId;
  final int? rigId;

  UserModel({
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

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id:            json["id"],
      name:          json["name"] ?? '',
      email:         json["email"] ?? '',
      profile:       json["profile"],
      entryCompany:  json["entryCompany"] ?? '',
      position:      json["position"] ?? '',
      phone:         json["phone"] ?? '',
      isVerified:    json["isVerified"] ?? false,
      approveStatus: json["approveStatus"] ?? '',
      status:        json["status"] ?? '',
      createdAt:     DateTime.parse(json["createdAt"]),
      updatedAt:     DateTime.parse(json["updatedAt"]),
      companyId:     json["companyId"],
      rigId:         json["rigId"],
    );
  }




  // Handy getters for decision making in controller
  bool get isPending  => approveStatus == 'PENDING';
  bool get isInactive => approveStatus == 'INACTIVE';
  bool get isApproved => approveStatus == 'APPROVED';
  bool get isSuspended => approveStatus == 'SUSPENDED';
  bool get isDeleted => approveStatus == 'DELETED';
  bool get isNotSubmitted => approveStatus == 'NOT_SUBMITTED';
  bool get isActive   => status == 'ACTIVE';
}