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
  // สถานะผลรางวัล (true = ไม่ถูกรางวัล, false = ถูกรางวัล, null = ยังไม่ทราบ/ยังไม่ขึ้นเงิน)
  bool? status;

  HistoryBuyResPost({
    this.oid, // ไม่บังคับ
    this.lotteryId, // ไม่บังคับ
    this.number, // ไม่บังคับ
    this.dateIso, // ไม่บังคับ
    this.dateTh, // ไม่บังคับ
    this.status,
  });

  factory HistoryBuyResPost.fromJson(
    Map<String, dynamic> json,
  ) => HistoryBuyResPost(
    oid: json["oid"],
    lotteryId: json["lotteryId"],
    number: json["number"],
    // ปรับให้รองรับ null และ invalid date format
    dateIso: json["dateIso"] != null ? _parseDateTime(json["dateIso"]) : null,
    dateTh: json["dateTh"],
    // พยายาม map ค่าจาก key ต่าง ๆ มาสู่สถานะ boolean ตามสัญญะข้างต้น
    status: () {
      final dynamic v = json['status'] ?? json['result'] ?? json['win'];
      if (v == null) return null;
      if (v is bool) return v; // สมมติ true = ไม่ถูกรางวัล, false = ถูกรางวัล
      final s = v.toString().toLowerCase().trim();
      if (s == 'true' ||
          s == 'lose' ||
          s == 'lost' ||
          s == 'notwin' ||
          s == 'fail') {
        return true; // ไม่ถูกรางวัล
      }
      if (s == 'false' || s == 'win' || s == 'won') {
        return false; // ถูกรางวัล
      }
      return null; // แปลงไม่ได้ → ไม่ทราบผล
    }(),
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
    "status": status,
  };
}
