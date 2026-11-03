import 'dart:collection';
import 'dart:math' as math;

class CurrentSample {
  const CurrentSample(this.time, this.a, this.b, this.c);
  final double time, a, b, c;
  List<double> get phases => [a, b, c];
}

/// Actual command samples on the active run clock, not a predicted sine cycle.
class CurrentHistory {
  static const windowSeconds = 3.0;
  final List<CurrentSample> _samples = [];
  late final samples = UnmodifiableListView<CurrentSample>(_samples);
  int revision = 0;
  double get time => _samples.isEmpty ? 0 : _samples.last.time;

  void reset(double fieldAngle) {
    _samples.clear();
    record(0, fieldAngle);
  }

  void record(double time, double fieldAngle) {
    final sample = CurrentSample(
      time,
      math.cos(fieldAngle),
      math.cos(fieldAngle - 2 * math.pi / 3),
      math.cos(fieldAngle + 2 * math.pi / 3),
    );
    if (_samples.isNotEmpty && (time - _samples.last.time).abs() < 1e-9) {
      _samples[_samples.length - 1] = sample;
    } else {
      _samples.add(sample);
    }
    // Keep one sample before the visible window, for a continuous left edge.
    var remove = 0;
    while (remove + 1 < _samples.length &&
        _samples[remove + 1].time < time - windowSeconds) {
      remove++;
    }
    if (remove > 0) {
      _samples.removeRange(0, remove);
    }
    if (_samples.length > 2048) {
      _samples.removeRange(0, _samples.length - 2048);
    }
    revision++;
  }
}
