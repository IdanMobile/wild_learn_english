import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:learn_english_flutter/saga_map/domain/saga_map_state.dart';
import 'package:learn_english_flutter/saga_map/projection/perspective_projector.dart';
import 'package:learn_english_flutter/saga_map/rendering/saga_map_painter.dart';
import 'package:learn_english_flutter/saga_map/rendering/saga_scene_builder.dart';

void main() {
  test(
    'renders the procedural map when every optional image is unavailable',
    () {
      final scene = buildSagaScene(
        const SagaMapState(progress: 0, currentLevel: 0),
        const PerspectiveProjector(
          viewportCenterX: 200,
          horizonY: 100,
          baseY: 420,
          fogDistance: 3600,
        ),
      );
      final recorder = PictureRecorder();
      final canvas = Canvas(recorder);

      expect(
        () => SagaMapPainter(scene: scene).paint(canvas, const Size(400, 800)),
        returnsNormally,
      );
      recorder.endRecording();
    },
  );
}
