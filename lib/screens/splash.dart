import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:xpense/controllers/splashprovider.dart';
import 'dart:math' as math;

class Splash extends StatelessWidget {
  const Splash({super.key});

  @override
  Widget build(BuildContext context) {
    Future.delayed(const Duration(seconds: 3), () {
      if (context.mounted) {
        Provider.of<SplashProvider>(context, listen: false).completeSplash();
      }
    });
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Hexagonal icon with banknote design
            CustomPaint(
              size: const Size(120, 120),
              painter: LogoPainter(),
            ),
            const SizedBox(height: 30),
            // XPENSE text
            const Text(
              'XPENSE',
              style: TextStyle(
                color: Colors.white,
                fontSize: 36,
                fontWeight: FontWeight.bold,
                letterSpacing: 4,
                fontFamily: 'Roboto',
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class LogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;

    final fillPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 3;

    // Draw outer hexagon
    final outerHexagon = _createHexagon(center, radius);
    canvas.drawPath(outerHexagon, paint);

    // Draw inner hexagon (concentric)
    final innerRadius = radius * 0.85;
    final innerHexagon = _createHexagon(center, innerRadius);
    canvas.drawPath(innerHexagon, paint);

    // Draw banknote rectangle
    final banknoteWidth = radius * 0.6;
    final banknoteHeight = radius * 0.4;
    final banknoteRect = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: center,
        width: banknoteWidth,
        height: banknoteHeight,
      ),
      const Radius.circular(4),
    );
    canvas.drawRRect(banknoteRect, fillPaint);

    // Draw center circle
    canvas.drawCircle(center, 4, fillPaint);

    // Draw curved arrows
    final arrowPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;

    // Bottom-left arrow curving to center
    final bottomLeft = Offset(
      center.dx - banknoteWidth / 2 + 8,
      center.dy + banknoteHeight / 2 - 8,
    );
    final path1 = Path();
    path1.moveTo(bottomLeft.dx, bottomLeft.dy);
    path1.quadraticBezierTo(
      bottomLeft.dx + 5,
      bottomLeft.dy - 10,
      center.dx - 2,
      center.dy - 2,
    );
    canvas.drawPath(path1, arrowPaint);
    _drawArrowhead(canvas, Offset(center.dx - 2, center.dy - 2), 45, arrowPaint);

    // Top-right arrow curving to center
    final topRight = Offset(
      center.dx + banknoteWidth / 2 - 8,
      center.dy - banknoteHeight / 2 + 8,
    );
    final path2 = Path();
    path2.moveTo(topRight.dx, topRight.dy);
    path2.quadraticBezierTo(
      topRight.dx - 5,
      topRight.dy + 10,
      center.dx + 2,
      center.dy + 2,
    );
    canvas.drawPath(path2, arrowPaint);
    _drawArrowhead(canvas, Offset(center.dx + 2, center.dy + 2), 225, arrowPaint);
  }

  Path _createHexagon(Offset center, double radius) {
    final path = Path();
    for (int i = 0; i < 6; i++) {
      final angle = (math.pi / 3) * i - math.pi / 2;
      final x = center.dx + radius * math.cos(angle);
      final y = center.dy + radius * math.sin(angle);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();
    return path;
  }

  void _drawArrowhead(Canvas canvas, Offset point, double angle, Paint paint) {
    final arrowSize = 6.0;
    final angleRad = angle * math.pi / 180;
    final path = Path();
    path.moveTo(point.dx, point.dy);
    path.lineTo(
      point.dx - arrowSize * math.cos(angleRad - math.pi / 6),
      point.dy - arrowSize * math.sin(angleRad - math.pi / 6),
    );
    path.moveTo(point.dx, point.dy);
    path.lineTo(
      point.dx - arrowSize * math.cos(angleRad + math.pi / 6),
      point.dy - arrowSize * math.sin(angleRad + math.pi / 6),
    );
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
