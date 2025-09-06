// To parse this JSON data, do
//
//     final addLotteryRequest = addLotteryRequestFromJson(jsonString);

import 'dart:convert';

AddLotteryRequest addLotteryRequestFromJson(String str) =>
    AddLotteryRequest.fromJson(json.decode(str));

String addLotteryRequestToJson(AddLotteryRequest data) =>
    json.encode(data.toJson());

class AddLotteryRequest {
  String role;
  int number;

  AddLotteryRequest({required this.role, required this.number});

  factory AddLotteryRequest.fromJson(Map<String, dynamic> json) =>
      AddLotteryRequest(role: json["role"], number: json["number"]);

  Map<String, dynamic> toJson() => {"role": role, "number": number};
}
