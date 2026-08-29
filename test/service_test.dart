import 'package:bdo_event/core/model/event_model/event_model.dart';
import 'package:bdo_event/core/model/user_model/user_model.dart';
import 'package:bdo_event/core/model/user_model/event_attendee.dart';
import 'package:bdo_event/core/model/notification_model/notification_model.dart';
import 'package:bdo_event/core/prefs/supabase_store.dart';
import 'package:bdo_event/features/auth_screen/domain/repositories/auth_repository.dart';
import 'package:bdo_event/features/event_detail_screen/data/datasource/registration_remote_data_source.dart';
import 'package:bdo_event/features/event_detail_screen/data/repositories/registered_event_repository.dart';
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

  test('active registration repository enforces registration policy', () async {
    final repository = RegisteredEventRepository(
      dataSource: RegistrationRemoteDataSource(store),
      authRepository: FakeAuthRepository(),
    );

    final unavailable = await repository.registerEvent(
      event.copyWith(isAvailable: false),
    );
    expect(unavailable, 'This event is no longer available for registration');

    final full = await repository.registerEvent(
      event.copyWith(attendeeCount: 2),
    );
    expect(full, 'This event has reached its capacity');

    expect(await repository.registerEvent(event), isNull);
    expect(await repository.registerEvent(event), 'You are already registered for this event');
  });

  test('event JSON preserves an optional deadline as an instant', () {
    final deadline = DateTime(2026, 9, 1, 14, 30);
    final restored = Event.fromJson(
      event.copyWith(registrationDeadline: deadline).toJson(),
    );

    expect(restored.registrationDeadline, deadline.toUtc());
  });

  test('event JSON preserves event start and end times', () {
    final restored = Event.fromJson(
      event.copyWith(startTime: '09:30', endTime: '17:00').toJson(),
    );

    expect(restored.startTime, '09:30');
    expect(restored.endTime, '17:00');
  });

  test('active registration repository rejects a passed deadline', () async {
    final repository = RegisteredEventRepository(
      dataSource: RegistrationRemoteDataSource(store),
      authRepository: FakeAuthRepository(),
    );

    final error = await repository.registerEvent(
      event.copyWith(registrationDeadline: DateTime.now().subtract(const Duration(minutes: 1))),
    );

    expect(error, 'Registration for this event has closed');
  });

  test('active registration repository revokes a registration', () async {
    final repository = RegisteredEventRepository(
      dataSource: RegistrationRemoteDataSource(store),
      authRepository: FakeAuthRepository(),
    );
    await repository.registerEvent(event);

    expect(await repository.cancelRegistration(event), isNull);
    expect(await repository.isUserRegistered(event.id), isFalse);
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

  test('event service loads active registration counts into events', () async {
    final service = EventRemoteDataSource(store);
    final user = User(
      id: 'user-1',
      displayName: 'Test User',
      email: 'test@example.com',
      createdAt: DateTime(2026),
    );

    await service.create(event, user);
    await store.activateRegistration(user.id, event);

    final loaded = await service.loadEvents();

    expect(loaded.single.attendeeCount, 1);
  });

  test('event service reports updates for missing events', () async {
    final result = await EventRemoteDataSource(store).update(event);

    expect(result.events, isEmpty);
    expect(result.error, 'Event could not be found');
  });
}

class FakeAuthRepository implements AuthRepositoryContract {
  final User user = User(
    id: 'user-1',
    displayName: 'Test User',
    email: 'test@example.com',
    roles: {UserRole.user},
    createdAt: DateTime(2026),
  );

  @override
  User get currentUser => user;

  @override
  bool can(UserPermission permission) => user.hasPermission(permission);

  @override
  bool canUpdate(Event event) => false;

  @override
  bool canDelete(Event event) => false;

  @override
  Future<void> initialize() async {}

  @override
  Future<String?> register({
    required String name,
    required String email,
    required String password,
    required UserRole requestedRole,
  }) async => null;

  @override
  Future<String?> login({required String email, required String password}) async => null;

  @override
  Future<void> logout() async {}
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
  Future<Map<String, int>> loadRegistrationCounts(List<String> eventIds) async {
    return {
      for (final eventId in eventIds)
        eventId: registrations.values
            .expand((events) => events)
            .where((event) => event.id == eventId)
            .length,
    };
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

  @override
  Future<int> loadCheckedInCount(String eventId) async => 0;

  @override
  Future<List<EventAttendee>> loadEventAttendees(String eventId) async => [];

  @override
  Future<List<AppNotification>> loadNotifications() async => [];

  @override
  Future<int> loadUnreadNotificationCount() async => 0;

  @override
  Future<void> markNotificationRead(String notificationId) async {}

  @override
  Future<void> updateArrivalStatus({
    required String eventId,
    required ArrivalStatus status,
  }) async {}
}
