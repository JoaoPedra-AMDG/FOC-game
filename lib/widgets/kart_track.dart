import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../theme/game_theme.dart';

class KartTrack extends StatelessWidget {
  const KartTrack({super.key, required this.distance, required this.rpm});

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
    final road = Rect.fromLTWH(
      0,
      size.height * 0.34,
      size.width,
      size.height * 0.52,
    );
    canvas.drawRect(road, Paint()..color = const Color(0xFF29404B));
    canvas.drawLine(
      Offset(0, road.top),
      Offset(size.width, road.top),
      Paint()
        ..color = GameColors.mint.withValues(alpha: 0.45)
        ..strokeWidth = 2,
    );
    canvas.drawLine(
      Offset(0, road.bottom),
      Offset(size.width, road.bottom),
      Paint()
        ..color = GameColors.mint.withValues(alpha: 0.45)
        ..strokeWidth = 2,
    );
    final offset = distance % 70;
    for (double x = -70 + offset; x < size.width + 70; x += 70) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(x, road.center.dy - 2, 31, 4),
          const Radius.circular(2),
        ),
        Paint()..color = GameColors.cream.withValues(alpha: 0.6),
      );
      canvas.drawCircle(
        Offset(x + 12, size.height * 0.18),
        3,
        Paint()..color = GameColors.mint.withValues(alpha: 0.4),
      );
    }

    final cx = size.width * 0.52;
    final cy = road.center.dy;
    final speed = (rpm.abs() / 450).clamp(0.0, 1.0);
    if (speed > 0.2) {
      final direction = rpm.sign;
      for (var i = 0; i < 3; i++) {
        final x = cx - direction * (37 + i * 15);
        canvas.drawLine(
          Offset(x, cy - 13 + i * 11),
          Offset(x - direction * (9 + speed * 18), cy - 13 + i * 11),
          Paint()
            ..color = GameColors.mint.withValues(alpha: 0.45 - i * 0.1)
            ..strokeWidth = 2,
        );
      }
    }
    final body = Rect.fromCenter(center: Offset(cx, cy), width: 62, height: 25);
    canvas.drawRRect(
      RRect.fromRectAndRadius(body, const Radius.circular(10)),
      Paint()..color = GameColors.coral,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset(cx - 7, cy - 5), width: 27, height: 17),
        const Radius.circular(6),
      ),
      Paint()..color = GameColors.gold,
    );
    for (final dx in [-19.0, 19.0]) {
      for (final dy in [-15.0, 15.0]) {
        canvas.drawCircle(
          Offset(cx + dx, cy + dy),
          5,
          Paint()..color = GameColors.ink,
        );
      }
    }
    final icon = rpm < -1 ? '◀' : '▶';
    final text = TextPainter(
      text: TextSpan(
        text: 'KART VISUAL  $icon',
        style: const TextStyle(
          color: GameColors.muted,
          fontSize: 10,
          fontWeight: FontWeight.w800,
          letterSpacing: 1.1,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    text.paint(canvas, Offset(12, math.max(4, size.height * 0.08)));
  }

  @override
  bool shouldRepaint(covariant _KartPainter oldDelegate) =>
      distance != oldDelegate.distance || rpm != oldDelegate.rpm;
}
