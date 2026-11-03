import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:torque_chase/game/current_history.dart';
import 'package:torque_chase/game/game_controller.dart';
import 'package:torque_chase/screens/game_screen.dart';
import 'package:torque_chase/theme/game_theme.dart';

void main() {
  test('a held command produces flat currents at distinct real times', () {
    final history = CurrentHistory()..reset(0);
    history.record(.4, 0);
    history.record(1.7, 0);
    expect(history.samples.map((s) => s.time), [0, .4, 1.7]);
    for (final sample in history.samples) {
      expect(sample.a, 1);
      expect(sample.b, closeTo(-.5, 1e-12));
      expect(sample.c, closeTo(-.5, 1e-12));
    }
    history.record(2, math.pi / 2);
    expect(history.samples.last.a, closeTo(0, 1e-12));
    expect(history.samples.last.b, closeTo(math.sqrt(3) / 2, 1e-12));
    expect(history.samples.last.c, closeTo(-math.sqrt(3) / 2, 1e-12));
  });

  test(
    'history rolls with time, merges same-time commands and resets per run',
    () {
      final history = CurrentHistory()..reset(0);
      for (var i = 1; i <= 1200; i++) {
        history.record(i / 60, .4);
      }
      expect(history.samples.length, lessThanOrEqualTo(182));
      expect(history.samples[1].time, greaterThanOrEqualTo(17));
      expect(history.time, 20);
      final length = history.samples.length;
      history.record(20, 1);
      expect(history.samples.length, length);
      history.reset(math.pi / 2);
      expect(history.samples.length, 1);
      expect(history.time, 0);
    },
  );

  testWidgets('history uses the active run clock and restarts with the game', (
    tester,
  ) async {
    final controller = GameController()..start();
    addTearDown(controller.dispose);
    await tester.pumpWidget(
      MaterialApp(
        theme: gameTheme(),
        home: GameScreen(controller: controller, onExit: () {}),
      ),
    );
    await tester.pump(const Duration(milliseconds: 500));
    expect(controller.currentHistory.time, 0);
    for (var i = 0; i < 8; i++) {
      await tester.pump(const Duration(milliseconds: 500));
    }
    expect(controller.phase, GamePhase.playing);
    expect(
      controller.currentHistory.time,
      closeTo(25 - controller.timeLeft, 1e-9),
    );
    controller.setFieldAngle(0);
    await tester.pump();
    expect(controller.currentHistory.samples.last.a, 1);
    expect(find.text('PHASE CURRENTS vs TIME'), findsOneWidget);
    expect(tester.takeException(), isNull);
    controller.start();
    expect(controller.currentHistory.time, 0);
    expect(controller.currentHistory.samples.length, 1);
    controller.home();
    await tester.pumpWidget(const SizedBox());
  });
}
