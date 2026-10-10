import 'dart:math' as math;

import 'package:flutter_test/flutter_test.dart';
import 'package:torque_chase/physics/motor_simulation.dart';

void main() {
  test(
    'zero and signed ninety-degree field angles produce expected torque',
    () {
      final motor = MotorSimulation(initialRpm: 0);
      motor.fieldAngle = 0;
      expect(motor.electromagneticTorque, closeTo(0, 1e-10));
      motor.fieldAngle = math.pi / 2;
      expect(motor.electromagneticTorque, closeTo(motor.maxTorque, 1e-10));
      motor.fieldAngle = -math.pi / 2;
      expect(motor.electromagneticTorque, closeTo(-motor.maxTorque, 1e-10));
    },
  );

  test('positive torque accelerates; negative torque can reverse', () {
    final motor = MotorSimulation(initialRpm: 0);
    for (var i = 0; i < 240; i++) {
      motor.fieldAngle = motor.rotorAngle + math.pi / 2;
      motor.step(1 / 240);
    }
    expect(motor.rpm, greaterThan(0));
    for (var i = 0; i < 480; i++) {
      motor.fieldAngle = motor.rotorAngle - math.pi / 2;
      motor.step(1 / 240);
    }
    expect(motor.rpm, lessThan(0));
  });

  test('friction slows a coasting rotor', () {
    final motor = MotorSimulation(initialRpm: 100);
    final start = motor.rpm;
    for (var i = 0; i < 240; i++) {
      motor.fieldAngle = motor.rotorAngle;
      motor.step(1 / 240);
    }
    expect(motor.rpm, lessThan(start));
  });

  test('angle wraps smoothly around both boundaries', () {
    expect(MotorSimulation.wrapAngle(2 * math.pi - 0.01), closeTo(-0.01, 1e-9));
    expect(
      MotorSimulation.wrapAngle(-math.pi - 0.01),
      closeTo(math.pi - 0.01, 1e-9),
    );
  });

  test('different frame sizes produce similar motion', () {
    MotorSimulation run(double dt) {
      final motor = MotorSimulation();
      final steps = (2 / dt).round();
      for (var i = 0; i < steps; i++) {
        motor.fieldAngle = motor.rotorAngle + math.pi / 2;
        motor.step(dt);
      }
      return motor;
    }

    final sixty = run(1 / 60);
    final oneTwenty = run(1 / 120);
    expect(sixty.rpm, closeTo(oneTwenty.rpm, 0.2));
    expect(
      MotorSimulation.wrapAngle(sixty.rotorAngle - oneTwenty.rotorAngle),
      closeTo(0, 0.02),
    );
  });
}
