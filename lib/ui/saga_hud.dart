import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../saga_map/domain/saga_map_state.dart';

part 'saga_hud_side.dart';
part 'saga_hud_top.dart';
part 'saga_hud_bottom.dart';

typedef SagaHudAction = void Function(String title, String message);

class SagaHud extends StatelessWidget {
  const SagaHud({
    super.key,
    required this.stateListenable,
    required this.starPulse,
    required this.debugVisible,
    required this.onDebugPressed,
    required this.onPresetPressed,
    required this.onLevelChanged,
    required this.onStarTargetChanged,
    required this.onEnergyTargetChanged,
    required this.onAction,
    required this.stepCount,
  });

  final ValueNotifier<SagaMapState> stateListenable;
  final ValueListenable<int> starPulse;
  final bool debugVisible;
  final VoidCallback onDebugPressed;
  final VoidCallback onPresetPressed;
  final ValueChanged<int> onLevelChanged;
  final ValueChanged<Offset> onStarTargetChanged;
  final ValueChanged<Offset> onEnergyTargetChanged;
  final SagaHudAction onAction;
  final int? stepCount;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<SagaMapState>(
      valueListenable: stateListenable,
      builder: (context, state, _) {
        return Stack(
          children: [
            _SideHudButtons(onAction: onAction),
            _TopHud(
              level: state.currentLevel,
              energy: state.energy,
              stars: state.stars,
              starPulse: starPulse,
              debugVisible: debugVisible,
              onDebugPressed: onDebugPressed,
              onPresetPressed: onPresetPressed,
              onLevelChanged: onLevelChanged,
              onStarTargetChanged: onStarTargetChanged,
              onEnergyTargetChanged: onEnergyTargetChanged,
              onAction: onAction,
            ),
            _LessonCard(
              level: state.currentLevel,
              stepCount: stepCount,
              onPressed: () => onAction(
                'Current lesson',
                'Chapter ${state.currentLevel ~/ 10 + 1}, lesson ${state.currentLevel % 10 + 1}. Tap the glowing map stone to begin.',
              ),
            ),
            _BottomNav(onAction: onAction),
          ],
        );
      },
    );
  }
}
