import 'package:bdo_event/core/model/event_model/event_model.dart';
import 'package:bdo_event/core/prefs/supabase_store.dart';
import 'package:bdo_event/core/util/event.resource.dart';

class RegistrationService {
  RegistrationService(this._store);

  final EventStore _store;

  Future<List<Event>> load(String userId) => _store.loadRegistrations(userId);

  Future<RegistrationOperationResult> register(
    String userId,
    Event event,
  ) async {
    if (!event.isAvailable) {
      return const RegistrationOperationResult(
        [],
        AppText.eventNoLongerAvailable,
      );
    }
    if (event.capacity != null && event.attendeeCount >= event.capacity!) {
      return const RegistrationOperationResult(
        [],
        AppText.eventAtCapacity,
      );
    }

    final events = await _store.loadRegistrations(userId);
    if (events.any((registered) => registered.id == event.id)) {
      return const RegistrationOperationResult(
        [],
        AppText.alreadyRegistered,
      );
    }

    events.add(event);
    try {
      await _store.writeRegistrations(userId, events);
    } on LocalStorageException {
      return const RegistrationOperationResult(
        [],
        AppText.unableToSaveRegistration,
      );
    }
    return RegistrationOperationResult(events);
  }

  Future<RegistrationOperationResult> cancel(String userId, Event event) async {
    final events = await _store.loadRegistrations(userId);
    events.removeWhere((registered) => registered.id == event.id);
    try {
      await _store.writeRegistrations(userId, events);
    } on LocalStorageException {
      return const RegistrationOperationResult(
        [],
        AppText.unableToCancelRegistration,
      );
    }
    return RegistrationOperationResult(events);
  }
}

class RegistrationOperationResult {
  final List<Event> events;
  final String? error;

  const RegistrationOperationResult(this.events, [this.error]);
}
