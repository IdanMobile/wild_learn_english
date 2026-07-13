import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../domain/saga_node_state.dart';
import '../projection/perspective_projector.dart';
import '../world/saga_path.dart' as saga_path;
import 'saga_fx.dart';
import 'saga_scene.dart';

part 'saga_map_painter_environment.dart';
part 'saga_map_painter_nodes.dart';
part 'saga_map_painter_effects.dart';
part 'saga_map_painter_shapes.dart';

const double _baseRadius = 54;
const Color _completedColor = Color(0xFF21A9F2);
const Color _currentColor = Color(0xFF52D64A);
const Color _upcomingColor = Color(0xFFD8E2E6);
const Color _fogColor = Color(0xFFEFF7FA);
// Three bars pinned across the bottom half of the button, laid left -> right
// (angle pi = left, pi/2 = bottom, 0 = right; negative sweep runs leftward
// to rightward along the bottom). ~0.30 rad gaps between them.
const _ringSegments = <({double start, double sweep})>[
  (start: 3.1416, sweep: -0.8472),
  (start: 1.9944, sweep: -0.8472),
  (start: 0.8472, sweep: -0.8472),
];

// Completion sequence timings, all measured from fxState age (bars full):
// green->blue, then the V draws, then the item/lightning reward.
const double _checkDrawStart = 0.3;
const double _checkDrawTime = 1.0; // V finishes drawing at ~1.3s
const double _rewardStart = 1.4; // item / plain reward after the V
const double _comboDelay = 1.4; // lightning plays last, after the V

Color _baseColorFor(SagaNodeState state) {
  switch (state) {
    case SagaNodeState.completed:
      return _completedColor;
    case SagaNodeState.current:
      return _currentColor;
    case SagaNodeState.upcoming:
      return _upcomingColor;
  }
}

/// Paints a [SagaScene]: simple procedural stone shapes, no raster assets.
///
/// Reads only the [scene] handed to it — never calls `windowFor`, `nodeAt`,
/// or [PerspectiveProjector.project] itself, and never mutates progress.
/// Draws far-to-near (painter's algorithm) so nearer stones occlude farther
/// ones correctly.
class SagaMapPainter extends CustomPainter {
  SagaMapPainter({
    required this.scene,
    this.skyImage,
    this.mountainsImage,
    this.hazeImage,
    this.foregroundMistImage,
    this.castleImage,
    this.castleDetailImage,
    this.chestImage,
    this.orbImage,
    this.crystalImage,
    this.rewardStarImage,
    this.sparkleImage,
    this.softGlowImage,
    this.lightningResidualImage,
    this.lightningComboFrames = const [],
    this.animationTime = 0,
    this.fxState = const SagaFxState(),
    this.starTarget,
    this.energyTarget,
    this.barStars = const [],
  });

  final SagaScene scene;
  final ui.Image? skyImage;
  final ui.Image? mountainsImage;
  final ui.Image? hazeImage;
  final ui.Image? foregroundMistImage;
  final ui.Image? castleImage;
  final ui.Image? castleDetailImage;
  final ui.Image? chestImage;
  final ui.Image? orbImage;
  final ui.Image? crystalImage;
  final ui.Image? rewardStarImage;
  final ui.Image? sparkleImage;
  final ui.Image? softGlowImage;
  final ui.Image? lightningResidualImage;
  final List<ui.Image> lightningComboFrames;
  final double animationTime;
  final SagaFxState fxState;
  final Offset? starTarget;
  final Offset? energyTarget;
  // Per-bar reward stars in flight, expressed in game time.
  final List<({double birth, Offset from, double seed})> barStars;

  final Paint _shadowPaint = Paint()
    ..style = PaintingStyle.fill
    ..color = const Color(0x1F6A8EA0);
  final Paint _strokePaint = Paint()
    ..style = PaintingStyle.stroke
    ..strokeWidth = 2
    ..color = const Color(0xFFEAF2F4);

  @override
  void paint(Canvas canvas, Size size) {
    _paintBackground(canvas, size);
    _paintCastle(canvas, size);
    _paintHorizonClouds(canvas, size);
    _paintAmbientSparkles(canvas, size);

    // scene.nodes is ascending by depth (nearest first); walk it back-to-
    // front so nearer stones draw last and occlude farther ones.
    for (final projected in scene.nodes.reversed) {
      _paintNode(canvas, projected);
    }

    _paintPathProps(canvas);
    _paintForegroundMist(canvas, size);
    _paintRewardStars(canvas, size);
    _paintBarStars(canvas, size);
    _paintEnergyReward(canvas, size);
    _paintItemReward(canvas, size);
    _paintLightningCombo(canvas, size);
  }

  @override
  bool shouldRepaint(covariant SagaMapPainter oldDelegate) =>
      oldDelegate.scene != scene;
}
