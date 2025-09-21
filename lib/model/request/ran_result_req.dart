// To parse this JSON data, do
//
//     final ranResultReq = ranResultReqFromJson(jsonString);

import 'dart:convert';

RanResultReq ranResultReqFromJson(String str) =>
    RanResultReq.fromJson(json.decode(str));

String ranResultReqToJson(RanResultReq data) => json.encode(data.toJson());

class RanResultReq {
  int uid;

  RanResultReq({required this.uid});

  factory RanResultReq.fromJson(Map<String, dynamic> json) =>
      RanResultReq(uid: json["uid"]);

  Map<String, dynamic> toJson() => {"uid": uid};
}
