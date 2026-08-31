import 'dart:math' as math;

import 'package:bdo_event/core/model/event_model/event_model.dart';
import 'package:bdo_event/features/event_screen/presentation/widgets/analytics_palette.dart';
import 'package:bdo_event/features/event_screen/presentation/widgets/analytics_shared.dart';
import 'package:flutter/material.dart';

import 'package:bdo_event/core/util/resource/app_text.dart';

class AnalyticsChartPanel extends StatelessWidget {
  const AnalyticsChartPanel({
    required this.event,
    required this.palette,
    super.key,
  });

  final Event event;
  final AnalyticsPalette palette;

  @override
  Widget build(BuildContext context) => AnalyticsPanel(
    palette: palette,
    title: AppText.capacityTrajectory,
    subtitle: AppText.registrationsMappedAgainstCapacity,
    child: SizedBox(
      height: 230,
      child: CustomPaint(
        painter: _CapacityTrajectoryPainter(event: event, palette: palette),
        child: const SizedBox.expand(),
      ),
    ),
  );
}

class _CapacityTrajectoryPainter extends CustomPainter {
  _CapacityTrajectoryPainter({required this.event, required this.palette});

  final Event event;
  final AnalyticsPalette palette;

  @override
  void paint(Canvas canvas, Size size) {
    final chart = Rect.fromLTWH(36, 12, size.width - 48, size.height - 42);
    final maxValue = math
        .max(
          event.capacity ?? event.attendeeCount,
          math.max(event.attendeeCount, 1),
        )
        .toDouble();
    final values = [0.0, 0.0, 0.0, event.attendeeCount.toDouble()];
    final step = chart.width / (values.length - 1);
    final line = Path();

    for (var i = 0; i < values.length; i++) {
      final point = Offset(
        chart.left + step * i,
        chart.bottom - (values[i] / maxValue) * chart.height,
      );
      if (i == 0) {
        line.moveTo(point.dx, point.dy);
      } else {
        line.lineTo(point.dx, point.dy);
      }
    }

    final fill = Path.from(line)
      ..lineTo(chart.right, chart.bottom)
      ..lineTo(chart.left, chart.bottom)
      ..close();
    canvas.drawPath(
      fill,
      Paint()
        ..shader = LinearGradient(
          colors: [
            palette.teal.withValues(alpha: .3),
            palette.teal.withValues(alpha: .02),
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ).createShader(chart),
    );

    final grid = Paint()
      ..color = palette.border
      ..strokeWidth = 1;
    for (var i = 0; i < 4; i++) {
      final y = chart.top + chart.height * i / 3;
      canvas.drawLine(Offset(chart.left, y), Offset(chart.right, y), grid);
    }

    canvas.drawPath(
      line,
      Paint()
        ..color = palette.teal
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3
        ..strokeCap = StrokeCap.round,
    );
    for (var i = 0; i < values.length; i++) {
      final point = Offset(
        chart.left + step * i,
        chart.bottom - (values[i] / maxValue) * chart.height,
      );
      canvas.drawCircle(point, 5, Paint()..color = palette.panel);
      canvas.drawCircle(point, 3, Paint()..color = palette.teal);
    }

    _drawText(
      canvas,
      '${event.attendeeCount}',
      Offset(3, chart.top - 7),
      palette.muted,
      10,
    );
    _drawText(canvas, '0', Offset(16, chart.bottom - 6), palette.muted, 10);
    for (var i = 0; i < 4; i++) {
      final label = i == 3
          ? 'NOW'
          : i == 0
          ? 'START'
          : 'TARGET';
      _drawText(
        canvas,
        label,
        Offset(chart.left + step * i - 12, chart.bottom + 12),
        palette.muted,
        9,
      );
    }
  }

  void _drawText(
    Canvas canvas,
    String text,
    Offset offset,
    Color color,
    double size,
  ) {
    final painter = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          color: color,
          fontSize: size,
          fontWeight: FontWeight.w700,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    painter.paint(canvas, offset);
  }

  @override
  bool shouldRepaint(covariant _CapacityTrajectoryPainter oldDelegate) =>
      oldDelegate.event.attendeeCount != event.attendeeCount;
}
