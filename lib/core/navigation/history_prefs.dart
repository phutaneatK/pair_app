import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

const _kCoveHistoryKey = 'cove_nav_history_v1';

class HistoryPrefs {
  /// Save history list to SharedPreferences as JSON array of strings.
  static Future<void> save(List<String> history) async {
    final prefs = await SharedPreferences.getInstance();
    try {
      await prefs.setString(_kCoveHistoryKey, jsonEncode(history));
    } catch (_) {}
  }

  /// Load history list from SharedPreferences. Returns empty list if none.
  static Future<List<String>> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_kCoveHistoryKey);
    if (raw == null || raw.isEmpty) return <String>[];
    try {
      final decoded = jsonDecode(raw);
      if (decoded is List) return decoded.map((e) => e?.toString() ?? '').toList();
    } catch (_) {}
    return <String>[];
  }

  /// Clear persisted history
  static Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_kCoveHistoryKey);
  }
}
