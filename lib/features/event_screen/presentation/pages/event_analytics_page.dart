import 'package:bdo_event/core/di/app_dependencies.dart';
import 'package:bdo_event/core/model/event_model/event_model.dart';
import 'package:bdo_event/core/prefs/supabase_store.dart';
import 'package:bdo_event/features/event_screen/presentation/widgets/analytics_dashboard.dart';
import 'package:flutter/material.dart';
import 'package:bdo_event/core/util/event_resource.dart';
import 'package:gap/gap.dart';

class EventAnalyticsPage extends StatefulWidget {
  const EventAnalyticsPage({required this.event, super.key});

  final Event event;

  @override
  State<EventAnalyticsPage> createState() => _EventAnalyticsPageState();
}

class _EventAnalyticsPageState extends State<EventAnalyticsPage> {
  @override
  Widget build(BuildContext context) {
    final event = widget.event;
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppText.eventAnalysis),
        actions: [
          IconButton(
            tooltip: AppText.refreshAnalytics,
            onPressed: () => setState(() {}),
            icon: const Icon(Icons.refresh_rounded),
          ),
          const Gap(AppSpace.space8),
        ],
      ),
      body: FutureBuilder<int>(
        future: getIt<EventStore>().loadCheckedInCount(event.id),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text(AppText.unableToLoadAnalytics));
          }
          return AnalyticsDashboard(
            event: event,
            checkedIn: snapshot.data ?? 0,
            isLoadingCheckIns:
                snapshot.connectionState == ConnectionState.waiting,
          );
        },
      ),
    );
  }
}
