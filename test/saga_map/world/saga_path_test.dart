import 'package:flutter_test/flutter_test.dart';
import 'package:learn_english_flutter/saga_map/domain/saga_node.dart';
import 'package:learn_english_flutter/saga_map/world/saga_path.dart';

/// SagaNode has no value equality, so compare it field-by-field.
void expectSameNode(SagaNode a, SagaNode b) {
  expect(a.index, b.index);
  expect(a.x, b.x);
  expect(a.depth, b.depth);
  expect(a.state, b.state);
}

void main() {
  group('nodeAt', () {
    test('is deterministic — same arguments yield equal results', () {
      final first = nodeAt(7, currentLevel: 3);
      final second = nodeAt(7, currentLevel: 3);
      expectSameNode(first, second);
    });

    test('large index returns a finite, valid node', () {
      final node = nodeAt(1000000, currentLevel: 0);
      expect(node.index, 1000000);
      expect(node.x.isFinite, isTrue);
      expect(node.depth, isNonNegative);
      expect(node.state, isNotNull);
    });

    // Documented decision: negative indices are SUPPORTED. The layout is a
    // pure function of index (sinusoidal x, linear depth) with no lower bound,
    // so a negative index simply mirrors the path into negative depth and
    // stays finite. No rejection/clamping.
    test('negative index is supported and returns a finite node', () {
      final node = nodeAt(-5, currentLevel: 0);
      expect(node.index, -5);
      expect(node.x.isFinite, isTrue);
      expect(node.depth, -700); // -5 * depthSpacing(140)
      expect(node.state, isNotNull);
    });

    test('path preset changes geometry without changing the node contract', () {
      final gentle = nodeAt(7, currentLevel: 3);
      final dramatic = nodeAt(
        7,
        currentLevel: 3,
        preset: SagaPathPreset.dramatic,
      );

      expect(dramatic.index, gentle.index);
      expect(dramatic.depth, gentle.depth);
      expect(dramatic.state, gentle.state);
      expect(dramatic.x, isNot(gentle.x));
    });
  });

  group('levelForProgress', () {
    test('maps progress thresholds to their current level', () {
      // Recovery-Governance Exception 2: additive regression coverage for
      // the canonical progress -> currentLevel helper.
      final firstThreshold = depth(1).toDouble();
      final fourthThreshold = depth(4).toDouble();

      expect(levelForProgress(firstThreshold - 0.001), 0); // A
      expect(levelForProgress(firstThreshold), 1); // B
      expect(levelForProgress(firstThreshold + 0.001), 1); // C
      expect(levelForProgress(fourthThreshold + 0.5), 4); // D
      expect(levelForProgress(depth(3).toDouble() + 1), 3); // E
      expect(levelForProgress(0), 0); // F
      expect(levelForProgress(-42), 0); // F
    });
  });

  group('frameAt', () {
    test('returns finite tangent normal and curvature', () {
      final frame = frameAt(25);

      expect(frame.tangentX.isFinite, isTrue);
      expect(frame.tangentDepth.isFinite, isTrue);
      expect(frame.normalX.isFinite, isTrue);
      expect(frame.normalDepth.isFinite, isTrue);
      expect(frame.curvature.isFinite, isTrue);
    });

    test('tangent is normalized', () {
      final frame = frameAt(25);
      final length =
          frame.tangentX * frame.tangentX +
          frame.tangentDepth * frame.tangentDepth;

      expect(length, closeTo(1, 0.0001));
    });
  });

  group('propAt', () {
    test('is deterministic, sparse, and includes every supplied prop kind', () {
      final props = [for (var i = 0; i < 200; i++) propAt(i)];

      for (var i = 0; i < props.length; i++) {
        expect(propAt(i), props[i]);
      }
      expect(props.whereType<SagaPropKind>().length, lessThan(80));
      expect(props, contains(SagaPropKind.chest));
      expect(props, contains(SagaPropKind.orb));
      expect(props, contains(SagaPropKind.crystal));
    });
  });
}
