import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:torque_chase/game/foc_transform.dart';
import 'package:torque_chase/screens/transform_lab.dart';
import 'package:torque_chase/theme/game_theme.dart';

void main() {
  test('q current at zero rotor angle produces balanced B/C currents', () {
    const v = FocTransform(d: 0, q: 1, theta: 0);
    expect(v.a, closeTo(0, 1e-12));
    expect(v.b, closeTo(math.sqrt(3) / 2, 1e-12));
    expect(v.c, closeTo(-math.sqrt(3) / 2, 1e-12));
  });
  test(
    'phase fields sum to desired vector and forward transforms recover d/q',
    () {
      for (var step = 0; step < 36; step++) {
        for (final d in [-1.3, 0.0, .7]) {
          final v = FocTransform(d: d, q: -.8, theta: step * math.pi / 18);
          final alpha = 2 / 3 * (v.a - v.b / 2 - v.c / 2);
          final beta = (v.b - v.c) / math.sqrt(3);
          expect(v.a + v.b + v.c, closeTo(0, 1e-12));
          expect(alpha, closeTo(v.alpha, 1e-12));
          expect(beta, closeTo(v.beta, 1e-12));
          expect(
            alpha * math.cos(v.theta) + beta * math.sin(v.theta),
            closeTo(d, 1e-12),
          );
          expect(
            -alpha * math.sin(v.theta) + beta * math.cos(v.theta),
            closeTo(v.q, 1e-12),
          );
        }
      }
    },
  );
  for (final size in [const Size(390, 844), const Size(1280, 900)]) {
    testWidgets('lab fits $size and dragging changes phase commands', (
      tester,
    ) async {
      tester.view.physicalSize = size;
      tester.view.devicePixelRatio = 1;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });
      await tester.pumpWidget(
        MaterialApp(theme: gameTheme(), home: const TransformLab()),
      );
      expect(tester.takeException(), isNull);
      final stator = find.byKey(const Key('stator-vector'));
      await tester.ensureVisible(stator);
      final center = tester.getCenter(stator);
      await tester.tapAt(center + const Offset(40, -30));
      await tester.pump();
      expect(tester.takeException(), isNull);
      await tester.scrollUntilVisible(find.text('PHASE A'), 300);
      expect(find.text('0.00 A'), findsNothing);
      await tester.pumpWidget(const SizedBox());
    });
  }
}
