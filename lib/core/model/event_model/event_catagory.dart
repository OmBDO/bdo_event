import 'package:flutter/material.dart';

class EventCategory {
  static const defaults = <EventCategory>[
    EventCategory(
      name: 'Sports',
      icon: Icons.sports_soccer,
      color: Colors.orange,
    ),
    EventCategory(name: 'Festival', icon: Icons.festival, color: Colors.purple),
    EventCategory(
      name: 'Food Event',
      icon: Icons.restaurant,
      color: Colors.red,
    ),
    EventCategory(
      name: 'Game Event',
      icon: Icons.sports_esports,
      color: Colors.blue,
    ),
    EventCategory(name: 'Music', icon: Icons.music_note, color: Colors.green),
    EventCategory(
      name: 'Business',
      icon: Icons.business_center,
      color: Colors.teal,
    ),
  ];

  final String name;
  final IconData icon;
  final Color color;

  const EventCategory({
    required this.name,
    required this.icon,
    required this.color,
  });

  /// Factory constructor to parse category safely from json string name
  factory EventCategory.fromJson(dynamic json) {
    final String categoryName = json is Map<String, dynamic>
        ? (json['name'] as String? ?? 'Other')
        : (json as String? ?? 'Other');

    switch (categoryName.toLowerCase()) {
      case 'sports':
        return const EventCategory(
          name: 'Sports',
          icon: Icons.sports_soccer,
          color: Colors.orange,
        );
      case 'festival':
        return const EventCategory(
          name: 'Festival',
          icon: Icons.festival,
          color: Colors.purple,
        );
      case 'food event':
      case 'food':
        return const EventCategory(
          name: 'Food Event',
          icon: Icons.restaurant,
          color: Colors.red,
        );
      case 'game event':
      case 'gaming':
        return const EventCategory(
          name: 'Game Event',
          icon: Icons.sports_esports,
          color: Colors.blue,
        );
      default:
        return const EventCategory(
          name: 'Other',
          icon: Icons.event,
          color: Colors.grey,
        );
    }
  }

  /// Exports category data as a primitive payload for database storage
  Map<String, dynamic> toJson() => {
    'name': name,
    'iconCode': icon.codePoint,
    'colorValue': color.value,
  };
}
