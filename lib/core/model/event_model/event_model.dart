import 'package:bdo_event/core/model/event_model/event_catagory.dart';

class _UnsetValue {
  const _UnsetValue();
}

const _unsetValue = _UnsetValue();

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
    Object? startTime = _unsetValue,
    Object? endTime = _unsetValue,
    String? location,
    Object? locationId = _unsetValue,
    Object? locationAddress = _unsetValue,
    Object? latitude = _unsetValue,
    Object? longitude = _unsetValue,
    String? imageUrl,
    String? description,
    bool? isAvailable,
    int? attendeeCount,
    Object? capacity = _unsetValue,
    Object? registrationDeadline = _unsetValue,
    Object? organizerName = _unsetValue,
    Object? creatorId = _unsetValue,
    Object? createdAt = _unsetValue,
    Object? catagory = _unsetValue,
  }) {
    return Event(
      id: id ?? this.id,
      title: title ?? this.title,
      date: date ?? this.date,
        startTime: identical(startTime, _unsetValue) ? this.startTime : startTime as String?,
        endTime: identical(endTime, _unsetValue) ? this.endTime : endTime as String?,
      location: location ?? this.location,
        locationId: identical(locationId, _unsetValue)
          ? this.locationId
          : locationId as String?,
        locationAddress: identical(locationAddress, _unsetValue)
          ? this.locationAddress
          : locationAddress as String?,
        latitude: identical(latitude, _unsetValue)
          ? this.latitude
          : latitude as double?,
        longitude: identical(longitude, _unsetValue)
          ? this.longitude
          : longitude as double?,
      imageUrl: imageUrl ?? this.imageUrl,
      description: description ?? this.description,
      isAvailable: isAvailable ?? this.isAvailable,
      attendeeCount: attendeeCount ?? this.attendeeCount,
        capacity: identical(capacity, _unsetValue)
          ? this.capacity
          : capacity as int?,
        registrationDeadline: identical(registrationDeadline, _unsetValue)
          ? this.registrationDeadline
          : registrationDeadline as DateTime?,
        organizerName: identical(organizerName, _unsetValue)
          ? this.organizerName
          : organizerName as String?,
        creatorId: identical(creatorId, _unsetValue)
          ? this.creatorId
          : creatorId as String?,
        createdAt: identical(createdAt, _unsetValue)
          ? this.createdAt
          : createdAt as DateTime?,
        catagory: identical(catagory, _unsetValue)
          ? this.catagory
          : catagory as EventCategory?,
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
