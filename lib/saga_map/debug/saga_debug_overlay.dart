import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

import '../domain/saga_map_state.dart';
import '../navigation/saga_camera.dart';

class SagaDebugOverlay extends StatelessWidget {
  const SagaDebugOverlay({
    super.key,
    required this.stateListenable,
    required this.cameraListenable,
    required this.visible,
    required this.infiniteSteps,
    required this.stepCount,
    required this.cameraHeight,
    required this.cameraAngle,
    required this.cameraResponse,
    required this.onInfiniteStepsChanged,
    required this.onStepCountChanged,
    required this.onCameraHeightChanged,
    required this.onCameraAngleChanged,
    required this.onCameraResponseChanged,
    required this.stepCountController,
  });

  final ValueNotifier<SagaMapState> stateListenable;
  final ValueListenable<SagaCameraSnapshot> cameraListenable;
  final bool visible;
  final bool infiniteSteps;
  final int stepCount;
  final double cameraHeight;
  final double cameraAngle;
  final double cameraResponse;
  final ValueChanged<bool> onInfiniteStepsChanged;
  final ValueChanged<int> onStepCountChanged;
  final ValueChanged<double> onCameraHeightChanged;
  final ValueChanged<double> onCameraAngleChanged;
  final ValueChanged<double> onCameraResponseChanged;
  final TextEditingController stepCountController;

  @override
  Widget build(BuildContext context) {
    if (!visible) return const SizedBox.shrink();

    return Positioned(
      left: 12,
      bottom: 12,
      child: ValueListenableBuilder<SagaMapState>(
        valueListenable: stateListenable,
        builder: (context, state, _) {
          final visibleCount = state.currentLevel == 0 ? 15 : 17;
          return ValueListenableBuilder<SagaCameraSnapshot>(
            valueListenable: cameraListenable,
            builder: (context, camera, _) {
              return DecoratedBox(
                decoration: BoxDecoration(
                  color: const Color(0xCC111318),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0x55FFFFFF)),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: DefaultTextStyle(
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      height: 1.35,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('Progress: ${state.progress.toStringAsFixed(2)}'),
                        Text(
                          'Visual: ${camera.visualProgress.toStringAsFixed(2)}',
                        ),
                        Text('Current index: ${state.currentLevel}'),
                        Text('Camera X: ${camera.cameraX.toStringAsFixed(2)}'),
                        Text('Yaw: ${camera.yaw.toStringAsFixed(3)}'),
                        Text('Velocity: ${camera.velocity.toStringAsFixed(1)}'),
                        Text('Visible nodes: $visibleCount'),
                        Text(
                          'Step mode: ${infiniteSteps ? 'infinite' : '$stepCount'}',
                        ),
                        Text('Path preset: ${state.pathPreset.name}'),
                        const Text('Renderer: 2.5D projection'),
                        const Text('FPS: unavailable'),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text('Infinite'),
                            Switch(
                              value: infiniteSteps,
                              onChanged: onInfiniteStepsChanged,
                            ),
                          ],
                        ),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text('Steps'),
                            const SizedBox(width: 10),
                            SizedBox(
                              width: 72,
                              height: 32,
                              child: TextField(
                                controller: stepCountController,
                                enabled: !infiniteSteps,
                                keyboardType: TextInputType.number,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                ),
                                decoration: const InputDecoration(
                                  isDense: true,
                                  contentPadding: EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 7,
                                  ),
                                  border: OutlineInputBorder(),
                                ),
                                onSubmitted: (value) {
                                  final parsed = int.tryParse(value);
                                  if (parsed != null) {
                                    onStepCountChanged(parsed);
                                  }
                                },
                              ),
                            ),
                          ],
                        ),
                        _DebugSlider(
                          label: 'Height',
                          value: cameraHeight,
                          min: 0.48,
                          max: 0.82,
                          onChanged: onCameraHeightChanged,
                        ),
                        _DebugSlider(
                          label: 'Angle',
                          value: cameraAngle,
                          min: 0.08,
                          max: 0.34,
                          onChanged: onCameraAngleChanged,
                        ),
                        _DebugSlider(
                          label: 'Speed',
                          value: cameraResponse,
                          min: 1,
                          max: 26,
                          onChanged: onCameraResponseChanged,
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class _DebugSlider extends StatelessWidget {
  const _DebugSlider({
    required this.label,
    required this.value,
    required this.min,
    required this.max,
    required this.onChanged,
  });

  final String label;
  final double value;
  final double min;
  final double max;
  final ValueChanged<double> onChanged;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 230,
      child: Row(
        children: [
          SizedBox(width: 46, child: Text(label)),
          Expanded(
            child: Slider(
              value: value,
              min: min,
              max: max,
              onChanged: onChanged,
            ),
          ),
          SizedBox(
            width: 34,
            child: Text(value.toStringAsFixed(2), textAlign: TextAlign.right),
          ),
        ],
      ),
    );
  }
}
