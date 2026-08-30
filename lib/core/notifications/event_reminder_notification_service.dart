import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:bdo_event/core/model/event_model/event_model.dart';
import 'package:bdo_event/core/util/event_date_formatter.dart';
import 'package:bdo_event/core/notifications/event_reminder_permission_service.dart';
import 'package:bdo_event/core/notifications/event_reminder_policy.dart';
import 'package:bdo_event/core/util/event_resource.dart';
import 'package:flutter/foundation.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class EventReminderNotificationService {
  factory EventReminderNotificationService({
    FlutterLocalNotificationsPlugin? plugin,
    EventReminderPermissionService? permissionService,
  }) {
    final resolvedPlugin = plugin ?? FlutterLocalNotificationsPlugin();
    return EventReminderNotificationService._(
      resolvedPlugin,
      permissionService ??
          EventReminderPermissionService(plugin: resolvedPlugin),
    );
  }

  EventReminderNotificationService._(this._plugin, this._permissionService);

  final FlutterLocalNotificationsPlugin _plugin;
  final EventReminderPermissionService _permissionService;
  List<Event> _lastRegisteredEvents = const [];

  static const reminderLeadTimeOptions = EventReminderPolicy.leadTimeOptions;
  static const _eventReminderPayload = AppNotificationConfig.reminderPayload;

  Future<void> initialize() async {
    if (!_isSupportedPlatform) return;
    tz.initializeTimeZones();
    const settings = InitializationSettings(
      android: AndroidInitializationSettings(AppNotificationConfig.androidIcon),
      iOS: DarwinInitializationSettings(),
    );
    await _plugin.initialize(settings);
  }

  Future<bool> requestPermission() async {
    return _permissionService.request();
  }

  Future<void> scheduleTestNotification({
    Duration delay = const Duration(seconds: 5),
  }) {
    final scheduledDate = tz.TZDateTime.now(tz.local).add(delay);
    return _plugin.zonedSchedule(
      0,
      'Event reminder test',
      'Your notification setup is working.',
      scheduledDate,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          AppNotificationConfig.reminderChannelId,
          AppNotificationConfig.reminderChannelName,
          channelDescription: AppNotificationConfig.reminderChannelDescription,
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
    );
  }

  Future<bool> scheduleEventReminder(
    Event event, {
    Duration leadTime = const Duration(days: 1),
  }) async {
    if (!_isSupportedPlatform) return false;
    final reminderTime = EventReminderPolicy.reminderTime(
      event,
      leadTime: leadTime,
    );
    if (reminderTime == null) return false;
    if (!reminderTime.isAfter(DateTime.now())) return false;
    if (!await requestPermission()) return false;

    await _plugin.zonedSchedule(
      EventReminderPolicy.notificationIdFor(event.id),
      event.title,
      'Your event is scheduled for ${formatEventDate(event.date, AppDateFormats.dayMonthYear)} at ${formatEventTime(event.startTime)}.',
      tz.TZDateTime.from(reminderTime, tz.local),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          AppNotificationConfig.reminderChannelId,
          AppNotificationConfig.reminderChannelName,
          channelDescription: AppNotificationConfig.reminderChannelDescription,
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(),
      ),
      payload: _eventReminderPayload,
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
    );
    return true;
  }

  Future<void> reconcileEventReminders(
    List<Event> events, {
    bool enabled = true,
    Duration leadTime = const Duration(days: 1),
  }) async {
    _lastRegisteredEvents = List<Event>.of(events);
    await _reconcile(events, enabled: enabled, leadTime: leadTime);
  }

  Future<void> reconcileLastEventReminders({
    required bool enabled,
    required Duration leadTime,
  }) => _reconcile(_lastRegisteredEvents, enabled: enabled, leadTime: leadTime);

  Future<void> _reconcile(
    List<Event> events, {
    bool enabled = true,
    Duration leadTime = const Duration(days: 1),
  }) async {
    final scheduledIds = <int>{};
    if (!enabled) {
      final pending = await _plugin.pendingNotificationRequests();
      for (final notification in pending) {
        if (notification.payload == _eventReminderPayload) {
          await _plugin.cancel(notification.id);
        }
      }
      return;
    }
    for (final event in events) {
      try {
        final scheduled = await scheduleEventReminder(
          event,
          leadTime: leadTime,
        );
        if (scheduled) {
          scheduledIds.add(EventReminderPolicy.notificationIdFor(event.id));
        }
      } on Object {
        continue;
      }
    }

    final pending = await _plugin.pendingNotificationRequests();
    for (final notification in pending) {
      if (notification.payload == _eventReminderPayload &&
          !scheduledIds.contains(notification.id)) {
        await _plugin.cancel(notification.id);
      }
    }
  }

  Future<void> cancelEventReminder(String eventId) =>
      _plugin.cancel(EventReminderPolicy.notificationIdFor(eventId));

  static DateTime? eventStartTime(Event event) =>
      EventReminderPolicy.eventStartTime(event);

  static int notificationIdFor(String eventId) =>
      EventReminderPolicy.notificationIdFor(eventId);

  Future<void> cancelTestNotification() => _plugin.cancel(0);

  bool get _isSupportedPlatform =>
      defaultTargetPlatform == TargetPlatform.android ||
      defaultTargetPlatform == TargetPlatform.iOS;
}
