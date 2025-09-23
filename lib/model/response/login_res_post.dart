// To parse this JSON data, do
//
//     final loginRespone = loginResponeFromJson(jsonString);

import 'dart:convert';

LoginRespone loginResponeFromJson(String str) =>
    LoginRespone.fromJson(json.decode(str));

String loginResponeToJson(LoginRespone data) => json.encode(data.toJson());

class LoginRespone {
  String message;
  User user;

  LoginRespone({required this.message, required this.user});

  factory LoginRespone.fromJson(Map<String, dynamic> json) =>
      LoginRespone(message: json["message"], user: User.fromJson(json["user"]));

  Map<String, dynamic> toJson() => {"message": message, "user": user.toJson()};
}

class User {
  int uid;
  String fullName;
  String email;
  double balance;
  String phone;
  String bankName;
  String bankNumber;
  String role;

  User({
    required this.uid,
    required this.fullName,
    required this.email,
    required this.balance,
    required this.phone,
    required this.bankName,
    required this.bankNumber,
    required this.role,
  });

  factory User.fromJson(Map<String, dynamic> json) => User(
    uid: json["uid"],
    fullName: json["fullName"],
    email: json["email"],
    balance: (json["balance"] is int)
        ? (json["balance"] as int).toDouble()
        : (json["balance"] as num).toDouble(),
    phone: json["phone"],
    bankName: json["bankName"],
    bankNumber: json["bankNumber"],
    role: json["role"],
  );

  Map<String, dynamic> toJson() => {
    "uid": uid,
    "fullName": fullName,
    "email": email,
    "balance": balance,
    "phone": phone,
    "bankName": bankName,
    "bankNumber": bankNumber,
    "role": role,
  };
}
