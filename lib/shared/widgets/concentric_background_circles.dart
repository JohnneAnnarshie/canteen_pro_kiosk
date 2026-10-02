import 'dart:math' as math;
import 'package:flutter/material.dart';

/// A background widget with concentric ellipses drawn at an angle.
class ConcentricCirclesBackground extends StatelessWidget {
  const ConcentricCirclesBackground({
    super.key,
    required this.child,
    this.color,
    this.angleDegrees = 15,
    this.circleCount = 6,
    this.strokeWidth = 1.0,
    this.opacity = 0.15,
    this.ellipseRatio = 0.5,
  });

  final Widget child;

  /// Color of the ellipses. Defaults to `colorScheme.primary`.
  final Color? color;

  /// Rotation angle in degrees. Defaults to 15.
  final double angleDegrees;

  /// Number of concentric ellipses to draw. Defaults to 6.
  final int circleCount;

  /// Stroke width of each ellipse. Defaults to 1.0.
  final double strokeWidth;

  /// Overall opacity of the ellipses. Defaults to 0.15.
  final double opacity;

  /// Height-to-width ratio of the ellipses.
  /// 1.0 = perfect circle, 0.5 = half as tall as wide (default), 0.25 = very flat.
  final double ellipseRatio;

  @override
  Widget build(BuildContext context) {
    final resolvedColor = color ?? Theme.of(context).colorScheme.primary;

    return Stack(
      children: [
        Positioned.fill(
          child: CustomPaint(
            painter: _ConcentricEllipsesPainter(
              color: resolvedColor.withOpacity(opacity),
              angleDegrees: angleDegrees,
              circleCount: circleCount,
              strokeWidth: strokeWidth,
              ellipseRatio: ellipseRatio,
            ),
          ),
        ),
        child,
      ],
    );
  }
}

class _ConcentricEllipsesPainter extends CustomPainter {
  _ConcentricEllipsesPainter({
    required this.color,
    required this.angleDegrees,
    required this.circleCount,
    required this.strokeWidth,
    required this.ellipseRatio,
  });

  final Color color;
  final double angleDegrees;
  final int circleCount;
  final double strokeWidth;
  final double ellipseRatio;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    final center = Offset(size.width / 2, size.height / 2);
    final angleRadians = angleDegrees * (math.pi / 180);

    // Rotate around center
    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(angleRadians);

    // Largest ellipse fills just past the screen diagonal
    final maxRadius = math.sqrt(
      size.width * size.width + size.height * size.height,
    ) / 2;

    final spacing = maxRadius / circleCount;

    for (int i = 1; i <= circleCount; i++) {
      final rx = spacing * i;           // horizontal radius
      final ry = rx * ellipseRatio;     // vertical radius — flattened

      canvas.drawOval(
        Rect.fromCenter(
          center: Offset.zero, // already translated to center
          width: rx * 2,
          height: ry * 2,
        ),
        paint,
      );
    }

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _ConcentricEllipsesPainter old) =>
      old.color != color ||
          old.angleDegrees != angleDegrees ||
          old.circleCount != circleCount ||
          old.strokeWidth != strokeWidth ||
          old.ellipseRatio != ellipseRatio;
}