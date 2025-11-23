import 'package:apk_absensi/models/profile_model.dart';

class UpdateProfileRequest {
  final String? password;
  final String? currentPassword;

  UpdateProfileRequest({
    this.password,
    this.currentPassword,
  });

  Map<String, dynamic> toJson() {
    return {
      if (password != null) 'password': password,
      if (currentPassword != null) 'currentPassword': currentPassword,
    };
  }
}

class UpdateProfileResponse {
  final bool success;
  final String message;
  final Profile? data;

  UpdateProfileResponse({
    required this.success,
    required this.message,
    this.data,
  });

  factory UpdateProfileResponse.fromJson(Map<String, dynamic> json) {
    return UpdateProfileResponse(
      success: json['success'],
      message: json['message'],
      data: json['data'] != null ? Profile.fromJson(json['data']) : null,
    );
  }
}