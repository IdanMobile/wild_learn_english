import 'dart:ui';

import 'package:flame/events.dart';
import 'package:flame/game.dart';

import 'domain/saga_map_state.dart';
import 'navigation/saga_scroll_physics.dart';
import 'projection/perspective_projector.dart';
import 'rendering/saga_map_painter.dart';
import 'rendering/saga_scene_builder.dart';

/// Thin Flame host for the saga map.
///
/// Owns only the single [SagaMapState] and translates drag into progress via
/// [progressDeltaFromDrag]. Every frame it builds the immutable scene through
/// [buildSagaScene] and hands it to [SagaMapPainter] — it never calls
/// `windowFor`/`nodeAt`/`PerspectiveProjector.project` itself, and holds no
/// projection or drawing logic of its own.
class SagaMapGame extends FlameGame with DragCallbacks {
  SagaMapGame({
    this.state = const SagaMapState(progress: 0, currentLevel: 0),
  });

  SagaMapState state;

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    final projector = PerspectiveProjector(
      viewportCenterX: size.x / 2,
      horizonY: size.y * 0.15,
      baseY: size.y * 0.9,
    );
    final scene = buildSagaScene(state, projector);
    SagaMapPainter(scene: scene).paint(canvas, Size(size.x, size.y));
  }

  @override
  void onDragUpdate(DragUpdateEvent event) {
    final delta = progressDeltaFromDrag(event.localDelta.y);
    final next = state.progress + delta;
    state = state.copyWith(progress: next < 0 ? 0 : next);
  }
}
