import 'package:flutter/material.dart';

class SectionHeader extends StatelessWidget {
  final String subtitle;
  final String title;
  final String description;

  const SectionHeader({
    super.key,
    required this.subtitle,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          subtitle,
          style: const TextStyle(
            color: Color(0xFFB14F36),
            fontSize: 12,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.8,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          title,
          style: const TextStyle(
            color: Color(0xFF2D0C57),
            fontSize: 30,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          description,
          style: const TextStyle(color: Color(0xFF6F607A), fontSize: 15),
        ),
      ],
    );
  }
}
