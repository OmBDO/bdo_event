import 'package:bdo_event/core/notifications/local_notification_adapter.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;

class RecordingLocalNotificationAdapter implements LocalNotificationAdapter {
  RecordingLocalNotificationAdapter({
    this.supported = true,
    this.initializeError,
    this.permissionError,
    this.scheduleError,
    this.pendingError,
    this.cancelError,
  });

  final bool supported;
  final Object? initializeError;
  final Object? permissionError;
  final Object? scheduleError;
  final Object? pendingError;
  final Object? cancelError;
  bool permissionGranted = true;
  int initializeCalls = 0;
  final scheduled = <RecordedNotification>[];
  final pending = <PendingNotificationRequest>[];
  final canceledIds = <int>[];

  @override
  bool get isSupportedPlatform => supported;

  @override
  Future<void> initialize() async {
    if (initializeError != null) throw initializeError!;
    initializeCalls++;
  }

  @override
  Future<bool> requestPermission() async {
    if (permissionError != null) throw permissionError!;
    return permissionGranted;
  }

  @override
  Future<void> schedule({
    required int id,
    required String title,
    required String body,
    required tz.TZDateTime scheduledDate,
    required NotificationDetails details,
    String? payload,
  }) async {
    if (scheduleError != null) throw scheduleError!;
    scheduled.add(
      RecordedNotification(
        id: id,
        title: title,
        body: body,
        scheduledDate: scheduledDate,
        payload: payload,
      ),
    );
    pending
      ..removeWhere((request) => request.id == id)
      ..add(PendingNotificationRequest(id, title, body, payload));
  }

  @override
  Future<List<PendingNotificationRequest>> pendingRequests() async {
    if (pendingError != null) throw pendingError!;
    return pending;
  }

  @override
  Future<void> cancel(int id) async {
    if (cancelError != null) throw cancelError!;
    canceledIds.add(id);
    pending.removeWhere((request) => request.id == id);
  }
}

class RecordedNotification {
  const RecordedNotification({
    required this.id,
    required this.title,
    required this.body,
    required this.scheduledDate,
    required this.payload,
  });

  final int id;
  final String title;
  final String body;
  final tz.TZDateTime scheduledDate;
  final String? payload;
}
