import 'dart:math' as math;

/// Pure drag-to-progress conversion and release inertia for the saga map.
///
/// Deliberately has no dependency on Flutter's `ListView`/`ScrollController`:
/// `progress` is owned by `SagaMapState`, not by a scroll offset.
const double _defaultSensitivity = 0.0025;
const double _defaultFriction = 6.0;
const double _velocitySettleThreshold = 0.001;

/// Converts a raw vertical drag [deltaY] (pixels) into a progress delta,
/// scaled by [sensitivity] (progress units per pixel).
double progressDeltaFromDrag(
  double deltaY, {
  double sensitivity = _defaultSensitivity,
}) {
  return deltaY * sensitivity;
}

/// Result of a single inertia decay step: the progress advanced this step
/// and the velocity remaining afterwards.
class InertiaStep {
  const InertiaStep({required this.progressDelta, required this.velocity});

  final double progressDelta;
  final double velocity;

  /// Whether velocity has decayed enough that inertia should stop.
  bool get isSettled => velocity.abs() < _velocitySettleThreshold;
}

/// Advances [velocity] by [dt] seconds of exponential friction decay and
/// returns the progress covered during that step along with the decayed
/// velocity. Deterministic and dt-aware: the progress delta is the exact
/// integral of the exponential decay over [dt], so results stay consistent
/// across frame rates rather than drifting with step size.
InertiaStep applyInertiaStep(
  double velocity,
  double dt, {
  double friction = _defaultFriction,
}) {
  final decayed = velocity * math.exp(-friction * dt);
  final progressDelta = (velocity - decayed) / friction;
  return InertiaStep(progressDelta: progressDelta, velocity: decayed);
}
