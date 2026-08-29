class EventAttendee {
  const EventAttendee({
    required this.userId,
    required this.displayName,
    this.photoUrl,
  });

  final String userId;
  final String displayName;
  final String? photoUrl;

  factory EventAttendee.fromJson(Map<String, dynamic> json) {
    return EventAttendee(
      userId: json['userId'] as String,
      displayName: json['displayName'] as String? ?? 'User',
      photoUrl: json['photoUrl'] as String?,
    );
  }
}