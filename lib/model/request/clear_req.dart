// To parse this JSON data, do
//
//     final clearReq = clearReqFromJson(jsonString);

import 'dart:convert';

ClearReq clearReqFromJson(String str) => ClearReq.fromJson(json.decode(str));

String clearReqToJson(ClearReq data) => json.encode(data.toJson());

class ClearReq {
  int uid;

  ClearReq({required this.uid});

  factory ClearReq.fromJson(Map<String, dynamic> json) =>
      ClearReq(uid: json["uid"]);

  Map<String, dynamic> toJson() => {"uid": uid};
}
