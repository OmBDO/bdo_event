import 'package:bdo_event/core/util/event_resource.dart';
import 'package:flutter/material.dart';

class AnalyticsMetric extends StatelessWidget {
  const AnalyticsMetric({
    required this.label,
    required this.value,
    required this.icon,
    super.key,
  });

  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) => Card(
    margin: const EdgeInsets.only(bottom: 12),
    child: ListTile(
      leading: Icon(icon),
      title: Text(label),
      trailing: Text(
        value,
        style: const TextStyle(
          fontSize: AppSize.text18,
          fontWeight: FontWeight.w800,
        ),
      ),
    ),
  );
}
