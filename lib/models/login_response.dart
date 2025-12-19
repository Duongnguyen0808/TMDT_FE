// To parse this JSON data, do
//
//     final loginResponse = loginResponseFromJson(jsonString);

import 'dart:convert';

LoginResponse loginResponseFromJson(String str) {
  final Map<String, dynamic> raw = json.decode(str);
  final Map<String, dynamic> payload = raw['data'] is Map<String, dynamic>
      ? Map<String, dynamic>.from(raw['data'])
      : Map<String, dynamic>.from(raw);

  // userToken hiện nằm ngoài object data trong response mới => ghép lại cho tiện dùng chung
  payload['userToken'] = payload['userToken'] ?? raw['userToken'] ?? '';

  return LoginResponse.fromJson(payload);
}

String loginResponseToJson(LoginResponse data) => json.encode(data.toJson());

class LoginResponse {
  final String id;
  final String username;
  final String email;
  final String fcm;
  final bool verification;
  final String phone;
  final bool phoneVerification;
  final String userType;
  final String profile;
  final String userToken;

  LoginResponse({
    required this.id,
    required this.username,
    required this.email,
    required this.fcm,
    required this.verification,
    required this.phone,
    required this.phoneVerification,
    required this.userType,
    required this.profile,
    required this.userToken,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) => LoginResponse(
        id: (json["_id"] ?? json["id"] ?? "").toString(),
        username: (json["username"] ?? "").toString(),
        email: (json["email"] ?? "").toString(),
        fcm: (json["fcm"] ?? "").toString(),
        verification: json["verification"] == true,
        phone: (json["phone"] ?? "").toString(),
        phoneVerification: json["phoneVerification"] == true,
        userType: (json["userType"] ?? "").toString(),
        profile: (json["profile"] ?? "").toString(),
        userToken: (json["userToken"] ?? "").toString(),
      );

  Map<String, dynamic> toJson() => {
        "_id": id,
        "username": username,
        "email": email,
        "fcm": fcm,
        "verification": verification,
        "phone": phone,
        "phoneVerification": phoneVerification,
        "userType": userType,
        "profile": profile,
        "userToken": userToken,
      };
}
