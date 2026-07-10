import 'dart:math' as math;

class SagaFxState {
  const SagaFxState({
    this.completedLevel,
    this.startedAt = 0,
    this.serial = 0,
    this.comboNumber,
  });

  final int? completedLevel;
  final double startedAt;
  final int serial;
  final int? comboNumber;

  bool get isActive => completedLevel != null;

  bool get hasCombo => comboNumber != null;

  double ageAt(double time) => time - startedAt;

  double completionT(double time) => smooth01(ageAt(time) / 0.75);

  double rewardT(double time) => smooth01((ageAt(time) - 0.18) / 0.95);

  double get rewardArrivalAge => hasCombo ? 5.45 : 1.08;

  double comboT(double time) => smooth01(ageAt(time) / 4.8);

  int lightningFrameIndex(double time, int frameCount) {
    if (frameCount <= 0) return 0;
    final t = (ageAt(time) / 1.3).clamp(0.0, 0.999);
    return (t * frameCount).floor();
  }

  int get rewardStarCount {
    final level = completedLevel;
    if (level == null) return 0;
    return 3 + stableHash(level) % 5;
  }

  int get activeAnimationCount =>
      isActive ? rewardStarCount + 1 + (hasCombo ? 1 : 0) : 0;
}

int stableHash(int value) {
  var x = value & 0x7fffffff;
  x = ((x >> 16) ^ x) * 0x45d9f3b;
  x = ((x >> 16) ^ x) * 0x45d9f3b;
  return ((x >> 16) ^ x) & 0x7fffffff;
}

double stablePhase(int value) => (stableHash(value) % 10000) / 10000;

double smooth01(double value) {
  final t = value.clamp(0.0, 1.0);
  return t * t * (3 - 2 * t);
}

double easeOutBack(double value) {
  final t = value.clamp(0.0, 1.0) - 1;
  const c1 = 1.70158;
  const c3 = c1 + 1;
  return 1 + c3 * math.pow(t, 3) + c1 * math.pow(t, 2);
}
