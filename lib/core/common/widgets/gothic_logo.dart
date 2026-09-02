import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';

class GothicLogo extends StatelessWidget {
  final double size;
  final bool glowing;
  const GothicLogo({super.key, this.size = 100, this.glowing = false});

  @override
  Widget build(BuildContext context) {
    final painter = _GothicLogoPainter();
    Widget svg = CustomPaint(size: Size(size, size), painter: painter);
    if (glowing) {
      svg = DecoratedBox(
        decoration: const BoxDecoration(),
        child: ImageFiltered(
          imageFilter: ImageFilter.blur(sigmaX: 0, sigmaY: 0),
          child: svg,
        ),
      );
      // Approximate the CSS drop-shadow glow with a glow behind the painter.
      return Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: size * 1.3,
            height: size * 1.3,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(color: const Color(0xFF00CCFF).withOpacity(0.5), blurRadius: size * 0.35, spreadRadius: size * 0.02),
                BoxShadow(color: const Color(0xFF00CCFF).withOpacity(0.25), blurRadius: size * 0.6),
              ],
            ),
          ),
          svg,
        ],
      );
    }
    return svg;
  }
}

class _GothicLogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final s = size.width / 100; // original viewBox is 0..100
    Offset p(double x, double y) => Offset(x * s, y * s);

    final chromeGradient = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFF8A8D9E), Color(0xFFC8CDD8), Color(0xFFECEEF8), Color(0xFF9CA0B0)],
        stops: [0.0, 0.3, 0.6, 1.0],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height))
      ..style = PaintingStyle.stroke;

    final chromeFill = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFF8A8D9E), Color(0xFFC8CDD8), Color(0xFFECEEF8), Color(0xFF9CA0B0)],
        stops: [0.0, 0.3, 0.6, 1.0],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height))
      ..style = PaintingStyle.fill;

    // Outer rings
    canvas.drawCircle(p(50, 50), 46 * s, Paint()..color = const Color(0x80C2C5D6)..style = PaintingStyle.stroke..strokeWidth = 1.5 * s);
    canvas.drawCircle(p(50, 50), 42 * s, chromeGradient..strokeWidth = 2.5 * s);
    canvas.drawCircle(p(50, 50), 38 * s, Paint()..color = const Color(0x33C2C5D6)..style = PaintingStyle.stroke..strokeWidth = 1 * s);

    // 8-pointed gothic crown
    final linePaint = Paint()
      ..shader = chromeGradient.shader
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5 * s;
    for (final deg in [0, 45, 90, 135, 180, 225, 270, 315]) {
      final r = math.pi * deg / 180;
      final tip1 = p(50 + math.sin(r - 0.18) * 47, 50 - math.cos(r - 0.18) * 47);
      final tip = p(50 + math.sin(r) * 50, 50 - math.cos(r) * 50);
      final tip2 = p(50 + math.sin(r + 0.18) * 47, 50 - math.cos(r + 0.18) * 47);
      final path = Path()
        ..moveTo(tip1.dx, tip1.dy)
        ..lineTo(tip.dx, tip.dy)
        ..lineTo(tip2.dx, tip2.dy);
      canvas.drawPath(path, linePaint);
    }

    // Diamond ornaments at cardinal points
    for (final deg in [0, 90, 180, 270]) {
      final r = math.pi * deg / 180;
      final cx = 50 + math.sin(r) * 42;
      final cy = 50 - math.cos(r) * 42;
      const d = 3.0;
      final path = Path()
        ..moveTo((cx) * s, (cy - d) * s)
        ..lineTo((cx + d) * s, (cy) * s)
        ..lineTo((cx) * s, (cy + d) * s)
        ..lineTo((cx - d) * s, (cy) * s)
        ..close();
      canvas.drawPath(path, chromeFill);
    }

    // Eye — almond shape
    final eyePath = Path()
      ..moveTo(18 * s, 50 * s)
      ..quadraticBezierTo(34 * s, 30 * s, 50 * s, 30 * s)
      ..quadraticBezierTo(66 * s, 30 * s, 82 * s, 50 * s)
      ..quadraticBezierTo(66 * s, 70 * s, 50 * s, 70 * s)
      ..quadraticBezierTo(34 * s, 70 * s, 18 * s, 50 * s)
      ..close();
    canvas.drawPath(eyePath, Paint()..color = const Color(0x0F00CCFF)..style = PaintingStyle.fill);
    canvas.drawPath(eyePath, Paint()..shader = chromeGradient.shader..style = PaintingStyle.stroke..strokeWidth = 1.8 * s);

    // Iris ring + fill + pupil
    canvas.drawCircle(p(50, 50), 13 * s, Paint()..shader = chromeGradient.shader..style = PaintingStyle.stroke..strokeWidth = 1.5 * s);
    canvas.drawCircle(
        p(50, 50),
        11 * s,
        Paint()
          ..shader = const RadialGradient(colors: [Color(0xFF001832), Color(0xFF000510)])
              .createShader(Rect.fromCircle(center: p(50, 50), radius: 11 * s)));
    canvas.drawCircle(p(50, 50), 5.5 * s, chromeFill);
    canvas.drawCircle(p(52.5, 47.5), 1.8 * s, Paint()..color = Colors.white.withOpacity(0.85));

    // Eyelash marks
    final lashPaint = Paint()
      ..shader = chromeGradient.shader
      ..strokeWidth = 1.5 * s
      ..strokeCap = StrokeCap.round;
    for (final i in [-1, 0, 1]) {
      final baseX = 50 + i * 8.0;
      final startYUp = 30 + i.abs() * 4.0;
      canvas.drawLine(p(baseX, startYUp), p(baseX, startYUp - 5), lashPaint);
      final startYDown = 70 - i.abs() * 4.0;
      canvas.drawLine(p(baseX, startYDown), p(baseX, startYDown + 5), lashPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
