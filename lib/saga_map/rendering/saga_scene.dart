import '../projection/perspective_projector.dart';
import '../world/saga_path.dart';
import '../world/visible_node_window.dart';

/// Immutable, bounded snapshot of what to draw this frame — the
/// window → path → projector pipeline's output, assembled once and handed
/// to the renderer. Plain data holder: no mutation methods, no scene-graph
/// behavior.
class SagaScene {
  const SagaScene({
    required this.window,
    required this.nodes,
    required this.cameraProgress,
    required this.projector,
    required this.pathPreset,
    this.stepFillProgress = 1,
    this.maxLevel,
  });

  /// The bounded index range this scene was assembled from.
  final VisibleNodeWindow window;

  /// Projected nodes, in the same ascending order as [window.indices],
  /// skipping any index the projector culled (behind camera, singularity,
  /// non-finite coordinates). Bounded by [window.length].
  final List<ProjectedNode> nodes;

  /// Absolute camera progress used to project this scene.
  final double cameraProgress;

  /// Projector used by this frame so every world item follows the same camera.
  final PerspectiveProjector projector;

  /// Active path shape, shared by stones and projected world decorations.
  final SagaPathPreset pathPreset;

  /// Fill animation progress for the current step rings.
  final double stepFillProgress;

  /// Last playable level for finite maps. Null means endless mode.
  final int? maxLevel;
}
