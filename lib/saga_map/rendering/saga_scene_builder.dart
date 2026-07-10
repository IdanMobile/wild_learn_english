import '../domain/saga_map_state.dart';
import '../projection/perspective_projector.dart';
import '../world/saga_path.dart';
import '../world/visible_node_window.dart';
import 'saga_scene.dart';

/// Pure scene-assembly: given the current [state] and a [projector], derive
/// the bounded window, project every visible node, cull the ones the
/// projector rejects, and return the immutable [SagaScene] for this frame.
///
/// No mutable state, no drawing, no Flame lifecycle — every call is a pure
/// function of its inputs.
SagaScene buildSagaScene(
  SagaMapState state,
  PerspectiveProjector projector, {
  double stepFillProgress = 1,
  int? maxLevel,
}) {
  final window = windowFor(state.currentLevel);
  final nodes = <ProjectedNode>[];
  for (final index in window.indices) {
    if (maxLevel != null && index > maxLevel) continue;
    final node = nodeAt(
      index,
      currentLevel: state.currentLevel,
      preset: state.pathPreset,
    );
    final projected = projector.project(node, state.progress);
    if (projected != null) nodes.add(projected);
  }
  return SagaScene(
    window: window,
    nodes: nodes,
    cameraProgress: state.progress,
    projector: projector,
    pathPreset: state.pathPreset,
    stepFillProgress: stepFillProgress,
    maxLevel: maxLevel,
  );
}
