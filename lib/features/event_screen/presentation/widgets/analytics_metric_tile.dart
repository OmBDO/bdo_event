import 'package:flutter/material.dart';

class AnalyticsMetricData {
  const AnalyticsMetricData(
    this.label,
    this.value,
    this.icon,
    this.color,
    this.note,
  );

  final String label;
  final String value;
  final IconData icon;
  final Color color;
  final String note;
}

class AnalyticsMetricGrid extends StatelessWidget {
  const AnalyticsMetricGrid({
    required this.metrics,
    required this.isWide,
    super.key,
  });

  final List<AnalyticsMetricData> metrics;
  final bool isWide;

  @override
  Widget build(BuildContext context) => GridView.builder(
    shrinkWrap: true,
    physics: const NeverScrollableScrollPhysics(),
    itemCount: metrics.length,
    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
      crossAxisCount: isWide ? 4 : 2,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: isWide ? 1.65 : 1.38,
    ),
    itemBuilder: (_, index) => _AnalyticsMetricTile(data: metrics[index]),
  );
}

class _AnalyticsMetricTile extends StatelessWidget {
  const _AnalyticsMetricTile({required this.data});

  final AnalyticsMetricData data;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: data.color.withValues(alpha: .09),
      border: Border.all(color: data.color.withValues(alpha: .2)),
      borderRadius: BorderRadius.circular(10),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(data.icon, color: data.color, size: 21),
        const Spacer(),
        Text(
          data.value,
          style: TextStyle(
            color: data.color,
            fontSize: 24,
            fontWeight: FontWeight.w900,
          ),
        ),
        Text(data.label, style: const TextStyle(fontWeight: FontWeight.w700)),
        Text(
          data.note,
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurface
                .withValues(alpha: .55),
            fontSize: 10,
          ),
        ),
      ],
    ),
  );
}
