// To parse this JSON data, do
//
//     final myLottoryRes = myLottoryResFromJson(jsonString);

import 'dart:convert';

List<MyLottoryRes> myLottoryResFromJson(String str) => List<MyLottoryRes>.from(
  json.decode(str).map((x) => MyLottoryRes.fromJson(x)),
);

String myLottoryResToJson(List<MyLottoryRes> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class MyLottoryRes {
  int oid;
  int lotteryId;
  String number;
  bool? status;

  MyLottoryRes({
    required this.oid,
    required this.lotteryId,
    required this.number,
    required this.status,
  });

  factory MyLottoryRes.fromJson(Map<String, dynamic> json) => MyLottoryRes(
    oid: json["oid"],
    lotteryId: json["lotteryId"],
    number: json["number"],
    status: json["status"],
  );

  Map<String, dynamic> toJson() => {
    "oid": oid,
    "lotteryId": lotteryId,
    "number": number,
    "status": status,
  };
}
