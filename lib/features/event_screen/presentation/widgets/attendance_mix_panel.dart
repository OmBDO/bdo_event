import 'dart:math' as math;

import 'package:bdo_event/features/event_screen/presentation/widgets/analytics_palette.dart';
import 'package:bdo_event/features/event_screen/presentation/widgets/analytics_shared.dart';
import 'package:flutter/material.dart';
import 'package:bdo_event/core/util/event_resource.dart';
import 'package:gap/gap.dart';

class AttendanceMixPanel extends StatelessWidget {
  const AttendanceMixPanel({required this.registered, required this.checkedIn, required this.palette, super.key});

  final int registered;
  final int checkedIn;
  final AnalyticsPalette palette;

  @override
  Widget build(BuildContext context) {
    final pending = math.max(registered - checkedIn, 0);
    final conversion = registered == 0 ? 0 : ((checkedIn / registered) * 100).round();
    return AnalyticsPanel(
      palette: palette,
      title: AppText.attendanceMix,
      subtitle: AppText.registrationToArrivalConversion,
      child: SizedBox(
        height: 230,
        child: Row(
          children: [
            SizedBox(
              width: 155,
              child: CustomPaint(
                painter: _AttendanceDonutPainter(checkedIn: checkedIn, pending: pending, palette: palette),
                child: Center(child: Text('$conversion%', style: TextStyle(fontSize: AppSize.text25, fontWeight: FontWeight.w900, color: palette.ink))),
              ),
            ),
            const Gap(AppSpace.space8),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _LegendDot(color: palette.coral, label: AppText.analyticsCheckedIn, value: '$checkedIn'),
                  const Gap(AppSpace.space18),
                  _LegendDot(color: palette.teal.withValues(alpha: .28), label: AppText.awaitingArrival, value: '$pending'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LegendDot extends StatelessWidget {
  const _LegendDot({required this.color, required this.label, required this.value});

  final Color color;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Container(width: 9, height: 9, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
      const Gap(AppSpace.space8),
      Expanded(child: Text(label, style: const TextStyle(fontSize: AppSize.text12))),
      Text(value, style: const TextStyle(fontWeight: FontWeight.w800)),
    ],
  );
}

class _AttendanceDonutPainter extends CustomPainter {
  _AttendanceDonutPainter({required this.checkedIn, required this.pending, required this.palette});

  final int checkedIn;
  final int pending;
  final AnalyticsPalette palette;

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = math.min(size.width, size.height) / 2 - 14;
    final total = math.max(checkedIn + pending, 1);
    var start = -math.pi / 2;
    for (final entry in [(checkedIn, palette.coral), (pending, palette.teal.withValues(alpha: .25))]) {
      final sweep = math.pi * 2 * entry.$1 / total;
      canvas.drawArc(Rect.fromCircle(center: center, radius: radius), start, sweep, false, Paint()..color = entry.$2..style = PaintingStyle.stroke..strokeWidth = 14..strokeCap = StrokeCap.round);
      start += sweep;
    }
  }

  @override
  bool shouldRepaint(covariant _AttendanceDonutPainter oldDelegate) => oldDelegate.checkedIn != checkedIn || oldDelegate.pending != pending;
}
