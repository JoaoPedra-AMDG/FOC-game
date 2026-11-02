import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import '../game/foc_transform.dart';
import '../theme/game_theme.dart';

const _phaseColors = [Color(0xFFB65E55), Color(0xFF548776), Color(0xFF537EA7)];
const _vectorColor = Color(0xFFAD8025);
String _amps(double value) =>
    '${value.abs() < .005 ? '0.00' : value.toStringAsFixed(2)} A';

class TransformLab extends StatefulWidget {
  const TransformLab({super.key});
  @override
  State<TransformLab> createState() => _TransformLabState();
}

class _TransformLabState extends State<TransformLab>
    with SingleTickerProviderStateMixin {
  late final Ticker _ticker;
  Duration? _last;
  double _theta = 0;
  double _d = 0;
  double _q = 1;
  double _speed = 6;
  bool _running = false;
  @override
  void initState() {
    super.initState();
    _ticker = createTicker((elapsed) {
      final dt = _last == null ? 0.0 : (elapsed - _last!).inMicroseconds / 1e6;
      _last = elapsed;
      if (_running) {
        setState(
          () => _theta = (_theta + dt * _speed * math.pi / 30) % (2 * math.pi),
        );
      }
    })..start();
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  void _drag(Offset p, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) * .38;
    final delta = p - center;
    final x = delta.dx / (radius * .63);
    final y = -delta.dy / (radius * .63);
    // The circular limit keeps a freely dragged vector within the control range.
    final scale = math.max(1.0, math.sqrt(x * x + y * y) / 1.4);
    setState(() {
      _d = ((x * math.cos(_theta) + y * math.sin(_theta)) / scale).clamp(
        -1.4,
        1.4,
      );
      _q = ((-x * math.sin(_theta) + y * math.cos(_theta)) / scale).clamp(
        -1.4,
        1.4,
      );
    });
  }

  Widget _card(String number, String title, String description, Widget child) =>
      Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: .55),
          border: Border.all(color: GameColors.line.withValues(alpha: .5)),
          borderRadius: BorderRadius.circular(18),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '$number  /  $title',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 6),
            Text(description),
            const SizedBox(height: 14),
            child,
          ],
        ),
      );

  Widget _slider(
    String label,
    double value,
    double min,
    double max,
    ValueChanged<double> change,
  ) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(label, style: const TextStyle(fontWeight: FontWeight.w700)),
      Slider(value: value, min: min, max: max, onChanged: change),
    ],
  );

  @override
  Widget build(BuildContext context) {
    final v = FocTransform(d: _d, q: _q, theta: _theta);
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1200),
              child: Padding(
                padding: const EdgeInsets.all(22),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'FOC FAST  /  FIELD LAB',
                      style: TextStyle(
                        letterSpacing: 2,
                        fontWeight: FontWeight.w800,
                        color: _vectorColor,
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'One vector. Three currents.',
                      style: TextStyle(
                        fontSize: 34,
                        height: 1.1,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Explore how a desired rotor-frame current becomes a rotating stator field. Drag the gold vector in the stator, or change d and q below. All values update together.',
                    ),
                    const SizedBox(height: 22),
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        FilledButton.icon(
                          onPressed: () => setState(() => _running = !_running),
                          icon: Icon(_running ? Icons.pause : Icons.play_arrow),
                          label: Text(
                            _running ? 'Pause rotation' : 'Animate rotation',
                          ),
                        ),
                        OutlinedButton(
                          onPressed:
                              () => setState(() {
                                _d = 0;
                                _q = 1;
                              }),
                          child: const Text('Torque only · d = 0, q = 1 A'),
                        ),
                        OutlinedButton(
                          onPressed:
                              () => setState(() {
                                _theta = 0;
                                _d = 0;
                                _q = 1;
                                _speed = 6;
                                _running = false;
                              }),
                          child: const Text('Reset'),
                        ),
                        Text(
                          'θe = ${(_theta * 180 / math.pi).toStringAsFixed(1)}°  ·  |I*| = ${_amps(v.magnitude)}',
                        ),
                      ],
                    ),
                    const SizedBox(height: 22),
                    LayoutBuilder(
                      builder: (context, box) {
                        final wide = box.maxWidth >= 820;
                        final controls = _card(
                          '01',
                          'Desired vector · d / q',
                          'The d-axis follows rotor flux. The q-axis is 90° ahead; positive q produces positive torque in this ideal model.',
                          Column(
                            children: [
                              SizedBox(
                                height: 210,
                                child: CustomPaint(
                                  painter: _FramePainter(v, rotating: true),
                                  child: const SizedBox.expand(),
                                ),
                              ),
                              _slider(
                                'Direct current id*  ${_amps(_d)}',
                                _d,
                                -1.4,
                                1.4,
                                (x) => setState(() => _d = x),
                              ),
                              _slider(
                                'Quadrature current iq*  ${_amps(_q)}',
                                _q,
                                -1.4,
                                1.4,
                                (x) => setState(() => _q = x),
                              ),
                              _slider(
                                'Rotor electrical angle  ${(_theta * 180 / math.pi).toStringAsFixed(0)}°',
                                _theta,
                                0,
                                2 * math.pi,
                                (x) => setState(() {
                                  _running = false;
                                  _theta = x;
                                }),
                              ),
                              _slider(
                                'Animation speed  ${_speed.toStringAsFixed(0)} electrical RPM',
                                _speed,
                                1,
                                30,
                                (x) => setState(() => _speed = x),
                              ),
                            ],
                          ),
                        );
                        final stator = _card(
                          '02',
                          'Inverse Park · stator field',
                          'Rotate the desired d/q vector by θe to obtain stationary α/β components. The coloured winding pairs create the gold resultant field.',
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(
                                height: wide ? 370 : 310,
                                child: LayoutBuilder(
                                  builder:
                                      (context, bounds) => GestureDetector(
                                        key: const Key('stator-vector'),
                                        behavior: HitTestBehavior.opaque,
                                        onPanStart:
                                            (e) => _drag(
                                              e.localPosition,
                                              bounds.biggest,
                                            ),
                                        onPanUpdate:
                                            (e) => _drag(
                                              e.localPosition,
                                              bounds.biggest,
                                            ),
                                        onTapDown:
                                            (e) => _drag(
                                              e.localPosition,
                                              bounds.biggest,
                                            ),
                                        child: CustomPaint(
                                          painter: _StatorPainter(v),
                                          child: const SizedBox.expand(),
                                        ),
                                      ),
                                ),
                              ),
                              Text(
                                'iα = id cos θe − iq sin θe = ${_amps(v.alpha)}\niβ = id sin θe + iq cos θe = ${_amps(v.beta)}',
                                style: const TextStyle(
                                  fontSize: 15,
                                  height: 1.7,
                                ),
                              ),
                              const SizedBox(height: 8),
                              const Text(
                                'Gold = resultant field / desired current vector. Dashed d/q axes rotate with the rotor; α/β axes stay fixed. Coloured arrows show each phase’s field contribution.',
                              ),
                            ],
                          ),
                        );
                        if (wide) {
                          return Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(flex: 4, child: controls),
                              const SizedBox(width: 18),
                              Expanded(flex: 6, child: stator),
                            ],
                          );
                        }
                        return Column(
                          children: [
                            stator,
                            const SizedBox(height: 18),
                            controls,
                          ],
                        );
                      },
                    ),
                    const SizedBox(height: 18),
                    _card(
                      '03',
                      'Inverse Clarke · three phase currents',
                      'The windings are spaced 120° apart. Positive and negative values reverse current through each winding pair; they are ideal current commands, not measured hardware currents.',
                      Column(
                        children: [
                          LayoutBuilder(
                            builder:
                                (context, box) => Wrap(
                                  spacing: 12,
                                  runSpacing: 12,
                                  children: List.generate(
                                    3,
                                    (i) => Container(
                                      width:
                                          box.maxWidth < 530
                                              ? box.maxWidth
                                              : (box.maxWidth - 24) / 3,
                                      padding: const EdgeInsets.all(16),
                                      decoration: BoxDecoration(
                                        color: _phaseColors[i].withValues(
                                          alpha: .09,
                                        ),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'PHASE ${['A', 'B', 'C'][i]}',
                                            style: TextStyle(
                                              color: _phaseColors[i],
                                              fontWeight: FontWeight.w800,
                                            ),
                                          ),
                                          Text(
                                            _amps(v.phases[i]),
                                            style: TextStyle(
                                              color: _phaseColors[i],
                                              fontSize: 30,
                                              fontWeight: FontWeight.w900,
                                            ),
                                          ),
                                          Text(
                                            [
                                              'ia = iα',
                                              'ib = −½ iα + √3/2 iβ',
                                              'ic = −½ iα − √3/2 iβ',
                                            ][i],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                          ),
                          const SizedBox(height: 14),
                          SizedBox(
                            height: 180,
                            child: CustomPaint(
                              painter: _WavePainter(v),
                              child: const SizedBox.expand(),
                            ),
                          ),
                          Text(
                            'ia + ib + ic = ${_amps(v.a + v.b + v.c)}  ·  Balanced, amplitude-invariant convention · zero-sequence current = 0',
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'One electrical revolution (0–360°). The vertical cursor marks θe. Curves predict the phase commands for the current d/q settings.',
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 18),
                    _card(
                      '04',
                      'Clarke + Park · check the return path',
                      'In a real drive, current sensors supply ia, ib and ic. Clarke and Park map those measurements back to d/q for feedback.',
                      Text(
                        'Clarke:  iα = ⅔(ia − ½ib − ½ic),   iβ = (ib − ic)/√3\nPark:  id = iα cos θe + iβ sin θe,   iq = −iα sin θe + iβ cos θe\n\nRecovered id = ${_amps(v.alpha * math.cos(_theta) + v.beta * math.sin(_theta))}     iq = ${_amps(-v.alpha * math.sin(_theta) + v.beta * math.cos(_theta))}\n\nThe stator sketch assumes a balanced sinusoidal, two-pole motor. Coil locations indicate magnetic axes, not a detailed winding layout. Current arrows use ⅔ × phase current so their vector sum equals the gold vector. This view shows current geometry; an actual controller also needs current regulation, voltage commands and PWM.',
                        style: const TextStyle(height: 1.7),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

Offset _polar(Offset c, double r, double a) =>
    c + Offset(math.cos(a), -math.sin(a)) * r;
void _label(Canvas c, String text, Offset p, Color color, {double size = 12}) {
  final t = TextPainter(
    text: TextSpan(
      text: text,
      style: TextStyle(
        color: color,
        fontSize: size,
        fontWeight: FontWeight.w700,
      ),
    ),
    textDirection: TextDirection.ltr,
  )..layout();
  t.paint(c, p - Offset(t.width / 2, t.height / 2));
}

void _arrow(
  Canvas c,
  Offset start,
  Offset end,
  Color color, {
  double width = 2,
}) {
  if ((end - start).distance < .5) return;
  final p =
      Paint()
        ..color = color
        ..strokeWidth = width
        ..strokeCap = StrokeCap.round;
  c.drawLine(start, end, p);
  final a = math.atan2(end.dy - start.dy, end.dx - start.dx);
  for (final sign in [-1, 1]) {
    c.drawLine(
      end,
      end - Offset(math.cos(a + sign * .5), math.sin(a + sign * .5)) * 8,
      p,
    );
  }
}

void _axes(
  Canvas c,
  Offset center,
  double r,
  double angle,
  String x,
  String y,
  Color color,
) {
  for (var i = 0; i < 2; i++) {
    final a = angle + i * math.pi / 2;
    c.drawLine(
      _polar(center, -r, a),
      _polar(center, r, a),
      Paint()
        ..color = color
        ..strokeWidth = 1,
    );
    _label(c, i == 0 ? x : y, _polar(center, r + 12, a), color);
  }
}

class _FramePainter extends CustomPainter {
  _FramePainter(this.v, {required this.rotating});
  final FocTransform v;
  final bool rotating;
  @override
  void paint(Canvas canvas, Size size) {
    final c = Offset(size.width / 2, size.height / 2);
    final r = math.min(size.width, size.height) * .36;
    _axes(canvas, c, r, 0, 'd', 'q', GameColors.muted);
    final tip = c + Offset(v.d, -v.q) * (r * .63);
    final corner = c + Offset(v.d * r * .63, 0);
    canvas.drawLine(
      corner,
      tip,
      Paint()
        ..color = GameColors.southPole
        ..strokeWidth = 2,
    );
    _arrow(canvas, c, corner, GameColors.northPole);
    _arrow(canvas, c, tip, _vectorColor, width: 4);
    _label(canvas, 'I*', tip + const Offset(16, -8), _vectorColor);
  }

  @override
  bool shouldRepaint(covariant _FramePainter old) => true;
}

class _StatorPainter extends CustomPainter {
  _StatorPainter(this.v);
  final FocTransform v;
  @override
  void paint(Canvas canvas, Size size) {
    final c = Offset(size.width / 2, size.height / 2);
    final r = math.min(size.width, size.height) * .38;
    canvas.drawCircle(
      c,
      r,
      Paint()
        ..color = GameColors.panel
        ..style = PaintingStyle.stroke
        ..strokeWidth = 22,
    );
    _axes(canvas, c, r * .80, 0, 'α', 'β', GameColors.line);
    // Rotor reference axes use separate colours and a dashed line.
    for (var j = 0; j < 2; j++) {
      final a = v.theta + j * math.pi / 2;
      for (var i = -8; i < 8; i += 2) {
        canvas.drawLine(
          _polar(c, r * i / 10, a),
          _polar(c, r * (i + 1) / 10, a),
          Paint()
            ..color = GameColors.muted
            ..strokeWidth = 1.5,
        );
      }
      _label(
        canvas,
        j == 0 ? 'd' : 'q',
        _polar(c, r * .91, a),
        GameColors.cream,
      );
    }
    for (var i = 0; i < 3; i++) {
      final a = i * 2 * math.pi / 3;
      final color = _phaseColors[i];
      final current = v.phases[i];
      for (final sign in [-1, 1]) {
        final p = _polar(c, r, a + (sign < 0 ? math.pi : 0));
        canvas.drawCircle(
          p,
          14,
          Paint()
            ..color = color.withValues(
              alpha: .22 + .65 * (current.abs() / 2).clamp(0, 1),
            ),
        );
        _label(
          canvas,
          current.abs() < .005 ? '0' : (current * sign > 0 ? '•' : '×'),
          p,
          color,
          size: 19,
        );
        _label(
          canvas,
          '${['A', 'B', 'C'][i]}${sign > 0 ? '+' : '−'}',
          _polar(c, r + 29, a + (sign < 0 ? math.pi : 0)),
          color,
        );
      }
      _arrow(
        canvas,
        c,
        _polar(c, r * .63 * (2 / 3) * current, a),
        color,
        width: 3,
      );
    }
    // A family of parallel lines represents the ideal resultant air-gap field.
    final direction = Offset(math.cos(v.fieldAngle), -math.sin(v.fieldAngle));
    final normal = Offset(-direction.dy, direction.dx);
    for (var i = -2; i <= 2; i++) {
      final origin = c + normal * (i * r * .12);
      final half = r * .5;
      if (v.magnitude > .005) {
        _arrow(
          canvas,
          origin - direction * half,
          origin + direction * half,
          _vectorColor.withValues(
            alpha: .12 + .16 * (v.magnitude / 2).clamp(0, 1),
          ),
          width: 2,
        );
      }
    }
    final tip = c + Offset(v.alpha, -v.beta) * r * .63;
    _arrow(canvas, c, tip, _vectorColor, width: 5);
    _label(canvas, 'I* / Bs', tip + const Offset(12, -17), _vectorColor);
    canvas.drawCircle(c, 4, Paint()..color = GameColors.cream);
  }

  @override
  bool shouldRepaint(covariant _StatorPainter old) => true;
}

class _WavePainter extends CustomPainter {
  _WavePainter(this.v);
  final FocTransform v;
  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromLTRB(26, 12, size.width - 14, size.height - 28);
    final mid = rect.center.dy;
    final peak = math.max(1.0, v.magnitude);
    for (final y in [-1, 0, 1]) {
      final height = mid - y * rect.height * .43;
      canvas.drawLine(
        Offset(rect.left, height),
        Offset(rect.right, height),
        Paint()..color = GameColors.line.withValues(alpha: .5),
      );
    }
    for (var phase = 0; phase < 3; phase++) {
      final path = Path();
      for (var i = 0; i <= 240; i++) {
        final value =
            FocTransform(
              d: v.d,
              q: v.q,
              theta: i * 2 * math.pi / 240,
            ).phases[phase];
        final p = Offset(
          rect.left + rect.width * i / 240,
          mid - value / peak * rect.height * .43,
        );
        if (i == 0) {
          path.moveTo(p.dx, p.dy);
        } else {
          path.lineTo(p.dx, p.dy);
        }
      }
      canvas.drawPath(
        path,
        Paint()
          ..color = _phaseColors[phase]
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.5,
      );
      canvas.drawCircle(
        Offset(
          rect.left + rect.width * v.theta / (2 * math.pi),
          mid - v.phases[phase] / peak * rect.height * .43,
        ),
        4,
        Paint()..color = _phaseColors[phase],
      );
    }
    final x = rect.left + rect.width * v.theta / (2 * math.pi);
    canvas.drawLine(
      Offset(x, rect.top),
      Offset(x, rect.bottom),
      Paint()
        ..color = GameColors.cream
        ..strokeWidth = 1,
    );
    for (var i = 0; i <= 4; i++) {
      _label(
        canvas,
        '${i * 90}°',
        Offset(rect.left + rect.width * i / 4, rect.bottom + 16),
        GameColors.muted,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _WavePainter old) => true;
}
