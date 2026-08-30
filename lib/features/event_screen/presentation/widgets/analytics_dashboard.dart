import 'dart:math' as math;

import 'package:bdo_event/core/model/event_model/event_model.dart';
import 'package:bdo_event/core/util/event_date_formatter.dart';
import 'package:bdo_event/features/event_screen/presentation/widgets/analytics_chart_panel.dart';
import 'package:bdo_event/features/event_screen/presentation/widgets/analytics_insight_panel.dart';
import 'package:bdo_event/features/event_screen/presentation/widgets/analytics_metric_tile.dart';
import 'package:bdo_event/features/event_screen/presentation/widgets/analytics_palette.dart';
import 'package:bdo_event/features/event_screen/presentation/widgets/analytics_shared.dart';
import 'package:bdo_event/features/event_screen/presentation/widgets/attendance_mix_panel.dart';
import 'package:bdo_event/features/profile_screen/presentation/cubit/profile_screen_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AnalyticsDashboard extends StatelessWidget {
  const AnalyticsDashboard({required this.event, required this.checkedIn, required this.isLoadingCheckIns, super.key});

  final Event event;
  final int checkedIn;
  final bool isLoadingCheckIns;

  @override
  Widget build(BuildContext context) {
    final palette = AnalyticsPalette.of(context);
    final registered = event.attendeeCount;
    final capacity = event.capacity;
    final remaining = capacity == null ? null : math.max(capacity - registered, 0);
    final conversion = registered == 0 ? 0.0 : (checkedIn / registered).clamp(0.0, 1.0);
    final fill = capacity == null || capacity == 0 ? null : (registered / capacity).clamp(0.0, 1.0);

    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth >= 820;
        return ListView(
          padding: EdgeInsets.fromLTRB(isWide ? 36 : 20, 12, isWide ? 36 : 20, 40),
          children: [
            _AnalyticsHeading(event: event, palette: palette),
            const SizedBox(height: 24),
            AnalyticsMetricGrid(
              isWide: isWide,
              metrics: [
                AnalyticsMetricData('Registered', '$registered', Icons.groups_2_outlined, palette.teal, 'live total'),
                AnalyticsMetricData('Checked in', isLoadingCheckIns ? '--' : '$checkedIn', Icons.how_to_reg_rounded, palette.coral, '${(conversion * 100).round()}% conversion'),
                AnalyticsMetricData('Capacity', capacity?.toString() ?? 'Open', Icons.event_seat_outlined, palette.gold, capacity == null ? 'no limit' : '${(fill! * 100).round()}% filled'),
                AnalyticsMetricData('Remaining', remaining?.toString() ?? '--', Icons.bolt_rounded, palette.lilac, event.isAvailable ? 'registration open' : 'registration closed'),
              ],
            ),
            const SizedBox(height: 24),
            if (isWide)
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(flex: 3, child: AnalyticsChartPanel(event: event, palette: palette)),
                  const SizedBox(width: 16),
                  Expanded(flex: 2, child: AttendanceMixPanel(registered: registered, checkedIn: checkedIn, palette: palette)),
                ],
              )
            else ...[
              AnalyticsChartPanel(event: event, palette: palette),
              const SizedBox(height: 16),
              AttendanceMixPanel(registered: registered, checkedIn: checkedIn, palette: palette),
            ],
            const SizedBox(height: 16),
            AnalyticsInsightPanel(registered: registered, checkedIn: checkedIn, capacity: capacity, palette: palette),
          ],
        );
      },
    );
  }
}

class _AnalyticsHeading extends StatelessWidget {
  const _AnalyticsHeading({required this.event, required this.palette});

  final Event event;
  final AnalyticsPalette palette;

  @override
  Widget build(BuildContext context) => Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('OPERATIONS / EVENT ANALYSIS', style: TextStyle(color: palette.teal, fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: 1.5)),
            const SizedBox(height: 8),
            Text(event.title, maxLines: 2, overflow: TextOverflow.ellipsis, style: TextStyle(color: palette.ink, fontSize: 28, fontWeight: FontWeight.w900, height: 1.05)),
            const SizedBox(height: 8),
            Text('${formatEventDate(event.date, context.watch<ProfileScreenCubit>().state.dateFormat)}  /  ${event.location}', style: TextStyle(color: palette.muted, fontSize: 13)),
          ],
        ),
      ),
      const SizedBox(width: 16),
      AnalyticsStatusPill(isOpen: event.isAvailable, palette: palette),
    ],
  );
}
