import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../game/foc_transform.dart';
import '../game/current_history.dart';
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
    this.history,
  });
  final double rotorAngle, fieldAngle, rpm;
  final bool sensorless;
  final CurrentHistory? history;
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
                    'PHASE CURRENTS vs TIME',
                    style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800),
                  ),
                ),
                const SizedBox(height: 2),
                Expanded(
                  child: Semantics(
                    label:
                        'Recorded phase A, B and C current commands over the last three seconds of game time, in amperes.',
                    child: CustomPaint(
                      key: const Key('phase-current-history'),
                      painter: PhaseCurrentTimePainter(history),
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
                    'A · 3 s rolling command history',
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

class PhaseCurrentTimePainter extends CustomPainter {
  PhaseCurrentTimePainter(this.history) : revision = history?.revision ?? 0;
  final CurrentHistory? history;
  final int revision;
  double get startTime =>
      math.max(0, (history?.time ?? 0) - CurrentHistory.windowSeconds);
  double get endTime => startTime + CurrentHistory.windowSeconds;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromLTRB(
      16,
      3,
      math.max(17, size.width - 5),
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
      _label(
        canvas,
        level > 0 ? '+1' : '$level',
        Offset(6, y),
        GameColors.muted,
        size: 7,
      );
    }
    final samples = history?.samples ?? const <CurrentSample>[];
    canvas.save();
    canvas.clipRect(rect);
    for (var phase = 0; phase < 3; phase++) {
      final path = Path();
      for (var i = 0; i < samples.length; i++) {
        final sample = samples[i];
        final x =
            rect.left +
            rect.width *
                (sample.time - startTime) /
                CurrentHistory.windowSeconds;
        final y = mid - sample.phases[phase] * amplitude;
        if (i == 0) {
          path.moveTo(x, y);
        } else {
          path.lineTo(x, y);
        }
      }
      canvas.drawPath(
        path,
        Paint()
          ..color = _phaseColors[phase]
          ..strokeWidth = 1.6
          ..style = PaintingStyle.stroke,
      );
      if (samples.isNotEmpty) {
        final last = samples.last;
        final x =
            rect.left +
            rect.width * (last.time - startTime) / CurrentHistory.windowSeconds;
        canvas.drawCircle(
          Offset(x, mid - last.phases[phase] * amplitude),
          2.3,
          Paint()..color = _phaseColors[phase],
        );
      }
    }
    canvas.restore();
    for (var i = 0; i < 3; i++) {
      final t = startTime + CurrentHistory.windowSeconds * i / 2;
      _label(
        canvas,
        '${t.toStringAsFixed(1)}s',
        Offset(rect.left + rect.width * i / 2, rect.bottom + 7),
        GameColors.muted,
        size: 7,
      );
    }
  }

  @override
  bool shouldRepaint(covariant PhaseCurrentTimePainter old) =>
      revision != old.revision;
}
