// To parse this JSON data, do
//
//     final withdrawReq = withdrawReqFromJson(jsonString);

import 'dart:convert';

WithdrawReq withdrawReqFromJson(String str) =>
    WithdrawReq.fromJson(json.decode(str));

String withdrawReqToJson(WithdrawReq data) => json.encode(data.toJson());

class WithdrawReq {
  int memberId;
  int money;

  WithdrawReq({required this.memberId, required this.money});

  factory WithdrawReq.fromJson(Map<String, dynamic> json) =>
      WithdrawReq(memberId: json["memberId"], money: json["money"]);

  Map<String, dynamic> toJson() => {"memberId": memberId, "money": money};
}
