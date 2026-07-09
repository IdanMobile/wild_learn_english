import 'package:flutter_test/flutter_test.dart';
import 'package:learn_english_flutter/saga_map/domain/saga_node.dart';
import 'package:learn_english_flutter/saga_map/domain/saga_node_state.dart';
import 'package:learn_english_flutter/saga_map/projection/perspective_projector.dart';

// baseY below the horizon so "toward the horizon" means screenY decreasing.
const projector = PerspectiveProjector(
  viewportCenterX: 100,
  horizonY: 50,
  baseY: 400,
);

SagaNode nodeAtDepth(int depth, {double x = 10}) =>
    SagaNode(index: depth, x: x, depth: depth, state: SagaNodeState.upcoming);

void main() {
  group('project', () {
    test('farther depth yields smaller scale', () {
      final near = projector.project(nodeAtDepth(1), 0)!;
      final mid = projector.project(nodeAtDepth(5), 0)!;
      final far = projector.project(nodeAtDepth(15), 0)!;

      expect(mid.scale, lessThan(near.scale));
      expect(far.scale, lessThan(mid.scale));
    });

    test('screenY trends toward the horizon as depth grows', () {
      final near = projector.project(nodeAtDepth(1), 0)!;
      final far = projector.project(nodeAtDepth(30), 0)!;

      // baseY (400) is below the horizon (50); far nodes converge upward.
      expect(far.screenY, lessThan(near.screenY));
      expect((far.screenY - projector.horizonY).abs(),
          lessThan((near.screenY - projector.horizonY).abs()));
    });

    test('a wide sweep of valid inputs yields only finite outputs', () {
      for (var depth = 0; depth <= 500; depth += 5) {
        for (final x in const [-1000.0, -1.0, 0.0, 1.0, 1000.0]) {
          final projected = projector.project(nodeAtDepth(depth, x: x), 0);
          if (projected == null) continue; // culled is acceptable
          expect(projected.screenX.isFinite, isTrue);
          expect(projected.screenY.isFinite, isTrue);
          expect(projected.scale.isFinite, isTrue);
          expect(projected.scale, greaterThan(0));
          expect(projected.fogFactor, inInclusiveRange(0, 1));
        }
      }
    });

    test('nodes at or behind the camera are culled', () {
      // relativeDepth <= -focalLength (6) => denom <= 0 => culled.
      // With progress large enough, a node sits behind the camera plane.
      expect(projector.project(nodeAtDepth(0), 6), isNull); // relDepth = -6
      expect(projector.project(nodeAtDepth(0), 20), isNull); // well behind
      expect(projector.project(nodeAtDepth(3), 100), isNull);
    });

    test('the perspective singularity is culled, not returned as infinity', () {
      // denom = focalLength + (depth - progress) ≈ 0 at progress = depth + 6.
      final result = projector.project(nodeAtDepth(4), 10); // relDepth = -6
      expect(result, isNull);
    });
  });
}
