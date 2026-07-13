part of 'saga_map_painter.dart';

extension _SagaShapePainting on SagaMapPainter {
  double _segmentProgress(double fillProgress, int index) {
    // Each bar fills within its own window, separated by a small hold so the
    // three read as distinct steps with a beat between them (not one sweep).
    const hold = 0.2;
    final fillEach =
        (1 - hold * (_ringSegments.length - 1)) / _ringSegments.length;
    final start = index * (fillEach + hold);
    final t = ((fillProgress - start) / fillEach).clamp(0.0, 1.0);
    return t * t * (3 - 2 * t);
  }

  void _paintDisc(Canvas canvas, Rect top, Color color, SagaNodeState state) {
    // One extruded puck: a bottom ellipse joined to the top face by a solid
    // side wall, so top + side read as a single floating step button rather
    // than two stacked discs.
    final depth = top.height * 0.24;
    final halfW = top.width / 2;
    final bottom = top.shift(Offset(0, depth));

    // Contact shadow on the ground below the button.
    canvas.drawOval(bottom.shift(Offset(0, top.height * 0.1)), _shadowPaint);

    // Side wall: down the left edge, around the front (bottom) half of the
    // bottom ellipse, up the right edge, closed across the top (hidden by the
    // top face).
    final body = Path()
      ..moveTo(top.center.dx - halfW, top.center.dy)
      ..lineTo(bottom.center.dx - halfW, bottom.center.dy)
      ..arcTo(bottom, math.pi, -math.pi, false)
      ..lineTo(top.center.dx + halfW, top.center.dy)
      ..close();
    canvas.drawPath(
      body,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color.lerp(color, const Color(0xFF7E9AA6), 0.28)!,
            Color.lerp(color, Colors.black, 0.32)!,
          ],
        ).createShader(body.getBounds()),
    );

    // Raised top face.
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

  // A checkmark that draws stroke-by-stroke as [drawT] goes 0 -> 1.
  void _paintAnimatedCheck(
    Canvas canvas,
    Offset center,
    double size,
    double drawT,
  ) {
    if (drawT <= 0) return;
    final path = Path()
      ..moveTo(center.dx - size * 0.5, center.dy + size * 0.04)
      ..lineTo(center.dx - size * 0.12, center.dy + size * 0.42)
      ..lineTo(center.dx + size * 0.56, center.dy - size * 0.44);
    final metric = path.computeMetrics().first;
    final shown = metric.extractPath(0, metric.length * drawT.clamp(0.0, 1.0));
    canvas.drawPath(
      shown,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = size * 0.26
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..color = Colors.white.withValues(alpha: 0.95),
    );
  }

  // Per-bar reward stars: each spawned star flies from the step up to the HUD
  // star chip on a gentle arc over a fixed real-time duration (independent of
  // fill/camera speed), matching the normal reward-star flight.
  void _paintBarStars(Canvas canvas, Size size) {
    if (barStars.isEmpty) return;
    final target = starTarget ?? _fallbackStarChipCenter(size);
    for (final star in barStars) {
      final t = (animationTime - star.birth) / sagaBarStarFlightDuration;
      if (t <= 0 || t >= 1) continue;
      final e = smooth01(t);
      final spread = (star.seed - 0.5) * 90;
      final control = Offset(
        (star.from.dx + target.dx) * 0.5 + spread,
        math.min(star.from.dy, target.dy) - 90 - star.seed * 60,
      );
      final p = _quadratic(star.from, control, target, e);
      _paintStar(
        canvas,
        p,
        (11 - e * 5) * (0.8 + star.seed * 0.3),
        animationTime * 6 + star.seed * math.pi * 2,
        (1 - ((e - 0.85) / 0.15).clamp(0.0, 1.0)),
      );
    }
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
}
