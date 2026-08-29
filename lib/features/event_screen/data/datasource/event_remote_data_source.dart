import 'package:bdo_event/core/model/event_model/event_model.dart';
import 'package:bdo_event/core/model/user_model/user_model.dart';
import 'package:bdo_event/core/prefs/supabase_store.dart';
import 'package:bdo_event/features/event_screen/domain/entities/event_operation_result.dart';
abstract interface class EventDataSource {
  Future<List<Event>> loadEvents();
  Future<EventOperationResult> create(Event event, User user);
  Future<EventOperationResult> update(Event event);
  Future<EventOperationResult> delete(Event event);
}

class EventRemoteDataSource implements EventDataSource {
  EventRemoteDataSource(this._store);

  final EventStore _store;

  @override
  Future<List<Event>> loadEvents() => _store.readCreatedEvents();

  Future<List<Event>> load() => loadEvents();

  @override
  Future<EventOperationResult> create(Event event, User user) async {
    final created = event.copyWith(
      creatorId: user.id,
      organizerName: user.displayName,
    );
    try {
      await _store.createEvent(created);
    } on LocalStorageException {
      return const EventOperationResult([], 'Unable to save the event');
    }
    return EventOperationResult(await loadEvents());
  }

  @override
  Future<EventOperationResult> update(Event event) async {
    final events = await _store.readCreatedEvents();
    final index = events.indexWhere((created) => created.id == event.id);
    if (index == -1) {
      return const EventOperationResult([], 'Event could not be found');
    }

    final existing = events[index];
    events[index] = Event(
      id: event.id,
      title: event.title,
      date: event.date,
      location: event.location,
      locationId: event.locationId,
      locationAddress: event.locationAddress,
      latitude: event.latitude,
      longitude: event.longitude,
      imageUrl: event.imageUrl,
      description: event.description,
      isAvailable: event.isAvailable,
      attendeeCount: event.attendeeCount,
      capacity: event.capacity,
      organizerName: existing.organizerName,
      creatorId: existing.creatorId,
      createdAt: existing.createdAt,
      catagory: event.catagory,
    );
    try {
      await _store.updateEvent(events[index]);
    } on LocalStorageException {
      return const EventOperationResult([], 'Unable to update the event');
    }
    return EventOperationResult(await loadEvents());
  }

  @override
  Future<EventOperationResult> delete(Event event) async {
    final events = await _store.readCreatedEvents();
    events.removeWhere((created) => created.id == event.id);
    try {
      await _store.deleteEvent(event.id);
    } on LocalStorageException {
      return const EventOperationResult([], 'Unable to delete the event');
    }
    return EventOperationResult(await loadEvents());
  }
}
