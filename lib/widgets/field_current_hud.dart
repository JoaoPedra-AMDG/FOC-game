import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../game/foc_transform.dart';
import '../theme/game_theme.dart';
import 'motor_painter.dart';

const _phaseColors = [Color(0xFFB65E55), Color(0xFF548776), Color(0xFF537EA7)];

/// Angles follow the clockwise screen convention of the game motor.
/// Currents are ideal 1 A peak commands, not hardware measurements.
FocTransform gameCurrentCommand(double rotorAngle, double fieldAngle) =>
    FocTransform(
      d: math.cos(fieldAngle - rotorAngle),
      q: math.sin(fieldAngle - rotorAngle),
      theta: rotorAngle,
    );

/// Amplitude-invariant phase fields: their vector sum is exactly the control.
List<Offset> phaseFieldContributions(FocTransform command) => List.generate(3, (
  i,
) {
  final angle = i * 2 * math.pi / 3;
  return Offset(math.cos(angle), math.sin(angle)) * (2 / 3 * command.phases[i]);
});
String _number(double x) => (x.abs() < .005 ? 0.0 : x).toStringAsFixed(2);

class FieldCurrentHud extends StatelessWidget {
  const FieldCurrentHud({
    super.key,
    required this.rotorAngle,
    required this.fieldAngle,
    this.sensorless = false,
    this.rpm = 0,
  });
  final double rotorAngle, fieldAngle, rpm;
  final bool sensorless;
  @override
  Widget build(BuildContext context) {
    final command = gameCurrentCommand(rotorAngle, fieldAngle);
    final rotorKnown = !sensorless || SensorlessVisibility.reveal(rpm) == 1;
    final x = rotorKnown ? command.d : command.alpha;
    final y = rotorKnown ? command.q : command.beta;
    final xName = rotorKnown ? 'd' : 'α';
    final yName = rotorKnown ? 'q' : 'β';
    return Row(
      key: const Key('field-current-hud'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: _panel(
            Column(
              children: [
                const FittedBox(
                  child: Text(
                    'PHASE FIELDS · Σ = I*',
                    key: Key('vector-frame-label'),
                    style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800),
                  ),
                ),
                Expanded(
                  child: Semantics(
                    label:
                        'Phase A, B and C fields add to the gold resultant aligned with the control arrow. $xName ${_number(x)} amperes, $yName ${_number(y)} amperes.',
                    child: CustomPaint(
                      key: const Key('phase-field-diagram'),
                      painter: PhaseFieldPainter(command, fieldAngle),
                      child: const SizedBox.expand(),
                    ),
                  ),
                ),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    '$xName ${_number(x)}  ·  $yName ${_number(y)} A',
                    key: const Key('vector-components'),
                    style: const TextStyle(fontSize: 11),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _panel(
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const FittedBox(
                  alignment: Alignment.centerLeft,
                  fit: BoxFit.scaleDown,
                  child: Text(
                    'THREE PHASE SINUSOIDS',
                    style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800),
                  ),
                ),
                const SizedBox(height: 2),
                Expanded(
                  child: Semantics(
                    label:
                        'Three sinusoidal phase current commands over 0 to 360 degrees of field angle. The cursor and dots mark the current commands.',
                    child: CustomPaint(
                      key: const Key('phase-sinusoids'),
                      painter: PhaseSinusoidsPainter(fieldAngle),
                      child: const SizedBox.expand(),
                    ),
                  ),
                ),
                const SizedBox(height: 2),
                Row(
                  children: List.generate(
                    3,
                    (i) => Expanded(
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Column(
                          children: [
                            Text(
                              ['A', 'B', 'C'][i],
                              style: TextStyle(
                                color: _phaseColors[i],
                                fontSize: 9,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            Text(
                              '${_number(command.phases[i])} A',
                              key: Key('phase-current-$i'),
                              style: TextStyle(
                                color: _phaseColors[i],
                                fontSize: 10,
                                fontWeight: FontWeight.w800,
                                fontFeatures: const [
                                  FontFeature.tabularFigures(),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 2),
                const FittedBox(
                  alignment: Alignment.centerLeft,
                  fit: BoxFit.scaleDown,
                  child: Text(
                    '1 A peak · field angle, not time',
                    style: TextStyle(fontSize: 8, color: GameColors.muted),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _panel(Widget child) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
    decoration: BoxDecoration(
      color: GameColors.panel,
      borderRadius: BorderRadius.circular(6),
      border: Border.all(color: GameColors.line.withValues(alpha: .6)),
    ),
    child: child,
  );
}

void _label(
  Canvas canvas,
  String value,
  Offset p,
  Color color, {
  double size = 9,
}) {
  final text = TextPainter(
    text: TextSpan(
      text: value,
      style: TextStyle(
        fontSize: size,
        color: color,
        fontWeight: FontWeight.w700,
      ),
    ),
    textDirection: TextDirection.ltr,
  )..layout();
  text.paint(canvas, p - Offset(text.width / 2, text.height / 2));
}

void _arrow(
  Canvas canvas,
  Offset start,
  Offset end,
  Color color,
  double width,
) {
  final delta = end - start;
  if (delta.distance < .5) return;
  final paint =
      Paint()
        ..color = color
        ..strokeWidth = width
        ..strokeCap = StrokeCap.round;
  canvas.drawLine(start, end, paint);
  final angle = math.atan2(delta.dy, delta.dx);
  final head = math.min(5.0, delta.distance * .35);
  for (final sign in [-1, 1]) {
    canvas.drawLine(
      end,
      end -
          Offset(math.cos(angle + sign * .5), math.sin(angle + sign * .5)) *
              head,
      paint,
    );
  }
}

class PhaseFieldPainter extends CustomPainter {
  const PhaseFieldPainter(this.command, this.fieldAngle);
  final FocTransform command;
  final double fieldAngle;
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width * .33, size.height * .35);
    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..color = GameColors.line.withValues(alpha: .5)
        ..style = PaintingStyle.stroke,
    );
    for (var i = 0; i < 3; i++) {
      final angle = i * 2 * math.pi / 3;
      final direction = Offset(math.cos(angle), math.sin(angle));
      canvas.drawLine(
        center - direction * radius,
        center + direction * radius,
        Paint()
          ..color = _phaseColors[i].withValues(alpha: .25)
          ..strokeWidth = 1,
      );
      _label(
        canvas,
        ['A', 'B', 'C'][i],
        center + direction * (radius + 9),
        _phaseColors[i],
      );
    }
    // Faint head-to-tail segments expose the sum; solid arrows show each
    // phase's field from a common origin.
    var sum = Offset.zero;
    final fields = phaseFieldContributions(command);
    for (var i = 0; i < 3; i++) {
      final next = sum + fields[i];
      canvas.drawLine(
        center + sum * radius,
        center + next * radius,
        Paint()
          ..color = _phaseColors[i].withValues(alpha: .28)
          ..strokeWidth = 1,
      );
      _arrow(canvas, center, center + fields[i] * radius, _phaseColors[i], 2);
      sum = next;
    }
    final tip = center + sum * radius;
    _arrow(canvas, center, tip, GameColors.fieldArrow, 3);
    final tangent = Offset(-math.sin(fieldAngle), math.cos(fieldAngle));
    _label(canvas, 'Σ', tip + tangent * 10, GameColors.gold);
    canvas.drawCircle(center, 2, Paint()..color = GameColors.cream);
  }

  @override
  bool shouldRepaint(covariant PhaseFieldPainter old) =>
      fieldAngle != old.fieldAngle;
}

class PhaseSinusoidsPainter extends CustomPainter {
  const PhaseSinusoidsPainter(this.fieldAngle);
  final double fieldAngle;
  double get cursorAngle => fieldAngle % (2 * math.pi);
  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromLTRB(
      5,
      3,
      math.max(6, size.width - 6),
      math.max(4, size.height - 12),
    );
    final mid = rect.center.dy;
    final amplitude = rect.height * .43;
    for (final level in [-1, 0, 1]) {
      final y = mid - level * amplitude;
      canvas.drawLine(
        Offset(rect.left, y),
        Offset(rect.right, y),
        Paint()
          ..color = GameColors.line.withValues(alpha: .55)
          ..strokeWidth = .7,
      );
    }
    for (var phase = 0; phase < 3; phase++) {
      final path = Path();
      for (var step = 0; step <= 120; step++) {
        final angle = step * 2 * math.pi / 120;
        final point = Offset(
          rect.left + rect.width * step / 120,
          mid - math.cos(angle - phase * 2 * math.pi / 3) * amplitude,
        );
        if (step == 0) {
          path.moveTo(point.dx, point.dy);
        } else {
          path.lineTo(point.dx, point.dy);
        }
      }
      canvas.drawPath(
        path,
        Paint()
          ..color = _phaseColors[phase]
          ..strokeWidth = 1.6
          ..style = PaintingStyle.stroke,
      );
    }
    final cursorX = rect.left + rect.width * cursorAngle / (2 * math.pi);
    canvas.drawLine(
      Offset(cursorX, rect.top),
      Offset(cursorX, rect.bottom),
      Paint()
        ..color = GameColors.cream.withValues(alpha: .7)
        ..strokeWidth = 1,
    );
    for (var i = 0; i < 3; i++) {
      canvas.drawCircle(
        Offset(
          cursorX,
          mid - math.cos(cursorAngle - i * 2 * math.pi / 3) * amplitude,
        ),
        2.6,
        Paint()..color = _phaseColors[i],
      );
    }
    for (var i = 0; i < 3; i++) {
      _label(
        canvas,
        '${i * 180}°',
        Offset(rect.left + rect.width * i / 2, rect.bottom + 7),
        GameColors.muted,
        size: 7,
      );
    }
  }

  @override
  bool shouldRepaint(covariant PhaseSinusoidsPainter old) =>
      fieldAngle != old.fieldAngle;
}
