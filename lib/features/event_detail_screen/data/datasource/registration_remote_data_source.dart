import 'package:bdo_event/core/model/event_model/event_model.dart';
import 'package:bdo_event/core/prefs/supabase_store.dart';

abstract interface class RegistrationDataSource {
  Future<List<Event>> load(String userId);
  Future<void> save(String userId, List<Event> events);
}

class RegistrationRemoteDataSource implements RegistrationDataSource {
  RegistrationRemoteDataSource(this._store);

  final EventStore _store;

  @override
  Future<List<Event>> load(String userId) => _store.loadRegistrations(userId);

  @override
  Future<void> save(String userId, List<Event> events) =>
      _store.writeRegistrations(userId, events);
}
