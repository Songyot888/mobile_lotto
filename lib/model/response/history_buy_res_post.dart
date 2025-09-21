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
  int? oid; // เปลี่ยนเป็น nullable
  int? lotteryId; // เปลี่ยนเป็น nullable
  String? number; // เปลี่ยนเป็น nullable
  DateTime? dateIso; // เปลี่ยนเป็น nullable
  String? dateTh; // เปลี่ยนเป็น nullable

  HistoryBuyResPost({
    this.oid, // ไม่บังคับ
    this.lotteryId, // ไม่บังคับ
    this.number, // ไม่บังคับ
    this.dateIso, // ไม่บังคับ
    this.dateTh, // ไม่บังคับ
  });

  factory HistoryBuyResPost.fromJson(Map<String, dynamic> json) =>
      HistoryBuyResPost(
        oid: json["oid"],
        lotteryId: json["lotteryId"],
        number: json["number"],
        // ปรับให้รองรับ null และ invalid date format
        dateIso: json["dateIso"] != null
            ? _parseDateTime(json["dateIso"])
            : null,
        dateTh: json["dateTh"],
      );

  // ฟังก์ชันช่วยในการ parse DateTime อย่างปลอดภัย
  static DateTime? _parseDateTime(dynamic dateValue) {
    if (dateValue == null) return null;

    try {
      if (dateValue is String) {
        return DateTime.parse(dateValue);
      } else if (dateValue is int) {
        // ถ้าเป็น timestamp
        return DateTime.fromMillisecondsSinceEpoch(dateValue);
      }
      return null;
    } catch (e) {
      // ถ้า parse ไม่ได้ ให้คืน null
      return null;
    }
  }

  Map<String, dynamic> toJson() => {
    "oid": oid,
    "lotteryId": lotteryId,
    "number": number,
    "dateIso": dateIso?.toIso8601String(),
    "dateTh": dateTh,
  };
}
