import 'package:flutter/material.dart';

class ScannerTargetOverlay extends StatefulWidget {
  const ScannerTargetOverlay({super.key});

  @override
  State<ScannerTargetOverlay> createState() => _ScannerTargetOverlayState();
}

class _ScannerTargetOverlayState extends State<ScannerTargetOverlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animationController = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 2),
  )..repeat();

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: _animationController,
    builder: (context, child) => CustomPaint(
      painter: _ScannerTargetPainter(_animationController.value),
      child: child,
    ),
    child: const SizedBox.expand(),
  );
}

class _ScannerTargetPainter extends CustomPainter {
  const _ScannerTargetPainter(this.progress);

  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    final boxSize = size.shortestSide * 0.68;
    final rect = Rect.fromCenter(
      center: size.center(Offset.zero),
      width: boxSize,
      height: boxSize,
    );
    final cornerPaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 4
      ..style = PaintingStyle.stroke;
    final linePaint = Paint()
      ..color = Colors.cyanAccent
      ..strokeWidth = 2;
    const cornerLength = 28.0;

    for (final corner in [
      [rect.topLeft, rect.topLeft + const Offset(cornerLength, 0)],
      [rect.topLeft, rect.topLeft + const Offset(0, cornerLength)],
      [rect.topRight, rect.topRight - const Offset(cornerLength, 0)],
      [rect.topRight, rect.topRight + const Offset(0, cornerLength)],
      [rect.bottomLeft, rect.bottomLeft + const Offset(cornerLength, 0)],
      [rect.bottomLeft, rect.bottomLeft - const Offset(0, cornerLength)],
      [rect.bottomRight, rect.bottomRight - const Offset(cornerLength, 0)],
      [rect.bottomRight, rect.bottomRight - const Offset(0, cornerLength)],
    ]) {
      canvas.drawLine(corner[0], corner[1], cornerPaint);
    }

    final scanY = rect.top + rect.height * progress;
    canvas.drawLine(
      Offset(rect.left + 8, scanY),
      Offset(rect.right - 8, scanY),
      linePaint,
    );
  }

  @override
  bool shouldRepaint(covariant _ScannerTargetPainter oldDelegate) =>
      oldDelegate.progress != progress;
}
