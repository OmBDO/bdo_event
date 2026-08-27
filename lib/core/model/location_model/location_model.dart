class Location {
  final String id;
  final String name;
  final String city;
  final String country;
  final String? zone;
  final String? address;
  final double? latitude;
  final double? longitude;

  const Location({
    required this.id,
    required this.name,
    required this.city,
    required this.country,
    this.zone,
    this.address,
    this.latitude,
    this.longitude,
  });

  String get displayName {
    final locationZone = zone == null ? '' : ' ($zone)';
    return '$city, $country$locationZone';
  }

  Location copyWith({
    String? id,
    String? name,
    String? city,
    String? country,
    String? zone,
    String? address,
    double? latitude,
    double? longitude,
  }) {
    return Location(
      id: id ?? this.id,
      name: name ?? this.name,
      city: city ?? this.city,
      country: country ?? this.country,
      zone: zone ?? this.zone,
      address: address ?? this.address,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
    );
  }

  factory Location.fromJson(Map<String, dynamic> json) {
    return Location(
      id: json['id'] as String,
      name: json['name'] as String,
      city: json['city'] as String,
      country: json['country'] as String,
      zone: json['zone'] as String?,
      address: json['address'] as String?,
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'city': city,
    'country': country,
    'zone': zone,
    'address': address,
    'latitude': latitude,
    'longitude': longitude,
  };
}
