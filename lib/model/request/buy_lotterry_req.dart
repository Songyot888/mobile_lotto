// To parse this JSON data, do
//
//     final buyLotterryReq = buyLotterryReqFromJson(jsonString);

import 'dart:convert';

BuyLotterryReq buyLotterryReqFromJson(String str) =>
    BuyLotterryReq.fromJson(json.decode(str));

String buyLotterryReqToJson(BuyLotterryReq data) => json.encode(data.toJson());

class BuyLotterryReq {
  int memberId;
  int lotteryId;

  BuyLotterryReq({required this.memberId, required this.lotteryId});

  factory BuyLotterryReq.fromJson(Map<String, dynamic> json) =>
      BuyLotterryReq(memberId: json["memberId"], lotteryId: json["lotteryId"]);

  Map<String, dynamic> toJson() => {
    "memberId": memberId,
    "lotteryId": lotteryId,
  };
}
