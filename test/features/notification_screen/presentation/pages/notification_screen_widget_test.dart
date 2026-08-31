import 'dart:async';

import 'package:bdo_event/core/di/app_dependencies.dart';
import 'package:bdo_event/core/model/event_model/event_model.dart';
import 'package:bdo_event/core/model/notification_model/notification_model.dart';
import 'package:bdo_event/core/model/user_model/event_attendee.dart';
import 'package:bdo_event/core/prefs/supabase_store.dart';
import 'package:bdo_event/core/util/event_resource.dart';
import 'package:bdo_event/core/util/resource/app_text.dart';
import 'package:bdo_event/features/notification_screen/presentation/pages/notification_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../profile_screen/presentation/cubit/profile_screen_cubit_test.dart'
    as profile_fixtures;

void main() {
  tearDown(() async {
    await getIt.reset();
  });

  testWidgets('shows the empty notification state', (tester) async {
    final store = FakeNotificationEventStore();
    await pumpNotifications(tester, store);

    expect(find.text('No notifications'), findsOneWidget);
  });

  testWidgets('shows the notification loading state', (tester) async {
    final store = FakeNotificationEventStore(pendingNotifications: true);
    await pumpNotifications(tester, store);

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    store.completeNotifications(const []);
    await tester.pumpAndSettle();
    expect(find.text('No notifications'), findsOneWidget);
  });

  testWidgets('renders an arrival notification and marks it read', (
    tester,
  ) async {
    final notification = sampleNotification();
    final store = FakeNotificationEventStore(notifications: [notification]);
    await pumpNotifications(tester, store);
    await tester.pump();

    expect(find.text('Event reminder'), findsOneWidget);
    expect(find.text('Would you like to attend?'), findsOneWidget);
    expect(find.text(AppText.attending), findsOneWidget);
    expect(store.markedReadId, notification.id);
  });

  testWidgets('renders invitation actions and sends an accept response', (
    tester,
  ) async {
    final notification = sampleNotification(
      category: NotificationCategory.invitation,
    );
    final store = FakeNotificationEventStore(notifications: [notification]);
    await pumpNotifications(tester, store);

    await tester.tap(find.text('Accept'));
    await tester.pumpAndSettle();

    expect(store.respondedEventId, notification.eventId);
    expect(store.respondedAccepted, isTrue);
  });

  testWidgets('shows an error when notifications cannot be loaded', (
    tester,
  ) async {
    await pumpNotifications(
      tester,
      FakeNotificationEventStore(notificationError: true),
    );

    expect(find.text(AppText.unableToLoadNotifications), findsOneWidget);
  });

  testWidgets('confirms attendance and shows success feedback', (tester) async {
    final store = FakeNotificationEventStore(
      notifications: [sampleNotification()],
    );
    await pumpNotifications(tester, store);

    await tester.tap(find.text(AppText.attending));
    await tester.pumpAndSettle();

    expect(store.arrivalEventId, 'event-1');
    expect(store.arrivalStatus, ArrivalStatus.attending);
    expect(find.text(AppText.arrivalConfirmed), findsOneWidget);
  });

  testWidgets('shows feedback when attendance confirmation fails', (
    tester,
  ) async {
    final store = FakeNotificationEventStore(
      notifications: [sampleNotification()],
      arrivalError: true,
    );
    await pumpNotifications(tester, store);

    await tester.tap(find.text(AppText.notAttending));
    await tester.pumpAndSettle();

    expect(find.text(AppText.unableToUpdateArrival), findsOneWidget);
  });
}

AppNotification sampleNotification({
  NotificationCategory category = NotificationCategory.event,
  ArrivalStatus arrivalStatus = ArrivalStatus.pending,
}) => AppNotification(
  id: 'notification-1',
  eventId: 'event-1',
  title: 'Event reminder',
  message: 'Town Hall starts soon',
  eventDate: DateTime.utc(2099, 9, 1),
  createdAt: DateTime.utc(2099, 8, 1),
  isRead: false,
  arrivalStatus: arrivalStatus,
  category: category,
);

Future<void> pumpNotifications(
  WidgetTester tester,
  FakeNotificationEventStore store,
) async {
  getIt.registerSingleton<EventStore>(store);
  final profileCubit = profile_fixtures.createCubit();
  await tester.pumpWidget(
    MaterialApp(
      home: BlocProvider.value(
        value: profileCubit,
        child: const NotificationScreen(),
      ),
    ),
  );
  await tester.pump();
  await profileCubit.close();
}

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
  }) : _recipients = recipients,
       _notificationsCompleter = pendingNotifications
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
  final List<Map<String, String>> _recipients;
  String? sentEventId;
  List<String>? sentUserIds;

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
  Future<void> markNotificationRead(String notificationId) async =>
      markedReadId = notificationId;

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
      _recipients;

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
  Future<List<EventAttendee>> loadEventAttendees(String eventId) =>
      throw UnimplementedError();
  @override
  Future<int> loadUnreadNotificationCount() => throw UnimplementedError();
  @override
  Future<void> recordLoginActivity({String? deviceLabel, String? platform}) =>
      throw UnimplementedError();
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
