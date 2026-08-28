import 'package:bdo_event/core/model/event_model/event_model.dart';
import 'package:bdo_event/core/prefs/local_auth_store.dart';

class RegistrationService {
  RegistrationService(this._store);

  final LocalAuthStore _store;

  Future<List<Event>> load(String userId) => _store.loadRegistrations(userId);

  Future<RegistrationOperationResult> register(
    String userId,
    Event event,
  ) async {
    if (!event.isAvailable) {
      return const RegistrationOperationResult(
        [],
        'This event is no longer available for registration',
      );
    }
    if (event.capacity != null && event.attendeeCount >= event.capacity!) {
      return const RegistrationOperationResult(
        [],
        'This event has reached its capacity',
      );
    }

    final events = await _store.loadRegistrations(userId);
    if (events.any((registered) => registered.id == event.id)) {
      return const RegistrationOperationResult(
        [],
        'You are already registered for this event',
      );
    }

    events.add(event);
    try {
      await _store.writeRegistrations(userId, events);
    } on LocalStorageException {
      return const RegistrationOperationResult(
        [],
        'Unable to save the registration',
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
        'Unable to cancel the registration',
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
