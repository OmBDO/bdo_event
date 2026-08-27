class Event {
  final String id;
  final String title;
  final String date;
  final String location;
  final String imageUrl;
  final String description;
  final bool isAvailable;
  final int attendeeCount;
  final int? capacity;
  final String? organizerName;
  final String? creatorId;
  final DateTime? createdAt;

  const Event({
    required this.id,
    required this.title,
    required this.date,
    required this.location,
    required this.imageUrl,
    this.description = '',
    this.isAvailable = true,
    this.attendeeCount = 0,
    this.capacity,
    this.organizerName,
    this.creatorId,
    this.createdAt,
  });

  Event copyWith({
    String? id,
    String? title,
    String? date,
    String? location,
    String? imageUrl,
    String? description,
    bool? isAvailable,
    int? attendeeCount,
    int? capacity,
    String? organizerName,
    String? creatorId,
    DateTime? createdAt,
  }) {
    return Event(
      id: id ?? this.id,
      title: title ?? this.title,
      date: date ?? this.date,
      location: location ?? this.location,
      imageUrl: imageUrl ?? this.imageUrl,
      description: description ?? this.description,
      isAvailable: isAvailable ?? this.isAvailable,
      attendeeCount: attendeeCount ?? this.attendeeCount,
      capacity: capacity ?? this.capacity,
      organizerName: organizerName ?? this.organizerName,
      creatorId: creatorId ?? this.creatorId,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  factory Event.fromJson(Map<String, dynamic> json) {
    return Event(
      id: json['id'] as String? ?? _fallbackId(json['title'] as String),
      title: json['title'] as String,
      date: json['date'] as String,
      location: json['location'] as String,
      imageUrl: json['imageUrl'] as String? ?? '',
      description: json['description'] as String? ?? '',
      isAvailable: json['isAvailable'] as bool? ?? true,
      attendeeCount: json['attendeeCount'] as int? ?? 0,
      capacity: json['capacity'] as int?,
      organizerName: json['organizerName'] as String?,
      creatorId: json['creatorId'] as String?,
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.tryParse(json['createdAt'] as String),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'date': date,
    'location': location,
    'imageUrl': imageUrl,
    'description': description,
    'isAvailable': isAvailable,
    'attendeeCount': attendeeCount,
    'capacity': capacity,
    'organizerName': organizerName,
    'creatorId': creatorId,
    'createdAt': createdAt?.toIso8601String(),
  };

  static String _fallbackId(String title) {
    return title.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]+'), '-');
  }
}
