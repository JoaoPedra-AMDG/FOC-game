import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../theme/game_theme.dart';

class KartTrack extends StatelessWidget {
  const KartTrack({super.key, required this.distance, required this.rpm});

  // Signed visual distance: braking and reverse RPM move the kart backwards.
  final double distance;
  final double rpm;

  @override
  Widget build(BuildContext context) => RepaintBoundary(
    child: ClipRRect(
      borderRadius: BorderRadius.circular(20),
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

    final center = Offset(size.width * 0.5, size.height * 0.53);
    final radius = math.min(size.height * 0.34, size.width * 0.19);
    const roadWidth = 19.0;

    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..color = const Color(0xFF29404B)
        ..style = PaintingStyle.stroke
        ..strokeWidth = roadWidth,
    );
    for (final edgeRadius in [radius - roadWidth / 2, radius + roadWidth / 2]) {
      canvas.drawCircle(
        center,
        edgeRadius,
        Paint()
          ..color = GameColors.mint.withValues(alpha: 0.52)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.7,
      );
    }

    // Fixed lane marks make both the circuit and the kart's direction clear.
    for (var i = 0; i < 12; i++) {
      final start = -math.pi / 2 + i * math.pi / 6;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        start,
        math.pi / 23,
        false,
        Paint()
          ..color = GameColors.cream.withValues(alpha: 0.65)
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round
          ..strokeWidth = 1.8,
      );
    }

    final startLine = Offset(center.dx, center.dy - radius);
    canvas.drawLine(
      Offset(startLine.dx - roadWidth / 2, startLine.dy),
      Offset(startLine.dx + roadWidth / 2, startLine.dy),
      Paint()
        ..color = GameColors.cream
        ..strokeWidth = 2.5,
    );
    canvas.drawCircle(
      center,
      radius * 0.36,
      Paint()..color = GameColors.ink.withValues(alpha: 0.55),
    );

    // Distance is presentation-only. It is wrapped around the circular lane.
    final angle = -math.pi / 2 + distance / radius;
    final kartPosition =
        center + Offset(math.cos(angle), math.sin(angle)) * radius;
    canvas.save();
    canvas.translate(kartPosition.dx, kartPosition.dy);
    canvas.rotate(angle + math.pi / 2 + (rpm < -1 ? math.pi : 0));
    _paintKart(canvas);
    canvas.restore();

    _label(canvas, 'CIRCULAR KART TRACK', const Offset(14, 12));
    final direction =
        rpm > 1
            ? 'CLOCKWISE'
            : rpm < -1
            ? 'COUNTERCLOCKWISE'
            : 'STATIONARY';
    _label(
      canvas,
      direction,
      Offset(size.width - 14, size.height - 21),
      alignRight: true,
      color: rpm < -1 ? GameColors.coral : GameColors.mint,
    );
  }

  void _paintKart(Canvas canvas) {
    final shadow = Paint()..color = GameColors.ink.withValues(alpha: 0.6);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(-9, -13, 18, 26),
        const Radius.circular(5),
      ),
      shadow,
    );
    for (final dx in [-10.0, 10.0]) {
      for (final dy in [-8.0, 8.0]) {
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromCenter(center: Offset(dx, dy), width: 5, height: 7),
            const Radius.circular(2),
          ),
          Paint()..color = GameColors.ink,
        );
      }
    }
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(-7, -11, 14, 22),
        const Radius.circular(4),
      ),
      Paint()..color = GameColors.coral,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(-5, -4, 10, 8),
        const Radius.circular(3),
      ),
      Paint()..color = GameColors.gold,
    );
    canvas.drawLine(
      const Offset(-4, -8),
      const Offset(4, -8),
      Paint()
        ..color = GameColors.cream
        ..strokeWidth = 2,
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
