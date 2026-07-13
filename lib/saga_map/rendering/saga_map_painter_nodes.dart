part of 'saga_map_painter.dart';

extension _SagaNodePainting on SagaMapPainter {
  void _paintNode(Canvas canvas, ProjectedNode projected) {
    final index = projected.node.index;
    final state = projected.node.state;
    // The node whose bars just filled celebrates in place: it turns blue and
    // draws its V even while still the "current" node, until the camera moves.
    final celebrating = fxState.isActive && fxState.completedLevel == index;
    final age = celebrating ? fxState.ageAt(animationTime) : -1.0;
    // A current node stays "completed" (blue + V) once its bars are full, even
    // after the transient fx clears — so it never reverts to filling bars.
    final barsFull =
        state == SagaNodeState.current && scene.stepFillProgress >= 1.0;
    final isCompleting =
        (celebrating || barsFull) && state != SagaNodeState.upcoming;
    final isFilling = state == SagaNodeState.current && !isCompleting;

    final completionT = _completionTFor(index);
    final settledColor = isCompleting || state == SagaNodeState.completed
        ? _completedColor
        : _baseColorFor(state);
    final completedFlash = Color.lerp(
      _currentColor,
      const Color(0xFFFFE67A),
      math.sin(completionT * math.pi).clamp(0.0, 1.0),
    )!;
    final animatedBase = completionT > 0
        ? Color.lerp(completedFlash, settledColor, completionT)!
        : settledColor;
    final topColor =
        Color.lerp(animatedBase, _fogColor, projected.fogFactor) ??
        animatedBase;
    final arrivalPulse = isFilling
        ? _arrivalPulse(scene.stepFillProgress)
        : 1.0;
    final completePulse = completionT > 0
        ? 1 + math.sin(completionT * math.pi) * 0.14
        : 1.0;
    final activePulse = state == SagaNodeState.current
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
    final top = Rect.fromCenter(
      center: Offset.zero,
      width: topWidth,
      height: topHeight,
    );

    canvas.save();
    canvas.translate(center.dx, center.dy - radius * 0.04);
    canvas.rotate(heading);
    _paintDisc(canvas, top, topColor, projected.node.state);
    canvas.restore();

    final anchor = center - Offset(0, radius * 0.04);
    if (state == SagaNodeState.current || completionT > 0) {
      _paintNodeGlow(canvas, anchor, radius);
    }

    if (isFilling) {
      _paintProgressArcs(
        canvas,
        anchor,
        radius,
        projected.platformAspect,
        scene.stepFillProgress,
      );
    } else if (isCompleting || state == SagaNodeState.completed) {
      // Fresh completion: the V draws on progressively. Old ones show it whole.
      final drawT = celebrating
          ? ((age - _checkDrawStart) / _checkDrawTime).clamp(0.0, 1.0)
          : 1.0;
      _paintAnimatedCheck(canvas, anchor, radius * 0.5, drawT);
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
      // A prop is collected once its step is done — gone on completed steps and
      // on the current step the moment its bars fill. From there the item
      // reward (rise + poof) owns drawing it; it is never shown in place again.
      final propState = target.node.state;
      if (propState == SagaNodeState.completed ||
          (propState == SagaNodeState.current &&
              scene.stepFillProgress >= 1.0)) {
        continue;
      }
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
    const rotation = 0.0; // pinned to the bottom, no spin
    final pulse = 0.92 + math.sin(animationTime * 4.5) * 0.05;
    final width = radius * 2.42 * pulse;
    final rect = Rect.fromCenter(
      center: center + Offset(0, width * aspect * 0.14),
      width: width,
      height: width * (aspect + 0.14),
    );
    final trackPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 10
      ..strokeCap = StrokeCap.round
      ..color = const Color(0xFFBFC9CD);
    final fillPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 10
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
}
