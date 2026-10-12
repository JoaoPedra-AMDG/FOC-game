import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../theme/game_theme.dart';

class MotorPainter extends CustomPainter {
  const MotorPainter({
    required this.rotorAngle,
    required this.fieldAngle,
    required this.torqueAngle,
    required this.torque,
  });

  final double rotorAngle;
  final double fieldAngle;
  final double torqueAngle;
  final double torque;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) * 0.46;
    final strong = torque > 0.78;
    final glow =
        Paint()
          ..color = (torque >= 0
                  ? const Color(0xFF789176)
                  : GameColors.coral)
              .withValues(alpha: strong ? 0.12 : 0.06)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 28);
    canvas.drawCircle(center, radius * 0.87, glow);

    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..color = GameColors.panel
        ..style = PaintingStyle.fill,
    );
    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..color = GameColors.line
        ..style = PaintingStyle.stroke
        ..strokeWidth = radius * 0.065,
    );

    for (var i = 0; i < 12; i++) {
      final a = i * 2 * math.pi / 12;
      final point = _point(center, radius * 0.79, a);
      canvas.save();
      canvas.translate(point.dx, point.dy);
      canvas.rotate(a);
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(
            center: Offset.zero,
            width: radius * 0.25,
            height: radius * 0.17,
          ),
          Radius.circular(radius * 0.035),
        ),
        Paint()
          ..color =
              i.isEven
                  ? GameColors.coral.withValues(alpha: 0.7)
                  : GameColors.muted.withValues(alpha: 0.75),
      );
      canvas.restore();
    }

    canvas.drawCircle(center, radius * 0.64, Paint()..color = GameColors.ink);
    for (var i = 0; i < 3; i++) {
      canvas.drawCircle(
        center,
        radius * (0.40 + i * 0.08),
        Paint()
          ..color = GameColors.line.withValues(alpha: 0.55 - i * 0.13)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1,
      );
    }

    final rotorTip = _point(center, radius * 0.42, rotorAngle);
    final rotorTail = _point(center, radius * 0.42, rotorAngle + math.pi);
    final bar = RRect.fromRectAndRadius(
      Rect.fromLTWH(
        -radius * 0.53,
        -radius * 0.11,
        radius * 1.06,
        radius * 0.22,
      ),
      Radius.circular(radius * 0.11),
    );
    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(rotorAngle);
    canvas.clipRRect(bar);
    canvas.drawRect(
      Rect.fromLTWH(
        -radius * 0.53,
        -radius * 0.11,
        radius * 0.53,
        radius * 0.22,
      ),
      Paint()..color = GameColors.southPole,
    );
    canvas.drawRect(
      Rect.fromLTWH(0, -radius * 0.11, radius * 0.53, radius * 0.22),
      Paint()..color = GameColors.northPole,
    );
    canvas.restore();
    _label(canvas, 'N', rotorTip, radius * 0.12, Colors.white);
    _label(canvas, 'S', rotorTail, radius * 0.12, Colors.white);

    final arcRadius = radius * 0.60;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: arcRadius),
      rotorAngle,
      torqueAngle,
      false,
      Paint()
        ..color =
            torque >= 0
                ? const Color(0xFF6E8A72)
                : GameColors.coral
        ..style = PaintingStyle.stroke
        ..strokeWidth = radius * 0.035
        ..strokeCap = StrokeCap.round,
    );

    final fieldTip = _point(center, radius * 0.5175, fieldAngle);
    final fieldBase = _point(center, radius * 0.1125, fieldAngle);
    final arrowWidth = radius * (strong ? 0.04725 : 0.039);
    final outline =
        Paint()
          ..color = GameColors.road
          ..strokeWidth = arrowWidth + radius * 0.0285
          ..strokeCap = StrokeCap.round
          ..strokeJoin = StrokeJoin.round;
    final fieldPaint =
        Paint()
          ..color = GameColors.fieldArrow
          ..strokeWidth = arrowWidth
          ..strokeCap = StrokeCap.round
          ..strokeJoin = StrokeJoin.round;
    final headA = _point(fieldTip, radius * 0.1125, fieldAngle + 2.55);
    final headB = _point(fieldTip, radius * 0.1125, fieldAngle - 2.55);
    for (final paint in [outline, fieldPaint]) {
      canvas.drawLine(fieldBase, fieldTip, paint);
      canvas.drawLine(fieldTip, headA, paint);
      canvas.drawLine(fieldTip, headB, paint);
    }
    canvas.drawCircle(center, radius * 0.07, Paint()..color = GameColors.rod);
  }

  Offset _point(Offset origin, double length, double angle) => Offset(
    origin.dx + math.cos(angle) * length,
    origin.dy + math.sin(angle) * length,
  );

  void _label(
    Canvas canvas,
    String text,
    Offset center,
    double size,
    Color color,
  ) {
    final painter = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          color: color,
          fontSize: size,
          fontWeight: FontWeight.w900,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    painter.paint(
      canvas,
      center - Offset(painter.width / 2, painter.height / 2),
    );
  }

  @override
  bool shouldRepaint(covariant MotorPainter oldDelegate) =>
      rotorAngle != oldDelegate.rotorAngle ||
      fieldAngle != oldDelegate.fieldAngle ||
      torqueAngle != oldDelegate.torqueAngle ||
      torque != oldDelegate.torque;
}
