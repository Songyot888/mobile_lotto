// To parse this JSON data, do
//
//     final topupResPost = topupResPostFromJson(jsonString);

import 'dart:convert';

TopupResPost topupResPostFromJson(String str) =>
    TopupResPost.fromJson(json.decode(str));

String topupResPostToJson(TopupResPost data) => json.encode(data.toJson());

class TopupResPost {
  String message;
  int memberId;
  int amount;
  int wallet;

  TopupResPost({
    required this.message,
    required this.memberId,
    required this.amount,
    required this.wallet,
  });

  factory TopupResPost.fromJson(Map<String, dynamic> json) => TopupResPost(
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
