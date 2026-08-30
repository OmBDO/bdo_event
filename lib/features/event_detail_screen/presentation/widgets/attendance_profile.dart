import 'package:bdo_event/core/common/loading_shimmer/loading_shimmer.dart';
import 'package:bdo_event/core/di/app_dependencies.dart';
import 'package:bdo_event/core/model/user_model/event_attendee.dart';
import 'package:bdo_event/core/prefs/supabase_store.dart';
import 'package:bdo_event/core/util/event_resource.dart';
import 'package:bdo_event/features/event_detail_screen/presentation/pages/event_attendees_page.dart';
import 'package:bdo_event/features/event_detail_screen/presentation/widgets/overlay_section.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

class AttendanceProfileWidget extends StatelessWidget {
  const new({super.key, required this.widget});

  final OverlayCurveSection widget;

  String _roundedCount(int count) {
    if (count < 10) return '$count';
    final unit = count < 100 ? 10 : 100;
    return '${(count ~/ unit) * unit}+';
  }

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
                    fontSize: AppSize.text9,
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

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        border: Border.all(
          color: Theme.of(context).colorScheme.secondary.withAlpha(66),
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => EventAttendeesPage(event: widget.event),
          ),
        ),
        child: FutureBuilder<List<EventAttendee>>(
          future: getIt<EventStore>().loadEventAttendees(widget.event.id),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const AttendeeSummaryShimmer();
            }
            final attendees = snapshot.data ?? const <EventAttendee>[];
            return Row(
              children: [
                _buildAvatarStack(attendees),
                const Gap(AppSpace.space12),
                Text(
                  snapshot.hasData
                      ? '${attendees.length} ${AppText.attendees}'
                      : AppText.attend100Plus,
                  style: TextStyle(
                    color: widget
                        .primaryDark, // Used widget.primaryDark consistently
                    fontSize: AppSize.text14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const Spacer(),
                CircleAvatar(
                  radius: 14,
                  backgroundColor: Theme.of(context).colorScheme.surface,
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
    );
  }
}
