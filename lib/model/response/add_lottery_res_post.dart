// To parse this JSON data, do
//
//     final addLotteryRespone = addLotteryResponeFromJson(jsonString);

import 'dart:convert';

AddLotteryRespone addLotteryResponeFromJson(String str) =>
    AddLotteryRespone.fromJson(json.decode(str));

String addLotteryResponeToJson(AddLotteryRespone data) =>
    json.encode(data.toJson());

class AddLotteryRespone {
  String message;
  List<Lotto> lotto;

  AddLotteryRespone({required this.message, required this.lotto});

  factory AddLotteryRespone.fromJson(Map<String, dynamic> json) =>
      AddLotteryRespone(
        message: json["message"],
        lotto: List<Lotto>.from(json["lotto"].map((x) => Lotto.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
    "message": message,
    "lotto": List<dynamic>.from(lotto.map((x) => x.toJson())),
  };
}

class Lotto {
  int lid;
  String number;
  int price;
  int total;
  DateTime endDate;

  Lotto({
    required this.lid,
    required this.number,
    required this.price,
    required this.total,
    required this.endDate,
  });

  factory Lotto.fromJson(Map<String, dynamic> json) => Lotto(
    lid: json["lid"],
    number: json["number"],
    price: json["price"],
    total: json["total"],
    endDate: DateTime.parse(json["endDate"]),
  );

  Map<String, dynamic> toJson() => {
    "lid": lid,
    "number": number,
    "price": price,
    "total": total,
    "endDate":
        "${endDate.year.toString().padLeft(4, '0')}-${endDate.month.toString().padLeft(2, '0')}-${endDate.day.toString().padLeft(2, '0')}",
  };
}
