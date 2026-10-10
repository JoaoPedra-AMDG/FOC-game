import 'dart:math' as math;

import '../config/game_physics_config.dart';

/// A deliberately small model: field angle -> torque -> acceleration -> angle.
class MotorSimulation {
  MotorSimulation({
    this.inertia = GamePhysicsConfig.rotorInertia,
    this.maxTorque = GamePhysicsConfig.maxElectromagneticTorque,
    this.viscousFriction = GamePhysicsConfig.viscousFriction,
    this.coulombFriction = GamePhysicsConfig.coulombFriction,
    double initialRpm = GamePhysicsConfig.initialRotorRpm,
  }) : angularVelocity = initialRpm * 2 * math.pi / 60;

  final double inertia;
  final double maxTorque;
  final double viscousFriction;
  final double coulombFriction;

  double rotorAngle = 0;
  double fieldAngle = math.pi / 2;
  double angularVelocity;

  static double wrapAngle(double angle) {
    final wrapped = (angle + math.pi) % (2 * math.pi);
    return (wrapped < 0 ? wrapped + 2 * math.pi : wrapped) - math.pi;
  }

  double get torqueAngle => wrapAngle(fieldAngle - rotorAngle);
  double get electromagneticTorque => maxTorque * math.sin(torqueAngle);
  double get normalizedTorque => math.sin(torqueAngle);
  double get rpm => angularVelocity * 60 / (2 * math.pi);

  void step(double elapsedSeconds) {
    if (elapsedSeconds <= 0 || !elapsedSeconds.isFinite) return;
    final scaled = elapsedSeconds * GamePhysicsConfig.simulationTimeScale;
    final count = (scaled / GamePhysicsConfig.maximumStepSeconds).ceil();
    final dt = scaled / count;
    for (var i = 0; i < count; i++) {
      final applied = electromagneticTorque;
      final viscous = viscousFriction * angularVelocity;
      final withoutDryFriction =
          angularVelocity + (applied - viscous) / inertia * dt;

      // Dry friction opposes motion but cannot make a coasting rotor reverse.
      final dryDelta = coulombFriction / inertia * dt;
      if (withoutDryFriction.abs() <= dryDelta &&
          applied.abs() <= coulombFriction) {
        angularVelocity = 0;
      } else {
        final direction =
            withoutDryFriction == 0 ? applied.sign : withoutDryFriction.sign;
        angularVelocity = withoutDryFriction - direction * dryDelta;
      }
      rotorAngle = wrapAngle(rotorAngle + angularVelocity * dt);
    }
  }
}
