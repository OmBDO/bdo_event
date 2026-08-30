import 'package:bdo_event/features/event_screen/presentation/widgets/analytics_palette.dart';
import 'package:bdo_event/features/event_screen/presentation/widgets/analytics_shared.dart';
import 'package:flutter/material.dart';

class AnalyticsInsightPanel extends StatelessWidget {
  const AnalyticsInsightPanel({required this.registered, required this.checkedIn, required this.capacity, required this.palette, super.key});

  final int registered;
  final int checkedIn;
  final int? capacity;
  final AnalyticsPalette palette;

  @override
  Widget build(BuildContext context) {
    final title = capacity != null && registered >= capacity! ? 'Capacity reached' : checkedIn > 0 ? 'Attendance is active' : 'Ready for event day';
    final message = capacity != null && registered >= capacity! ? 'Your event is at capacity. Keep an eye on check-in throughput.' : checkedIn > 0 ? '$checkedIn attendee${checkedIn == 1 ? '' : 's'} have arrived. The live conversion signal is updating.' : 'No check-ins recorded yet. This panel will become live when attendees arrive.';
    return AnalyticsPanel(
      palette: palette,
      title: 'Operational insight',
      subtitle: 'A quick read on the current event state',
      child: Row(
        children: [
          Container(width: 44, height: 44, decoration: BoxDecoration(color: palette.gold.withValues(alpha: .16), borderRadius: BorderRadius.circular(12)), child: Icon(Icons.auto_awesome_outlined, color: palette.gold)),
          const SizedBox(width: 14),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: TextStyle(color: palette.ink, fontWeight: FontWeight.w800)), const SizedBox(height: 4), Text(message, style: TextStyle(color: palette.muted, fontSize: 12, height: 1.35))])),
        ],
      ),
    );
  }
}
