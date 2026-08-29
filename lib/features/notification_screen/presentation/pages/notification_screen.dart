import 'package:bdo_event/core/di/app_dependencies.dart';
import 'package:bdo_event/core/model/notification_model/notification_model.dart';
import 'package:bdo_event/core/prefs/supabase_store.dart';
import 'package:bdo_event/core/util/event.resource.dart';
import 'package:flutter/material.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  late Future<List<AppNotification>> _notificationsFuture;
  final Set<String> _readRequested = <String>{};

  @override
  void initState() {
    super.initState();
    _reload();
  }

  void _reload() {
    _notificationsFuture = getIt<EventStore>().loadNotifications();
  }

  Future<void> _confirmArrival(
    AppNotification notification,
    ArrivalStatus status,
  ) async {
    try {
      await getIt<EventStore>().updateArrivalStatus(
        eventId: notification.eventId,
        status: status,
      );
      if (!mounted) return;
      setState(_reload);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text(AppText.arrivalConfirmed)));
    } on LocalStorageException {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text(AppText.unableToUpdateArrival)),
      );
    }
  }

  Future<void> _markRead(AppNotification notification) async {
    if (notification.isRead || !_readRequested.add(notification.id)) return;
    await getIt<EventStore>().markNotificationRead(notification.id);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text(AppText.notifications)),
      body: FutureBuilder<List<AppNotification>>(
        future: _notificationsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text(AppText.unableToLoadNotifications));
          }

          final notifications = snapshot.data ?? const <AppNotification>[];
          if (notifications.isEmpty) {
            return const Center(child: Text(AppText.noNotifications));
          }

          return RefreshIndicator(
            onRefresh: () async => setState(_reload),
            child: ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
              itemCount: notifications.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final notification = notifications[index];
                return _NotificationCard(
                  notification: notification,
                  onShown: () => _markRead(notification),
                  onConfirm: (status) => _confirmArrival(notification, status),
                );
              },
            ),
          );
        },
      ),
    );
  }
}

class _NotificationCard extends StatelessWidget {
  const _NotificationCard({
    required this.notification,
    required this.onShown,
    required this.onConfirm,
  });

  final AppNotification notification;
  final VoidCallback onShown;
  final ValueChanged<ArrivalStatus> onConfirm;

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) => onShown());
    final hasResponse = notification.arrivalStatus != ArrivalStatus.pending;

    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  notification.isRead
                      ? Icons.notifications_none_rounded
                      : Icons.notifications_active_rounded,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    notification.title,
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(notification.message),
            const SizedBox(height: 6),
            Text(
              'Event date: ${notification.eventDate.toLocal().toString().split(' ').first}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            if (!hasResponse) ...[
              const SizedBox(height: 14),
              Text(
                AppText.arrivalConfirmation,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: [
                  OutlinedButton(
                    onPressed: () => onConfirm(ArrivalStatus.attending),
                    child: const Text(AppText.attending),
                  ),
                  TextButton(
                    onPressed: () => onConfirm(ArrivalStatus.notAttending),
                    child: const Text(AppText.notAttending),
                  ),
                ],
              ),
            ] else
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Text(
                  notification.arrivalStatus == ArrivalStatus.attending
                      ? AppText.attending
                      : AppText.notAttending,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
          ],
        ),
      ),
    );
  }
}