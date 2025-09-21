// To parse this JSON data, do
//
//     final withdrawResPost = withdrawResPostFromJson(jsonString);

import 'dart:convert';

WithdrawResPost withdrawResPostFromJson(String str) =>
    WithdrawResPost.fromJson(json.decode(str));

String withdrawResPostToJson(WithdrawResPost data) =>
    json.encode(data.toJson());

class WithdrawResPost {
  String message;
  int memberId;
  num amount;
  num wallet;

  WithdrawResPost({
    required this.message,
    required this.memberId,
    required this.amount,
    required this.wallet,
  });

  factory WithdrawResPost.fromJson(Map<String, dynamic> json) =>
      WithdrawResPost(
        message: json["message"],
        memberId: json["memberId"],
        amount: json["amount"],
        wallet: json["wallet"],
      );

  Map<String, dynamic> toJson() => {
    "message": message,
    "memberId": memberId,
    "amount": amount,
    "wallet": wallet,
  };
}
