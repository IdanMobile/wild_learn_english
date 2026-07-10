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
    required this.relativeDepth,
    required this.fogFactor,
    required this.platformAspect,
  });

  final SagaNode node;

  /// Horizontal screen position, in the same units as the viewport.
  final double screenX;

  /// Vertical screen position; nearer nodes sit lower, far nodes converge
  /// toward the horizon.
  final double screenY;

  /// Perspective scale in (0, 1.28]; capped near the camera so past stones
  /// stay stable instead of exploding through the screen.
  final double scale;

  /// World depth relative to the camera progress.
  final double relativeDepth;

  /// Atmospheric fade in [0, 1]; 0 = fully clear (near), 1 = fully fogged.
  final double fogFactor;

  /// Height/width ratio for flattened saga platforms at this depth.
  final double platformAspect;
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
    this.cameraX = 0.0,
    this.cameraYaw = 0.0,
    this.cameraPitch = 0.17,
    this.fogDistance = 20.0,
  });

  /// Distance from camera to the projection plane. Larger = flatter,
  /// less exaggerated perspective. Tune to taste.
  final double focalLength;

  /// Screen x that a node at world x=0 maps to.
  final double viewportCenterX;

  /// Camera horizontal position in world units.
  ///
  /// Horizontal parallax comes from subtracting this before perspective scale:
  /// far objects have smaller scale, so they move less than near objects.
  final double cameraX;

  /// Subtle horizontal camera yaw. Positive values look toward upcoming right
  /// turns; applied in camera space before projection.
  final double cameraYaw;

  /// Artist-tuned pitch value; higher means the camera looks down more.
  final double cameraPitch;

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

    final rawScale = focalLength / denom;

    // Behind camera (or at infinity) => nothing to draw.
    if (rawScale <= 0) return null;

    final scale = rawScale.clamp(0.0, 1.28);
    final yawedX = node.x - cameraX - relativeDepth * cameraYaw * 0.18;
    final screenX = viewportCenterX + yawedX * scale;
    final screenY = _groundY(relativeDepth, rawScale);

    if (!screenX.isFinite || !screenY.isFinite || !scale.isFinite) return null;

    final fogFactor = _smoothstep(_clamp01(relativeDepth / fogDistance));
    final platformAspect = aspectForPlatform(scale, fogFactor);

    return ProjectedNode(
      node: node,
      screenX: screenX,
      screenY: screenY,
      scale: scale,
      relativeDepth: relativeDepth,
      fogFactor: fogFactor,
      platformAspect: platformAspect,
    );
  }

  double aspectForPlatform(double scale, double fogFactor) {
    final nearAspect = (0.46 + cameraPitch * 0.75).clamp(0.48, 0.72);
    final farAspect = (0.22 + cameraPitch * 0.45).clamp(0.24, 0.42);
    final t = _smoothstep(_clamp01(scale)) * (1 - fogFactor * 0.28);
    return (farAspect + (nearAspect - farAspect) * t).clamp(0.24, 0.72);
  }

  double _groundY(double relativeDepth, double rawScale) {
    if (relativeDepth >= 0) {
      // Nonlinear horizon compression: future nodes bunch toward the horizon
      // while the current gameplay zone remains readable.
      final t = _smoothstep(_clamp01(rawScale));
      return horizonY + (baseY - horizonY) * t;
    }

    // Once the camera has passed a node, it should slide below us on the same
    // ground plane, not climb toward the horizon.
    final passed = _smoothstep(_clamp01(-relativeDepth / (focalLength * 0.82)));
    return baseY + (baseY - horizonY) * 0.72 * passed;
  }

  static double _clamp01(double v) => v < 0 ? 0 : (v > 1 ? 1 : v);

  static double _smoothstep(double v) => v * v * (3 - 2 * v);
}
