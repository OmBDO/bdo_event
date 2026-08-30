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
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          subtitle,
          style: TextStyle(
            color: theme.colorScheme.primary,
            fontSize: 12,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.8,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          title,
          style: TextStyle(
            color: theme.colorScheme.onSurface,
            fontSize: 30,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          description,
          style: TextStyle(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
            fontSize: 15,
          ),
        ),
      ],
    );
  }
}
