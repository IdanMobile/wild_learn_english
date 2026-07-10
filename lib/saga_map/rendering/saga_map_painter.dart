import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../domain/saga_node_state.dart';
import '../projection/perspective_projector.dart';
import '../world/saga_path.dart' as saga_path;
import 'saga_fx.dart';
import 'saga_scene.dart';

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

  static const double _baseRadius = 54;
  static const Color _completedColor = Color(0xFF21A9F2);
  static const Color _currentColor = Color(0xFF52D64A);
  static const Color _upcomingColor = Color(0xFFD8E2E6);
  static const Color _fogColor = Color(0xFFEFF7FA);
  static const _ringSegments = <({double start, double sweep})>[
    (start: 2.72, sweep: 0.5),
    (start: 1.34, sweep: 0.78),
    (start: -0.08, sweep: 0.54),
  ];

  final Paint _shadowPaint = Paint()
    ..style = PaintingStyle.fill
    ..color = const Color(0x1F6A8EA0);
  final Paint _strokePaint = Paint()
    ..style = PaintingStyle.stroke
    ..strokeWidth = 2
    ..color = const Color(0xFFEAF2F4);

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
    _paintEnergyReward(canvas, size);
    _paintLightningCombo(canvas, size);
  }

  void _paintBackground(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final sky = skyImage;
    if (sky != null) {
      _drawImageCover(canvas, sky, rect, opacity: 0.28);
    }
    final paint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0xDFFFFFFF), Color(0xDFF7FCFF), Color(0xD8ECF8FC)],
      ).createShader(rect);
    canvas.drawRect(rect, paint);

    final mountains = mountainsImage;
    if (mountains != null) {
      final anchor = _projectDistantAnchor(size, _castleIndex + 8);
      final drift = anchor == null ? 0.0 : anchor.dx - size.width * 0.5;
      final opacity = (0.24 + _mapCompletion * 0.46).clamp(0.24, 0.7);
      _drawImageFitWidth(
        canvas,
        mountains,
        Rect.fromLTWH(
          -size.width * 0.16 + drift * 0.22,
          size.height * 0.1,
          size.width * 1.32,
          size.height * 0.22,
        ),
        opacity: opacity,
      );
    }

    final haze = hazeImage;
    if (haze != null) {
      _drawImageCover(canvas, haze, rect, opacity: 0.38);
    }
  }

  void _paintHorizonClouds(Canvas canvas, Size size) {
    final paint = Paint()..color = const Color(0x66FFFFFF);
    for (final projected in scene.nodes) {
      if (projected.scale > 0.42 || projected.scale < 0.12) continue;
      final center = Offset(projected.screenX, projected.screenY + 4);
      final width = 90 * projected.scale;
      final height = 22 * projected.scale;
      canvas.drawOval(
        Rect.fromCenter(center: center, width: width, height: height),
        paint,
      );
    }

    final haze = hazeImage;
    if (haze != null) {
      final farAnchor = _projectDistantAnchor(size, _castleIndex + 4);
      final drift = farAnchor == null ? 0.0 : farAnchor.dx - size.width * 0.5;
      final ambientDrift = math.sin(animationTime * 0.12) * size.width * 0.025;
      _drawImageCover(
        canvas,
        haze,
        Rect.fromLTWH(
          -size.width * 0.12 + drift * 0.16 + ambientDrift,
          size.height * 0.18,
          size.width * 1.24,
          size.height * 0.22,
        ),
        opacity: 0.34,
      );
      _drawImageCover(
        canvas,
        haze,
        Rect.fromLTWH(
          -size.width * 0.2 - drift * 0.1 - ambientDrift * 0.65,
          size.height * 0.36,
          size.width * 1.36,
          size.height * 0.24,
        ),
        opacity: 0.24,
      );
    }
  }

  void _paintForegroundMist(Canvas canvas, Size size) {
    final mist = foregroundMistImage;
    if (mist == null) return;
    final drift =
        math.sin(animationTime * 0.2) * size.width * 0.035 -
        scene.projector.cameraX * 0.09;
    _drawImageFitWidth(
      canvas,
      mist,
      Rect.fromLTWH(
        -size.width * 0.08 + drift,
        size.height * 0.55,
        size.width * 1.16,
        size.height * 0.45,
      ),
      opacity: 0.48,
    );
  }

  void _paintCastle(Canvas canvas, Size size) {
    final image = castleImage;
    if (image == null) return;

    final anchor = _castleDoorAnchor(size);
    if (anchor == null) return;

    final width = (size.width * (0.2 + anchor.scale * 0.55)).clamp(
      size.width * 0.2,
      size.width * 0.36,
    );
    final height = width * image.height / image.width;
    final dst = Rect.fromCenter(
      center: Offset(anchor.dx, anchor.dy - height * 0.28),
      width: width,
      height: height,
    );
    final opacity = (0.18 + _mapCompletion * 0.58 + anchor.scale * 0.24).clamp(
      0.18,
      0.92,
    );
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: opacity)
      ..filterQuality = FilterQuality.medium
      ..isAntiAlias = true;
    canvas.drawImageRect(
      image,
      Rect.fromLTWH(0, 0, image.width.toDouble(), image.height.toDouble()),
      dst,
      paint,
    );

    final detail = castleDetailImage;
    if (detail != null) {
      canvas.drawImageRect(
        detail,
        Rect.fromLTWH(0, 0, detail.width.toDouble(), detail.height.toDouble()),
        dst,
        Paint()
          ..color = Colors.white.withValues(alpha: opacity * 0.45)
          ..filterQuality = FilterQuality.medium
          ..isAntiAlias = true,
      );
    }
  }

  int get _castleIndex {
    final maxLevel = scene.maxLevel;
    if (maxLevel != null) return maxLevel + 1;
    return saga_path.levelForProgress(scene.cameraProgress) + 30;
  }

  double get _mapCompletion {
    final maxLevel = scene.maxLevel;
    if (maxLevel == null || maxLevel <= 0) return 0.35;
    return (scene.cameraProgress / saga_path.depth(maxLevel)).clamp(0.0, 1.0);
  }

  ({double dx, double dy, double scale})? _projectDistantAnchor(
    Size size,
    int index,
  ) {
    final relativeDepth = saga_path.depth(index) - scene.cameraProgress;
    final denom = scene.projector.focalLength + relativeDepth;
    if (denom <= 0) return null;

    final scale = scene.projector.focalLength / denom;
    final worldX = saga_path.x(index, preset: scene.pathPreset);
    final yawedX =
        worldX -
        scene.projector.cameraX -
        relativeDepth * scene.projector.cameraYaw * 0.06;
    final dx = size.width * 0.5 + yawedX * scale;
    // Share the node projector's ground plane so the castle sits exactly
    // where the path converges, however the debug camera is tuned.
    final horizonY = scene.projector.horizonY;
    final baseY = scene.projector.baseY;
    final dy = horizonY + (baseY - horizonY) * scale;
    return (dx: dx, dy: dy, scale: scale);
  }

  ({double dx, double dy, double scale})? _castleDoorAnchor(Size size) =>
      _projectDistantAnchor(size, _castleIndex);

  void _paintNode(Canvas canvas, ProjectedNode projected) {
    final completionT = _completionTFor(projected.node.index);
    final base = _baseColorFor(projected.node.state);
    final completedFlash = Color.lerp(
      _currentColor,
      const Color(0xFFFFE67A),
      math.sin(completionT * math.pi).clamp(0.0, 1.0),
    )!;
    final animatedBase = completionT > 0
        ? Color.lerp(completedFlash, _completedColor, completionT)!
        : base;
    final topColor =
        Color.lerp(animatedBase, _fogColor, projected.fogFactor) ??
        animatedBase;
    final arrivalPulse = projected.node.state == SagaNodeState.current
        ? _arrivalPulse(scene.stepFillProgress)
        : 1.0;
    final completePulse = completionT > 0
        ? 1 + math.sin(completionT * math.pi) * 0.14
        : 1.0;
    final activePulse = projected.node.state == SagaNodeState.current
        ? 1.02 + math.sin(animationTime * 5.5) * 0.018
        : 1.0;
    final radius =
        (_baseRadius *
                projected.scale *
                activePulse *
                arrivalPulse *
                completePulse)
            .clamp(7.0, 64.0);
    final center = Offset(projected.screenX, projected.screenY);
    final frame = saga_path.frameAt(
      projected.node.index,
      preset: scene.pathPreset,
    );
    final heading = math.atan2(frame.tangentX, frame.tangentDepth) * 0.16;
    final topWidth = radius * 1.72;
    final topHeight = topWidth * projected.platformAspect;
    final side = Rect.fromCenter(
      center: Offset.zero + Offset(0, topHeight * 0.32),
      width: radius * 1.9,
      height: topHeight * 1.16,
    );
    final top = Rect.fromCenter(
      center: Offset.zero,
      width: topWidth,
      height: topHeight,
    );

    canvas.save();
    canvas.translate(center.dx, center.dy - radius * 0.18);
    canvas.rotate(heading);
    _paintDisc(canvas, side, top, topColor, projected.node.state);
    canvas.restore();

    if (projected.node.state == SagaNodeState.current || completionT > 0) {
      _paintNodeGlow(canvas, center - Offset(0, radius * 0.18), radius);
    }

    if (projected.node.state == SagaNodeState.current) {
      _paintProgressArcs(
        canvas,
        center - Offset(0, radius * 0.18),
        radius,
        projected.platformAspect,
        scene.stepFillProgress,
      );
    } else if (projected.node.state == SagaNodeState.completed) {
      final iconT = completionT > 0
          ? easeOutBack(((completionT - 0.24) / 0.76).clamp(0.0, 1.0))
          : 1.0;
      _paintIcon(
        canvas,
        Icons.check_rounded,
        center - Offset(0, radius * (0.18 + (1 - iconT) * 0.1)),
        radius * (0.48 + math.sin(animationTime * 2.6) * 0.015) * iconT,
        Colors.white.withValues(alpha: 0.78 * iconT.clamp(0.0, 1.0)),
      );
    }
  }

  double _completionTFor(int index) {
    if (fxState.completedLevel != index) return 0;
    final age = fxState.ageAt(animationTime);
    if (age < 0 || age > 0.75) return 0;
    return fxState.completionT(animationTime);
  }

  double _arrivalPulse(double fillProgress) {
    final t = fillProgress.clamp(0.0, 1.0);
    if (t >= 0.62) return 1;
    return 1 + math.sin((t / 0.62) * math.pi) * 0.12;
  }

  void _paintNodeGlow(Canvas canvas, Offset center, double radius) {
    final opacity = 0.16 + math.sin(animationTime * 4.0) * 0.035;
    final glow = softGlowImage;
    if (glow != null) {
      _drawImageContain(
        canvas,
        glow,
        Rect.fromCenter(
          center: center + Offset(0, radius * 0.05),
          width: radius * 3.2,
          height: radius * 2.1,
        ),
        opacity: opacity * 1.25,
      );
      return;
    }
    canvas.drawOval(
      Rect.fromCenter(
        center: center + Offset(0, radius * 0.05),
        width: radius * 2.6,
        height: radius * 1.2,
      ),
      Paint()
        ..color = const Color(0xFF56F06C).withValues(alpha: opacity)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8),
    );
  }

  void _paintPathProps(Canvas canvas) {
    if (scene.nodes.isEmpty) return;
    for (final target in scene.nodes) {
      final kind = saga_path.propAt(target.node.index);
      final image = switch (kind) {
        saga_path.SagaPropKind.chest => chestImage,
        saga_path.SagaPropKind.orb => orbImage,
        saga_path.SagaPropKind.crystal => crystalImage,
        null => null,
      };
      if (image == null) continue;
      final radius = (_baseRadius * target.scale).clamp(12.0, 44.0);
      final phase = stablePhase(target.node.index) * math.pi * 2;
      final bob = math.sin(animationTime * 2.4 + phase) * 4;
      final center = Offset(
        target.screenX,
        target.screenY - radius * 0.78 + bob,
      );
      final width = switch (kind) {
        saga_path.SagaPropKind.chest => radius * 1.25,
        saga_path.SagaPropKind.orb => radius * 0.92,
        saga_path.SagaPropKind.crystal => radius * 0.72,
        null => radius,
      };
      _drawImageContain(
        canvas,
        image,
        Rect.fromCenter(center: center, width: width, height: radius * 1.34),
        opacity: (1 - target.fogFactor * 0.72).clamp(0.18, 1.0),
      );
      if (kind != saga_path.SagaPropKind.chest && target.scale > 0.22) {
        _paintSparkle(
          canvas,
          center - Offset(0, radius * 0.45),
          radius * 0.08,
          0.2 + math.sin(animationTime * 2 + phase).abs() * 0.22,
        );
      }
    }
  }

  void _paintProgressArcs(
    Canvas canvas,
    Offset center,
    double radius,
    double aspect,
    double fillProgress,
  ) {
    final rotation = animationTime * 0.45;
    final pulse = 0.92 + math.sin(animationTime * 4.5) * 0.05;
    final width = radius * 2.42 * pulse;
    final rect = Rect.fromCenter(
      center: center + Offset(0, width * aspect * 0.14),
      width: width,
      height: width * (aspect + 0.14),
    );
    final trackPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6
      ..strokeCap = StrokeCap.round
      ..color = const Color(0xFFBFC9CD);
    final fillPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6
      ..strokeCap = StrokeCap.round
      ..color = const Color(0xFF21C94D);
    for (final segment in _ringSegments) {
      canvas.drawArc(
        rect,
        segment.start + rotation,
        segment.sweep,
        false,
        trackPaint,
      );
    }
    for (var i = 0; i < _ringSegments.length; i++) {
      final segmentProgress = _segmentProgress(fillProgress, i);
      if (segmentProgress == 0) continue;
      final segment = _ringSegments[i];
      canvas.drawArc(
        rect,
        segment.start + rotation,
        segment.sweep * segmentProgress,
        false,
        fillPaint,
      );
    }
  }

  void _paintRewardStars(Canvas canvas, Size size) {
    final completedLevel = fxState.completedLevel;
    if (completedLevel == null || fxState.rewardStarCount == 0) return;

    if (fxState.hasCombo) {
      _paintHeroRewardStar(canvas, size);
      return;
    }

    ProjectedNode? source;
    for (final node in scene.nodes) {
      if (node.node.index == completedLevel) {
        source = node;
        break;
      }
    }
    if (source == null) return;

    final start = Offset(source.screenX, source.screenY - 36 * source.scale);
    final end = starTarget ?? _fallbackStarChipCenter(size);
    final t = fxState.rewardT(animationTime);
    if (t <= 0 || t >= 1) return;

    final count = fxState.rewardStarCount;
    for (var i = 0; i < count; i++) {
      final seed = stablePhase(completedLevel * 31 + i);
      final delay = i * 0.045;
      final localT = smooth01(((t - delay) / (1 - delay)).clamp(0.0, 1.0));
      if (localT <= 0) continue;
      final angle = -math.pi * (0.18 + seed * 0.64);
      final burst = Offset(math.cos(angle), math.sin(angle)) * (34 + seed * 20);
      final control = start + burst + Offset((seed - 0.5) * 120, -92);
      final p = _quadratic(start + burst * (1 - localT), control, end, localT);
      final scale = (1.1 - localT * 0.42) * (0.78 + seed * 0.24);
      _paintStar(
        canvas,
        p,
        8.5 * scale,
        animationTime * 6 + seed * math.pi * 2,
        (1 - localT * 0.35).clamp(0.0, 1.0),
      );
      if (i.isEven) {
        _paintSparkle(
          canvas,
          _quadratic(start, control, end, (localT - 0.08).clamp(0.0, 1.0)),
          2.5 * scale,
          0.38 * (1 - localT),
        );
      }
    }
  }

  void _paintHeroRewardStar(Canvas canvas, Size size) {
    final age = fxState.ageAt(animationTime);
    if (age < 1.45 || age > 3.15) return;

    final t = smooth01(((age - 1.45) / 1.7).clamp(0.0, 1.0));
    final start = Offset(size.width * 0.5, size.height * 0.34);
    final end = starTarget ?? _fallbackStarChipCenter(size);
    final control = Offset(size.width * 0.38, size.height * 0.04);
    final p = _quadratic(start, control, end, t);
    final radius = ui.lerpDouble(42, 8.5, t)!;
    final opacity = (1 - ((t - 0.9) / 0.1).clamp(0.0, 1.0) * 0.15).clamp(
      0.0,
      1.0,
    );

    _paintStar(canvas, p, radius, t * math.pi * 5.2, opacity);
    _paintSparkle(canvas, p, radius * 0.18, 0.42 * (1 - t));
  }

  Offset _fallbackStarChipCenter(Size size) {
    final compact = size.width < 400;
    return Offset(compact ? 163 : 186, compact ? 50 : 52);
  }

  void _paintEnergyReward(Canvas canvas, Size size) {
    final completedLevel = fxState.completedLevel;
    if (completedLevel == null) return;
    final age = fxState.ageAt(animationTime);
    final startAge = fxState.hasCombo ? 1.55 : 0.28;
    final duration = fxState.hasCombo ? 1.5 : 0.78;
    if (age <= startAge || age >= startAge + duration) return;

    ProjectedNode? source;
    for (final node in scene.nodes) {
      if (node.node.index == completedLevel) {
        source = node;
        break;
      }
    }
    final start = fxState.hasCombo
        ? Offset(size.width * 0.52, size.height * 0.35)
        : source == null
        ? Offset(size.width * 0.5, size.height * 0.48)
        : Offset(source.screenX, source.screenY - 30 * source.scale);
    final end = energyTarget ?? _fallbackEnergyChipCenter(size);
    final t = smooth01(((age - startAge) / duration).clamp(0.0, 1.0));
    final control = Offset(
      (start.dx + end.dx) * 0.5 + size.width * 0.1,
      math.min(start.dy, end.dy) - size.height * 0.12,
    );
    final center = _quadratic(start, control, end, t);
    final radius = ui.lerpDouble(15, 6.5, t)!;
    _paintEnergyBolt(canvas, center, radius, t * math.pi * 2.4);
    _paintSparkle(canvas, center, radius * 0.32, 0.5 * (1 - t));
  }

  Offset _fallbackEnergyChipCenter(Size size) {
    final compact = size.width < 400;
    return Offset(compact ? 99 : 111, compact ? 50 : 52);
  }

  void _paintEnergyBolt(
    Canvas canvas,
    Offset center,
    double radius,
    double rotation,
  ) {
    final path = Path()
      ..moveTo(-radius * 0.12, -radius)
      ..lineTo(radius * 0.7, -radius * 0.18)
      ..lineTo(radius * 0.18, -radius * 0.08)
      ..lineTo(radius * 0.42, radius)
      ..lineTo(-radius * 0.72, radius * 0.12)
      ..lineTo(-radius * 0.2, radius * 0.02)
      ..close();
    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(rotation);
    canvas.drawPath(
      path,
      Paint()
        ..color = const Color(0xFF22B7FF)
        ..style = PaintingStyle.fill
        ..maskFilter = const MaskFilter.blur(BlurStyle.solid, 2),
    );
    canvas.restore();
  }

  void _paintLightningCombo(Canvas canvas, Size size) {
    final comboNumber = fxState.comboNumber;
    if (comboNumber == null) return;

    final age = fxState.ageAt(animationTime);
    if (age < 0 || age > 3.8) return;

    final glow = softGlowImage;
    if (glow != null) {
      final glowT = age < 2.0 ? 1.0 : (1 - (age - 2.0) / 1.8).clamp(0.0, 1.0);
      _drawImageContain(
        canvas,
        glow,
        Rect.fromCenter(
          center: Offset(size.width * 0.52, size.height * 0.35),
          width: size.width * 1.08,
          height: size.width * 0.72,
        ),
        opacity: 0.48 * glowT,
      );
    }

    if (age <= 1.45 && lightningComboFrames.isNotEmpty) {
      final peakIndex = math.min(4, lightningComboFrames.length - 1);
      final frame = age < 0.74
          ? lightningComboFrames[fxState.lightningFrameIndex(
              animationTime,
              lightningComboFrames.length,
            )]
          : lightningComboFrames[peakIndex];
      final sweepT = smooth01((age / 1.02).clamp(0.0, 1.0));
      final holdT = ((age - 0.74) / 0.71).clamp(0.0, 1.0);
      final center =
          Offset.lerp(
            Offset(size.width * 0.88, size.height * 0.18),
            Offset(size.width * 0.46, size.height * 0.39),
            sweepT,
          ) ??
          Offset(size.width * 0.5, size.height * 0.35);
      final height =
          size.height *
          (0.52 + sweepT * 0.13 + math.sin(holdT * math.pi) * 0.05);
      final width = height * frame.width / frame.height;
      canvas.save();
      canvas.translate(center.dx, center.dy);
      canvas.rotate(-0.1 + math.sin(age * 10) * 0.012);
      _drawImageContain(
        canvas,
        frame,
        Rect.fromCenter(center: Offset.zero, width: width, height: height),
        opacity: age < 1.1
            ? 1
            : (1 - (age - 1.1).clamp(0.0, 0.35) / 0.35).clamp(0.0, 1.0),
      );
      canvas.restore();
    }

    final residual = lightningResidualImage;
    if (residual != null && age >= 0.65 && age <= 2.4) {
      final t = ((age - 0.65) / 1.75).clamp(0.0, 1.0);
      final center =
          Offset.lerp(
            Offset(size.width * 0.55, size.height * 0.43),
            Offset(size.width * 0.36, size.height * 0.51),
            t,
          ) ??
          Offset(size.width * 0.48, size.height * 0.45);
      final width = size.width * (0.86 - t * 0.16);
      final height = width * residual.height / residual.width;
      canvas.save();
      canvas.translate(center.dx, center.dy);
      canvas.rotate(-0.18);
      _drawImageContain(
        canvas,
        residual,
        Rect.fromCenter(center: Offset.zero, width: width, height: height),
        opacity: (1 - t) * 0.76,
      );
      canvas.restore();
    }

    _paintComboNumber(canvas, size, comboNumber, age);
    _paintComboSparkles(canvas, size, age);
  }

  void _paintComboNumber(Canvas canvas, Size size, int number, double age) {
    if (age < 0.32 || age > 2.25) return;
    final enter = easeOutBack(((age - 0.32) / 0.42).clamp(0.0, 1.0));
    final exit = age < 1.75 ? 1.0 : (1 - (age - 1.75) / 0.5).clamp(0.0, 1.0);
    final scale = (0.58 + enter * 0.56 + math.sin(age * 7) * 0.015) * exit;
    final opacity = exit.clamp(0.0, 1.0);
    final fontSize = size.width * 0.18 * scale;
    final painter = TextPainter(
      text: TextSpan(
        text: '$number',
        style: TextStyle(
          fontSize: fontSize,
          fontWeight: FontWeight.w900,
          foreground: Paint()
            ..shader = const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFFFFF36A), Color(0xFFFF8700)],
            ).createShader(Rect.fromLTWH(0, 0, fontSize, fontSize)),
          shadows: [
            Shadow(
              color: const Color(0xFFFF4A00).withValues(alpha: opacity),
              blurRadius: 18,
            ),
            Shadow(
              color: const Color(0xAA642000).withValues(alpha: opacity),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    final center = Offset(size.width * 0.5, size.height * 0.34);
    canvas.saveLayer(
      Offset.zero & size,
      Paint()..color = Colors.white.withValues(alpha: opacity),
    );
    canvas.translate(center.dx, center.dy);
    canvas.rotate(0.015 * math.sin(age * 9));
    painter.paint(canvas, Offset(-painter.width / 2, -painter.height / 2));
    canvas.restore();
  }

  void _paintComboSparkles(Canvas canvas, Size size, double age) {
    if (age < 0.44 || age > 3.0) return;
    final life = (1 - ((age - 0.44) / 2.56)).clamp(0.0, 1.0);
    for (var i = 0; i < 16; i++) {
      final seed = stablePhase(900 + i * 17);
      final drift = Offset((seed - 0.5) * 260, -20 - seed * 145) * (1 - life);
      final center =
          Offset(size.width * (0.42 + seed * 0.22), size.height * 0.42) + drift;
      _paintSparkle(canvas, center, 3.0 + seed * 3.5, life * 0.55);
    }
  }

  void _paintAmbientSparkles(Canvas canvas, Size size) {
    for (var i = 0; i < 12; i++) {
      final x = size.width * stablePhase(i * 17 + 3);
      final baseY = size.height * (0.22 + stablePhase(i * 29 + 5) * 0.58);
      final drift = math.sin(animationTime * 0.55 + i) * 8;
      final twinkle = (math.sin(animationTime * 1.8 + i * 1.7) + 1) * 0.5;
      if (twinkle < 0.55) continue;
      _paintSparkle(
        canvas,
        Offset(x + drift, baseY - animationTime % 4 * 4),
        1.6 + twinkle * 2.2,
        (twinkle - 0.55) * 0.42,
      );
    }
  }

  Offset _quadratic(Offset a, Offset b, Offset c, double t) {
    final inv = 1 - t;
    return a * (inv * inv) + b * (2 * inv * t) + c * (t * t);
  }

  void _paintStar(
    Canvas canvas,
    Offset center,
    double radius,
    double rotation,
    double opacity,
  ) {
    final image = rewardStarImage;
    if (image != null) {
      canvas.save();
      canvas.translate(center.dx, center.dy);
      canvas.rotate(rotation * 0.12);
      _drawImageContain(
        canvas,
        image,
        Rect.fromCenter(
          center: Offset.zero,
          width: radius * 3.2,
          height: radius * 3.2,
        ),
        opacity: opacity,
      );
      canvas.restore();
      return;
    }

    final path = Path();
    for (var i = 0; i < 10; i++) {
      final r = i.isEven ? radius : radius * 0.46;
      final a = rotation - math.pi / 2 + i * math.pi / 5;
      final p = center + Offset(math.cos(a), math.sin(a)) * r;
      if (i == 0) {
        path.moveTo(p.dx, p.dy);
      } else {
        path.lineTo(p.dx, p.dy);
      }
    }
    path.close();
    canvas.drawPath(
      path,
      Paint()
        ..color = const Color(0xFFFFCA3A).withValues(alpha: opacity)
        ..style = PaintingStyle.fill,
    );
    canvas.drawPath(
      path,
      Paint()
        ..color = Colors.white.withValues(alpha: opacity * 0.35)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1,
    );
  }

  void _paintSparkle(
    Canvas canvas,
    Offset center,
    double radius,
    double alpha,
  ) {
    final image = sparkleImage;
    if (image != null) {
      _drawImageContain(
        canvas,
        image,
        Rect.fromCenter(center: center, width: radius * 8, height: radius * 8),
        opacity: alpha.clamp(0.0, 1.0),
      );
      return;
    }

    final paint = Paint()
      ..color = Colors.white.withValues(alpha: alpha)
      ..strokeWidth = 1.4
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(
      center - Offset(radius, 0),
      center + Offset(radius, 0),
      paint,
    );
    canvas.drawLine(
      center - Offset(0, radius),
      center + Offset(0, radius),
      paint,
    );
  }

  double _segmentProgress(double fillProgress, int index) {
    final start = index / _ringSegments.length;
    final end = (index + 1) / _ringSegments.length;
    final t = ((fillProgress - start) / (end - start)).clamp(0.0, 1.0);
    return t * t * (3 - 2 * t);
  }

  void _paintDisc(
    Canvas canvas,
    Rect side,
    Rect top,
    Color color,
    SagaNodeState state,
  ) {
    canvas.drawOval(side.shift(Offset(0, side.height * 0.25)), _shadowPaint);
    final sideColor = Color.lerp(color, const Color(0xFF7E9AA6), 0.35)!;
    canvas.drawOval(side, Paint()..color = sideColor.withValues(alpha: 0.78));
    canvas.drawOval(
      top,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color.lerp(color, Colors.white, 0.34)!,
            color,
            Color.lerp(
              color,
              Colors.black,
              state == SagaNodeState.upcoming ? 0.08 : 0.16,
            )!,
          ],
        ).createShader(top),
    );
    canvas.drawOval(top, _strokePaint);
    canvas.drawOval(
      Rect.fromCenter(
        center: top.center - Offset(0, top.height * 0.18),
        width: top.width * 0.62,
        height: top.height * 0.18,
      ),
      Paint()..color = Colors.white.withValues(alpha: 0.18),
    );
  }

  void _paintIcon(
    Canvas canvas,
    IconData icon,
    Offset center,
    double size,
    Color color,
  ) {
    final painter = TextPainter(
      text: TextSpan(
        text: String.fromCharCode(icon.codePoint),
        style: TextStyle(
          fontSize: size,
          fontFamily: icon.fontFamily,
          package: icon.fontPackage,
          color: color,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    painter.paint(
      canvas,
      center - Offset(painter.width / 2, painter.height / 2),
    );
  }

  void _drawImageCover(
    Canvas canvas,
    ui.Image image,
    Rect dst, {
    double opacity = 1,
  }) {
    final imageRatio = image.width / image.height;
    final dstRatio = dst.width / dst.height;
    final src = imageRatio > dstRatio
        ? Rect.fromCenter(
            center: Offset(image.width / 2, image.height / 2),
            width: image.height * dstRatio,
            height: image.height.toDouble(),
          )
        : Rect.fromCenter(
            center: Offset(image.width / 2, image.height / 2),
            width: image.width.toDouble(),
            height: image.width / dstRatio,
          );
    canvas.drawImageRect(
      image,
      src,
      dst,
      Paint()..color = Colors.white.withValues(alpha: opacity),
    );
  }

  void _drawImageFitWidth(
    Canvas canvas,
    ui.Image image,
    Rect dst, {
    double opacity = 1,
  }) {
    final height = dst.width * image.height / image.width;
    final fitted = Rect.fromLTWH(
      dst.left,
      dst.bottom - height,
      dst.width,
      height,
    );
    canvas.drawImageRect(
      image,
      Rect.fromLTWH(0, 0, image.width.toDouble(), image.height.toDouble()),
      fitted,
      Paint()..color = Colors.white.withValues(alpha: opacity),
    );
  }

  void _drawImageContain(
    Canvas canvas,
    ui.Image image,
    Rect dst, {
    double opacity = 1,
  }) {
    final imageRatio = image.width / image.height;
    final dstRatio = dst.width / dst.height;
    final fitted = imageRatio > dstRatio
        ? Rect.fromCenter(
            center: dst.center,
            width: dst.width,
            height: dst.width / imageRatio,
          )
        : Rect.fromCenter(
            center: dst.center,
            width: dst.height * imageRatio,
            height: dst.height,
          );
    canvas.drawImageRect(
      image,
      Rect.fromLTWH(0, 0, image.width.toDouble(), image.height.toDouble()),
      fitted,
      Paint()
        ..color = Colors.white.withValues(alpha: opacity)
        ..filterQuality = FilterQuality.medium
        ..isAntiAlias = true,
    );
  }

  @override
  bool shouldRepaint(covariant SagaMapPainter oldDelegate) =>
      oldDelegate.scene != scene;
}
