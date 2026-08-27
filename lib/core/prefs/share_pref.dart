import 'package:shared_preferences/shared_preferences.dart';

class SharePref {
  SharePref._(this._preferences);

  static SharePref? _instance;
  final SharedPreferences _preferences;

  static Future<SharePref> get instance async {
    if (_instance != null) return _instance!;
    final preferences = await SharedPreferences.getInstance();
    return _instance = SharePref._(preferences);
  }

  String? readString(String key) => _preferences.getString(key);

  Future<bool> writeString(String key, String value) {
    return _preferences.setString(key, value);
  }

  bool readBool(String key, {bool defaultValue = false}) {
    return _preferences.getBool(key) ?? defaultValue;
  }

  Future<bool> writeBool(String key, bool value) {
    return _preferences.setBool(key, value);
  }

  Future<bool> remove(String key) {
    return _preferences.remove(key);
  }
}
