import 'dart:math' as math;
import 'dart:ui' show PathMetric;

import 'package:flutter/material.dart';

import '../theme/game_theme.dart';

class KartTrack extends StatelessWidget {
  const KartTrack({super.key, required this.distance, required this.rpm});

  // Signed distance lets braking and reverse RPM move the kart backwards.
  final double distance;
  final double rpm;

  @override
  Widget build(BuildContext context) => RepaintBoundary(
    child: ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: CustomPaint(
        painter: _KartPainter(distance: distance, rpm: rpm),
        child: const SizedBox.expand(),
      ),
    ),
  );
}

class _KartPainter extends CustomPainter {
  const _KartPainter({required this.distance, required this.rpm});

  final double distance;
  final double rpm;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(Offset.zero & size, Paint()..color = GameColors.panel);

    final center = Offset(size.width / 2, size.height / 2 + 3);
    final radius = size.height * 0.28;
    final halfStraight =
        (math.min(size.width - 55, size.height * 1.55) - radius * 2) / 2;
    const roadWidth = 21.0;
    final path =
        Path()
          ..moveTo(center.dx, center.dy - radius)
          ..lineTo(center.dx + halfStraight, center.dy - radius)
          ..arcToPoint(
            Offset(center.dx + halfStraight, center.dy + radius),
            radius: Radius.circular(radius),
          )
          ..lineTo(center.dx - halfStraight, center.dy + radius)
          ..arcToPoint(
            Offset(center.dx - halfStraight, center.dy - radius),
            radius: Radius.circular(radius),
          )
          ..close();
    final metric = path.computeMetrics().first;

    // The alternating outer strip sits behind the dark road, leaving a thin
    // red-and-white curb on each side like the supplied oval reference.
    canvas.drawPath(
      path,
      Paint()
        ..color = GameColors.curbRed
        ..style = PaintingStyle.stroke
        ..strokeWidth = roadWidth + 7,
    );
    _dashPath(
      canvas,
      metric,
      dash: 9,
      gap: 9,
      color: GameColors.ink,
      strokeWidth: roadWidth + 7,
    );
    canvas.drawPath(
      path,
      Paint()
        ..color = GameColors.road
        ..style = PaintingStyle.stroke
        ..strokeWidth = roadWidth,
    );
    _dashPath(
      canvas,
      metric,
      dash: 9,
      gap: 9,
      color: GameColors.ink.withValues(alpha: 0.88),
      strokeWidth: 1.5,
    );

    // A two-column checkerboard crosses the top straight at the lap origin.
    final startY = center.dy - radius;
    for (var row = 0; row < 6; row++) {
      for (var column = 0; column < 2; column++) {
        canvas.drawRect(
          Rect.fromLTWH(
            center.dx - 4 + column * 4,
            startY - roadWidth / 2 + row * roadWidth / 6,
            4,
            roadWidth / 6,
          ),
          Paint()
            ..color = (row + column).isEven ? GameColors.ink : GameColors.road,
        );
      }
    }

    final lapDistance =
        ((distance + 23) % metric.length + metric.length) % metric.length;
    final tangent = metric.getTangentForOffset(lapDistance)!;
    canvas.save();
    canvas.translate(tangent.position.dx, tangent.position.dy);
    canvas.rotate(
      math.atan2(tangent.vector.dy, tangent.vector.dx) +
          math.pi / 2 +
          (rpm < -1 ? math.pi : 0),
    );
    _paintKart(canvas);
    canvas.restore();

    //_label(canvas, 'OVAL KART TRACK', const Offset(12, 7));
    final direction =
        rpm > 1
            ? 'CLOCKWISE'
            : rpm < -1
            ? 'COUNTERCLOCKWISE'
            : 'STATIONARY';
    _label(
      canvas,
      direction,
      Offset(size.width - 12, 7),
      alignRight: true,
      color: rpm < -1 ? GameColors.coral : GameColors.muted,
    );
  }

  void _dashPath(
    Canvas canvas,
    PathMetric metric, {
    required double dash,
    required double gap,
    required Color color,
    required double strokeWidth,
  }) {
    final paint =
        Paint()
          ..color = color
          ..style = PaintingStyle.stroke
          ..strokeWidth = strokeWidth;
    for (var offset = 0.0; offset < metric.length; offset += dash + gap) {
      canvas.drawPath(
        metric.extractPath(offset, math.min(offset + dash, metric.length)),
        paint,
      );
    }
  }

  void _paintKart(Canvas canvas) {
    // Top-down outline: exposed wheels, curved nose, two frame rails, a
    // steering wheel and a seat. It stays legible over the road at phone size.
    final outline =
        Paint()
          ..color = GameColors.ink
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.1
          ..strokeCap = StrokeCap.round
          ..strokeJoin = StrokeJoin.round;
    final wheelFill = Paint()..color = GameColors.ink;
    for (final x in [-10.0, 10.0]) {
      for (final y in [-7.5, 7.5]) {
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromCenter(center: Offset(x, y), width: 4, height: 7),
            const Radius.circular(1.2),
          ),
          wheelFill,
        );
      }
    }
    canvas.drawPath(
      Path()
        ..moveTo(-7, -8)
        ..quadraticBezierTo(0, -15, 7, -8)
        ..moveTo(-7, -9)
        ..lineTo(-7, 11)
        ..lineTo(7, 11)
        ..lineTo(7, -9),
      outline,
    );
    canvas.drawCircle(const Offset(0, -4), 3.1, outline);
    canvas.drawLine(const Offset(0, -1), const Offset(0, 2), outline);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(-4.4, 3, 8.8, 5.2),
        const Radius.circular(1.5),
      ),
      outline,
    );
  }

  void _label(
    Canvas canvas,
    String value,
    Offset position, {
    bool alignRight = false,
    Color color = GameColors.muted,
  }) {
    final text = TextPainter(
      text: TextSpan(
        text: value,
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.w800,
          letterSpacing: 1,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    text.paint(
      canvas,
      Offset(alignRight ? position.dx - text.width : position.dx, position.dy),
    );
  }

  @override
  bool shouldRepaint(covariant _KartPainter oldDelegate) =>
      distance != oldDelegate.distance || rpm != oldDelegate.rpm;
}
