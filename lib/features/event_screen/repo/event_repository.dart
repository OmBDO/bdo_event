import 'package:bdo_event/core/model/event_model/event_model.dart';
import 'package:bdo_event/core/model/user_model/user_model.dart';
import 'package:bdo_event/core/prefs/local_auth_store.dart';
import 'package:bdo_event/features/calendar_screen/data/registration_service.dart';
import 'package:bdo_event/features/event_screen/data/event_service.dart';
import 'package:flutter/material.dart';

class EventRepository {
  EventRepository._();

  static final LocalAuthStore _store = LocalAuthStore();
  static final EventService _eventService = EventService(_store);
  static final RegistrationService _registrationService = RegistrationService(
    _store,
  );
  static User? _currentUser;
  static final ValueNotifier<List<Event>> registrations =
      ValueNotifier<List<Event>>([]);
  static final ValueNotifier<List<Event>> createdEvents =
      ValueNotifier<List<Event>>([]);
  static final ValueNotifier<List<Event>> listedEvents =
      ValueNotifier<List<Event>>([]);

  static User? get currentUser => _currentUser;
  static String? get currentUserName => _currentUser?.displayName;
  static bool can(UserPermission permission) =>
      _currentUser?.hasPermission(permission) ?? false;
  static bool canUpdate(Event event) =>
      can(UserPermission.manageAllEvents) ||
      (event.creatorId == _currentUser?.id &&
          can(UserPermission.updateOwnEvents));
  static bool canDelete(Event event) =>
      can(UserPermission.manageAllEvents) ||
      (event.creatorId == _currentUser?.id &&
          can(UserPermission.deleteOwnEvents));
  static bool canManage(Event event) => canUpdate(event);

  static Future<String?> registerEvent(Event event) async {
    final user = _currentUser;
    if (user == null) return 'Please sign in to register for an event';
    if (!user.hasPermission(UserPermission.registerForEvents)) {
      return 'Your account is not allowed to register for events';
    }
    final result = await _registrationService.register(user.id, event);
    if (result.error != null) return result.error;
    registrations.value = result.events;
    return null;
  }

  // ─── ADD THIS METHOD ────────────────────────────────────────────────────────
  /// Checks if the logged-in user is currently registered for a specific event ID
  static bool isUserRegistered(String eventId) {
    return registrations.value.any((e) => e.id == eventId);
  }
  // ────────────────────────────────────────────────────────────────────────────

  static Future<String?> cancelEvent(Event event) async {
    final user = _currentUser;
    if (user == null) return 'Please sign in to manage registrations';
    final result = await _registrationService.cancel(user.id, event);
    if (result.error != null) return result.error;
    registrations.value = result.events;
    return null;
  }

  static Future<String?> createEvent(Event event) async {
    final user = _currentUser;
    if (user == null) return 'Please sign in to create an event';
    if (!user.hasPermission(UserPermission.createEvents)) {
      return 'Organizer access is required to create events';
    }
    createdEvents.value = (await _eventService.create(event, user)).events;
    return null;
  }

  static Future<String?> updateEvent(Event event) async {
    if (!canUpdate(event)) {
      return 'You do not have permission to update this event';
    }
    final result = await _eventService.update(event);
    if (result.error != null) return result.error;
    createdEvents.value = result.events;
    return null;
  }

  static Future<String?> deleteEvent(Event event) async {
    if (!canDelete(event)) {
      return 'You do not have permission to delete this event';
    }
    createdEvents.value = (await _eventService.delete(event)).events;
    return null;
  }

  static Future<List<Event>> getEvent() async {
    listedEvents.value = (await _eventService.load());
    return listedEvents.value;
  }
}
