import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../game/foc_transform.dart';
import '../theme/game_theme.dart';
import 'motor_painter.dart';

const _phaseColors = [Color(0xFFB65E55), Color(0xFF548776), Color(0xFF537EA7)];

/// Game angles follow the on-screen clockwise motor convention. The upright
/// d/q chart displays the same transform in its own rotor reference frame.
/// Currents are ideal commands at a fixed 1 A peak, not hardware measurements.
FocTransform gameCurrentCommand(double rotorAngle, double fieldAngle) =>
    FocTransform(
      d: math.cos(fieldAngle - rotorAngle),
      q: math.sin(fieldAngle - rotorAngle),
      theta: rotorAngle,
    );

String _number(double x) => (x.abs() < .005 ? 0.0 : x).toStringAsFixed(2);

class FieldCurrentHud extends StatelessWidget {
  const FieldCurrentHud({
    super.key,
    required this.rotorAngle,
    required this.fieldAngle,
    this.sensorless = false,
    this.rpm = 0,
  });

  final double rotorAngle;
  final double fieldAngle;
  final bool sensorless;
  final double rpm;

  @override
  Widget build(BuildContext context) {
    final command = gameCurrentCommand(rotorAngle, fieldAngle);
    // A d/q readout would expose the hidden rotor angle in sensorless mode.
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
                Text(
                  rotorKnown ? 'PARK · d / q' : 'CLARKE · α / β',
                  key: const Key('vector-frame-label'),
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                Expanded(
                  child: Semantics(
                    label:
                        'Desired vector: $xName ${_number(x)} amperes, $yName ${_number(y)} amperes',
                    child: CustomPaint(
                      painter: _VectorPainter(x, y, xName, yName),
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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'THREE PHASE CURRENTS',
                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 3),
                for (var i = 0; i < 3; i++)
                  Expanded(
                    child: Row(
                      children: [
                        Text(
                          ['A', 'B', 'C'][i],
                          style: TextStyle(
                            color: _phaseColors[i],
                            fontSize: 12,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(width: 7),
                        Expanded(
                          child: CustomPaint(
                            painter: _CurrentBar(
                              command.phases[i],
                              _phaseColors[i],
                            ),
                            child: const SizedBox(height: 10),
                          ),
                        ),
                        const SizedBox(width: 7),
                        SizedBox(
                          width: 55,
                          child: Text(
                            '${_number(command.phases[i])} A',
                            key: Key('phase-current-$i'),
                            textAlign: TextAlign.right,
                            style: TextStyle(
                              color: _phaseColors[i],
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                              fontFeatures: const [
                                FontFeature.tabularFigures(),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                const Text(
                  '1 A peak · ideal commands',
                  style: TextStyle(fontSize: 9, color: GameColors.muted),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _panel(Widget child) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
    decoration: BoxDecoration(
      color: GameColors.panel,
      borderRadius: BorderRadius.circular(6),
      border: Border.all(color: GameColors.line.withValues(alpha: .6)),
    ),
    child: child,
  );
}

class _VectorPainter extends CustomPainter {
  const _VectorPainter(this.x, this.y, this.xName, this.yName);
  final double x, y;
  final String xName, yName;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width * .34, size.height * .32);
    final axis =
        Paint()
          ..color = GameColors.line
          ..strokeWidth = 1;
    canvas.drawLine(
      center - Offset(radius, 0),
      center + Offset(radius, 0),
      axis,
    );
    canvas.drawLine(
      center - Offset(0, radius),
      center + Offset(0, radius),
      axis,
    );
    _label(canvas, xName, center + Offset(radius + 9, 0), GameColors.muted);
    _label(canvas, yName, center - Offset(0, radius + 7), GameColors.muted);
    final corner = center + Offset(x * radius, 0);
    final tip = center + Offset(x, -y) * radius;
    canvas.drawLine(
      center,
      corner,
      Paint()
        ..color = GameColors.northPole
        ..strokeWidth = 2,
    );
    canvas.drawLine(
      corner,
      tip,
      Paint()
        ..color = GameColors.southPole
        ..strokeWidth = 2,
    );
    final p =
        Paint()
          ..color = GameColors.fieldArrow
          ..strokeWidth = 3
          ..strokeCap = StrokeCap.round;
    canvas.drawLine(center, tip, p);
    final angle = math.atan2(-y, x);
    for (final sign in [-1, 1]) {
      canvas.drawLine(
        tip,
        tip -
            Offset(math.cos(angle + sign * .5), math.sin(angle + sign * .5)) *
                6,
        p,
      );
    }
    _label(canvas, 'I*', tip + const Offset(10, -6), GameColors.gold);
    canvas.drawCircle(center, 2, Paint()..color = GameColors.cream);
  }

  void _label(Canvas canvas, String value, Offset p, Color color) {
    final text = TextPainter(
      text: TextSpan(
        text: value,
        style: TextStyle(
          fontSize: 10,
          color: color,
          fontWeight: FontWeight.w700,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    text.paint(canvas, p - Offset(text.width / 2, text.height / 2));
  }

  @override
  bool shouldRepaint(covariant _VectorPainter old) =>
      x != old.x || y != old.y || xName != old.xName || yName != old.yName;
}

class _CurrentBar extends CustomPainter {
  const _CurrentBar(this.value, this.color);
  final double value;
  final Color color;
  @override
  void paint(Canvas canvas, Size size) {
    final center = size.width / 2;
    canvas.drawRRect(
      RRect.fromRectAndRadius(Offset.zero & size, const Radius.circular(3)),
      Paint()..color = color.withValues(alpha: .13),
    );
    canvas.drawRect(
      Rect.fromLTRB(
        math.min(center, center + value * center),
        1,
        math.max(center, center + value * center),
        size.height - 1,
      ),
      Paint()..color = color,
    );
    canvas.drawLine(
      Offset(center, -2),
      Offset(center, size.height + 2),
      Paint()..color = GameColors.line,
    );
  }

  @override
  bool shouldRepaint(covariant _CurrentBar old) =>
      value != old.value || color != old.color;
}
