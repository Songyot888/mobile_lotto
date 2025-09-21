// To parse this JSON data, do
//
//     final historyBuyResPost = historyBuyResPostFromJson(jsonString);

import 'dart:convert';

List<HistoryBuyResPost> historyBuyResPostFromJson(String str) =>
    List<HistoryBuyResPost>.from(
      json.decode(str).map((x) => HistoryBuyResPost.fromJson(x)),
    );

String historyBuyResPostToJson(List<HistoryBuyResPost> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class HistoryBuyResPost {
  int oid;
  int lotteryId;
  String number;
  DateTime dateIso;
  String dateTh;

  HistoryBuyResPost({
    required this.oid,
    required this.lotteryId,
    required this.number,
    required this.dateIso,
    required this.dateTh,
  });

  factory HistoryBuyResPost.fromJson(Map<String, dynamic> json) =>
      HistoryBuyResPost(
        oid: json["oid"],
        lotteryId: json["lotteryId"],
        number: json["number"],
        dateIso: DateTime.parse(json["dateIso"]),
        dateTh: json["dateTh"],
      );

  Map<String, dynamic> toJson() => {
    "oid": oid,
    "lotteryId": lotteryId,
    "number": number,
    "dateIso": dateIso.toIso8601String(),
    "dateTh": dateTh,
  };
}
