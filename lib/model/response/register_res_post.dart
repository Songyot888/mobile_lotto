// To parse this JSON data, do
//
//     final registerRespone = registerResponeFromJson(jsonString);

import 'dart:convert';

RegisterRespone registerResponeFromJson(String str) =>
    RegisterRespone.fromJson(json.decode(str));

String registerResponeToJson(RegisterRespone data) =>
    json.encode(data.toJson());

class RegisterRespone {
  int uid;
  String fullName;
  String email;
  String bankName;
  String bankNumber;

  RegisterRespone({
    required this.uid,
    required this.fullName,
    required this.email,
    required this.bankName,
    required this.bankNumber,
  });

  factory RegisterRespone.fromJson(Map<String, dynamic> json) =>
      RegisterRespone(
        uid: json["uid"],
        fullName: json["fullName"],
        email: json["email"],
        bankName: json["bankName"],
        bankNumber: json["bankNumber"],
      );

  Map<String, dynamic> toJson() => {
    "uid": uid,
    "fullName": fullName,
    "email": email,
    "bankName": bankName,
    "bankNumber": bankNumber,
  };
}
