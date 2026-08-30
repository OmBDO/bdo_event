import 'package:bdo_event/core/model/event_model/event_model.dart';
import 'package:bdo_event/core/di/app_dependencies.dart';
import 'package:bdo_event/core/prefs/supabase_store.dart';
import 'package:bdo_event/features/event_screen/presentation/widgets/analytics_metric.dart';
import 'package:flutter/material.dart';
import 'package:bdo_event/core/util/event_date_formatter.dart';
import 'package:bdo_event/features/profile_screen/presentation/cubit/profile_screen_cubit.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class EventAnalyticsPage extends StatelessWidget {
  const EventAnalyticsPage({required this.event, super.key});

  final Event event;

  @override
  Widget build(BuildContext context) {
    final remainingCapacity = event.capacity == null
        ? null
        : event.capacity! - event.attendeeCount;

    return Scaffold(
      appBar: AppBar(title: const Text('Event analytics')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(
            event.title,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 8),
          Text(
            '${formatEventDate(event.date, context.watch<ProfileScreenCubit>().state.dateFormat)} • ${event.location}',
          ),
          const SizedBox(height: 24),
          AnalyticsMetric(
            label: 'Registered attendees',
            value: event.attendeeCount.toString(),
            icon: Icons.groups_outlined,
          ),
          FutureBuilder<int>(
            future: getIt<EventStore>().loadCheckedInCount(event.id),
            builder: (context, snapshot) => AnalyticsMetric(
              label: 'Checked-in attendees',
              value: snapshot.hasError ? 'Unavailable' : '${snapshot.data ?? 0}',
              icon: Icons.how_to_reg_outlined,
            ),
          ),
          AnalyticsMetric(
            label: 'Capacity',
            value: event.capacity?.toString() ?? 'Unlimited',
            icon: Icons.event_seat_outlined,
          ),
          AnalyticsMetric(
            label: 'Remaining capacity',
            value: remainingCapacity == null
                ? 'Unlimited'
                : remainingCapacity.clamp(0, event.capacity!).toString(),
            icon: Icons.person_add_alt_1_outlined,
          ),
          AnalyticsMetric(
            label: 'Registration status',
            value: event.isAvailable ? 'Open' : 'Closed',
            icon: Icons.campaign_outlined,
          ),
        ],
      ),
    );
  }
}
