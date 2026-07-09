import '../projection/perspective_projector.dart';
import '../world/visible_node_window.dart';

/// Immutable, bounded snapshot of what to draw this frame — the
/// window → path → projector pipeline's output, assembled once and handed
/// to the renderer. Plain data holder: no mutation methods, no scene-graph
/// behavior.
class SagaScene {
  const SagaScene({required this.window, required this.nodes});

  /// The bounded index range this scene was assembled from.
  final VisibleNodeWindow window;

  /// Projected nodes, in the same ascending order as [window.indices],
  /// skipping any index the projector culled (behind camera, singularity,
  /// non-finite coordinates). Bounded by [window.length].
  final List<ProjectedNode> nodes;
}
