// To parse this JSON data, do
//
//     final buyLotteryResPost = buyLotteryResPostFromJson(jsonString);

import 'dart:convert';

BuyLotteryResPost buyLotteryResPostFromJson(String str) =>
    BuyLotteryResPost.fromJson(json.decode(str));

String buyLotteryResPostToJson(BuyLotteryResPost data) =>
    json.encode(data.toJson());

class BuyLotteryResPost {
  String message;
  int orderId;
  int lotteryId;
  String number;
  int price;
  int wallet;

  BuyLotteryResPost({
    required this.message,
    required this.orderId,
    required this.lotteryId,
    required this.number,
    required this.price,
    required this.wallet,
  });

  factory BuyLotteryResPost.fromJson(Map<String, dynamic> json) =>
      BuyLotteryResPost(
        message: json["message"],
        orderId: json["orderId"],
        lotteryId: json["lotteryId"],
        number: json["number"],
        price: json["price"],
        wallet: json["wallet"],
      );

  Map<String, dynamic> toJson() => {
    "message": message,
    "orderId": orderId,
    "lotteryId": lotteryId,
    "number": number,
    "price": price,
    "wallet": wallet,
  };
}
