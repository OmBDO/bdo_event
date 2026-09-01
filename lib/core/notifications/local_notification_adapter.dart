import 'package:bdo_event/core/util/resource/app_notification.dart';
import 'package:timezone/data/latest_10y.dart' as tz;

import 'event_reminder_permission_service.dart';

import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;

abstract interface class LocalNotificationAdapter {
  bool get isSupportedPlatform;

  Future<void> initialize();

  Future<bool> requestPermission();

  Future<void> schedule({
    required int id,
    required String title,
    required String body,
    required tz.TZDateTime scheduledDate,
    required NotificationDetails details,
    String? payload,
  });

  Future<List<PendingNotificationRequest>> pendingRequests();

  Future<void> cancel(int id);
}

class FlutterLocalNotificationAdapter implements LocalNotificationAdapter {
  FlutterLocalNotificationAdapter({
    FlutterLocalNotificationsPlugin? plugin,
    EventReminderPermissionService? permissionService,
  }) {
    _plugin = plugin ?? FlutterLocalNotificationsPlugin();
    _permissionService =
        permissionService ?? EventReminderPermissionService(plugin: _plugin);
  }

  late final FlutterLocalNotificationsPlugin _plugin;
  late final EventReminderPermissionService _permissionService;

  @override
  bool get isSupportedPlatform =>
      defaultTargetPlatform == TargetPlatform.android ||
      defaultTargetPlatform == TargetPlatform.iOS;

  @override
  Future<void> initialize() async {
    if (!isSupportedPlatform) return;
    tz.initializeTimeZones();
    const settings = InitializationSettings(
      android: AndroidInitializationSettings(AppNotificationConfig.androidIcon),
      iOS: DarwinInitializationSettings(),
    );
    await _plugin.initialize(settings);
  }

  @override
  Future<bool> requestPermission() => _permissionService.request();

  @override
  Future<void> schedule({
    required int id,
    required String title,
    required String body,
    required tz.TZDateTime scheduledDate,
    required NotificationDetails details,
    String? payload,
  }) => _plugin.zonedSchedule(
    id,
    title,
    body,
    scheduledDate,
    details,
    payload: payload,
    androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
  );

  @override
  Future<List<PendingNotificationRequest>> pendingRequests() =>
      _plugin.pendingNotificationRequests();

  @override
  Future<void> cancel(int id) => _plugin.cancel(id);
}
