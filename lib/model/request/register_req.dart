// To parse this JSON data, do
//
//     final registerRequest = registerRequestFromJson(jsonString);

import 'dart:convert';

RegisterRequest registerRequestFromJson(String str) =>
    RegisterRequest.fromJson(json.decode(str));

String registerRequestToJson(RegisterRequest data) =>
    json.encode(data.toJson());

class RegisterRequest {
  String fullName;
  String phone;
  String email;
  String bankName;
  String bankNumber;
  String password;

  RegisterRequest({
    required this.fullName,
    required this.phone,
    required this.email,
    required this.bankName,
    required this.bankNumber,
    required this.password,
  });

  factory RegisterRequest.fromJson(Map<String, dynamic> json) =>
      RegisterRequest(
        fullName: json["fullName"],
        phone: json["phone"],
        email: json["email"],
        bankName: json["bankName"],
        bankNumber: json["bankNumber"],
        password: json["password"],
      );

  Map<String, dynamic> toJson() => {
    "fullName": fullName,
    "phone": phone,
    "email": email,
    "bankName": bankName,
    "bankNumber": bankNumber,
    "password": password,
  };
}
