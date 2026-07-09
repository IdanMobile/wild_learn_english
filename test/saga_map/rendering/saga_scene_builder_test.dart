import 'package:flutter_test/flutter_test.dart';
import 'package:learn_english_flutter/saga_map/domain/saga_map_state.dart';
import 'package:learn_english_flutter/saga_map/projection/perspective_projector.dart';
import 'package:learn_english_flutter/saga_map/rendering/saga_scene_builder.dart';
import 'package:learn_english_flutter/saga_map/world/visible_node_window.dart';

void main() {
  const projector = PerspectiveProjector(
    viewportCenterX: 200,
    horizonY: 100,
    baseY: 600,
  );

  group('buildSagaScene', () {
    test('scene window equals windowFor(currentLevel)', () {
      final scene = buildSagaScene(
        const SagaMapState(progress: 0, currentLevel: 10),
        projector,
      );
      final expected = windowFor(10);
      expect(scene.window.start, expected.start);
      expect(scene.window.end, expected.end);
    });

    test('keeps every node when all are in front of the camera', () {
      final scene = buildSagaScene(
        const SagaMapState(progress: 0, currentLevel: 10),
        projector,
      );
      expect(scene.nodes.length, scene.window.length);
    });

    test('nodes stay in ascending index order', () {
      final scene = buildSagaScene(
        const SagaMapState(progress: 0, currentLevel: 10),
        projector,
      );
      for (var i = 1; i < scene.nodes.length; i++) {
        expect(
          scene.nodes[i].node.index,
          greaterThan(scene.nodes[i - 1].node.index),
        );
      }
    });

    test('culls nodes the projector rejects (behind the camera)', () {
      // progress past the nearest window depths pushes low indices behind
      // the camera, so the scene holds fewer nodes than the window.
      final scene = buildSagaScene(
        const SagaMapState(progress: 1200, currentLevel: 10),
        projector,
      );
      expect(scene.nodes.length, lessThan(scene.window.length));
    });

    test('is pure: identical inputs yield identical output', () {
      const state = SagaMapState(progress: 42, currentLevel: 7);
      final a = buildSagaScene(state, projector);
      final b = buildSagaScene(state, projector);
      expect(a.nodes.length, b.nodes.length);
      for (var i = 0; i < a.nodes.length; i++) {
        expect(a.nodes[i].node.index, b.nodes[i].node.index);
        expect(a.nodes[i].screenX, b.nodes[i].screenX);
        expect(a.nodes[i].screenY, b.nodes[i].screenY);
      }
    });
  });
}
