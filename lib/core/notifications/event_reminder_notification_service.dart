import 'package:bdo_event/core/util/resource/app_notification.dart';
import 'package:bdo_event/core/util/resource/app_other.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:bdo_event/core/model/event_model/event_model.dart';
import 'package:bdo_event/core/util/event_date_formatter.dart';

import 'event_reminder_permission_service.dart';

import 'package:bdo_event/core/notifications/local_notification_adapter.dart';
import 'package:bdo_event/core/notifications/event_reminder_policy.dart';
import 'package:timezone/timezone.dart' as tz;

class EventReminderNotificationService {
  factory EventReminderNotificationService({
    FlutterLocalNotificationsPlugin? plugin,
    EventReminderPermissionService? permissionService,
    LocalNotificationAdapter? adapter,
  }) {
    if (adapter != null) {
      return EventReminderNotificationService._(adapter);
    }
    final resolvedPlugin = plugin ?? FlutterLocalNotificationsPlugin();
    return EventReminderNotificationService._(
      FlutterLocalNotificationAdapter(
        plugin: resolvedPlugin,
        permissionService:
            permissionService ??
            EventReminderPermissionService(plugin: resolvedPlugin),
      ),
    );
  }

  EventReminderNotificationService._(this._adapter);

  final LocalNotificationAdapter _adapter;
  List<Event> _lastRegisteredEvents = const [];

  static const reminderLeadTimeOptions = EventReminderPolicy.leadTimeOptions;
  static const _eventReminderPayload = AppNotificationConfig.reminderPayload;

  Future<void> initialize() async {
    try {
      await _adapter.initialize();
      // ignore: empty_catches
    } on Object {}
  }

  Future<bool> requestPermission() async {
    try {
      return await _adapter.requestPermission();
    } on Object {
      return false;
    }
  }

  Future<void> scheduleTestNotification({
    Duration delay = const Duration(seconds: 5),
  }) async {
    final scheduledDate = tz.TZDateTime.now(tz.local).add(delay);
    try {
      await _adapter.schedule(
        id: 0,
        title: 'Event reminder test',
        body: 'Your notification setup is working.',
        scheduledDate: scheduledDate,
        details: const NotificationDetails(
          android: AndroidNotificationDetails(
            AppNotificationConfig.reminderChannelId,
            AppNotificationConfig.reminderChannelName,
            channelDescription:
                AppNotificationConfig.reminderChannelDescription,
            importance: Importance.high,
            priority: Priority.high,
          ),
          iOS: DarwinNotificationDetails(),
        ),
      );
      // ignore: empty_catches
    } on Object {}
  }

  Future<bool> scheduleEventReminder(
    Event event, {
    Duration leadTime = const Duration(days: 1),
  }) async {
    if (!_adapter.isSupportedPlatform) return false;
    final reminderTime = EventReminderPolicy.reminderTime(
      event,
      leadTime: leadTime,
    );
    if (reminderTime == null) return false;
    if (!reminderTime.isAfter(DateTime.now())) return false;
    if (!await requestPermission()) return false;

    final body =
        'Your event is scheduled for '
        '${formatEventDate(event.date, AppDateFormats.dayMonthYear)} '
        'at ${formatEventTime(event.startTime)}.';
    try {
      await _adapter.schedule(
        id: EventReminderPolicy.notificationIdFor(event.id),
        title: event.title,
        body: body,
        scheduledDate: tz.TZDateTime.from(reminderTime, tz.local),
        details: const NotificationDetails(
          android: AndroidNotificationDetails(
            AppNotificationConfig.reminderChannelId,
            AppNotificationConfig.reminderChannelName,
            channelDescription:
                AppNotificationConfig.reminderChannelDescription,
            importance: Importance.high,
            priority: Priority.high,
          ),
          iOS: DarwinNotificationDetails(),
        ),
        payload: _eventReminderPayload,
      );
    } on Object {
      return false;
    }
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
      final pending = await _pendingRequests();
      for (final notification in pending) {
        if (notification.payload == _eventReminderPayload) {
          await _cancel(notification.id);
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

    final pending = await _pendingRequests();
    for (final notification in pending) {
      if (notification.payload == _eventReminderPayload &&
          !scheduledIds.contains(notification.id)) {
        await _cancel(notification.id);
      }
    }
  }

  Future<void> cancelEventReminder(String eventId) =>
      _cancel(EventReminderPolicy.notificationIdFor(eventId));

  static DateTime? eventStartTime(Event event) =>
      EventReminderPolicy.eventStartTime(event);

  static int notificationIdFor(String eventId) =>
      EventReminderPolicy.notificationIdFor(eventId);

  Future<void> cancelTestNotification() => _cancel(0);

  Future<List<PendingNotificationRequest>> _pendingRequests() async {
    try {
      return await _adapter.pendingRequests();
    } on Object {
      return const [];
    }
  }

  Future<void> _cancel(int id) async {
    try {
      await _adapter.cancel(id);
      // ignore: empty_catches
    } on Object {}
  }
}
