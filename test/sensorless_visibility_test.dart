import 'dart:math' as math;

import 'package:flutter_test/flutter_test.dart';
import 'package:torque_chase/widgets/motor_painter.dart';

void main() {
  test('sensorless rotor resolves from the starting speed to 300 RPM', () {
    expect(SensorlessVisibility.reveal(0), 0);
    expect(SensorlessVisibility.reveal(18), 0);
    expect(
      SensorlessVisibility.uncertaintySweep(18),
      closeTo(2 * math.pi, 1e-9),
    );
    expect(SensorlessVisibility.reveal(159), closeTo(0.5, 1e-9));
    expect(SensorlessVisibility.reveal(-159), closeTo(0.5, 1e-9));
    expect(SensorlessVisibility.reveal(300), 1);
    expect(SensorlessVisibility.uncertaintySweep(300), 0);
    expect(SensorlessVisibility.reveal(450), 1);
  });

  test('rotor shadows converge from both sides and disappear at 300 RPM', () {
    final start = SensorlessVisibility.shadowOffsets(18);
    final halfway = SensorlessVisibility.shadowOffsets(159);
    expect(start, hasLength(6));
    expect(start.first, lessThan(-2));
    expect(start.last, greaterThan(2));
    expect(halfway.first.abs(), lessThan(start.first.abs()));
    expect(halfway.last, lessThan(start.last));
    expect(SensorlessVisibility.shadowOffsets(300), isEmpty);
  });
}
