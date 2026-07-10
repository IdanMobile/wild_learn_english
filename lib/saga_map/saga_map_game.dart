import 'dart:math' as math;
import 'dart:ui';

import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';

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
  }) : _state = state ?? const SagaMapState(progress: 0, currentLevel: 0);

  final ValueNotifier<SagaMapState>? stateNotifier;
  final ValueNotifier<SagaCameraSnapshot>? cameraDebugNotifier;
  final ValueChanged<int>? onNodePressed;
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
  var _fxState = const SagaFxState();
  late final SagaCamera _camera = SagaCamera(progress: state.progress);
  SagaScene? _latestScene;
  Offset? _starTarget;
  Offset? _energyTarget;
  int _creditedFxSerial = 0;
  int _pendingStars = 0;
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
    super.onRemove();
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
    _camera.setTarget(state.progress);
    _camera.update(dt, state.pathPreset);
    _queueCameraNotify();

    final visualLevel = _camera.nearestLevel(_maxLevel);
    if (visualLevel != _lastStepLevel) {
      if (visualLevel > _lastStepLevel) {
        _deferActiveReward();
        final completedLevel = visualLevel - 1;
        _fxState = SagaFxState(
          completedLevel: completedLevel,
          startedAt: _time,
          serial: _fxState.serial + 1,
          comboNumber: _comboNumberFor(completedLevel),
        );
      }
      _lastStepLevel = visualLevel;
      _stepEnteredAt = _time;
      state = state.copyWith(currentLevel: visualLevel);
    }
    if (_fxState.isActive &&
        _fxState.ageAt(_time) >= _fxState.rewardArrivalAge) {
      _collectActiveReward();
    }
    if (_fxState.isActive && _fxState.ageAt(_time) > 3.8) {
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
    final fillT = ((_time - _stepEnteredAt) / 0.95).clamp(0.0, 1.0);
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
    ).paint(canvas, Size(size.x, size.y));
  }

  @override
  void onDragStart(DragStartEvent event) {
    super.onDragStart(event);
    _inertiaVelocity = 0;
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
        onNodePressed?.call(node.node.index);
        moveToLevel(node.node.index);
        info.handled = true;
        return;
      }
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
    final progress = depth(_clampLevel(level)).toDouble();
    state = state.copyWith(progress: progress);
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

  void _collectActiveReward() {
    if (!_fxState.isActive || _creditedFxSerial == _fxState.serial) return;
    _creditedFxSerial = _fxState.serial;
    state = state.copyWith(
      stars: state.stars + _pendingStars + _fxState.rewardStarCount,
      energy: state.energy + _pendingEnergy + 1,
    );
    _pendingStars = 0;
    _pendingEnergy = 0;
  }

  void _deferActiveReward() {
    if (!_fxState.isActive || _creditedFxSerial == _fxState.serial) return;
    _creditedFxSerial = _fxState.serial;
    _pendingStars += _fxState.rewardStarCount;
    _pendingEnergy++;
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
