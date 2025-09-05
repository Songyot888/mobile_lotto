import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mobile_lotto/model/response/login_res_post.dart'; // ที่มี User

class Session {
  static const _kUid = 'uid';
  static const _kUserJson = 'user_json';

  static Future<void> saveUser(User user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_kUid, user.uid);
    await prefs.setString(_kUserJson, jsonEncode(user.toJson()));
  }

  static Future<User?> getUser() async {
    final prefs = await SharedPreferences.getInstance();
    final s = prefs.getString(_kUserJson);
    if (s == null) return null;
    return User.fromJson(jsonDecode(s));
  }

  static Future<int?> getUid() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_kUid);
  }


  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_kUid);
    await prefs.remove(_kUserJson);
  }
}
