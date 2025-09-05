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

  User({required this.uid, required this.fullName, required this.email});

  factory User.fromJson(Map<String, dynamic> json) =>
      User(uid: json["uid"], fullName: json["fullName"], email: json["email"]);

  Map<String, dynamic> toJson() => {
    "uid": uid,
    "fullName": fullName,
    "email": email,
  };
}
