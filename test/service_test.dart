import 'package:bdo_event/core/model/event_model/event_model.dart';
import 'package:bdo_event/core/model/user_model/user_model.dart';
import 'package:bdo_event/core/prefs/supabase_store.dart';
import 'package:bdo_event/features/calendar_screen/data/repositories/registration_service.dart';
import 'package:bdo_event/features/event_screen/data/datasource/event_remote_data_source.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late EventStore store;
  late Event event;

  setUp(() {
    store = InMemoryEventStore();
    event = const Event(
      id: 'event-1',
      title: 'Community Festival',
      date: '2026-09-01',
      location: 'Pune',
      imageUrl: '',
      capacity: 2,
    );
  });

  test('registration service rejects unavailable, full, and duplicate events', () async {
    final service = RegistrationService(store);

    final unavailable = await service.register(
      'user-1',
      event.copyWith(isAvailable: false),
    );
    expect(unavailable.error, 'This event is no longer available for registration');

    final full = await service.register(
      'user-1',
      event.copyWith(attendeeCount: 2),
    );
    expect(full.error, 'This event has reached its capacity');

    final first = await service.register('user-1', event);
    expect(first.error, isNull);
    expect(first.events, hasLength(1));

    final duplicate = await service.register('user-1', event);
    expect(duplicate.error, 'You are already registered for this event');
  });

  test('registration service cancels a registered event', () async {
    final service = RegistrationService(store);
    await service.register('user-1', event);

    final result = await service.cancel('user-1', event);

    expect(result.error, isNull);
    expect(result.events, isEmpty);
    expect(await service.load('user-1'), isEmpty);
  });

  test('event service preserves ownership metadata during updates', () async {
    final service = EventRemoteDataSource(store);
    final admin = User(
      id: 'admin-1',
      displayName: 'Admin',
      email: 'admin@example.com',
      roles: {UserRole.admin},
      createdAt: DateTime(2026),
    );

    final created = await service.create(event, admin);
    final updated = await service.update(
      event.copyWith(title: 'Updated Festival'),
    );

    expect(created.error, isNull);
    expect(updated.error, isNull);
    expect(updated.events.single.title, 'Updated Festival');
    expect(updated.events.single.creatorId, 'admin-1');
    expect(updated.events.single.organizerName, 'Admin');
  });

  test('event service reports updates for missing events', () async {
    final result = await EventRemoteDataSource(store).update(event);

    expect(result.events, isEmpty);
    expect(result.error, 'Event could not be found');
  });

}

class InMemoryEventStore implements EventStore {
  final List<Event> createdEvents = [];
  final Map<String, List<Event>> registrations = {};

  @override
  Future<List<Event>> readCreatedEvents() async => [...createdEvents];

  @override
  Future<void> createEvent(Event event) async {
    createdEvents.add(event);
  }

  @override
  Future<void> updateEvent(Event event) async {
    final index = createdEvents.indexWhere((created) => created.id == event.id);
    if (index >= 0) createdEvents[index] = event;
  }

  @override
  Future<void> deleteEvent(String eventId) async {
    createdEvents.removeWhere((event) => event.id == eventId);
  }

  @override
  Future<List<Event>> loadRegistrations(String userId) async => [
    ...(registrations[userId] ?? const <Event>[]),
  ];

  @override
  Future<void> writeRegistrations(String userId, List<Event> events) async {
    registrations[userId] = [...events];
  }

  @override
  Future<void> activateRegistration(String userId, Event event) async {
    final userEvents = registrations.putIfAbsent(userId, () => []);
    if (!userEvents.any((registered) => registered.id == event.id)) {
      userEvents.add(event);
    }
  }

  @override
  Future<void> revokeRegistration(String userId, String eventId) async {
    registrations[userId]?.removeWhere((event) => event.id == eventId);
  }

  @override
  Future<String?> loadRegistrationToken(String userId, String eventId) async =>
      null;

  @override
  Future<Map<String, dynamic>?> validateRegistration({
    required String token,
    required String eventId,
  }) async => null;

  @override
  Future<String> checkInRegistration({
    required String token,
    required String eventId,
  }) async => 'invalid';

  @override
  Future<int> loadAttendanceCount(String eventId) async => 0;
}
