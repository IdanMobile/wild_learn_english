part of 'saga_map_painter.dart';

extension _SagaEffectPainting on SagaMapPainter {
  void _paintRewardStars(Canvas canvas, Size size) {
    final completedLevel = fxState.completedLevel;
    if (completedLevel == null || fxState.rewardStarCount == 0) return;
    // Plain/item steps reward via the per-bar stars (fill) and the item poof;
    // only the combo finale still flies a hero star to the HUD from here.
    if (fxState.hasCombo) _paintHeroRewardStar(canvas, size);
  }

  void _paintHeroRewardStar(Canvas canvas, Size size) {
    // Combo finale runs after the V (see _comboDelay): shift its window out.
    final age = fxState.ageAt(animationTime) - _comboDelay;
    if (age < 2.4 || age > 4.2) return;

    final t = smooth01(((age - 2.4) / 1.8).clamp(0.0, 1.0));
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

  // Item finale: the step's prop rises to screen centre while growing, then
  // poofs into smoke with stars bursting out. Only runs on steps with a prop.
  void _paintItemReward(Canvas canvas, Size size) {
    final level = fxState.completedLevel;
    if (level == null) return;
    final kind = saga_path.propAt(level);
    if (kind == null) return;
    final image = switch (kind) {
      saga_path.SagaPropKind.chest => chestImage,
      saga_path.SagaPropKind.orb => orbImage,
      saga_path.SagaPropKind.crystal => crystalImage,
    };
    if (image == null) return;

    final age = fxState.ageAt(animationTime);
    const riseEnd = 2.6;
    const poofEnd = 3.5;
    if (age < 0 || age > poofEnd) return;

    ProjectedNode? src;
    for (final node in scene.nodes) {
      if (node.node.index == level) {
        src = node;
        break;
      }
    }
    final radius = src == null
        ? 24.0
        : (_baseRadius * src.scale).clamp(12.0, 44.0);
    final from = src == null
        ? Offset(size.width * 0.5, size.height * 0.62)
        : Offset(src.screenX, src.screenY - radius * 0.78);
    final onNodeWidth = radius * 1.1;

    // While the V draws, the item rests on the node (the in-place prop is now
    // hidden), so there is no gap before it lifts off.
    if (age < _rewardStart) {
      final bob = math.sin(animationTime * 2.4) * 3;
      _drawImageContain(
        canvas,
        image,
        Rect.fromCenter(
          center: from + Offset(0, bob),
          width: onNodeWidth,
          height: onNodeWidth * image.height / image.width,
        ),
      );
      return;
    }

    final target = Offset(size.width * 0.5, size.height * 0.4);
    final riseT = smooth01(
      ((age - _rewardStart) / (riseEnd - _rewardStart)).clamp(0.0, 1.0),
    );
    final centre = Offset.lerp(from, target, riseT)!;
    final width = ui.lerpDouble(onNodeWidth, size.width * 0.26, riseT)!;
    final itemOpacity = age < riseEnd
        ? 1.0
        : (1 - (age - riseEnd) / 0.25).clamp(0.0, 1.0);

    if (itemOpacity > 0) {
      _drawImageContain(
        canvas,
        image,
        Rect.fromCenter(
          center: centre,
          width: width,
          height: width * image.height / image.width,
        ),
        opacity: itemOpacity,
      );
    }

    if (age >= riseEnd) {
      final poofT = ((age - riseEnd) / (poofEnd - riseEnd)).clamp(0.0, 1.0);
      _paintPoof(canvas, target, size.width * 0.16, poofT);
      // Bonus stars from the poof fly up into the counter.
      final chip = starTarget ?? _fallbackStarChipCenter(size);
      final flyT = smooth01(poofT);
      for (var i = 0; i < sagaPropStarBonus; i++) {
        final seed = stablePhase(level * 3 + i);
        final ang = i / sagaPropStarBonus * math.pi * 2 + seed;
        final burst =
            target + Offset(math.cos(ang), math.sin(ang)) * size.width * 0.09;
        final control = Offset(
          (burst.dx + chip.dx) * 0.5,
          math.min(burst.dy, chip.dy) - size.height * 0.12,
        );
        final p = _quadratic(burst, control, chip, flyT);
        final opacity = 1 - ((flyT - 0.82) / 0.18).clamp(0.0, 1.0);
        _paintStar(
          canvas,
          p,
          size.width * 0.022 * (1 - flyT * 0.5),
          animationTime * 6 + seed * math.pi * 2,
          opacity,
        );
      }
    }
  }

  // Procedural "poof": a ring of soft grey puffs expanding + fading, no asset.
  void _paintPoof(Canvas canvas, Offset center, double baseRadius, double t) {
    const count = 6;
    for (var i = 0; i < count; i++) {
      final seed = stablePhase(i * 29 + 3);
      final ang = i / count * math.pi * 2;
      final off =
          Offset(math.cos(ang), math.sin(ang)) * baseRadius * (0.4 + t * 1.1);
      final r = baseRadius * (0.5 + seed * 0.5) * (0.6 + t * 1.2);
      final op = ((1 - t) * 0.5 * (0.7 + seed * 0.3)).clamp(0.0, 1.0);
      canvas.drawCircle(
        center + off,
        r,
        Paint()
          ..color = const Color(0xFFEDF2F5).withValues(alpha: op)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10),
      );
    }
    canvas.drawCircle(
      center,
      baseRadius * (0.6 + t * 0.8),
      Paint()
        ..color = Colors.white.withValues(alpha: (1 - t) * 0.4)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 14),
    );
  }

  void _paintEnergyReward(Canvas canvas, Size size) {
    final completedLevel = fxState.completedLevel;
    if (completedLevel == null) return;
    final age = fxState.ageAt(animationTime);
    final startAge = fxState.hasCombo ? 2.5 + _comboDelay : 0.28;
    final duration = fxState.hasCombo ? 1.6 : 0.78;
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

    // Lightning is the last beat: it starts after the V has drawn (_comboDelay)
    // and needs no smoke. Number + sparkles inherit this shifted age.
    final age = fxState.ageAt(animationTime) - _comboDelay;
    if (age < 0 || age > 4.8) return;

    // A brief full-screen flash as the bolt strikes (the world lighting up),
    // instead of a glowing disc behind it.
    final flashT = (1 - age / 0.45).clamp(0.0, 1.0);
    if (flashT > 0) {
      canvas.drawRect(
        Offset.zero & size,
        Paint()..color = Colors.white.withValues(alpha: 0.3 * flashT),
      );
    }

    if (age <= 2.6 && lightningComboFrames.isNotEmpty) {
      final peakIndex = math.min(4, lightningComboFrames.length - 1);
      // Fast crackle through the frames early, then settle on the peak frame.
      final frame = age < 0.9
          ? lightningComboFrames[(age / 0.06).floor() %
                lightningComboFrames.length]
          : lightningComboFrames[peakIndex];
      // Full-screen and overscanned so the sprite's rectangular bounds sit off
      // screen — no visible box around the bolt.
      final width = size.width * 1.18;
      final height = width * frame.height / frame.width;
      final center = Offset(size.width * 0.5, size.height * 0.42);
      // High-frequency opacity flicker reads as crackling electricity and hides
      // the choppiness of only having a few sprite frames.
      final flicker = 0.7 + 0.3 * (0.5 + 0.5 * math.sin(age * 46));
      final fade = age < 2.0 ? 1.0 : (1 - (age - 2.0) / 0.6).clamp(0.0, 1.0);
      canvas.save();
      canvas.translate(center.dx, center.dy);
      canvas.rotate(math.sin(age * 13) * 0.01);
      _drawImageContain(
        canvas,
        frame,
        Rect.fromCenter(center: Offset.zero, width: width, height: height),
        opacity: fade * flicker,
      );
      canvas.restore();
    }

    final residual = lightningResidualImage;
    if (residual != null && age >= 0.9 && age <= 3.4) {
      final t = ((age - 0.9) / 2.5).clamp(0.0, 1.0);
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
    if (age < 0.4 || age > 3.0) return;
    final enter = easeOutBack(((age - 0.4) / 0.5).clamp(0.0, 1.0));
    final exit = age < 2.4 ? 1.0 : (1 - (age - 2.4) / 0.6).clamp(0.0, 1.0);
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
    if (age < 0.5 || age > 4.0) return;
    final life = (1 - ((age - 0.5) / 3.5)).clamp(0.0, 1.0);
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
}
