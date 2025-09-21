// To parse this JSON data, do
//
//     final allLotteryResGet = allLotteryResGetFromJson(jsonString);

import 'dart:convert';

List<AllLotteryResGet> allLotteryResGetFromJson(String str) =>
    List<AllLotteryResGet>.from(
      json.decode(str).map((x) => AllLotteryResGet.fromJson(x)),
    );

String allLotteryResGetToJson(List<AllLotteryResGet> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class AllLotteryResGet {
  int lid;
  String number;
  num price;
  num total;
  DateTime date;
  DateTime startDate;
  DateTime endDate;
  bool status;

  AllLotteryResGet({
    required this.lid,
    required this.number,
    required this.price,
    required this.total,
    required this.date,
    required this.startDate,
    required this.endDate,
    required this.status,
  });

  factory AllLotteryResGet.fromJson(Map<String, dynamic> json) =>
      AllLotteryResGet(
        lid: json["lid"],
        number: json["number"],
        price: json["price"],
        total: json["total"],
        date: DateTime.parse(json["date"]),
        startDate: DateTime.parse(json["startDate"]),
        endDate: DateTime.parse(json["endDate"]),
        status: json["status"],
      );

  Map<String, dynamic> toJson() => {
    "lid": lid,
    "number": number,
    "price": price,
    "total": total,
    "date": date.toIso8601String(),
    "startDate":
        "${startDate.year.toString().padLeft(4, '0')}-${startDate.month.toString().padLeft(2, '0')}-${startDate.day.toString().padLeft(2, '0')}",
    "endDate":
        "${endDate.year.toString().padLeft(4, '0')}-${endDate.month.toString().padLeft(2, '0')}-${endDate.day.toString().padLeft(2, '0')}",
    "status": status,
  };
}
