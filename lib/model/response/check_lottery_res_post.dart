// To parse this JSON data, do
//
//     final checkLotteryResPost = checkLotteryResPostFromJson(jsonString);

import 'dart:convert';

CheckLotteryResPost checkLotteryResPostFromJson(String str) =>
    CheckLotteryResPost.fromJson(json.decode(str));

String checkLotteryResPostToJson(CheckLotteryResPost data) =>
    json.encode(data.toJson());

class CheckLotteryResPost {
  String message;
  int lotteryId;
  String number;
  int prize;
  String status;

  CheckLotteryResPost({
    required this.message,
    required this.lotteryId,
    required this.number,
    required this.prize,
    required this.status,
  });

  factory CheckLotteryResPost.fromJson(Map<String, dynamic> json) =>
      CheckLotteryResPost(
        message: json["message"],
        lotteryId: json["lotteryId"],
        number: json["number"],
        prize: json["prize"],
        status: json["status"],
      );

  Map<String, dynamic> toJson() => {
    "message": message,
    "lotteryId": lotteryId,
    "number": number,
    "prize": prize,
    "status": status,
  };
}
