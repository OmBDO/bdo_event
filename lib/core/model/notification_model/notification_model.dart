enum ArrivalStatus { pending, attending, notAttending }

enum NotificationCategory { event, registration, reminder, system }

class AppNotification {
  const AppNotification({
    required this.id,
    required this.eventId,
    required this.title,
    required this.message,
    required this.eventDate,
    required this.createdAt,
    required this.isRead,
    required this.arrivalStatus,
    this.category = NotificationCategory.event,
  });

  final String id;
  final String eventId;
  final String title;
  final String message;
  final DateTime eventDate;
  final DateTime createdAt;
  final bool isRead;
  final ArrivalStatus arrivalStatus;
  final NotificationCategory category;

  factory AppNotification.fromJson(Map<String, dynamic> json) {
    return AppNotification(
      id: json['id'].toString(),
      eventId: json['eventId'] as String,
      title: json['title'] as String,
      message: json['message'] as String,
      eventDate: DateTime.parse(json['eventDate'] as String),
      createdAt: DateTime.parse(json['createdAt'] as String),
      isRead: json['isRead'] as bool? ?? false,
      arrivalStatus: switch (json['arrivalStatus']) {
        'attending' => ArrivalStatus.attending,
        'not_attending' => ArrivalStatus.notAttending,
        _ => ArrivalStatus.pending,
      },
      category: switch (json['notificationType'] ?? json['notification_type']) {
        'registration' => NotificationCategory.registration,
        'reminder' => NotificationCategory.reminder,
        'system' => NotificationCategory.system,
        _ => NotificationCategory.event,
      },
    );
  }
}