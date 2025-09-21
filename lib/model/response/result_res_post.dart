// To parse this JSON data, do
//
//     final resultResPost = resultResPostFromJson(jsonString);

import 'dart:convert';

ResultResPost resultResPostFromJson(String str) =>
    ResultResPost.fromJson(json.decode(str));

String resultResPostToJson(ResultResPost data) => json.encode(data.toJson());

class ResultResPost {
  String message;
  List<Result> result;

  ResultResPost({required this.message, required this.result});

  factory ResultResPost.fromJson(Map<String, dynamic> json) => ResultResPost(
    message: json["message"],
    result: List<Result>.from(json["result"].map((x) => Result.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "message": message,
    "result": List<dynamic>.from(result.map((x) => x.toJson())),
  };
}

class Result {
  int payoutRate;
  String amount;

  Result({required this.payoutRate, required this.amount});

  factory Result.fromJson(Map<String, dynamic> json) =>
      Result(payoutRate: json["payoutRate"], amount: json["amount"]);

  Map<String, dynamic> toJson() => {"payoutRate": payoutRate, "amount": amount};
}
