part of 'saga_map_painter.dart';

extension _SagaEnvironmentPainting on SagaMapPainter {
  void _paintBackground(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final sky = skyImage;
    if (sky != null) {
      _drawImageCover(canvas, sky, rect, opacity: 0.6);
    }
    // Thinner wash so the sky reads through instead of being buried under it.
    final paint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0x9EFFFFFF), Color(0x9EF7FCFF), Color(0x94ECF8FC)],
      ).createShader(rect);
    canvas.drawRect(rect, paint);

    final mountains = mountainsImage;
    if (mountains != null) {
      // Anchor the range far behind the castle (larger index = farther world
      // point). Because it is farther, the projector naturally gives it a
      // smaller, subtler parallax in both x and y than the castle — and being
      // deeper in the scene it always renders behind it.
      final anchor = _projectDistantAnchor(size, _castleWorldIndex + 20);
      if (anchor != null) {
        final opacity = (0.24 + _mapCompletion * 0.46).clamp(0.24, 0.7);
        final width = size.width * 1.4;
        final left =
            size.width * 0.5 - width * 0.5 + (anchor.dx - size.width * 0.5);
        final bottom = anchor.dy + size.height * 0.12;
        _drawImageFitWidth(
          canvas,
          mountains,
          Rect.fromLTWH(
            left,
            bottom - size.height * 0.22,
            width,
            size.height * 0.22,
          ),
          opacity: opacity,
        );
      }
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
      final farAnchor = _projectDistantAnchor(size, _castleWorldIndex + 4);
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
    // The path converges to the horizon line; anchor the castle's door
    // (~0.86 down the image) there so the road leads straight into it, rather
    // than to anchor.dy which sits below the horizon and leaves the path high.
    final dst = Rect.fromCenter(
      center: Offset(anchor.dx, scene.projector.horizonY - height * 0.36),
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

  // Continuous (fractional) world index for the far scenery. In endless mode it
  // tracks the camera smoothly at a fixed distance ahead — using the integer
  // levelForProgress here made the castle snap forward one whole step per level.
  double get _castleWorldIndex {
    final maxLevel = scene.maxLevel;
    if (maxLevel != null) return (maxLevel + 1).toDouble();
    return scene.cameraProgress / saga_path.depth(1) + 30;
  }

  double get _mapCompletion {
    final maxLevel = scene.maxLevel;
    if (maxLevel == null || maxLevel <= 0) return 0.35;
    return (scene.cameraProgress / saga_path.depth(maxLevel)).clamp(0.0, 1.0);
  }

  // Projects a continuous world index (may be fractional) so far scenery glides
  // rather than snapping between whole node positions.
  ({double dx, double dy, double scale})? _projectDistantAnchor(
    Size size,
    double worldIndex,
  ) {
    final worldDepth = saga_path.depth(1) * worldIndex;
    final relativeDepth = worldDepth - scene.cameraProgress;
    final denom = scene.projector.focalLength + relativeDepth;
    if (denom <= 0) return null;

    final scale = scene.projector.focalLength / denom;
    final worldX = _pathXAt(worldIndex);
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

  // Path x at a fractional index, linearly interpolated between node samples.
  double _pathXAt(double worldIndex) {
    final lo = worldIndex.floor();
    final frac = worldIndex - lo;
    final a = saga_path.x(lo, preset: scene.pathPreset);
    final b = saga_path.x(lo + 1, preset: scene.pathPreset);
    return a + (b - a) * frac;
  }

  ({double dx, double dy, double scale})? _castleDoorAnchor(Size size) =>
      _projectDistantAnchor(size, _castleWorldIndex);
}
