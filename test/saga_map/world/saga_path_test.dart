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
  });
}
