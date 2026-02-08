import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/hourly_entry.dart';

class LocalStorage {
  static const int maxDays = 7;

  /// 🧠 SAVE HOURLY ENTRIES ONLY
  static Future<void> saveEntries(
      String key, List<HourlyEntry> entries) async {
    final prefs = await SharedPreferences.getInstance();
    final data =
    entries.map((e) => jsonEncode(e.toJson())).toList();
    await prefs.setStringList(key, data);
    _cleanupOldData(prefs);
  }

  /// 🧠 LOAD HOURLY ENTRIES ONLY
  static Future<List<HourlyEntry>> loadEntries(String key) async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getStringList(key) ?? [];
    return data
        .map((e) => HourlyEntry.fromJson(jsonDecode(e)))
        .toList();
  }

  /// 🧠 SAVE A FULL SHIFT REPORT (entries + quality blocks)
  static Future<void> saveReport(
      String key, Map<String, dynamic> report) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = jsonEncode(report);
    await prefs.setString(key, jsonString);
    _cleanupOldData(prefs);
  }


  /// 🧠 LOAD A SAVED REPORT (as Map)
  static Future<Map<String, dynamic>?> loadReport(
      String key) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(key);
    if (jsonString == null) return null;
    return jsonDecode(jsonString);
  }

  static Future<SharedPreferences> getPrefsInstance() async {
    return await SharedPreferences.getInstance();
  }

  /// 🧹 Keep only last 7 days worth of keys
  static void _cleanupOldData(SharedPreferences prefs) {
    final keys = prefs.getKeys().toList();
    if (keys.length <= maxDays) return;
    keys.sort();
    for (int i = 0; i < keys.length - maxDays; i++) {
      prefs.remove(keys[i]);
    }
  }
}
