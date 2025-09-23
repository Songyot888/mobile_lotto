import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mobile_lotto/model/response/login_res_post.dart';

class Session {
  static const _kUid = 'uid';
  static const _kUserJson = 'user_json';

  // NEW: central reactive user object
  static final ValueNotifier<User?> currentUser = ValueNotifier<User?>(null);

  /// โหลด user จาก SharedPreferences ไปไว้ใน memory (เรียกครั้งแรกตอนแอปเริ่ม)
  static Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    final s = prefs.getString(_kUserJson);
    if (s != null) {
      try {
        currentUser.value = User.fromJson(jsonDecode(s));
      } catch (_) {
        currentUser.value = null;
      }
    } else {
      currentUser.value = null;
    }
  }

  static Future<void> saveUser(User user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_kUid, user.uid);
    await prefs.setString(_kUserJson, jsonEncode(user.toJson()));
    // update in-memory and notify listeners
    currentUser.value = user;
  }

  static Future<User?> getUser() async {
    // prefer in-memory value
    if (currentUser.value != null) return currentUser.value;
    final prefs = await SharedPreferences.getInstance();
    final s = prefs.getString(_kUserJson);
    if (s == null) return null;
    try {
      final u = User.fromJson(jsonDecode(s));
      currentUser.value = u;
      return u;
    } catch (_) {
      return null;
    }
  }

  static Future<int?> getUid() async {
    if (currentUser.value?.uid != null) return currentUser.value!.uid;
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_kUid);
  }

  /// NEW: อัปเดตยอดเงินทั้งใน memory และ persistent storage แล้ว notify ทุก listener
  static Future<void> updateBalance(double newBalance) async {
    final u = currentUser.value;
    if (u == null) return;
    try {
      // User.balance ถูกใช้งานแบบ mutable ในโค้ดอื่น ๆ (เช่น _user!.balance = ...)
      (u as dynamic).balance = newBalance;
    } catch (_) {}
    await saveUser(u);
  }

  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_kUid);
    await prefs.remove(_kUserJson);
    currentUser.value = null;
  }
}
