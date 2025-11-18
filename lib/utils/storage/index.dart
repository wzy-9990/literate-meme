// lib/utils/storage.dart
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class StorageKeys {
  static const String token = 'token';
  static const String userInfo = 'userInfo';
}

class Storage {
  // 存储字符串
  static Future<void> setString(String key, String value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(key, value);
  }

  // 获取字符串
  static Future<String?> getString(String key) async {
    final prefs = await SharedPreferences.getInstance();

    return prefs.getString(key);
  }

  // 存储列表
  static Future<void> setListMap(
      String key, List<Map<String, dynamic>> list) async {
    final jsonString = jsonEncode(list);
    await setString(key, jsonString);
  }

  // 获取列表
  static Future<List<Map<String, dynamic>>> getListMap(String key) async {
    final jsonString = await getString(key);
    if (jsonString == null || jsonString.isEmpty) {
      return [];
    }
    final List<dynamic> jsonList = jsonDecode(jsonString);
    return jsonList.map((item) => item as Map<String, dynamic>).toList();
  }

  // 存储对象
  static Future<void> setMap(String key, Map<String, dynamic> data) async {
    final jsonString = jsonEncode(data);
    await setString(key, jsonString);
  }

  // 获取对象
  static Future<Map<String, dynamic>?> getMap(String key) async {
    final jsonString = await getString(key);
    if (jsonString == null || jsonString.isEmpty) {
      return {};
    }
    return jsonDecode(jsonString) as Map<String, dynamic>;
  }

  // 删除
  static Future<void> remove(String key) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(key);
  }

  // 清空
  static Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}
