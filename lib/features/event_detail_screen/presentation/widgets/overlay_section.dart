import 'package:bdo_event/core/model/event_model/event_model.dart';
import 'package:bdo_event/features/event_detail_screen/presentation/pages/event_detail_screen.dart';
import 'package:bdo_event/features/event_detail_screen/presentation/pages/event_attendees_page.dart';
import 'package:bdo_event/features/event_detail_screen/presentation/widgets/event_location_map.dart';
import 'package:bdo_event/core/model/user_model/event_attendee.dart';
import 'package:bdo_event/core/prefs/supabase_store.dart';
import 'package:bdo_event/core/di/app_dependencies.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:bdo_event/core/util/event.resource.dart';

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
  bool _isExpanded = false;
  // Multi-Avatar Layering GeneratorWidget
  Widget _buildAvatarStack(List<EventAttendee> attendees) {
    final visibleAttendees = attendees.take(4).toList();
    final hasOverflow = attendees.length > visibleAttendees.length;
    final width = visibleAttendees.isEmpty
        ? 28.0
        : (visibleAttendees.length - 1) * 16.0 + 28.0 + (hasOverflow ? 16 : 0);

    return SizedBox(
      width: width,
      height: 28,
      child: Stack(
        children: [
          ...visibleAttendees.asMap().entries.map((entry) {
            return Positioned(
              left: entry.key * 16.0,
              child: EventAttendeeAvatar(attendee: entry.value),
            );
          }),
          if (hasOverflow)
            Positioned(
              left: visibleAttendees.length * 16.0,
              child: CircleAvatar(
                radius: 14,
                backgroundColor: Colors.amber.shade100,
                child: Text(
                  _roundedCount(attendees.length),
                  style: const TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                    color: Colors.amber,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  String _roundedCount(int count) {
    if (count < 10) return '$count';
    final unit = count < 100 ? 10 : 100;
    return '${(count ~/ unit) * unit}+';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
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
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.only(
                    top: 2.0,
                  ), // Aligns icon with first line of text
                  child: Icon(
                    Icons.location_on_rounded,
                    color: Colors.black26,
                    size: 16,
                  ),
                ),
                const Gap(6),
                // FIXED: Wrapped the text/arrow cluster in Expanded to prevent layout overflow
                Expanded(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              _isExpanded = !_isExpanded;
                            });
                          },
                          child: Text(
                            widget.widget.event.locationAddress ??
                                widget.widget.event.location,
                            maxLines: _isExpanded ? null : 1,
                            style: TextStyle(
                              overflow: _isExpanded
                                  ? TextOverflow.visible
                                  : TextOverflow.ellipsis,
                              color: widget.textGrey,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              height: 1.2, // Explicit line height ensures reliable vertical baseline alignment
                            ),
                          ),
                        ),
                      ),
                      IconButton(
                        alignment: Alignment.topCenter, // Aligns internal icon graphics to the top bounding box
                        padding: EdgeInsets
                            .zero, // Eliminates all inner button padding
                        constraints: const BoxConstraints(), // Overrides default 48x48 tap target constraints
                        style: const ButtonStyle(
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap, // Shrinks touch bounds to match the strict size
                        ),
                        icon: Icon(
                          _isExpanded
                              ? Icons.keyboard_arrow_up
                              : Icons.keyboard_arrow_down,
                          color: widget.textGrey,
                          size: 20,
                        ),
                        onPressed: () {
                          setState(() {
                            _isExpanded = !_isExpanded;
                          });
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const Gap(12),

            const Text(
              AppText.upcomingEvent,
              style: TextStyle(
                color: Colors.deepOrange,
                fontSize: 11,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.4,
              ),
            ),
            const Gap(8),

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
            const Gap(14),

            // Description Summary Details Text block
            Text(
              AppText.eventDetailDescription,
              style: TextStyle(
                color: widget.textGrey,
                fontSize: 14,
                fontWeight: FontWeight.w400,
                height: 1.5,
              ),
            ),
            const Gap(24),

            // 3. Attendance Counter Face Pile Badge Wrapper Block
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFF3F7F9),
                borderRadius: BorderRadius.circular(16),
              ),
              child: InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => EventAttendeesPage(event: widget.event),
                  ),
                ),
                child: FutureBuilder<List<EventAttendee>>(
                  future: getIt<EventStore>().loadEventAttendees(
                    widget.event.id,
                  ),
                  builder: (context, snapshot) {
                    final attendees = snapshot.data ?? const <EventAttendee>[];
                    return Row(
                      children: [
                        _buildAvatarStack(attendees),
                        const Gap(12),
                        Text(
                          snapshot.hasData
                              ? '${attendees.length} ${AppText.attendees}'
                              : AppText.attend100Plus,
                          style: TextStyle(
                            color: widget.primaryDark, // Used widget.primaryDark consistently
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const Spacer(),
                        CircleAvatar(
                          radius: 14,
                          backgroundColor: Colors.white,
                          child: Icon(
                            Icons.arrow_forward_ios_rounded,
                            size: 10,
                            color: widget.primaryDark,
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),
            const Gap(16),

            EventLocationMap(event: widget.widget.event),
          ],
        ),
      ),
    );
  }
}
