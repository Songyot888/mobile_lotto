// To parse this JSON data, do
//
//     final topupReq = topupReqFromJson(jsonString);

import 'dart:convert';

TopupReq topupReqFromJson(String str) => TopupReq.fromJson(json.decode(str));

String topupReqToJson(TopupReq data) => json.encode(data.toJson());

class TopupReq {
  int memberId;
  int money;

  TopupReq({required this.memberId, required this.money});

  factory TopupReq.fromJson(Map<String, dynamic> json) =>
      TopupReq(memberId: json["memberId"], money: json["money"]);

  Map<String, dynamic> toJson() => {"memberId": memberId, "money": money};
}
