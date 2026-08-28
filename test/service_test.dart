import 'dart:convert';

import 'package:bdo_event/core/model/event_model/event_model.dart';
import 'package:bdo_event/core/model/user_model/local_user_record.dart';
import 'package:bdo_event/core/model/user_model/user_model.dart';
import 'package:bdo_event/core/prefs/local_auth_store.dart';
import 'package:bdo_event/features/auth_screen/auth_repository.dart';
import 'package:bdo_event/features/calendar_screen/data/registration_service.dart';
import 'package:bdo_event/features/event_screen/data/event_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  SharedPreferences.setMockInitialValues({});

  late LocalAuthStore store;
  late Event event;

  setUp(() {
    store = LocalAuthStore();
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
    final service = EventService(store);
    final organizer = User(
      id: 'organizer-1',
      displayName: 'Organizer',
      email: 'organizer@example.com',
      roles: {UserRole.organizer},
      createdAt: DateTime(2026),
    );

    final created = await service.create(event, organizer);
    final updated = await service.update(
      event.copyWith(title: 'Updated Festival'),
    );

    expect(created.error, isNull);
    expect(updated.error, isNull);
    expect(updated.events.single.title, 'Updated Festival');
    expect(updated.events.single.creatorId, 'organizer-1');
    expect(updated.events.single.organizerName, 'Organizer');
  });

  test('event service reports updates for missing events', () async {
    final result = await EventService(store).update(event);

    expect(result.events, isEmpty);
    expect(result.error, 'Event could not be found');
  });

  test('local store round-trips users and created events', () async {
    final user = LocalUserRecord(
      id: 'user-1',
      name: 'Attendee',
      email: 'attendee@example.com',
      password: 'secret',
      createdAt: DateTime(2026),
    );

    await store.writeUsers({'attendee@example.com': user});
    await store.writeCreatedEvents([event]);

    final users = await store.readUsers();
    final events = await store.readCreatedEvents();

    expect(users['attendee@example.com']?.id, 'user-1');
    expect(users['attendee@example.com']?.name, 'Attendee');
    expect(events.single.id, 'event-1');
    expect(events.single.location, 'Pune');
  });

  test('local store ignores malformed persisted collections', () async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString('auth_users', '{malformed');
    await preferences.setString('created_events', '["malformed"]');

    expect(await store.readUsers(), isEmpty);
    expect(await store.readCreatedEvents(), isEmpty);
  });

  test('legacy registrations migrate to one explicit owner', () async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString(
      'auth_registrations',
      jsonEncode([event.toJson()]),
    );

    final ownerRegistrations = await store.loadRegistrations('user-owner');
    final otherRegistrations = await store.loadRegistrations('user-other');

    expect(ownerRegistrations.single.id, 'event-1');
    expect(otherRegistrations, isEmpty);
  });

  test('authentication facade registers, logs in, and logs out locally', () async {
    final registrationError = await AuthRepository.register(
      name: 'Attendee',
      email: 'attendee@example.com',
      password: 'secret',
    );

    expect(registrationError, isNull);

    final loginError = await AuthRepository.login(
      email: 'ATTENDEE@example.com',
      password: 'secret',
    );

    expect(loginError, isNull);
    expect(AuthRepository.currentUser?.email, 'attendee@example.com');
    expect(await store.readSessionEmail(), 'attendee@example.com');

    final preferenceError =
        await AuthRepository.updateNotificationPreference(false);

    expect(preferenceError, isNull);
    expect(AuthRepository.currentUser?.notificationsEnabled, isFalse);
    expect(
      await store.readNotificationPreference(AuthRepository.currentUser!.id),
      isFalse,
    );

    await AuthRepository.logout();

    expect(AuthRepository.currentUser, isNull);
    expect(await store.readSessionEmail(), isNull);
  });
}
