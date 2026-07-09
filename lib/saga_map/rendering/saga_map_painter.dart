import 'package:flutter/material.dart';

import '../domain/saga_node_state.dart';
import '../projection/perspective_projector.dart';
import 'saga_scene.dart';

/// Paints a [SagaScene]: simple procedural stone shapes, no raster assets.
///
/// Reads only the [scene] handed to it — never calls `windowFor`, `nodeAt`,
/// or [PerspectiveProjector.project] itself, and never mutates progress.
/// Draws far-to-near (painter's algorithm) so nearer stones occlude farther
/// ones correctly.
class SagaMapPainter extends CustomPainter {
  SagaMapPainter({required this.scene});

  final SagaScene scene;

  static const double _baseRadius = 28;
  static const Color _completedColor = Color(0xFF8D8D99);
  static const Color _currentColor = Color(0xFFFFC94D);
  static const Color _upcomingColor = Color(0xFF4A4A57);
  static const Color _fogColor = Color(0xFFBFC4CC);

  final Paint _fillPaint = Paint()..style = PaintingStyle.fill;
  final Paint _strokePaint = Paint()
    ..style = PaintingStyle.stroke
    ..strokeWidth = 3
    ..color = const Color(0xFF232329);

  final Path _stonePath = _buildStonePath();

  static Path _buildStonePath() {
    return Path()
      ..addPolygon(const [
        Offset(0.0, -1.0),
        Offset(0.8, -0.5),
        Offset(0.9, 0.4),
        Offset(0.3, 1.0),
        Offset(-0.6, 0.8),
        Offset(-0.95, -0.2),
      ], true);
  }

  static Color _baseColorFor(SagaNodeState state) {
    switch (state) {
      case SagaNodeState.completed:
        return _completedColor;
      case SagaNodeState.current:
        return _currentColor;
      case SagaNodeState.upcoming:
        return _upcomingColor;
    }
  }

  @override
  void paint(Canvas canvas, Size size) {
    // scene.nodes is ascending by depth (nearest first); walk it back-to-
    // front so nearer stones draw last and occlude farther ones.
    for (final projected in scene.nodes.reversed) {
      _paintNode(canvas, projected);
    }
  }

  void _paintNode(Canvas canvas, ProjectedNode projected) {
    final base = _baseColorFor(projected.node.state);
    _fillPaint.color = Color.lerp(base, _fogColor, projected.fogFactor) ?? base;

    canvas.save();
    canvas.translate(projected.screenX, projected.screenY);
    canvas.scale(projected.scale * _baseRadius);
    canvas.drawPath(_stonePath, _fillPaint);
    canvas.drawPath(_stonePath, _strokePaint);
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant SagaMapPainter oldDelegate) =>
      oldDelegate.scene != scene;
}
