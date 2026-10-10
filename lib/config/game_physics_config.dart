/// Developer tuning for the simplified educational motor model.
abstract final class GamePhysicsConfig {
  /// Larger inertia makes the rotor take longer to speed up or slow down.
  static const double rotorInertia = 0.13;

  /// Larger torque makes acceleration and braking stronger.
  static const double maxElectromagneticTorque = 0.7;

  /// Larger viscous friction removes more speed as RPM rises.
  static const double viscousFriction = 0.0018;

  /// Larger Coulomb friction makes low-speed coasting shorter.
  static const double coulombFriction = 0.012;

  /// Raise this to make the simulation run faster than real elapsed time.
  static const double simulationTimeScale = 1.0;

  /// The starting spin gives players time to find the rotor's direction.
  static const double initialRotorRpm = 18;

  /// Sets the range for HUD and kart visual effects. It is not a speed cap.
  static const double maximumExpectedRpm = 450;

  /// Raise this for a longer run. A fixed timer keeps recovery possible.
  static const double runDurationSeconds = 25;

  /// Countdown before the run starts.
  static const double countdownSeconds = 3;

  /// Numerical substep for stable motion across display refresh rates.
  static const double maximumStepSeconds = 1 / 240;
}
