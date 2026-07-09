import '../domain/saga_node.dart';

/// Result of projecting a [SagaNode] into 2D screen space.
///
/// Only produced for nodes that are in front of the camera and yield
/// finite coordinates — see [PerspectiveProjector.project].
class ProjectedNode {
  const ProjectedNode({
    required this.node,
    required this.screenX,
    required this.screenY,
    required this.scale,
    required this.fogFactor,
  });

  final SagaNode node;

  /// Horizontal screen position, in the same units as the viewport.
  final double screenX;

  /// Vertical screen position; nearer nodes sit lower, far nodes converge
  /// toward the horizon.
  final double screenY;

  /// Perspective scale in (0, 1]; 1 at the camera plane, →0 at infinity.
  final double scale;

  /// Atmospheric fade in [0, 1]; 0 = fully clear (near), 1 = fully fogged.
  final double fogFactor;
}

/// Pure, stateless perspective projection for saga map nodes.
///
/// No caching, no mutable state — every [project] call is a pure function
/// of its inputs. All tuning lives in the const fields so the math stays a
/// single readable pipeline.
class PerspectiveProjector {
  const PerspectiveProjector({
    this.focalLength = 6.0,
    required this.viewportCenterX,
    required this.horizonY,
    required this.baseY,
    this.fogDistance = 20.0,
  });

  /// Distance from camera to the projection plane. Larger = flatter,
  /// less exaggerated perspective. Tune to taste.
  final double focalLength;

  /// Screen x that a node at world x=0 maps to.
  final double viewportCenterX;

  /// Screen y that far nodes converge toward (vanishing line).
  final double horizonY;

  /// Screen y of a node sitting exactly on the camera plane (scale 1).
  final double baseY;

  /// World depth over which fog ramps from clear (0) to full (1).
  final double fogDistance;

  /// Smallest allowed magnitude of the perspective denominator before we
  /// treat the result as a divide blow-up and cull it.
  static const double _epsilon = 1e-6;

  /// Projects [node] given the camera's [progress] along the path.
  ///
  /// Returns null when the node is at/behind the camera, sits on the
  /// perspective singularity, or produces any non-finite coordinate.
  ProjectedNode? project(SagaNode node, double progress) {
    final relativeDepth = node.depth - progress;
    final denom = focalLength + relativeDepth;

    // Guard the singularity: near-zero denominator explodes scale.
    if (denom.abs() < _epsilon) return null;

    final scale = focalLength / denom;

    // Behind camera (or at infinity) => nothing to draw.
    if (scale <= 0) return null;

    final screenX = viewportCenterX + node.x * scale;
    // Converge toward the horizon as depth grows (scale → 0).
    final screenY = horizonY + (baseY - horizonY) * scale;

    if (!screenX.isFinite || !screenY.isFinite || !scale.isFinite) return null;

    final fogFactor = _clamp01(relativeDepth / fogDistance);

    return ProjectedNode(
      node: node,
      screenX: screenX,
      screenY: screenY,
      scale: scale,
      fogFactor: fogFactor,
    );
  }

  static double _clamp01(double v) => v < 0 ? 0 : (v > 1 ? 1 : v);
}
