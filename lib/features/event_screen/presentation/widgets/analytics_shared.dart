import 'package:bdo_event/features/event_screen/presentation/widgets/analytics_palette.dart';
import 'package:flutter/material.dart';

class AnalyticsPanel extends StatelessWidget {
  const AnalyticsPanel({
    required this.palette,
    required this.title,
    required this.subtitle,
    required this.child,
    super.key,
  });

  final AnalyticsPalette palette;
  final String title;
  final String subtitle;
  final Widget child;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(18),
    decoration: BoxDecoration(
      color: palette.panel,
      border: Border.all(color: palette.border),
      borderRadius: BorderRadius.circular(12),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: TextStyle(color: palette.ink, fontWeight: FontWeight.w800, fontSize: 16)),
        const SizedBox(height: 3),
        Text(subtitle, style: TextStyle(color: palette.muted, fontSize: 11)),
        const SizedBox(height: 18),
        child,
      ],
    ),
  );
}

class AnalyticsStatusPill extends StatelessWidget {
  const AnalyticsStatusPill({required this.isOpen, required this.palette, super.key});

  final bool isOpen;
  final AnalyticsPalette palette;

  @override
  Widget build(BuildContext context) {
    final color = isOpen ? palette.teal : palette.coral;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(color: color.withValues(alpha: .12), borderRadius: BorderRadius.circular(20)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(width: 7, height: 7, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
          const SizedBox(width: 6),
          Text(isOpen ? 'OPEN' : 'CLOSED', style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1)),
        ],
      ),
    );
  }
}
