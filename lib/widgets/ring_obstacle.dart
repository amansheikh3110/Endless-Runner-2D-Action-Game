import 'dart:math';
import 'package:flutter/material.dart';

class RingObstacle extends StatelessWidget {
  final double size;
  final Color baseColor;
  final Color glowColor;

  const RingObstacle({
    super.key,
    required this.size,
    required this.baseColor,
    required this.glowColor,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(size, size),
      painter: RingObstaclePainter(
        baseColor: baseColor,
        glowColor: glowColor,
      ),
    );
  }
}

class RingObstaclePainter extends CustomPainter {
  final Color baseColor;
  final Color glowColor;

  RingObstaclePainter({
    required this.baseColor,
    required this.glowColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final outerRadius = size.width / 2;
    final innerRadius = outerRadius * 0.65;

    // Main ring
    final ringPaint = Paint()
      ..color = baseColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = outerRadius - innerRadius;

    canvas.drawCircle(
      center,
      (outerRadius + innerRadius) / 2,
      ringPaint,
    );

    // Glow segments
    final glowPaint = Paint()
      ..color = glowColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);

    for (int i = 0; i < 4; i++) {
      final startAngle = i * pi / 2;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: outerRadius - 6),
        startAngle,
        pi / 6,
        false,
        glowPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

