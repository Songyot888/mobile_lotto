// To parse this JSON data, do
//
//     final registerRespone = registerResponeFromJson(jsonString);

import 'dart:convert';

RegisterRespone registerResponeFromJson(String str) =>
    RegisterRespone.fromJson(json.decode(str));

String registerResponeToJson(RegisterRespone data) =>
    json.encode(data.toJson());

class RegisterRespone {
  String fullName;
  String phone;
  String email;
  int balance;
  String bankName;
  String bankNumber;
  String password;

  RegisterRespone({
    required this.fullName,
    required this.phone,
    required this.email,
    required this.balance,
    required this.bankName,
    required this.bankNumber,
    required this.password,
  });

  factory RegisterRespone.fromJson(Map<String, dynamic> json) =>
      RegisterRespone(
        fullName: json["fullName"],
        phone: json["phone"],
        email: json["email"],
        balance: json["balance"],
        bankName: json["bankName"],
        bankNumber: json["bankNumber"],
        password: json["password"],
      );

  Map<String, dynamic> toJson() => {
    "fullName": fullName,
    "phone": phone,
    "email": email,
    "balance": balance,
    "bankName": bankName,
    "bankNumber": bankNumber,
    "password": password,
  };
}
