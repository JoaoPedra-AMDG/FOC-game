import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:torque_chase/app.dart';
import 'package:torque_chase/game/game_controller.dart';
import 'package:torque_chase/screens/about_screen.dart';
import 'package:torque_chase/screens/game_screen.dart';
import 'package:torque_chase/screens/results_screen.dart';
import 'package:torque_chase/theme/game_theme.dart';

void main() {
  testWidgets('About us is reachable from the landing screen', (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(const TorqueChaseApp());
    await tester.ensureVisible(find.byKey(const Key('home-about')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('home-about')));
    await tester.pumpAndSettle();

    expect(find.byType(AboutScreen), findsOneWidget);
    expect(find.byKey(const Key('about-dashboard')), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('dragging the motor changes the commanded field angle', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 740);
    tester.view.devicePixelRatio = 1;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    final controller = GameController()..start();
    addTearDown(controller.dispose);
    await tester.pumpWidget(
      MaterialApp(
        theme: gameTheme(),
        home: GameScreen(controller: controller, onExit: () {}),
      ),
    );
    for (var i = 0; i < 7; i++) {
      await tester.pump(const Duration(milliseconds: 500));
    }
    expect(controller.phase, GamePhase.playing);

    final center = tester.getCenter(find.byKey(const Key('motor-control')));
    final gesture = await tester.startGesture(center + const Offset(100, 0));
    await gesture.moveTo(center + const Offset(0, 100));
    await tester.pump();
    expect(controller.motor.fieldAngle, closeTo(math.pi / 2, 0.12));
    await gesture.up();
    expect(tester.takeException(), isNull);
    controller.home();
    await tester.pump();
  });

  testWidgets('a run reaches the results screen after the timer', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 740);
    tester.view.devicePixelRatio = 1;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(const TorqueChaseApp());
    await tester.ensureVisible(find.byKey(const Key('home-play')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('home-play')));
    await tester.pump();
    for (var i = 0; i < 58; i++) {
      await tester.pump(const Duration(milliseconds: 500));
    }

    expect(find.byType(ResultsScreen), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
