import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/scheduler.dart';

import '../config/game_physics_config.dart';
import '../physics/motor_simulation.dart';

enum GamePhase { home, countdown, playing, results }

class GameController extends ChangeNotifier {
  GameController() {
    _ticker = Ticker(_tick);
  }

  late final Ticker _ticker;
  Duration? _lastTick;

  MotorSimulation motor = MotorSimulation();
  GamePhase phase = GamePhase.home;
  double countdownLeft = GamePhysicsConfig.countdownSeconds;
  double timeLeft = GamePhysicsConfig.runDurationSeconds;
  double maxAbsoluteRpm = 0;
  double trackDistance = 0;
  double _positiveTorqueArea = 0;
  double _playSeconds = 0;

  double get torqueControlPercent =>
      _playSeconds == 0
          ? 0
          : (_positiveTorqueArea / _playSeconds * 100).clamp(0, 100);

  void start() {
    _ticker.stop();
    motor = MotorSimulation();
    phase = GamePhase.countdown;
    countdownLeft = GamePhysicsConfig.countdownSeconds;
    timeLeft = GamePhysicsConfig.runDurationSeconds;
    maxAbsoluteRpm = motor.rpm.abs();
    trackDistance = 0;
    _positiveTorqueArea = 0;
    _playSeconds = 0;
    _lastTick = null;
    _ticker.start();
    notifyListeners();
  }

  void setFieldAngle(double angle) {
    if (phase != GamePhase.playing && phase != GamePhase.countdown) return;
    motor.fieldAngle = MotorSimulation.wrapAngle(angle);
    notifyListeners();
  }

  void finish() {
    if (phase != GamePhase.playing) return;
    _ticker.stop();
    phase = GamePhase.results;
    notifyListeners();
  }

  void home() {
    _ticker.stop();
    phase = GamePhase.home;
    notifyListeners();
  }

  void _tick(Duration elapsed) {
    final previous = _lastTick;
    _lastTick = elapsed;
    if (previous == null) return;
    // Integrate ordinary dropped frames in full. Limit very long suspended-tab
    // gaps so resuming the page does not run thousands of substeps at once.
    var dt = ((elapsed - previous).inMicroseconds / 1000000).clamp(0.0, 0.5);
    if (phase == GamePhase.countdown) {
      countdownLeft -= dt;
      if (countdownLeft <= 0) {
        dt = -countdownLeft;
        countdownLeft = 0;
        phase = GamePhase.playing;
      } else {
        dt = 0;
      }
    }
    if (phase == GamePhase.playing) {
      motor.step(dt);
      timeLeft = math.max(0, timeLeft - dt);
      maxAbsoluteRpm = math.max(maxAbsoluteRpm, motor.rpm.abs());
      _positiveTorqueArea += math.max(0, motor.normalizedTorque) * dt;
      _playSeconds += dt;
      // Presentation-only mapping. Reverse RPM moves the track backwards.
      trackDistance += motor.rpm / 60 * dt * 110;
      if (timeLeft == 0) {
        finish();
        return;
      }
    }
    notifyListeners();
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }
}
