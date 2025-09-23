// To parse this JSON data, do
//
//     final winHistoryRes = winHistoryResFromJson(jsonString);

import 'dart:convert';

WinHistoryRes winHistoryResFromJson(String str) =>
    WinHistoryRes.fromJson(json.decode(str));

String winHistoryResToJson(WinHistoryRes data) => json.encode(data.toJson());

class WinHistoryRes {
  String message;
  List<WinningHistory> winningHistory;

  WinHistoryRes({required this.message, required this.winningHistory});

  factory WinHistoryRes.fromJson(Map<String, dynamic> json) => WinHistoryRes(
    message: json["message"],
    winningHistory: List<WinningHistory>.from(
      json["winningHistory"].map((x) => WinningHistory.fromJson(x)),
    ),
  );

  Map<String, dynamic> toJson() => {
    "message": message,
    "winningHistory": List<dynamic>.from(winningHistory.map((x) => x.toJson())),
  };
}

class WinningHistory {
  String number;
  String prize;
  double payout; // เปลี่ยนจาก int เป็น double
  String date;

  WinningHistory({
    required this.number,
    required this.prize,
    required this.payout,
    required this.date,
  });

  factory WinningHistory.fromJson(Map<String, dynamic> json) => WinningHistory(
    number: json["number"],
    prize: json["prize"],
    // แปลงเป็น double และรองรับทั้ง int, double และ string
    payout: _parseToDouble(json["payout"]),
    date: json["date"],
  );

  // Helper function สำหรับแปลงค่าเป็น double
  static double _parseToDouble(dynamic value) {
    if (value is double) {
      return value;
    } else if (value is int) {
      return value.toDouble();
    } else if (value is String) {
      return double.tryParse(value) ?? 0.0;
    } else {
      return 0.0;
    }
  }

  Map<String, dynamic> toJson() => {
    "number": number,
    "prize": prize,
    "payout": payout,
    "date": date,
  };
}
