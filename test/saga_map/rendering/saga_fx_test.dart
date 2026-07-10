import 'package:flutter_test/flutter_test.dart';
import 'package:learn_english_flutter/saga_map/rendering/saga_fx.dart';

void main() {
  group('SagaFxState', () {
    test('reward count is bounded from 3 to 7 stars', () {
      for (var level = 0; level < 500; level++) {
        final fx = SagaFxState(completedLevel: level);

        expect(fx.rewardStarCount, inInclusiveRange(3, 7));
      }
    });

    test('same level produces deterministic idle phase and reward count', () {
      const a = SagaFxState(completedLevel: 42);
      const b = SagaFxState(completedLevel: 42);

      expect(a.rewardStarCount, b.rewardStarCount);
      expect(stablePhase(42), stablePhase(42));
    });

    test('inactive state reports no active animations', () {
      const fx = SagaFxState();

      expect(fx.rewardStarCount, 0);
      expect(fx.activeAnimationCount, 0);
    });

    test('combo state adds one bounded major animation', () {
      const fx = SagaFxState(completedLevel: 4, comboNumber: 3);

      expect(fx.hasCombo, isTrue);
      expect(fx.activeAnimationCount, fx.rewardStarCount + 2);
    });

    test('completion and reward timelines are clamped', () {
      const fx = SagaFxState(completedLevel: 2, startedAt: 10);

      expect(fx.completionT(9), 0);
      expect(fx.completionT(20), 1);
      expect(fx.rewardT(9), 0);
      expect(fx.rewardT(20), 1);
    });

    test('lightning frame index stays inside supplied frame count', () {
      const fx = SagaFxState(completedLevel: 4, startedAt: 10, comboNumber: 3);

      expect(fx.lightningFrameIndex(10, 8), 0);
      expect(fx.lightningFrameIndex(20, 8), 7);
      expect(fx.lightningFrameIndex(10.3, 0), 0);
    });

    test('combo reward arrives after the cinematic hero flight', () {
      const regular = SagaFxState(completedLevel: 1);
      const combo = SagaFxState(completedLevel: 4, comboNumber: 3);

      expect(regular.rewardArrivalAge, lessThan(combo.rewardArrivalAge));
      expect(combo.rewardArrivalAge, 5.45);
    });
  });
}
