// Custom Painter to build standard minimalistic map road paths lines loops
import 'package:flutter/material.dart';

class MapLinesPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..strokeWidth = 6
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    final path1 = Path()
      ..moveTo(0, size.height * 0.3)
      ..lineTo(size.width * 0.4, size.height * 0.4)
      ..lineTo(size.width, size.height * 0.1);
    final path2 = Path()
      ..moveTo(size.width * 0.2, 0)
      ..lineTo(size.width * 0.5, size.height)
      ..lineTo(size.width * 0.8, size.height * 0.2);
    canvas.drawPath(path1, paint);
    canvas.drawPath(path2, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
