import 'dart:math' as math;

import 'package:flutter_test/flutter_test.dart';
import 'package:learn_english_flutter/saga_map/navigation/saga_scroll_physics.dart';

void main() {
  group('progressDeltaFromDrag', () {
    test('drag changes progress in the drag direction', () {
      expect(progressDeltaFromDrag(100), greaterThan(0));
      expect(progressDeltaFromDrag(-100), lessThan(0));
      expect(progressDeltaFromDrag(0), 0);
    });

    test('scales linearly with sensitivity', () {
      expect(
        progressDeltaFromDrag(100, sensitivity: 0.01),
        closeTo(1.0, 1e-12),
      );
    });

    test('default drag is large enough to cross level thresholds', () {
      expect(progressDeltaFromDrag(180), greaterThan(140));
    });
  });

  group('applyInertiaStep', () {
    test('release inertia continues progress in the velocity direction', () {
      final step = applyInertiaStep(2.0, 1 / 60);
      expect(step.progressDelta, greaterThan(0));
      expect(step.velocity, greaterThan(0));
    });

    test('friction decays velocity toward zero over successive steps', () {
      var velocity = 5.0;
      var previous = double.infinity;
      for (var i = 0; i < 100; i++) {
        final step = applyInertiaStep(velocity, 1 / 60);
        expect(step.velocity.abs(), lessThan(previous));
        previous = step.velocity.abs();
        velocity = step.velocity;
      }
      expect(velocity.abs(), lessThan(0.001));
    });

    test('motion settles below threshold', () {
      var velocity = 5.0;
      var steps = 0;
      InertiaStep step;
      do {
        step = applyInertiaStep(velocity, 1 / 60);
        velocity = step.velocity;
        steps++;
      } while (!step.isSettled && steps < 10000);
      expect(step.isSettled, isTrue);
      expect(velocity.abs(), lessThan(0.001));
    });

    test('is dt-aware: one big step equals two half steps', () {
      const v0 = 3.0;
      const dt = 1 / 30;

      final big = applyInertiaStep(v0, dt);

      final half1 = applyInertiaStep(v0, dt / 2);
      final half2 = applyInertiaStep(half1.velocity, dt / 2);
      final splitProgress = half1.progressDelta + half2.progressDelta;

      expect(big.velocity, closeTo(half2.velocity, 1e-12));
      expect(big.progressDelta, closeTo(splitProgress, 1e-12));
    });

    test('progress delta matches the exact exponential-decay integral', () {
      const v0 = 4.0;
      const dt = 1 / 45;
      const friction = 6.0;
      final expected = v0 * (1 - math.exp(-friction * dt)) / friction;
      final step = applyInertiaStep(v0, dt, friction: friction);
      expect(step.progressDelta, closeTo(expected, 1e-12));
    });
  });
}
