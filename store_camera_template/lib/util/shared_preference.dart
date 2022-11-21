import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart' as sp;

abstract class SharedPreference {
  String get key;
}

extension SharedPreferenceExtension on SharedPreference {
  Future<bool> set(dynamic value) async {
    sp.SharedPreferences prefs = await sp.SharedPreferences.getInstance();
    bool result = false;

    if (value is int) {
      result = await prefs.setInt(key, value);
    } else if (value is double) {
      result = await prefs.setDouble(key, value);
    } else if (value is String) {
      result = await prefs.setString(key, value);
    } else if (value is bool) {
      result = await prefs.setBool(key, value);
    } else if (value is Map) {
      result = await prefs.setString(key, json.encode(value));
    } else if (value is List<String>) {
      result = await prefs.setStringList(key, value);
    }
    return result;
  }

  Future<T> getOrDefault<T>(T value) async {
    return (await get<T>()) ?? value;
  }

  Future<T?> get<T>() async {
    sp.SharedPreferences prefs = await sp.SharedPreferences.getInstance();
    dynamic value = prefs.get(key);
    if (value == null) {
      return null;
    }
    try {
      switch (T) {
        case int:
        case double:
        case String:
        case bool:
          return value as T;
        case Map:
          final String? mapString = value is String ? value : null;
          if (mapString != null) {
            final map = json.decode(mapString);
            if (map is Map) {
              return map as T;
            }
          }
          return null;
      }
    } catch (_) {}

    return null;
  }

  Future<List<String>?> getStringList() async {
    sp.SharedPreferences prefs = await sp.SharedPreferences.getInstance();
    return prefs.getStringList(key);
  }

  Future<bool> remove() async {
    sp.SharedPreferences prefs = await sp.SharedPreferences.getInstance();
    return await prefs.remove(key);
  }
}
