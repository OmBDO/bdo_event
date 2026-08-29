import 'package:flutter/material.dart';

class ScannerDashboard extends StatelessWidget {
  const ScannerDashboard({
    super.key,
    required this.checkedInCount,
    required this.expectedCount,
    required this.historyCount,
    required this.onHistoryPressed,
  });

  final int? checkedInCount;
  final int? expectedCount;
  final int historyCount;
  final VoidCallback onHistoryPressed;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
    child: Row(
      children: [
        Expanded(
          child: _CounterTile(
            label: 'Checked in',
            value: checkedInCount?.toString() ?? '--',
            icon: Icons.how_to_reg,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _CounterTile(
            label: 'Expected',
            value: expectedCount?.toString() ?? '--',
            icon: Icons.groups_outlined,
          ),
        ),
        IconButton(
          tooltip: 'View scan history',
          onPressed: onHistoryPressed,
          icon: Badge(
            isLabelVisible: historyCount > 0,
            label: Text(historyCount.toString()),
            child: const Icon(Icons.history),
          ),
        ),
      ],
    ),
  );
}

class _CounterTile extends StatelessWidget {
  const _CounterTile({
    required this.label,
    required this.value,
    required this.icon,
  });

  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
    decoration: BoxDecoration(
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      borderRadius: BorderRadius.circular(12),
    ),
    child: Row(
      children: [
        Icon(icon, size: 20),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: Theme.of(context).textTheme.labelSmall),
            Text(value, style: Theme.of(context).textTheme.titleLarge),
          ],
        ),
      ],
    ),
  );
}
