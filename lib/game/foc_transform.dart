import 'dart:math' as math;

/// Amplitude-invariant transforms, balanced currents, zero sequence = 0.
/// Electrical angles are counterclockwise from the stationary alpha / A axis.
class FocTransform {
  const FocTransform({required this.d, required this.q, required this.theta});
  final double d;
  final double q;
  final double theta;
  double get alpha => d * math.cos(theta) - q * math.sin(theta);
  double get beta => d * math.sin(theta) + q * math.cos(theta);
  double get a => alpha;
  double get b => -alpha / 2 + math.sqrt(3) * beta / 2;
  double get c => -alpha / 2 - math.sqrt(3) * beta / 2;
  List<double> get phases => [a, b, c];
  double get magnitude => math.sqrt(d * d + q * q);
  double get fieldAngle => math.atan2(beta, alpha);
}
