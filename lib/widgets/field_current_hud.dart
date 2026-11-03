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
            Semantics(
              key: const Key('phase-field-semantics'),
              label:
                  'Phase A, B and C fields add to the gold resultant aligned with the control arrow. $xName ${_number(x)} amperes, $yName ${_number(y)} amperes.',
              child: CustomPaint(
                key: const Key('phase-field-diagram'),
                painter: PhaseFieldPainter(command, fieldAngle),
                child: const SizedBox.expand(),
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _panel(
            Semantics(
              label:
                  'Recorded phase A, B and C current commands over the last three seconds of game time, in amperes. Phase A ${_number(command.a)}, phase B ${_number(command.b)}, phase C ${_number(command.c)}.',
              child: CustomPaint(
                key: const Key('phase-current-history'),
                painter: PhaseCurrentTimePainter(history),
                child: const SizedBox.expand(),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _panel(Widget child) => Container(
    padding: const EdgeInsets.all(4),
    decoration: BoxDecoration(
      color: GameColors.panel,
      borderRadius: BorderRadius.circular(6),
      border: Border.all(color: GameColors.line.withValues(alpha: .6)),
    ),
    child: child,
  );
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
  final head = math.min(width * 3, delta.distance * .35);
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
    final radius = math.min(size.width, size.height) * .46;
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
      _arrow(
        canvas,
        center,
        center + fields[i] * radius,
        _phaseColors[i],
        math.max(2.0, radius * .02),
      );
      sum = next;
    }
    final tip = center + sum * radius;
    _arrow(
      canvas,
      center,
      tip,
      GameColors.fieldArrow,
      math.max(3.0, radius * .03),
    );
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
      4,
      4,
      math.max(5, size.width - 4),
      math.max(5, size.height - 4),
    );
    final mid = rect.center.dy;
    final amplitude = rect.height * .46;
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
    for (var i = 0; i <= 3; i++) {
      final x = rect.left + rect.width * i / 3;
      canvas.drawLine(
        Offset(x, rect.top),
        Offset(x, rect.bottom),
        Paint()
          ..color = GameColors.line.withValues(alpha: .30)
          ..strokeWidth = .7,
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
  }

  @override
  bool shouldRepaint(covariant PhaseCurrentTimePainter old) =>
      revision != old.revision;
}
