import 'dart:math' as math;
import 'dart:ui';

import '../world/saga_path.dart';

class SagaCamera {
  SagaCamera({double progress = 0}) {
    targetProgress = progress;
    visualProgress = progress;
  }

  double targetProgress = 0;
  double visualProgress = 0;
  double velocity = 0;
  double cameraX = 0;
  double yaw = 0;
  double height = 0.48;
  double angle = 0.17;
  double response = 14;

  void setTarget(double progress) {
    targetProgress = progress;
  }

  void tune({double? height, double? angle, double? response}) {
    if (height != null) this.height = height.clamp(0.48, 0.82);
    if (angle != null) this.angle = angle.clamp(0.08, 0.34);
    if (response != null) this.response = response.clamp(1.0, 26.0);
  }

  void update(double dt, SagaPathPreset preset) {
    final omega = response;
    final x = omega * dt;
    final exp = 1 / (1 + x + 0.48 * x * x + 0.235 * x * x * x);
    final change = visualProgress - targetProgress;
    final temp = (velocity + omega * change) * dt;
    velocity = (velocity - omega * temp) * exp;
    visualProgress = targetProgress + (change + temp) * exp;

    if ((targetProgress - visualProgress).abs() < 1.2 && velocity.abs() < 120) {
      visualProgress = targetProgress;
      velocity = 0;
    }

    final level = levelForProgress(visualProgress);
    final targetX = _lookAheadX(level, preset);
    final xFollow = 1 - math.exp(-response * 0.82 * dt);
    cameraX += (targetX - cameraX) * xFollow;

    final frame = frameAt(level, preset: preset);
    final yawTarget = (frame.tangentX * 0.7 + frame.curvature * 0.25).clamp(
      -0.16,
      0.16,
    );
    final yawFollow = 1 - math.exp(-response * 0.58 * dt);
    yaw += (yawTarget - yaw) * yawFollow;
  }

  int nearestLevel(int? maxLevel) =>
      _clampLevel((visualProgress / depth(1)).round(), maxLevel);

  int targetLevel(int? maxLevel) =>
      _clampLevel((targetProgress / depth(1)).round(), maxLevel);

  double get focalLength => 420 + angle * 720;

  SagaCameraSnapshot get snapshot => SagaCameraSnapshot(
    targetProgress: targetProgress,
    visualProgress: visualProgress,
    velocity: velocity,
    cameraX: cameraX,
    yaw: yaw,
    pitch: angle,
    height: height,
  );

  double _lookAheadX(int level, SagaPathPreset preset) {
    final current = _interpolatedPathX(preset);
    var futureSum = 0.0;
    var weightSum = 0.0;
    for (var i = 1; i <= 4; i++) {
      final weight = 5 - i;
      futureSum += x(level + i, preset: preset) * weight;
      weightSum += weight;
    }
    final future = weightSum == 0 ? current : futureSum / weightSum;
    final speed01 = (velocity.abs() / 1400).clamp(0.0, 1.0);
    final futureWeight = 0.28 + speed01 * 0.18;
    return current * (1 - futureWeight) + future * futureWeight;
  }

  double _interpolatedPathX(SagaPathPreset preset) {
    final level = levelForProgress(visualProgress);
    final fromDepth = depth(level);
    final toDepth = depth(level + 1);
    final t = ((visualProgress - fromDepth) / (toDepth - fromDepth))
        .clamp(0.0, 1.0)
        .toDouble();
    final fromX = x(level, preset: preset);
    final toX = x(level + 1, preset: preset);
    return lerpDouble(fromX, toX, t) ?? fromX;
  }

  static int _clampLevel(int level, int? maxLevel) {
    if (level < 0) return 0;
    if (maxLevel == null) return level;
    return math.min(level, maxLevel);
  }
}

class SagaCameraSnapshot {
  const SagaCameraSnapshot({
    required this.targetProgress,
    required this.visualProgress,
    required this.velocity,
    required this.cameraX,
    required this.yaw,
    required this.pitch,
    required this.height,
  });

  const SagaCameraSnapshot.zero()
    : targetProgress = 0,
      visualProgress = 0,
      velocity = 0,
      cameraX = 0,
      yaw = 0,
      pitch = 0.17,
      height = 0.48;

  final double targetProgress;
  final double visualProgress;
  final double velocity;
  final double cameraX;
  final double yaw;
  final double pitch;
  final double height;
}
