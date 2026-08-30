import 'package:bdo_event/core/util/ui/app_ui.dart';
import 'package:bdo_event/features/event_screen/presentation/widgets/analytics_palette.dart';
import 'package:bdo_event/features/event_screen/presentation/widgets/analytics_shared.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

import 'package:bdo_event/core/util/resource/app_text.dart';

class AnalyticsInsightPanel extends StatelessWidget {
  const AnalyticsInsightPanel({
    required this.registered,
    required this.checkedIn,
    required this.capacity,
    required this.palette,
    super.key,
  });

  final int registered;
  final int checkedIn;
  final int? capacity;
  final AnalyticsPalette palette;

  @override
  Widget build(BuildContext context) {
    final title = capacity != null && registered >= capacity!
        ? AppText.capacityReached
        : checkedIn > 0
        ? AppText.attendanceIsActive
        : AppText.readyForEventDay;
    final message = capacity != null && registered >= capacity!
        ? AppText.eventAtCapacityInsight
        : checkedIn > 0
        ? AppText.attendeesArrived(checkedIn)
        : AppText.noCheckInsRecorded;
    return AnalyticsPanel(
      palette: palette,
      title: AppText.operationalInsight,
      subtitle: AppText.quickReadOnEventState,
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: palette.gold.withValues(alpha: .16),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(Icons.auto_awesome_outlined, color: palette.gold),
          ),
          const Gap(AppSpace.space14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: palette.ink,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const Gap(AppSpace.space4),
                Text(
                  message,
                  style: TextStyle(
                    color: palette.muted,
                    fontSize: AppSize.text12,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
