import 'package:bdo_event/core/di/app_dependencies.dart';
import 'package:bdo_event/core/model/notification_model/notification_model.dart';
import 'package:bdo_event/core/prefs/supabase_store.dart';
import 'package:bdo_event/core/common/loading_shimmer/loading_shimmer.dart';
import 'package:bdo_event/core/util/resource/app_text.dart';
import 'package:bdo_event/core/util/ui/app_ui.dart';
import 'package:flutter/material.dart';
import 'package:bdo_event/core/util/event_date_formatter.dart';
import 'package:bdo_event/features/profile_screen/presentation/cubit/profile_screen_cubit.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';

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

  Future<void> _respondToInvitation(
    AppNotification notification,
    bool accepted,
  ) async {
    try {
      await getIt<EventStore>().respondToEventInvitation(
        eventId: notification.eventId,
        accepted: accepted,
      );
      if (mounted) setState(_reload);
    } on LocalStorageException {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text(AppText.unableToUpdateInvitation)),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text(AppText.notifications)),
      body: FutureBuilder<List<AppNotification>>(
        future: _notificationsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const NotificationListShimmer();
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
              separatorBuilder: (_, _) => const Gap(AppSpace.space12),
              itemBuilder: (context, index) {
                final notification = notifications[index];
                return _NotificationCard(
                  notification: notification,
                  onShown: () => _markRead(notification),
                  onConfirm: (status) => _confirmArrival(notification, status),
                  onInvitationResponse: (accepted) =>
                      _respondToInvitation(notification, accepted),
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
    required this.onInvitationResponse,
  });

  final AppNotification notification;
  final VoidCallback onShown;
  final ValueChanged<ArrivalStatus> onConfirm;
  final ValueChanged<bool> onInvitationResponse;

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) => onShown());
    final hasResponse = notification.arrivalStatus != ArrivalStatus.pending;
    final isInvitation =
        notification.category == NotificationCategory.invitation;

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
                const Gap(AppSpace.space10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        notification.title,
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                      const Gap(AppSpace.space3),
                      Text(
                        _categoryLabel(notification.category),
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const Gap(AppSpace.space10),
            Text(notification.message),
            const Gap(AppSpace.space6),
            Text(
              '${AppText.eventDatePrefix} ${formatEventDate(notification.eventDate.toLocal().toIso8601String(), context.watch<ProfileScreenCubit>().state.dateFormat)}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            if (isInvitation) ...[
              const Gap(AppSpace.space14),
              Text(
                AppText.wouldYouLikeToAttend,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              const Gap(AppSpace.space8),
              Wrap(
                spacing: AppSpace.space8,
                children: [
                  FilledButton(
                    onPressed: () => onInvitationResponse(true),
                    child: const Text(AppText.accept),
                  ),
                  TextButton(
                    onPressed: () => onInvitationResponse(false),
                    child: const Text(AppText.decline),
                  ),
                ],
              ),
            ] else if (!hasResponse) ...[
              const Gap(AppSpace.space14),
              Text(
                AppText.arrivalConfirmation,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              const Gap(AppSpace.space8),
              Wrap(
                spacing: AppSpace.space8,
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

  String _categoryLabel(NotificationCategory category) => switch (category) {
    NotificationCategory.registration => 'Registration',
    NotificationCategory.reminder => 'Reminder',
    NotificationCategory.system => 'System',
    NotificationCategory.event => 'Event',
    NotificationCategory.invitation => 'Invitation',
  };
}
