// To parse this JSON data, do
//
//     final clearResPost = clearResPostFromJson(jsonString);

import 'dart:convert';

ClearResPost clearResPostFromJson(String str) =>
    ClearResPost.fromJson(json.decode(str));

String clearResPostToJson(ClearResPost data) => json.encode(data.toJson());

class ClearResPost {
  String message;

  ClearResPost({required this.message});

  factory ClearResPost.fromJson(Map<String, dynamic> json) =>
      ClearResPost(message: json["message"]);

  Map<String, dynamic> toJson() => {"message": message};
}
