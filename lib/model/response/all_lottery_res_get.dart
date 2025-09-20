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
  int price;
  int total;
  String date;
  DateTime startDate;
  DateTime endDate;

  AllLotteryResGet({
    required this.lid,
    required this.number,
    required this.price,
    required this.total,
    required this.date,
    required this.startDate,
    required this.endDate,
  });

  factory AllLotteryResGet.fromJson(Map<String, dynamic> json) =>
      AllLotteryResGet(
        lid: (json["lid"] as num).toInt(),
        number: json["number"].toString(),
        price: (json["price"] as num).toInt(),
        total: (json["total"] as num).toInt(),
        date: json["date"].toString(),
        startDate: DateTime.parse(json["startDate"].toString()),
        endDate: DateTime.parse(json["endDate"].toString()),
      );

  Map<String, dynamic> toJson() => {
    "lid": lid,
    "number": number,
    "price": price,
    "total": total,
    "date": date,
    "startDate":
        "${startDate.year.toString().padLeft(4, '0')}-${startDate.month.toString().padLeft(2, '0')}-${startDate.day.toString().padLeft(2, '0')}",
    "endDate":
        "${endDate.year.toString().padLeft(4, '0')}-${endDate.month.toString().padLeft(2, '0')}-${endDate.day.toString().padLeft(2, '0')}",
  };
}
