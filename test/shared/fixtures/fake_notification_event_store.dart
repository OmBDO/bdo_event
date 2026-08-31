import 'dart:async';

import 'package:bdo_event/core/model/event_model/event_model.dart';
import 'package:bdo_event/core/model/notification_model/notification_model.dart';
import 'package:bdo_event/core/model/user_model/event_attendee.dart';
import 'package:bdo_event/core/prefs/supabase_store.dart';

class FakeNotificationEventStore implements EventStore {
  FakeNotificationEventStore({
    this.notifications = const [],
    this.recipients = const [],
    this.attendees = const [],
    this.pendingNotifications = false,
    this.pendingAttendees = false,
    this.sendError = false,
    this.attendeeError = false,
    this.notificationError = false,
    this.arrivalError = false,
    this.checkedInCount = 0,
    this.checkedInError,
  }) : _notificationsCompleter = pendingNotifications
           ? Completer<List<AppNotification>>()
           : null,
       _attendeesCompleter = pendingAttendees
           ? Completer<List<EventAttendee>>()
           : null;

  final List<AppNotification> notifications;
  final List<Map<String, String>> recipients;
  final List<EventAttendee> attendees;
  final bool pendingNotifications;
  final bool pendingAttendees;
  final bool sendError;
  final bool attendeeError;
  final bool notificationError;
  final bool arrivalError;
  final int checkedInCount;
  final Object? checkedInError;
  final Completer<List<AppNotification>>? _notificationsCompleter;
  final Completer<List<EventAttendee>>? _attendeesCompleter;
  String? markedReadId;
  String? respondedEventId;
  bool? respondedAccepted;
  String? arrivalEventId;
  ArrivalStatus? arrivalStatus;
  String? sentEventId;
  List<String>? sentUserIds;
  int attendeeLoadCount = 0;

  void completeNotifications(List<AppNotification> value) =>
      _notificationsCompleter?.complete(value);

  void completeAttendees(List<EventAttendee> value) =>
      _attendeesCompleter?.complete(value);

  @override
  Future<List<AppNotification>> loadNotifications() async {
    if (notificationError) throw const LocalStorageException();
    return _notificationsCompleter?.future ?? notifications;
  }

  @override
  Future<void> markNotificationRead(String notificationId) async {
    markedReadId = notificationId;
  }

  @override
  Future<void> respondToEventInvitation({
    required String eventId,
    required bool accepted,
  }) async {
    if (sendError) throw const LocalStorageException();
    respondedEventId = eventId;
    respondedAccepted = accepted;
  }

  @override
  Future<void> updateArrivalStatus({
    required String eventId,
    required ArrivalStatus status,
  }) async {
    if (arrivalError) throw const LocalStorageException();
    arrivalEventId = eventId;
    arrivalStatus = status;
  }

  @override
  Future<List<EventAttendee>> loadEventAttendees(String eventId) async {
    attendeeLoadCount++;
    if (attendeeError) throw const LocalStorageException();
    return _attendeesCompleter?.future ?? attendees;
  }

  @override
  Future<int> loadCheckedInCount(String eventId) async {
    if (checkedInError != null) throw checkedInError!;
    return checkedInCount;
  }

  @override
  Future<List<Map<String, String>>> loadInvitationRecipients() async =>
      recipients;

  @override
  Future<int> sendEventInvitations({
    required String eventId,
    required List<String> userIds,
  }) async {
    if (sendError) throw const LocalStorageException();
    sentEventId = eventId;
    sentUserIds = userIds;
    return userIds.length;
  }

  @override
  Future<List<Event>> readCreatedEvents() => throw UnimplementedError();

  @override
  Future<void> createEvent(Event event) => throw UnimplementedError();

  @override
  Future<void> updateEvent(Event event) => throw UnimplementedError();

  @override
  Future<void> deleteEvent(String eventId) => throw UnimplementedError();

  @override
  Future<List<Event>> loadRegistrations(String userId) =>
      throw UnimplementedError();

  @override
  Future<Map<String, int>> loadRegistrationCounts(List<String> eventIds) =>
      throw UnimplementedError();

  @override
  Future<void> activateRegistration(String userId, Event event) =>
      throw UnimplementedError();

  @override
  Future<void> revokeRegistration(String userId, String eventId) =>
      throw UnimplementedError();

  @override
  Future<String?> loadRegistrationToken(String userId, String eventId) =>
      throw UnimplementedError();

  @override
  Future<Map<String, dynamic>?> validateRegistration({
    required String token,
    required String eventId,
  }) => throw UnimplementedError();

  @override
  Future<String> checkInRegistration({
    required String token,
    required String eventId,
  }) => throw UnimplementedError();

  @override
  Future<int> loadAttendanceCount(String eventId) => throw UnimplementedError();

  @override
  Future<int> loadUnreadNotificationCount() => throw UnimplementedError();

  @override
  Future<void> recordLoginActivity({
    String? deviceLabel,
    String? platform,
  }) => throw UnimplementedError();

  @override
  Future<Map<String, String>> loadProfileVisibility(String userId) =>
      throw UnimplementedError();

  @override
  Future<void> saveProfileVisibility({
    required String userId,
    required String profileVisibility,
    required String registrationVisibility,
  }) => throw UnimplementedError();
}
