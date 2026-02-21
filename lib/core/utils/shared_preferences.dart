import 'package:shared_preferences/shared_preferences.dart';


class LocalStorage {
  static const String current = 'current_location';
}

Future<T?> getValue<T>(String key, {T? defaultValue}) async {
  final prefs = await SharedPreferences.getInstance();

  if (T == String) return (prefs.getString(key) as T?) ?? defaultValue;
  if (T == int) return (prefs.getInt(key) as T?) ?? defaultValue;
  if (T == double) return (prefs.getDouble(key) as T?) ?? defaultValue;
  if (T == bool) return (prefs.getBool(key) as T?) ?? defaultValue;
  if (T == List<String>) {
    return (prefs.getStringList(key) as T?) ?? defaultValue;
  }

  // fallback: attempt to read as string and cast
  final raw = prefs.getString(key);
  return (raw as T?) ?? defaultValue;
}

Future<bool> setValue(String key, dynamic value) async {
  final prefs = await SharedPreferences.getInstance();

  if (value is String) return prefs.setString(key, value);
  if (value is int) return prefs.setInt(key, value);
  if (value is double) return prefs.setDouble(key, value);
  if (value is bool) return prefs.setBool(key, value);
  if (value is List<String>) return prefs.setStringList(key, value);

  return false;
}

Future<bool> removeValue(String key) async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.remove(key);
}
