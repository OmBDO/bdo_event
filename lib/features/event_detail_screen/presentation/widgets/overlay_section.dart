import 'package:bdo_event/core/model/event_model/event_model.dart';
import 'package:bdo_event/features/event_detail_screen/presentation/pages/event_detail_screen.dart';
import 'package:bdo_event/features/event_detail_screen/presentation/widgets/attendance_profile.dart';
import 'package:bdo_event/features/event_detail_screen/presentation/widgets/event_location_map.dart';
import 'package:bdo_event/features/event_detail_screen/presentation/widgets/location_map.dart';
import 'package:flutter/material.dart';
import 'package:bdo_event/core/util/event_date_formatter.dart';
import 'package:gap/gap.dart';
import 'package:bdo_event/core/util/event_resource.dart';

class OverlayCurveSection extends StatefulWidget {
  const OverlayCurveSection({
    super.key,
    required this.widget,
    required this.event,
    required this.textGrey,
    required this.primaryDark,
    required this.mapBgColor,
    this.attendanceCount,
  });

  final EventDetailPage widget;
  final Event event;
  final Color textGrey;
  final Color primaryDark;
  final Color mapBgColor;
  final int? attendanceCount;

  @override
  State<OverlayCurveSection> createState() => _OverlayCurveSectionState();
}

class _OverlayCurveSectionState extends State<OverlayCurveSection> {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(36),
          topRight: Radius.circular(36),
        ),
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(
          24,
          28,
          24,
          110,
        ), // Bottom padding leaves space for sticky deck
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Location Meta String Header

            Row(
              children: [
                // Main Title Header
                Text(
                  widget.widget.event.title,
                  style: TextStyle(
                    color: widget.primaryDark,
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                    height: 1.25,
                    letterSpacing: -0.3,
                  ),
                ),
                Spacer(),
                Text(
                  AppText.upcomingEvent,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.secondary,
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.4,
                  ),
                ),
              ],
            ),

            Gap(10),

            Row(
              crossAxisAlignment: CrossAxisAlignment
                  .start, // Ensures time and location align at the top
              children: [
                // 1. Time Section
                if (widget.widget.event.startTime != null ||
                    widget.widget.event.endTime != null)
                  Expanded(
                    flex: 2, // Controls proportional horizontal space distribution
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.schedule_outlined,
                          color: widget.textGrey,
                          size: 18,
                        ),
                        const Gap(8),
                        Expanded(
                          // Prevents long time strings from crashing the layout
                          child: Text(
                            '${formatEventTime(widget.widget.event.startTime)} - ${formatEventTime(widget.widget.event.endTime)}',
                            style: TextStyle(
                              color: widget.textGrey,
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                // Spacer between Time and Location if both exist
                if (widget.widget.event.startTime != null ||
                    widget.widget.event.endTime != null)
                  const Gap(12),

                // 2. Location Section
                LocationSection(widget: widget),
              ],
            ),
            const Gap(12),

            // Description Summary Details Text block
            Text(
              widget.widget.event.description,
              style: TextStyle(
                color: widget.textGrey,
                fontSize: 14,
                fontWeight: FontWeight.w400,
                height: 1.5,
              ),
            ),
            const Gap(24),

            // 3. Attendance Counter Face Pile Badge Wrapper Block
            AttendanceProfileWidget(widget: widget),
            const Gap(16),

            EventLocationMap(event: widget.widget.event),
          ],
        ),
      ),
    );
  }
}
