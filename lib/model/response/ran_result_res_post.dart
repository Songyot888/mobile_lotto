// To parse this JSON data, do
//
//     final ranResultResPost = ranResultResPostFromJson(jsonString);

import 'dart:convert';

RanResultResPost ranResultResPostFromJson(String str) =>
    RanResultResPost.fromJson(json.decode(str));

String ranResultResPostToJson(RanResultResPost data) =>
    json.encode(data.toJson());

class RanResultResPost {
  String message;
  Prizes prizes;

  RanResultResPost({required this.message, required this.prizes});

  factory RanResultResPost.fromJson(Map<String, dynamic> json) =>
      RanResultResPost(
        message: json["message"],
        prizes: Prizes.fromJson(json["prizes"]),
      );

  Map<String, dynamic> toJson() => {
    "message": message,
    "prizes": prizes.toJson(),
  };
}

class Prizes {
  First first;
  First second;
  First third;
  Last3 last3;
  Last2 last2;

  Prizes({
    required this.first,
    required this.second,
    required this.third,
    required this.last3,
    required this.last2,
  });

  factory Prizes.fromJson(Map<String, dynamic> json) => Prizes(
    first: First.fromJson(json["first"]),
    second: First.fromJson(json["second"]),
    third: First.fromJson(json["third"]),
    last3: Last3.fromJson(json["last3"]),
    last2: Last2.fromJson(json["last2"]),
  );

  Map<String, dynamic> toJson() => {
    "first": first.toJson(),
    "second": second.toJson(),
    "third": third.toJson(),
    "last3": last3.toJson(),
    "last2": last2.toJson(),
  };
}

class First {
  String result;
  String number;
  num payout;

  First({required this.result, required this.number, required this.payout});

  factory First.fromJson(Map<String, dynamic> json) => First(
    result: json["result"],
    number: json["number"],
    payout: json["payout"],
  );

  Map<String, dynamic> toJson() => {
    "result": result,
    "number": number,
    "payout": payout,
  };
}

class Last2 {
  String result;
  String last2;
  num payoutEach;

  Last2({required this.result, required this.last2, required this.payoutEach});

  factory Last2.fromJson(Map<String, dynamic> json) => Last2(
    result: json["result"],
    last2: json["last2"],
    payoutEach: json["payoutEach"],
  );

  Map<String, dynamic> toJson() => {
    "result": result,
    "last2": last2,
    "payoutEach": payoutEach,
  };
}

class Last3 {
  String result;
  String last3;
  num payoutEach;

  Last3({required this.result, required this.last3, required this.payoutEach});

  factory Last3.fromJson(Map<String, dynamic> json) => Last3(
    result: json["result"],
    last3: json["last3"],
    payoutEach: json["payoutEach"],
  );

  Map<String, dynamic> toJson() => {
    "result": result,
    "last3": last3,
    "payoutEach": payoutEach,
  };
}
