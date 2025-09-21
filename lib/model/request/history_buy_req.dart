// To parse this JSON data, do
//
//     final historyBuyReq = historyBuyReqFromJson(jsonString);

import 'dart:convert';

HistoryBuyReq historyBuyReqFromJson(String str) =>
    HistoryBuyReq.fromJson(json.decode(str));

String historyBuyReqToJson(HistoryBuyReq data) => json.encode(data.toJson());

class HistoryBuyReq {
  int memberId;

  HistoryBuyReq({required this.memberId});

  factory HistoryBuyReq.fromJson(Map<String, dynamic> json) =>
      HistoryBuyReq(memberId: json["memberId"]);

  Map<String, dynamic> toJson() => {"memberId": memberId};
}
