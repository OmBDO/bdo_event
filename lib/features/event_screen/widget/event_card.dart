import 'package:flutter/material.dart';

class EventCard extends StatelessWidget {
  final String title;
  final String date;
  final String time;
  final String location;
  final String? imageUrl;

  const EventCard({
    super.key,
    required this.title,
    required this.date,
    required this.time,
    required this.location,
    this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Event image
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            child: imageUrl != null
                ? Image.network(
                    imageUrl!,
                    height: 180,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  )
                : Container(
                    height: 180,
                    width: double.infinity,
                    color: const Color(0xFFE8E8F5),
                    child: const Icon(
                      Icons.event,
                      size: 50,
                      color: Colors.grey,
                    ),
                  ),
          ),

          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 12),

                Row(
                  children: [
                    const Icon(
                      Icons.calendar_today_outlined,
                      size: 16,
                      color: Colors.grey,
                    ),
                    const SizedBox(width: 6),
                    Text(date, style: const TextStyle(color: Colors.grey)),

                    const SizedBox(width: 16),

                    const Icon(
                      Icons.access_time_outlined,
                      size: 16,
                      color: Colors.grey,
                    ),
                    const SizedBox(width: 6),
                    Text(time, style: const TextStyle(color: Colors.grey)),
                  ],
                ),

                const SizedBox(height: 8),

                Row(
                  children: [
                    const Icon(
                      Icons.location_on_outlined,
                      size: 17,
                      color: Colors.grey,
                    ),
                    const SizedBox(width: 6),
                    Text(location, style: const TextStyle(color: Colors.grey)),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
