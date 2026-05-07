
import 'package:nelsontan_offshore_drilling/features/auth/models/sign_in_response_model.dart';

class UpdateProfileStatus {
  final bool success;
  final String message;
  final UserModel? data;

  UpdateProfileStatus({
    required this.success,
    required this.message,
    this.data,
  });

  factory UpdateProfileStatus.fromJson(Map<String, dynamic> json) {
    return UpdateProfileStatus(
      success: json["success"] ?? false,
      message: json["message"] ?? '',
      data: UserModel.fromJson(json["data"]),

      // data: json["data"] != null ? User.fromJson(json["data"]) : null,
    );
  }
}
