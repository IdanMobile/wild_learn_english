import 'package:flutter_test/flutter_test.dart';
import 'package:learn_english_flutter/saga_map/world/visible_node_window.dart';

void main() {
  group('windowFor', () {
    // Away from the origin the window is a constant size: _behind + _ahead + 1.
    const boundedLength = 27; // 2 behind + 24 ahead + the current level.

    test('visible count stays bounded for small travel', () {
      for (var level = 2; level < 100; level++) {
        expect(windowFor(level).length, boundedLength);
      }
    });

    test('visible count stays bounded at ~1,000,000-equivalent travel', () {
      // Arithmetic, not brute-force: we read .length (end - start + 1), never
      // materialising the indices, so cost is O(1) regardless of level.
      for (final level in [1000, 100000, 1000000, 1 << 40]) {
        expect(windowFor(level).length, boundedLength);
      }
    });

    test('window clamps at the origin and never goes negative', () {
      expect(windowFor(0).start, 0);
      expect(windowFor(1).start, 0);
      expect(windowFor(0).length, lessThanOrEqualTo(boundedLength));
    });

    test('window shifts forward as progress increases', () {
      final a = windowFor(10);
      final b = windowFor(50);
      expect(b.start, greaterThan(a.start));
      expect(b.end, greaterThan(a.end));
    });

    test('indices are ascending with no duplicates', () {
      final indices = windowFor(500).indices;
      expect(indices.toSet().length, indices.length);
      for (var i = 1; i < indices.length; i++) {
        expect(indices[i], indices[i - 1] + 1);
      }
    });
  });
}
