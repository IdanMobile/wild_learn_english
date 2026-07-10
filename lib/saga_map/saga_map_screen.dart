import 'package:flame/game.dart';
import 'package:flutter/material.dart';

import '../ui/saga_hud.dart';
import 'debug/saga_debug_overlay.dart';
import 'domain/saga_map_state.dart';
import 'navigation/saga_camera.dart';
import 'saga_map_game.dart';
import 'world/saga_path.dart';

class SagaMapScreen extends StatefulWidget {
  const SagaMapScreen({super.key});

  @override
  State<SagaMapScreen> createState() => _SagaMapScreenState();
}

class _SagaMapScreenState extends State<SagaMapScreen> {
  final _mapStackKey = GlobalKey();
  final _stateNotifier = ValueNotifier(
    const SagaMapState(progress: 0, currentLevel: 0),
  );
  final _cameraNotifier = ValueNotifier(const SagaCameraSnapshot.zero());
  final _projectionDebugNotifier = ValueNotifier(false);
  final _stepCountController = TextEditingController(text: '100');
  late final SagaMapGame _game = SagaMapGame(
    stateNotifier: _stateNotifier,
    projectionDebugNotifier: _projectionDebugNotifier,
    cameraDebugNotifier: _cameraNotifier,
    onNodePressed: _showNodePanel,
  );

  bool _debugVisible = false;
  bool _infiniteSteps = false;
  int _stepCount = 100;
  double _cameraHeight = 0.48;
  double _cameraAngle = 0.17;
  double _cameraResponse = 14;

  @override
  void dispose() {
    _stateNotifier.dispose();
    _cameraNotifier.dispose();
    _projectionDebugNotifier.dispose();
    _stepCountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Recovery-Governance Exception 1 (additive only): the blank Scaffold stub
    // is composed with, not replaced — GameWidget remains the body layer.
    return Scaffold(
      body: Stack(
        key: _mapStackKey,
        fit: StackFit.expand,
        children: [
          GameWidget(
            game: _game,
            loadingBuilder: (context) => const _MapLoadingView(),
            errorBuilder: (context, error) => const _MapErrorView(),
          ),
          SagaHud(
            stateListenable: _stateNotifier,
            debugVisible: _debugVisible,
            onPresetPressed: _game.togglePathPreset,
            onLevelChanged: _game.jumpLevels,
            onStarTargetChanged: (center) => _updateRewardTarget(star: center),
            onEnergyTargetChanged: (center) =>
                _updateRewardTarget(energy: center),
            onAction: _showHudPanel,
            stepCount: _infiniteSteps ? null : _stepCount,
            onDebugPressed: () {
              setState(() => _debugVisible = !_debugVisible);
            },
          ),
          ValueListenableBuilder<bool>(
            valueListenable: _projectionDebugNotifier,
            builder: (context, projectionDebugEnabled, _) {
              return SagaDebugOverlay(
                stateListenable: _stateNotifier,
                cameraListenable: _cameraNotifier,
                visible: _debugVisible,
                projectionDebugEnabled: projectionDebugEnabled,
                infiniteSteps: _infiniteSteps,
                stepCount: _stepCount,
                cameraHeight: _cameraHeight,
                cameraAngle: _cameraAngle,
                cameraResponse: _cameraResponse,
                onProjectionDebugChanged: (value) {
                  _projectionDebugNotifier.value = value;
                },
                onInfiniteStepsChanged: (value) {
                  setState(() => _infiniteSteps = value);
                  _game.setStepLimit(stepCount: value ? null : _stepCount);
                },
                onStepCountChanged: (value) {
                  final stepCount = value.clamp(1, 1000000);
                  setState(() => _stepCount = stepCount);
                  _stepCountController.text = '$stepCount';
                  _game.setStepLimit(
                    stepCount: _infiniteSteps ? null : stepCount,
                  );
                },
                onCameraHeightChanged: (value) {
                  setState(() => _cameraHeight = value);
                  _game.setCameraTuning(height: value);
                },
                onCameraAngleChanged: (value) {
                  setState(() => _cameraAngle = value);
                  _game.setCameraTuning(angle: value);
                },
                onCameraResponseChanged: (value) {
                  setState(() => _cameraResponse = value);
                  _game.setCameraTuning(response: value);
                },
                stepCountController: _stepCountController,
              );
            },
          ),
        ],
      ),
    );
  }

  void _updateRewardTarget({Offset? star, Offset? energy}) {
    final box = _mapStackKey.currentContext?.findRenderObject() as RenderBox?;
    if (box != null) {
      _game.setRewardTargets(
        star: star == null ? null : box.globalToLocal(star),
        energy: energy == null ? null : box.globalToLocal(energy),
      );
    }
  }

  void _showNodePanel(int level) {
    final prop = propAt(level);
    final title = switch (prop) {
      SagaPropKind.chest => 'Treasure step',
      SagaPropKind.orb => 'Crystal orb',
      SagaPropKind.crystal => 'Floating crystal',
      null => 'Saga step ${level + 1}',
    };
    final message = switch (prop) {
      SagaPropKind.chest =>
        'This step contains a reward chest. Complete the lesson to open it.',
      SagaPropKind.orb =>
        'This orb marks a magical vocabulary challenge on step ${level + 1}.',
      SagaPropKind.crystal =>
        'This crystal marks a bonus pronunciation challenge on step ${level + 1}.',
      null when level == _game.state.currentLevel =>
        'This is your current lesson. The active rings show its progress.',
      null => 'Moving the camera to saga step ${level + 1}.',
    };
    _showHudPanel(title, message);
  }

  void _showHudPanel(String title, String message) {
    if (!mounted) return;
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      backgroundColor: const Color(0xFFF9FCFD),
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 4, 24, 28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: const Color(0xFF405865),
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                message,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: const Color(0xFF637A85),
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MapLoadingView extends StatelessWidget {
  const _MapLoadingView();

  @override
  Widget build(BuildContext context) {
    return const ColoredBox(
      color: Color(0xFFF0F7FA),
      child: Center(child: CircularProgressIndicator(color: Color(0xFF8B64D9))),
    );
  }
}

class _MapErrorView extends StatelessWidget {
  const _MapErrorView();

  @override
  Widget build(BuildContext context) {
    return const ColoredBox(
      color: Color(0xFFF0F7FA),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.cloud_off_rounded, color: Color(0xFF718995), size: 38),
            SizedBox(height: 10),
            Text(
              'Map could not start',
              style: TextStyle(
                color: Color(0xFF536B77),
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
