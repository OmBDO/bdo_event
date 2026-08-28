import 'package:shared_preferences/shared_preferences.dart';

class LocalDatabase {
  static const _usersKey = 'sqlite_fallback_users';
  static const _eventsKey = 'sqlite_fallback_events';
  static const _registrationsPrefix = 'sqlite_fallback_registrations:';

  Future<SharedPreferences> get _preferences =>
      SharedPreferences.getInstance();

  Future<Map<String, String>> readUsers() async {
    return _readMap((await _preferences).getStringList(_usersKey));
  }

  Future<void> writeUsers(Map<String, String> records) async {
    await _writeMap(_usersKey, records);
  }

  Future<List<String>> readEvents() async {
    return (await _preferences).getStringList(_eventsKey) ?? [];
  }

  Future<void> writeEvents(Map<String, String> records) async {
    final preferences = await _preferences;
    if (!await preferences.setStringList(_eventsKey, records.values.toList())) {
      throw const LocalDatabaseException();
    }
  }

  Future<List<String>> readRegistrations(String userId) async {
    return (await _preferences).getStringList('$_registrationsPrefix$userId') ??
        [];
  }

  Future<void> writeRegistrations(
    String userId,
    Map<String, String> records,
  ) async {
    final preferences = await _preferences;
    if (!await preferences.setStringList(
      '$_registrationsPrefix$userId',
      records.values.toList(),
    )) {
      throw const LocalDatabaseException();
    }
  }

  Map<String, String> _readMap(List<String>? values) {
    if (values == null) return {};
    return {
      for (final value in values)
        if (value.contains('\n'))
          value.substring(0, value.indexOf('\n')):
              value.substring(value.indexOf('\n') + 1),
    };
  }

  Future<void> _writeMap(String key, Map<String, String> records) async {
    final preferences = await _preferences;
    final values = records.entries
        .map((entry) => '${entry.key}\n${entry.value}')
        .toList();
    if (!await preferences.setStringList(key, values)) {
      throw const LocalDatabaseException();
    }
  }
}

class LocalDatabaseException implements Exception {
  const LocalDatabaseException();
}
