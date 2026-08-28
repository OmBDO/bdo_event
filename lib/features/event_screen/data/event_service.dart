import 'package:bdo_event/core/model/event_model/event_model.dart';
import 'package:bdo_event/core/model/user_model/user_model.dart';
import 'package:bdo_event/core/prefs/local_auth_store.dart';

class EventService {
  EventService(this._store);

  final LocalAuthStore _store;

  Future<List<Event>> load() => _store.readCreatedEvents();

  Future<EventOperationResult> create(Event event, User user) async {
    final events = await _store.readCreatedEvents();
    events.add(
      event.copyWith(creatorId: user.id, organizerName: user.displayName),
    );
    try {
      await _store.writeCreatedEvents(events);
    } on LocalStorageException {
      return const EventOperationResult([], 'Unable to save the event');
    }
    return EventOperationResult(events);
  }

  Future<EventOperationResult> update(Event event) async {
    final events = await _store.readCreatedEvents();
    final index = events.indexWhere((created) => created.id == event.id);
    if (index == -1) {
      return const EventOperationResult([], 'Event could not be found');
    }

    final existing = events[index];
    events[index] = event.copyWith(
      creatorId: existing.creatorId,
      organizerName: existing.organizerName,
      createdAt: existing.createdAt,
    );
    try {
      await _store.writeCreatedEvents(events);
    } on LocalStorageException {
      return const EventOperationResult([], 'Unable to update the event');
    }
    return EventOperationResult(events);
  }

  Future<EventOperationResult> delete(Event event) async {
    final events = await _store.readCreatedEvents();
    events.removeWhere((created) => created.id == event.id);
    try {
      await _store.writeCreatedEvents(events);
    } on LocalStorageException {
      return const EventOperationResult([], 'Unable to delete the event');
    }
    return EventOperationResult(events);
  }
}

class EventOperationResult {
  final List<Event> events;
  final String? error;

  const EventOperationResult(this.events, [this.error]);
}
