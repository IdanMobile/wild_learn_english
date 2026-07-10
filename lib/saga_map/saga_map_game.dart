import 'dart:math' as math;
import 'dart:ui';

import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';

import 'audio/saga_audio.dart';
import 'domain/saga_map_state.dart';
import 'navigation/saga_camera.dart';
import 'navigation/saga_scroll_physics.dart';
import 'projection/perspective_projector.dart';
import 'rendering/saga_map_painter.dart';
import 'rendering/saga_fx.dart';
import 'rendering/saga_scene.dart';
import 'rendering/saga_scene_builder.dart';
import 'world/saga_path.dart';

/// Thin Flame host for the saga map.
///
/// Owns only the single [SagaMapState] and translates drag into progress via
/// [progressDeltaFromDrag]. Every frame it builds the immutable scene through
/// [buildSagaScene] and hands it to [SagaMapPainter] — it never calls
/// `windowFor`/`nodeAt`/`PerspectiveProjector.project` itself, and holds no
/// projection or drawing logic of its own.
class SagaMapGame extends FlameGame with DragCallbacks, MultiTouchTapDetector {
  SagaMapGame({
    SagaMapState? state,
    this.stateNotifier,
    this.cameraDebugNotifier,
    this.onNodePressed,
    this.starPulseNotifier,
  }) : _state = state ?? const SagaMapState(progress: 0, currentLevel: 0);

  final ValueNotifier<SagaMapState>? stateNotifier;
  final ValueNotifier<SagaCameraSnapshot>? cameraDebugNotifier;
  final ValueChanged<int>? onNodePressed;
  // Bumped each time a bar's reward stars reach the HUD chip, so it can pulse.
  final ValueNotifier<int>? starPulseNotifier;
  Image? _skyImage;
  Image? _mountainsImage;
  Image? _hazeImage;
  Image? _foregroundMistImage;
  Image? _castleImage;
  Image? _castleDetailImage;
  Image? _chestImage;
  Image? _orbImage;
  Image? _crystalImage;
  Image? _rewardStarImage;
  Image? _sparkleImage;
  Image? _softGlowImage;
  Image? _lightningResidualImage;
  final _lightningComboFrames = <Image>[];
  double _time = 0;
  double _stepEnteredAt = 0;
  int _lastStepLevel = 0;
  int? _maxLevel = 99;
  double _inertiaVelocity = 0;
  double? _glideFrom;
  double _glideTo = 0;
  double _glideElapsed = 0;
  double _glideDuration = 0;
  // Seconds for a current step's 3 progress bars to fill (shared with render).
  static const double _stepFillDuration = 1.9;
  // Level whose completion celebration waits for its bars to finish filling.
  int? _pendingCompletionLevel;
  // Reward stars in flight to the HUD chip, one burst per filled progress bar.
  final List<({double birth, Offset from, double seed})> _barStars = [];
  int _barsAwarded = 0;
  // In-flight bar-star bursts: when each reaches the chip its [stars] are added
  // to the total (the step's reward is distributed across its 3 bars).
  final List<({double time, int stars})> _barStarLandings = [];
  static const double _barStarFlight = 0.8; // matches the painter flight time
  // Bonus stars a special (prop) step drops from the item poof — must match the
  // number of poof stars the painter flies to the chip.
  static const int _propStarBonus = 10;
  var _fxState = const SagaFxState();
  late final SagaCamera _camera = SagaCamera(progress: state.progress);
  SagaScene? _latestScene;
  Offset? _starTarget;
  Offset? _energyTarget;
  int _creditedFxSerial = 0;
  int _pendingEnergy = 0;
  bool _notifiersActive = true;
  bool _stateNotifyQueued = false;
  bool _cameraNotifyQueued = false;

  SagaMapState _state;

  SagaMapState get state => _state;
  SagaFxState get fxState => _fxState;

  set state(SagaMapState value) {
    _state = value;
    _queueStateNotify();
  }

  @override
  void onRemove() {
    _notifiersActive = false;
    SagaAudio.stopAmbient();
    super.onRemove();
  }

  @override
  void lifecycleStateChange(AppLifecycleState state) {
    super.lifecycleStateChange(state);
    // Screen off / app backgrounded: silence the loop and freeze the engine so
    // nothing keeps ticking or playing. Restore both on return to foreground.
    if (state == AppLifecycleState.resumed) {
      SagaAudio.resumeAmbient();
      if (paused) resumeEngine();
    } else {
      SagaAudio.pauseAmbient();
      if (!paused) pauseEngine();
    }
  }

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    _skyImage = await _tryLoadImage('assets/environment/sky.webp');
    _mountainsImage = await _tryLoadImage(
      'assets/environment/mountains_far.png',
    );
    _hazeImage = await _tryLoadImage('assets/environment/haze.png');
    _foregroundMistImage = await _tryLoadImage(
      'assets/environment/foreground_mist.png',
    );
    _castleImage = await _tryLoadImage('assets/environment/castle.png');
    _castleDetailImage = await _tryLoadImage(
      'assets/environment/castle_detail_overlay.png',
    );
    _chestImage = await _tryLoadImage('assets/props/magic_chest.png');
    _orbImage = await _tryLoadImage('assets/props/crystal_orb.png');
    _crystalImage = await _tryLoadImage('assets/props/floating_crystal.png');
    _rewardStarImage = await _tryLoadImage('assets/vfx/reward_star.png');
    _sparkleImage = await _tryLoadImage('assets/vfx/sparkle.png');
    _softGlowImage = await _tryLoadImage('assets/vfx/soft_glow.png');
    _lightningResidualImage = await _tryLoadImage(
      'assets/vfx/lightning_residual_streak.png',
    );
    for (var i = 0; i < 8; i++) {
      final image = await _tryLoadImage(
        'assets/vfx/lightning_combo/frame_$i.png',
      );
      if (image != null) _lightningComboFrames.add(image);
    }
    _camera.visualProgress = state.progress;
    _camera.targetProgress = state.progress;
    _lastStepLevel = state.currentLevel;
    _queueStateNotify();
    _queueCameraNotify();
    await SagaAudio.preload();
    await SagaAudio.startAmbient();
  }

  Future<Image?> _tryLoadImage(String assetPath) async {
    try {
      final data = await rootBundle.load(assetPath);
      final bytes = data.buffer.asUint8List(
        data.offsetInBytes,
        data.lengthInBytes,
      );
      final codec = await instantiateImageCodec(bytes);
      final frame = await codec.getNextFrame();
      return frame.image;
    } catch (error) {
      if (kDebugMode) debugPrint('Saga asset unavailable: $assetPath ($error)');
      return null;
    }
  }

  @override
  void update(double dt) {
    super.update(dt);
    _time += dt;
    _applyInertia(dt);
    _applyGlide(dt);
    _camera.setTarget(state.progress);
    _camera.update(dt, state.pathPreset);
    _queueCameraNotify();

    final visualLevel = _camera.nearestLevel(_maxLevel);
    if (visualLevel != _lastStepLevel) {
      if (visualLevel > _lastStepLevel) {
        _deferActiveReward();
        // Arm the celebration for the step we just landed on; it fires below
        // once THIS step's bars finish filling (green -> blue on this node).
        _pendingCompletionLevel = visualLevel;
      } else {
        _pendingCompletionLevel = null; // moving back cancels a pending one
        SagaAudio.nodeArrive();
      }
      _lastStepLevel = visualLevel;
      _stepEnteredAt = _time;
      _barsAwarded = 0; // new step: its bars haven't paid out yet
      state = state.copyWith(currentLevel: visualLevel);
    }

    // Each progress bar that fills flings a couple of stars up to the HUD chip.
    final fillFrac =
        ((_time - _stepEnteredAt) / _stepFillDuration).clamp(0.0, 1.0);
    final fillProgress = fillFrac * fillFrac * (3 - 2 * fillFrac);
    const barEnds = [0.2, 0.6, 1.0]; // matches the painter's 3 bars + holds
    var filled = 0;
    for (final end in barEnds) {
      if (fillProgress >= end) filled++;
    }
    if (filled > _barsAwarded) {
      // The step's total reward, split across its 3 bars.
      final total =
          SagaFxState(completedLevel: state.currentLevel).rewardStarCount;
      for (var bar = _barsAwarded; bar < filled; bar++) {
        _spawnBarStars(_barStarShare(bar, total));
      }
      _barsAwarded = filled;
    }
    _barStars.removeWhere((s) => _time - s.birth > 0.85);
    // When a burst reaches the chip: credit its stars to the total (which makes
    // the chip pulse), plus a soft collect sound.
    while (_barStarLandings.isNotEmpty &&
        _time >= _barStarLandings.first.time) {
      final landing = _barStarLandings.removeAt(0);
      state = state.copyWith(stars: state.stars + landing.stars);
      SagaAudio.rewardCollect();
      _bumpStarPulse();
    }

    // Stars / lightning / combo start only when the step's third progress bar
    // has filled completely — i.e. once the fill animation reaches its end.
    if (_pendingCompletionLevel != null &&
        _time - _stepEnteredAt >= _stepFillDuration) {
      final completedLevel = _pendingCompletionLevel!;
      _pendingCompletionLevel = null;
      _fxState = SagaFxState(
        completedLevel: completedLevel,
        startedAt: _time,
        serial: _fxState.serial + 1,
        comboNumber: _comboNumberFor(completedLevel),
      );
      SagaAudio.nodeComplete();
      SagaAudio.rewardSpawn();
      if (_fxState.comboNumber != null) {
        // ponytail: number-pop fires with the lightning; the clip's own attack
        // covers the ~0.2s until the number scales in.
        SagaAudio.comboLightning();
        SagaAudio.comboNumberPop();
      }
      // Special steps: the item's poof drops bonus stars that fly to the chip
      // and land (credited) ~3.5s in, alongside the poof animation.
      if (propAt(completedLevel) != null) {
        _barStarLandings.add((time: _time + 3.5, stars: _propStarBonus));
      }
    }

    // Stars are credited per bar as they land; this only credits the step's
    // energy once its reward flight arrives.
    if (_fxState.isActive &&
        _fxState.ageAt(_time) >= _fxState.rewardArrivalAge) {
      _collectActiveReward();
    }
    // Combo finale (lightning after the V + rewards) runs longer than a plain
    // or item completion, so hold its fx state open longer before clearing.
    if (_fxState.isActive &&
        _fxState.ageAt(_time) > (_fxState.hasCombo ? 6.5 : 4.8)) {
      _fxState = SagaFxState(serial: _fxState.serial);
    }
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    final projector = PerspectiveProjector(
      focalLength: _camera.focalLength,
      viewportCenterX: size.x / 2,
      cameraX: _camera.cameraX,
      cameraYaw: _camera.yaw,
      cameraPitch: _camera.angle,
      horizonY: size.y * _camera.angle,
      baseY: size.y * _camera.height,
      fogDistance: 3600,
    );
    final visualState = state.copyWith(progress: _camera.visualProgress);
    final fillT = ((_time - _stepEnteredAt) / _stepFillDuration).clamp(0.0, 1.0);
    final scene = buildSagaScene(
      visualState,
      projector,
      stepFillProgress: fillT * fillT * (3 - 2 * fillT),
      maxLevel: _maxLevel,
    );
    _latestScene = scene;
    SagaMapPainter(
      scene: scene,
      skyImage: _skyImage,
      mountainsImage: _mountainsImage,
      hazeImage: _hazeImage,
      foregroundMistImage: _foregroundMistImage,
      castleImage: _castleImage,
      castleDetailImage: _castleDetailImage,
      chestImage: _chestImage,
      orbImage: _orbImage,
      crystalImage: _crystalImage,
      rewardStarImage: _rewardStarImage,
      sparkleImage: _sparkleImage,
      softGlowImage: _softGlowImage,
      lightningResidualImage: _lightningResidualImage,
      lightningComboFrames: _lightningComboFrames,
      animationTime: _time,
      fxState: _fxState,
      starTarget: _starTarget,
      energyTarget: _energyTarget,
      barStars: _barStars,
    ).paint(canvas, Size(size.x, size.y));
  }

  @override
  void onDragStart(DragStartEvent event) {
    super.onDragStart(event);
    _inertiaVelocity = 0;
    _glideFrom = null; // a real drag takes over from any programmatic glide
  }

  @override
  void onDragUpdate(DragUpdateEvent event) {
    super.onDragUpdate(event);
    _inertiaVelocity = 0;
    applyDragDelta(event.canvasDelta.y);
  }

  @override
  void onDragEnd(DragEndEvent event) {
    super.onDragEnd(event);
    _inertiaVelocity = progressDeltaFromDrag(event.velocity.y);
  }

  void applyDragDelta(double deltaY) {
    final delta = progressDeltaFromDrag(deltaY);
    final nextProgress = state.progress + delta;
    final clampedProgress = _clampProgress(nextProgress);
    state = state.copyWith(progress: clampedProgress);
  }

  @override
  void onTapDown(int pointerId, TapDownInfo info) {
    final scene = _latestScene;
    if (scene == null) return;

    final tap = info.eventPosition.widget;
    for (final node in scene.nodes) {
      final radius = (54 * node.scale).clamp(14.0, 58.0);
      final dx = tap.x - node.screenX;
      final dy = tap.y - node.screenY;
      if (propAt(node.node.index) != null) {
        final propDy = tap.y - (node.screenY - radius * 0.78);
        final propRadius = (radius * 0.72).clamp(18.0, 44.0);
        if (dx * dx + propDy * propDy <= propRadius * propRadius) {
          _playNodeTapSound(node.node.index);
          onNodePressed?.call(node.node.index);
          moveToLevel(node.node.index);
          info.handled = true;
          return;
        }
      }
      final hitWidth = radius * 1.25;
      final hitHeight = radius * 0.72;
      if ((dx * dx) / (hitWidth * hitWidth) +
              (dy * dy) / (hitHeight * hitHeight) <=
          1) {
        _playNodeTapSound(node.node.index);
        onNodePressed?.call(node.node.index);
        moveToLevel(node.node.index);
        info.handled = true;
        return;
      }
    }
  }

  void _playNodeTapSound(int index) {
    switch (propAt(index)) {
      case SagaPropKind.chest:
        SagaAudio.chestOpen();
      case SagaPropKind.crystal:
        SagaAudio.crystalShimmer();
      case SagaPropKind.orb:
      case null:
        SagaAudio.nodeSelect();
    }
  }

  void togglePathPreset() {
    final next = state.pathPreset == SagaPathPreset.gentle
        ? SagaPathPreset.dramatic
        : SagaPathPreset.gentle;
    state = state.copyWith(pathPreset: next);
  }

  void jumpLevels(int delta) {
    final level = _clampLevel(state.currentLevel + delta);
    moveToLevel(level);
  }

  void moveToLevel(int level) {
    _inertiaVelocity = 0;
    // Glide progress to the target instead of snapping, so the camera trails a
    // continuous change exactly like it does during a scroll.
    final target = depth(_clampLevel(level)).toDouble();
    final from = state.progress;
    final distanceLevels = (target - from).abs() / depth(1);
    if (distanceLevels < 0.001) return;
    _glideFrom = from;
    _glideTo = target;
    _glideElapsed = 0;
    // Short and snappy so the camera spring — which smooths on top — doesn't
    // stack into a laggy feel. Ease-out (below) front-loads the motion.
    _glideDuration = (0.16 + distanceLevels * 0.06).clamp(0.16, 0.5);
  }

  void _applyGlide(double dt) {
    final from = _glideFrom;
    if (from == null) return;
    _glideElapsed += dt;
    final t = (_glideElapsed / _glideDuration).clamp(0.0, 1.0);
    // Ease-out: fast start, gentle settle — responsive like a scroll flick.
    final eased = 1 - math.pow(1 - t, 3).toDouble();
    final p = from + (_glideTo - from) * eased;
    state = state.copyWith(progress: _clampProgress(p));
    if (t >= 1.0) _glideFrom = null;
  }

  void setStepLimit({required int? stepCount}) {
    _maxLevel = stepCount == null ? null : math.max(0, stepCount - 1);
    final clampedProgress = _clampProgress(state.progress);
    if (clampedProgress != state.progress) {
      state = state.copyWith(progress: clampedProgress);
    }
  }

  void setCameraTuning({double? height, double? angle, double? response}) {
    _camera.tune(height: height, angle: angle, response: response);
  }

  void setRewardTargets({Offset? star, Offset? energy}) {
    if (star != null) _starTarget = star;
    if (energy != null) _energyTarget = energy;
  }

  // Stars are credited per bar as they land; this only credits energy.
  void _collectActiveReward() {
    if (!_fxState.isActive || _creditedFxSerial == _fxState.serial) return;
    _creditedFxSerial = _fxState.serial;
    state = state.copyWith(energy: state.energy + _pendingEnergy + 1);
    _pendingEnergy = 0;
  }

  void _deferActiveReward() {
    if (!_fxState.isActive || _creditedFxSerial == _fxState.serial) return;
    _creditedFxSerial = _fxState.serial;
    _pendingEnergy++;
  }

  // Even split of [total] across 3 bars, remainder going to the later bars.
  int _barStarShare(int barIndex, int total) =>
      total ~/ 3 + (barIndex >= 3 - total % 3 ? 1 : 0);

  void _spawnBarStars(int starCount) {
    // Always schedule the credit, even if the node is briefly off-screen, so
    // the total can never lose stars to a missing visual.
    _barStarLandings.add((time: _time + _barStarFlight, stars: starCount));
    final scene = _latestScene;
    if (scene == null) return;
    Offset? from;
    for (final node in scene.nodes) {
      if (node.node.index == state.currentLevel) {
        from = Offset(node.screenX, node.screenY - 30);
        break;
      }
    }
    final origin = from;
    if (origin == null) return;
    for (var s = 0; s < starCount; s++) {
      _barStars.add((
        birth: _time,
        from: origin,
        seed: stablePhase(_barStars.length * 7 + s),
      ));
    }
  }

  void _bumpStarPulse() {
    final notifier = starPulseNotifier;
    if (notifier == null) return;
    SchedulerBinding.instance.addPostFrameCallback((_) {
      if (_notifiersActive) notifier.value = notifier.value + 1;
    });
  }

  int _clampLevel(int level) {
    final maxLevel = _maxLevel;
    if (level < 0) return 0;
    if (maxLevel == null) return level;
    return math.min(level, maxLevel);
  }

  double _clampProgress(double progress) {
    if (progress <= 0) return 0;
    final maxLevel = _maxLevel;
    if (maxLevel == null) return progress;
    return math.min(progress, depth(maxLevel).toDouble());
  }

  int? _comboNumberFor(int completedLevel) {
    if (completedLevel < 4 || (completedLevel + 1) % 5 != 0) return null;
    return 3 + (((completedLevel + 1) ~/ 5 - 1) % 5);
  }

  void _applyInertia(double dt) {
    if (_inertiaVelocity == 0 || dt <= 0) return;
    final step = applyInertiaStep(_inertiaVelocity, dt);
    final nextProgress = _clampProgress(state.progress + step.progressDelta);
    final hitBound = nextProgress != state.progress + step.progressDelta;
    state = state.copyWith(progress: nextProgress);
    _inertiaVelocity = step.isSettled || hitBound ? 0 : step.velocity;
  }

  void _queueStateNotify() {
    final notifier = stateNotifier;
    if (notifier == null || _stateNotifyQueued) return;
    _stateNotifyQueued = true;
    SchedulerBinding.instance.addPostFrameCallback((_) {
      _stateNotifyQueued = false;
      if (!_notifiersActive) return;
      notifier.value = state;
    });
  }

  void _queueCameraNotify() {
    final notifier = cameraDebugNotifier;
    if (notifier == null || _cameraNotifyQueued) return;
    _cameraNotifyQueued = true;
    SchedulerBinding.instance.addPostFrameCallback((_) {
      _cameraNotifyQueued = false;
      if (!_notifiersActive) return;
      notifier.value = _camera.snapshot;
    });
  }
}
