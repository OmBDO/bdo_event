import 'package:bdo_event/core/model/event_model/event_catagory.dart';

class Event {
  final String id;
  final String title;
  final String date;
  final String? startTime;
  final String? endTime;
  final String location;
  final String? locationId;
  final String? locationAddress;
  final double? latitude;
  final double? longitude;
  final String imageUrl;
  final String description;
  final bool isAvailable;
  final int attendeeCount;
  final int? capacity;
  final DateTime? registrationDeadline;
  final String? organizerName;
  final String? creatorId;
  final DateTime? createdAt;
  final EventCategory? catagory;

  const Event({
    required this.id,
    required this.title,
    required this.date,
    this.startTime,
    this.endTime,
    required this.location,
    this.locationId,
    this.locationAddress,
    this.latitude,
    this.longitude,
    required this.imageUrl,
    this.description = '',
    this.isAvailable = true,
    this.attendeeCount = 0,
    this.capacity,
    this.registrationDeadline,
    this.organizerName,
    this.creatorId,
    this.createdAt,
    this.catagory,
  });

  Event copyWith({
    String? id,
    String? title,
    String? date,
    String? startTime,
    String? endTime,
    String? location,
    String? locationId,
    String? locationAddress,
    double? latitude,
    double? longitude,
    String? imageUrl,
    String? description,
    bool? isAvailable,
    int? attendeeCount,
    int? capacity,
    DateTime? registrationDeadline,
    String? organizerName,
    String? creatorId,
    DateTime? createdAt,
    EventCategory? catagory,
  }) {
    return Event(
      id: id ?? this.id,
      title: title ?? this.title,
      date: date ?? this.date,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      location: location ?? this.location,
      locationId: locationId ?? this.locationId,
      locationAddress: locationAddress ?? this.locationAddress,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      imageUrl: imageUrl ?? this.imageUrl,
      description: description ?? this.description,
      isAvailable: isAvailable ?? this.isAvailable,
      attendeeCount: attendeeCount ?? this.attendeeCount,
      capacity: capacity ?? this.capacity,
      registrationDeadline: registrationDeadline ?? this.registrationDeadline,
      organizerName: organizerName ?? this.organizerName,
      creatorId: creatorId ?? this.creatorId,
      createdAt: createdAt ?? this.createdAt,
      catagory: catagory ?? this.catagory,
    );
  }

  factory Event.fromJson(Map<String, dynamic> json) {
    return Event(
      id: json['id'] as String? ?? _fallbackId(json['title'] as String),
      title: json['title'] as String,
      date: json['date'] as String,
      startTime: json['startTime'] as String?,
      endTime: json['endTime'] as String?,
      location: json['location'] as String,
      locationId: json['locationId'] as String?,
      locationAddress: json['locationAddress'] as String?,
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      imageUrl: json['imageUrl'] as String? ?? '',
      description: json['description'] as String? ?? '',
      isAvailable: json['isAvailable'] as bool? ?? true,
      attendeeCount: json['attendeeCount'] as int? ?? 0,
      capacity: json['capacity'] as int?,
      registrationDeadline: json['registrationDeadline'] == null
          ? null
          : DateTime.tryParse(json['registrationDeadline'] as String),
      organizerName: json['organizerName'] as String?,
      creatorId: json['creatorId'] as String?,
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.tryParse(json['createdAt'] as String),

      catagory: EventCategory.fromJson(json['catagory']),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'date': date,
    'startTime': startTime,
    'endTime': endTime,
    'location': location,
    'locationId': locationId,
    'locationAddress': locationAddress,
    'latitude': latitude,
    'longitude': longitude,
    'imageUrl': imageUrl,
    'description': description,
    'isAvailable': isAvailable,
    'attendeeCount': attendeeCount,
    'capacity': capacity,
    'registrationDeadline': registrationDeadline?.toUtc().toIso8601String(),
    'organizerName': organizerName,
    'creatorId': creatorId,
    'createdAt': createdAt?.toIso8601String(),
    'catagory': catagory?.toJson() ?? {},
  };

  static String _fallbackId(String title) {
    return title.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]+'), '-');
  }
}
