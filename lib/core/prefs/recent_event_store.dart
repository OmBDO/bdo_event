import 'package:bdo_event/core/model/event_model/event_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RecentEventStore {
  RecentEventStore(this._preferences);

  static const _maxItems = 8;

  final SharedPreferences? _preferences;

  List<String> readIds({String? userId}) =>
      _preferences?.getStringList(_keyFor(userId)) ?? const [];

  Future<void> record(Event event, {String? userId}) async {
    if (_preferences == null) return;
    final key = _keyFor(userId);
    final ids = <String>[
      event.id,
      ...readIds(userId: userId).where((id) => id != event.id),
    ];
    await _preferences.setStringList(key, ids.take(_maxItems).toList());
  }

  String _keyFor(String? userId) => 'recent_event_ids_${userId ?? 'anonymous'}';
}
