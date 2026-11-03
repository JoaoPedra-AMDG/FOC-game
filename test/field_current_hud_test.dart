import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:torque_chase/game/game_controller.dart';
import 'package:torque_chase/screens/game_screen.dart';
import 'package:torque_chase/theme/game_theme.dart';
import 'package:torque_chase/widgets/field_current_hud.dart';
import 'package:torque_chase/widgets/kart_track.dart';

void main() {
  test(
    'game currents follow the commanded field independently of rotor angle',
    () {
      for (final rotor in [-2.0, 0.0, 1.7]) {
        for (final field in [-2.3, 0.0, math.pi / 2]) {
          final command = gameCurrentCommand(rotor, field);
          expect(command.a, closeTo(math.cos(field), 1e-12));
          expect(command.b, closeTo(math.cos(field - 2 * math.pi / 3), 1e-12));
          expect(command.c, closeTo(math.cos(field + 2 * math.pi / 3), 1e-12));
          expect(command.a + command.b + command.c, closeTo(0, 1e-12));
          expect(command.q, closeTo(math.sin(field - rotor), 1e-12));
        }
      }
    },
  );

  for (final size in [
    const Size(320, 568),
    const Size(390, 740),
    const Size(1280, 900),
  ]) {
    testWidgets(
      'game at $size keeps controls and updates the top current panel',
      (tester) async {
        tester.view.physicalSize = size;
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
        expect(find.byType(KartTrack), findsNothing);
        expect(find.byType(FieldCurrentHud), findsOneWidget);
        expect(find.byKey(const Key('phase-field-diagram')), findsOneWidget);
        expect(find.byKey(const Key('phase-current-history')), findsOneWidget);
        final motor = find.byKey(const Key('motor-control'));
        final figures = find.byKey(const Key('field-current-hud'));
        expect(
          tester.getSize(figures).height,
          closeTo(tester.getSize(motor).height, .01),
        );
        expect(
          find.descendant(of: figures, matching: find.byType(Text)),
          findsNothing,
        );
        expect(
          tester.getSize(find.byKey(const Key('phase-field-diagram'))).height,
          greaterThan(100),
        );
        await tester.tapAt(tester.getCenter(motor) + const Offset(75, 0));
        await tester.pump();
        final painter =
            tester
                    .widget<CustomPaint>(
                      find.byKey(const Key('phase-field-diagram')),
                    )
                    .painter!
                as PhaseFieldPainter;
        expect(painter.fieldAngle, closeTo(0, .01));
        expect(painter.command.a, closeTo(1, .01));
        expect(painter.command.b, closeTo(-.5, .01));
        expect(painter.command.c, closeTo(-.5, .01));
        expect(
          tester.getTopLeft(find.byKey(const Key('field-current-hud'))).dy,
          lessThan(tester.getTopLeft(motor).dy),
        );
        expect(tester.takeException(), isNull);
        controller.home();
        await tester.pumpWidget(const SizedBox());
      },
    );
  }

  testWidgets('sensorless panel does not disclose the hidden rotor frame', (
    tester,
  ) async {
    Future<void> show(double angle, double rpm) => tester.pumpWidget(
      MaterialApp(
        theme: gameTheme(),
        home: Scaffold(
          body: SizedBox(
            height: 124,
            child: FieldCurrentHud(
              rotorAngle: angle,
              fieldAngle: 0,
              sensorless: true,
              rpm: rpm,
            ),
          ),
        ),
      ),
    );
    await show(0, 18);
    String description() =>
        tester
            .widget<Semantics>(find.byKey(const Key('phase-field-semantics')))
            .properties
            .label!;
    expect(description(), contains('α 1.00 amperes, β 0.00 amperes'));
    await show(math.pi / 2, 18);
    expect(description(), contains('α 1.00 amperes, β 0.00 amperes'));
    await show(math.pi / 2, 300);
    expect(description(), contains('d 0.00 amperes, q -1.00 amperes'));
    expect(
      find.descendant(
        of: find.byType(FieldCurrentHud),
        matching: find.byType(Text),
      ),
      findsNothing,
    );
    expect(tester.takeException(), isNull);
  });

  test(
    'three phase field vectors sum to the control in screen coordinates',
    () {
      for (var step = -36; step <= 36; step++) {
        final angle = step * math.pi / 18;
        final command = gameCurrentCommand(.8, angle);
        final sum = phaseFieldContributions(
          command,
        ).fold(Offset.zero, (a, b) => a + b);
        expect(sum.dx, closeTo(math.cos(angle), 1e-12));
        expect(sum.dy, closeTo(math.sin(angle), 1e-12));
      }
    },
  );
}
